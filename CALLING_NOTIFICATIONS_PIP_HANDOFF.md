# Calling — Notification Actions & PiP — Session Handoff

> **App**: `livepoised_mobile` (Flutter / Dart) + `livepoisedapi` (FastAPI)
> **Branch**: `feature/calling-feature`
> **Scope of this doc**: what was fixed/built in this session for incoming-call notification actions and Picture-in-Picture, why, and what's still open. Read this before touching call notification/PiP code again — it'll save re-deriving the same investigation.

---

## 1. What was broken (starting point)

- Tapping **Accept**/**Decline** on the incoming-call push notification just opened the app to the ringing screen (`/incoming-call`) instead of acting immediately — user had to tap Accept/Decline a second time inside the app.
- No real OS-level Picture-in-Picture for active calls — only an in-app draggable mini window (`FloatingCallOverlay`) that doesn't survive leaving the app.
- No way to detect/guide the user to enable PiP permission on Android.

## 2. What's implemented now

### 2.1 Notification Accept/Reject (Android + iOS)

Key file: [`lib/core/services/push_notification_service.dart`](lib/core/services/push_notification_service.dart)

**Important Android routing fact** (verified by reading `flutter_local_notifications` 17.2.4's Android source, `FlutterLocalNotificationsPlugin.java` / `ActionBroadcastReceiver.java` — don't re-derive this, it's not documented anywhere obvious):
- A notification action with `showsUserInterface: false` (**Decline**) is **always** delivered via a `BroadcastReceiver` that spins up a **separate, brand-new headless `FlutterEngine`** — regardless of whether the main app process is already alive. This is the *only* code path Decline ever runs through. It never reaches the normal `onDidReceiveNotificationResponse` main-isolate callback.
- A notification action with `showsUserInterface: true` (**Accept**) **always** launches the Activity directly (`PendingIntent.getActivity`), and its response is delivered via the normal main-isolate `onDidReceiveNotificationResponse` callback once the engine is up. It never reaches the background-isolate callback.

Implementation:
- **Decline**: `AndroidNotificationAction('decline_call', ..., showsUserInterface: false)`. Handled in the top-level `@pragma('vm:entry-point') _onBackgroundNotificationResponse` function, which calls `_declineCallHeadless(data)` — reads the bearer token straight from `FlutterSecureStorage` (no GetX needed), and POSTs to a new backend endpoint `POST /call/decline` (see §2.2) — completely bypassing the `ChatWebSocketService` singleton, which isn't available in a headless isolate. The old "if `Get.isRegistered<LiveKitService>()`" branch for decline inside the *main*-isolate handler is dead code (kept as a harmless defensive no-op) — it will never actually run given the routing behavior above.
- **Accept**: keeps `showsUserInterface: true` (joining a call requires the real engine/UI). The bug this session fixed: `PushNotificationService().initialize()` (which wires up `onDidReceiveNotificationResponse`) runs in `main()` **before** `GetStorage.init()`/`runApp()`/`InitialBinding` — so on a cold start (app was killed), the Accept response can arrive *before* `LiveKitService` is registered. The old fallback for that case was `handleNavigation(data)`, which routed to `/incoming-call` (the ringing screen) — exactly the "still have to tap Accept again" bug. Fixed: that fallback now calls `_persistPendingAcceptAction(data)`, which writes a `pending_call_action` marker to `GetStorage` (works with zero GetX dependency). [`lib/core/bindings/initial_binding.dart`](lib/core/bindings/initial_binding.dart)'s `InitialBinding.dependencies()` is the single, race-free place that consumes that marker — once GetX is actually up, it calls `LiveKitService.acceptCallWithData(...)` directly and lands on `/active-call`, skipping the ringing screen entirely. If `LiveKitService` happens to already be registered when the tap arrives (warm background, not killed), the fast path calls `acceptCallWithData` immediately instead of round-tripping through storage.
- **iOS**: `DarwinNotificationCategory('incoming_call', ...)` registered with two actions — `accept_call` (`.foreground` option, brings UI up) and `decline_call` (no `.foreground` option — iOS launches the app in the background to run it, UI never shown). Apple's non-foreground notification actions give the same "don't open the app" effect Android gets from its background isolate, without needing CallKit/PushKit for this specific behavior.

### 2.2 Backend: headless-safe decline endpoint

New in [`livepoisedapi/app/routes/call.py`](../livepoisedapi/app/routes/call.py): `POST /call/decline` (auth via the existing `get_optional_user` bearer dependency, same pattern as `/call/token`). Backed by a new shared helper [`livepoisedapi/app/services/call_signal.py::notify_call_declined`](../livepoisedapi/app/services/call_signal.py) which relays a `call:decline` message to both parties over their live WebSocket (if connected) and fires the existing `fcm_service.send_call_cancelled_notification` — this is what dismisses the ringing UI on the decliner's *other* devices and posts the missed-call banner for the caller.

`app/routes/chat.py`'s existing websocket-based decline/cancel handling (~lines 120–140) was **not** refactored to use the new shared helper — left as-is to avoid risk to the working live-call flow; there's some duplicated logic between the two paths (acceptable, small, low-risk).

### 2.3 Real Android Picture-in-Picture

- [`android/app/src/main/AndroidManifest.xml`](android/app/src/main/AndroidManifest.xml): `MainActivity` has `android:supportsPictureInPicture="true"`.
- [`android/app/src/main/kotlin/.../MainActivity.kt`](android/app/src/main/kotlin/com/livepoised/app/livepoised_mobile/MainActivity.kt): exposes a `com.livepoised.app/pip` `MethodChannel` (`isPipSupported`, `isPipPermissionEnabled`, `openPipSettings`, `setCallActive`, `enterPip`). `onUserLeaveHint()` auto-enters PiP when a call is active (fires when the user presses Home — matches every other calling app). `onPictureInPictureModeChanged` forwards the mode change back to Dart.
- **PiP window now has a real "End Call" button** (added after initial testing showed the PiP window had no controls at all, just video + the OS's default expand affordance): `enterPip()` attaches a `RemoteAction` to `PictureInPictureParams` via `setActions(...)`, backed by a `BroadcastReceiver` (registered `onCreate`/unregistered `onDestroy`) listening for a custom action string, which forwards the tap to Dart via the same MethodChannel (`onPipAction` → `"end_call"`).
- Dart side: [`lib/core/services/pip_service.dart`](lib/core/services/pip_service.dart) wraps the channel (no-ops on non-Android via `Platform.isAndroid` guards), exposes `onModeChanged` and `onPipAction` streams. [`lib/features/call/data/livekit_service.dart`](lib/features/call/data/livekit_service.dart) has `isInNativePip` (`RxBool`), calls `PipService().setCallActive(true/false)` on call connect/cleanup, and subscribes to `onPipAction` → calls `endCall()` on `'end_call'`. [`lib/features/call/presentation/views/active_call_view.dart`](lib/features/call/presentation/views/active_call_view.dart) renders a chrome-free, full-bleed remote-video view when `isInNativePip.value` is true (no in-Flutter buttons — the real control now lives in the native PiP action bar).
- **PiP permission nudge**: `LiveKitService._maybePromptPipPermission()` shows a one-shot `Get.snackbar` ("Enable Picture-in-Picture...", "Open Settings" button → `PipService().openSettings()`) the first time a video call connects with PiP support-but-disabled — gated by a `GetStorage` flag so it only shows once per install.

### 2.4 iOS

- No native PiP this round (see §3 for why and what "correct" looks like).
- Background audio continuation relies on the already-declared `voip`/`audio` `UIBackgroundModes` in `ios/Runner/Info.plist` — not independently re-verified on a physical device this session.
- Incoming calls still arrive via plain FCM, not PushKit VoIP pushes — see §3, this is the biggest known gap.

## 3. Known gap: iOS isn't on the correct VoIP protocol yet (not implemented, planned only)

Apple's real mechanism for time-critical call alerts is **PushKit VoIP pushes + CallKit** — top-priority delivery (wakes the app even force-quit, even in Low Power Mode), in exchange for a hard rule enforced since iOS 13: every VoIP push received must be reported to CallKit (`CXProvider`) immediately or the OS can kill the process / revoke the VoIP entitlement.

This app currently uses plain FCM for iOS call alerts, which works (and the notification-action fix in §2.1 makes it behave correctly once it arrives) but has **no delivery guarantee** — it rides iOS's normal background-execution budget, which the OS throttles based on usage patterns/battery/Low Power Mode. If iOS users report missed/delayed incoming-call notifications, this is why.

**A full implementation plan for this exists** at `/Users/kumaranj/.claude/plans/ethereal-watching-rain.md`, section **"Part C.1 — Follow-up: real PushKit + CallKit for iOS"**. Summary of the decisions already made there:
- Use the `flutter_callkit_incoming` plugin (handles the CallKit UI + Apple's strict timing rules) rather than hand-rolling `CXProvider`/`PushKit` Swift code.
- iOS-only — Android keeps the custom notification-action flow from §2.1/§2.3, not the plugin's Android call UI.
- **Blocking prerequisite (needs the Apple Developer account holder, not code)**: generate a VoIP Services Auth Key (`.p8` file + Key ID + Team ID) in the Apple Developer portal for `com.livepoised.app`. VoIP pushes **cannot** go through FCM at all — they need a separate direct-to-APNs client (planned: `aioapns` in Python, token-based `.p8` auth, `push_type=PushType.VOIP`, topic `com.livepoised.app.voip`).
- Backend needs a new `voip_device_tokens` table (kept separate from the existing shared `device_tokens` table — see the plan doc for why) and a new `/notifications/voip-token/register` endpoint.
- Flagged risk to check early if this gets built: `flutter_callkit_incoming`'s Android setup docs call for `android:launchMode="singleInstance"` on `MainActivity`, which conflicts with the existing `singleTask` needed for the OAuth redirect deep link (`com.livepoised.app://callback`) — needs verifying whether adding the dependency iOS-only actually forces this via Android manifest merging, and resolving via manifest merge overrides rather than changing `launchMode` if so.

This was **explicitly deferred** by the product owner this session ("later we can implement") — not started, no code written for it.

## 4. Testing notes / what wasn't verified

None of this was tested on real hardware from within this session (only `flutter analyze` + `flutter build apk --debug` compile checks, and reasoning from the plugin's source code). Before considering this done:
- Force-stop the app, trigger an incoming call, tap **Decline** from the lock screen — confirm the app never visibly opens and the caller sees the call end promptly.
- Force-stop the app, tap **Accept** — confirm it opens directly into the connected call screen, no ringing screen.
- During an active video call, press Home on Android — confirm it shrinks into a real system PiP window with a working End Call button, and returning to the app restores the full screen.
- Disable PiP permission for the app in Android system settings, start a video call — confirm the one-shot "Enable Picture-in-Picture" prompt appears.
- On iOS, confirm audio survives backgrounding mid-call, and confirm Accept/Decline notification actions behave per §2.1 (this doesn't require the PushKit work in §3 to already be correct-per-Apple-spec, just to not visibly reopen the app on Decline).
