import Flutter
import UIKit
import PushKit
import flutter_callkit_incoming

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, PKPushRegistryDelegate {
  private var voipRegistry: PKPushRegistry?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Register for VoIP pushes as early as possible — CallKit calls arrive
    // via PushKit, independent of the regular FCM/APNs push registration.
    let registry = PKPushRegistry(queue: .main)
    registry.delegate = self
    registry.desiredPushTypes = [.voIP]
    voipRegistry = registry

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  // MARK: - PKPushRegistryDelegate

  func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
    guard type == .voIP else { return }
    let tokenString = pushCredentials.token.map { String(format: "%02.2hhx", $0) }.joined()
    // Fires CallEventActionDidUpdateDevicePushTokenVoip on the Dart side
    // (once the engine is running), which CallKitService uses to sync the
    // token to the backend. Also persists it natively so a fresh Dart
    // listener can read it back via FlutterCallkitIncoming.getDevicePushTokenVoIP().
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP(tokenString)
  }

  func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
    guard type == .voIP else { return }
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.setDevicePushTokenVoIP("")
  }

  private func ensureValidUUID(_ input: String) -> String {
    if let uuid = UUID(uuidString: input) {
      return uuid.uuidString.lowercased()
    }
    let hex = input.replacingOccurrences(of: "-", with: "").filter { $0.isHexDigit }
    if hex.count >= 32 {
      let cleanHex = String(hex.prefix(32))
      let index8 = cleanHex.index(cleanHex.startIndex, offsetBy: 8)
      let index12 = cleanHex.index(cleanHex.startIndex, offsetBy: 12)
      let index16 = cleanHex.index(cleanHex.startIndex, offsetBy: 16)
      let index20 = cleanHex.index(cleanHex.startIndex, offsetBy: 20)
      let formatted = "\(cleanHex[..<index8])-\(cleanHex[index8..<index12])-\(cleanHex[index12..<index16])-\(cleanHex[index16..<index20])-\(cleanHex[index20...])"
      if let uuid = UUID(uuidString: formatted) {
        return uuid.uuidString.lowercased()
      }
    }
    return UUID().uuidString.lowercased()
  }

  func pushRegistry(
    _ registry: PKPushRegistry,
    didReceiveIncomingPushWith payload: PKPushPayload,
    for type: PKPushType,
    completion: @escaping () -> Void
  ) {
    guard type == .voIP else {
      completion()
      return
    }

    // Apple requires reporting the call to CallKit synchronously, right
    // here — not after bouncing through the Dart engine, which may not be
    // running yet. The plugin's showCallkitIncoming(_:fromPushKit:) does
    // exactly that (it owns the CXProvider internally).
    let dict = payload.dictionaryPayload
    let roomId = dict["roomId"] as? String ?? ""
    let sender = dict["sender"] as? String ?? ""
    let senderFullName = (dict["senderFullName"] as? String).flatMap { $0.isEmpty ? nil : $0 } ?? sender
    let senderImage = dict["senderImage"] as? String ?? ""
    let isVideo = (dict["isVideo"] as? Bool) ?? true
    let callUuidRaw = dict["callUuid"] as? String ?? ""
    let rawCallId = callUuidRaw.isEmpty ? roomId : callUuidRaw
    let safeCallUuid = ensureValidUUID(rawCallId)

    let callData: [String: Any?] = [
      "id": safeCallUuid,
      "nameCaller": senderFullName,
      "appName": "Live Poised",
      "handle": senderFullName,
      "avatar": senderImage,
      "type": isVideo ? 1 : 0,
      "duration": 30000,
      "extra": [
        "roomId": roomId,
        "sender": sender,
        "senderFullName": senderFullName,
        "senderImage": senderImage,
        "isVideo": isVideo,
      ],
      "ios": [
        "handleType": "generic",
        "supportsVideo": true,
      ],
    ]

    let callkitData = flutter_callkit_incoming.Data(args: callData)
    SwiftFlutterCallkitIncomingPlugin.sharedInstance?.showCallkitIncoming(callkitData, fromPushKit: true)
    completion()
  }
}
