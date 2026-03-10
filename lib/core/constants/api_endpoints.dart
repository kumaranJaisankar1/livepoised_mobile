import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiEndpoints {
  static String get baseUrlSpringBoot => dotenv.get('BASE_URL_SB');
  static String get baseUrlFastAPI => dotenv.get('BASE_URL_FA');
  static String get baseWSURL => dotenv.get('WS_URL_FA');
  static String get keycloakUrl => dotenv.get('KEYCLOAK_URL');
  static String get realm => dotenv.get('KEYCLOAK_REALM');
  static String get clientId => dotenv.get('CLIENT_ID');
  
  // Keycloak OIDC Endpoints
  static String get authEndpoint => '$keycloakUrl/realms/$realm/protocol/openid-connect/auth';
  static String get tokenEndpoint => '$keycloakUrl/realms/$realm/protocol/openid-connect/token';
  static String get logoutEndpoint => '$keycloakUrl/realms/$realm/protocol/openid-connect/logout';
  static String get registrationEndpoint => '$keycloakUrl/realms/$realm/protocol/openid-connect/registrations';
  static String get discoveryUrl => '$keycloakUrl/realms/$realm/.well-known/openid-configuration';

  // Backend Auth Synchronization
  static String get googleSync => '$baseUrlSpringBoot/auth/google-sync';
  static String get register => '$baseUrlSpringBoot/auth/register';
  static String get login => '$baseUrlSpringBoot/auth/login';

  // Forum API (FastAPI)
  static String get trendingPosts => '$baseUrlFastAPI/posts/trending';
  static String get latestPosts => '$baseUrlFastAPI/posts/latest';
  static String get communities => '$baseUrlFastAPI/communities';
  static String createPost(dynamic communityId) => '$baseUrlFastAPI/communities/$communityId/posts';
  static String postDetails(dynamic postId) => '$baseUrlFastAPI/posts/$postId';
  static String likePost(dynamic postId) => '$baseUrlFastAPI/posts/$postId/like';
  static String postComments(dynamic postId) => '$baseUrlFastAPI/posts/$postId/comments';
  static String likeComment(dynamic commentId) => '$baseUrlFastAPI/comments/$commentId/like';
  // Profile API (Spring Boot)
  static String getProfile(String username) => '$baseUrlSpringBoot/profile/$username';
  static String updateProfile(String username) => '$baseUrlSpringBoot/profile/updateProfile/$username';
  static String get getUserImage => '$baseUrlSpringBoot/images/getUserImage';
  static String get uploadImage => '$baseUrlSpringBoot/images/uploadImage';

  // Forum contributions
  static String getUserForumContributions(String userId) => '$baseUrlSpringBoot/api/forum/user/$userId';

  // Chat sessions
  static String getUserChatSessions(String userId) => '$baseUrlSpringBoot/api/mentoring/sessions/$userId';

  // Connections
  static String get connections => '$baseUrlSpringBoot/api/connections';

  // Chat API (FastAPI)
  static String getChatHistory(String current, String other) => '$baseUrlFastAPI/chat/history/$current/$other';
  static String get chatWsUrl => baseWSURL;

  // Ally Network Requests (Spring Boot)
  static String get incomingAllyRequests => '$baseUrlSpringBoot/api/allies/requests/received';
  static String get outgoingAllyRequests => '$baseUrlSpringBoot/api/allies/requests/sent';
  static String acceptAllyRequest(dynamic id) => '$baseUrlSpringBoot/api/allies/requests/$id/accept';
  static String rejectAllyRequest(dynamic id) => '$baseUrlSpringBoot/api/allies/requests/$id/reject';

  // Caregiver / Support Network (Spring Boot)
  static String searchCaregivers(String query) => '$baseUrlSpringBoot/api/care-network/search?query=$query';
  static String sendCaregiverRequest(String username, String relationship) => 
      '$baseUrlSpringBoot/api/care-network/request?caregiverIdentifier=$username&relationship=$relationship';
  static String get pendingSupporterRequests => '$baseUrlSpringBoot/api/care-network/pending-requests';
  static String respondToSupporterRequest(dynamic linkId, bool accept) => 
      '$baseUrlSpringBoot/api/care-network/respond/$linkId?accept=$accept';
  static String get patientAllies => '$baseUrlSpringBoot/api/care-network/patient-allies';
  static String get suggestedConnections => '$baseUrlSpringBoot/api/care-network/suggestions';
  
  // Notifications (Spring Boot)
  static String get allNotifications => '$baseUrlSpringBoot/api/notifications';
  static String get unreadNotifications => '$baseUrlSpringBoot/api/notifications/unread';
  static String markNotificationAsRead(int id) => '$baseUrlSpringBoot/api/notifications/$id/read';
  static String get markAllNotificationsAsRead => '$baseUrlSpringBoot/api/notifications/read-all';

  // Redirect URI
  static const String redirectUri = 'com.livepoised.app://oidc/redirect';
}

