class AppUser {
  final String uid;
  final String email;
  final String username;
  String fcmToken;

  AppUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.fcmToken
  });

  // Convert Firebase snapshot -> Model
  factory AppUser.fromMap(String uid, Map<dynamic, dynamic> data) {
    return AppUser(
      uid: uid,
      email: data['email']?.toString() ?? '',
      username: data['username']?.toString() ?? '',
      fcmToken: data['fcmToken']?.toString() ?? '',
    );
  }

  // Convert Model -> Firebase map
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'username': username,
      'fcmToken': fcmToken,
    };
  }
}
