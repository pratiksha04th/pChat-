class AppUser {

  final String uid;
  final String email;
  final String username;

  final String firstName;
  final String lastName;
  final String gender;
  final String dob;

  final bool profileCompleted;

  final String profileImage;

  final String fcmToken;
  final String crashlyticsUserId;

  final int createdAt;
  final int lastUpdated;

  final bool isOnline;
  final int lastSeen;

  final double lat;
  final double lng;

  AppUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.dob,
    required this.profileCompleted,
    required this.profileImage,
    required this.fcmToken,
    required this.crashlyticsUserId,
    required this.createdAt,
    required this.lastUpdated,
    required this.isOnline,
    required this.lastSeen,
    required this.lat,
    required this.lng,
  });

  /// Firebase -> Model
  factory AppUser.fromMap(String uid, Map<dynamic, dynamic> data) {

    return AppUser(
      uid: uid,

      email: data["email"]?.toString() ?? "",
      username: data["username"]?.toString() ?? "",

      firstName: data["firstName"]?.toString() ?? "",
      lastName: data["lastName"]?.toString() ?? "",
      gender: data["gender"]?.toString() ?? "",
      dob: data["dob"]?.toString() ?? "",

      profileCompleted: data["profileCompleted"] ?? false,

      profileImage: data["profileImage"]?.toString() ?? "",

      fcmToken: data["fcmToken"]?.toString() ?? "",
      crashlyticsUserId: data["crashlyticsUserId"]?.toString() ?? "",

      createdAt: data["createdAt"] ?? 0,
      lastUpdated: data["lastUpdated"] ?? 0,

      isOnline: data["isOnline"] ?? false,
      lastSeen: data['lastSeen'] ?? 0,

      lat: (data['lat'] ?? 0.0).toDouble(),
      lng: (data['lng'] ?? 0.0).toDouble(),
    );
  }

  /// Model -> Firebase
  Map<String, dynamic> toMap() {

    return {
      "uid": uid,
      "email": email,
      "username": username,

      "firstName": firstName,
      "lastName": lastName,
      "gender": gender,
      "dob": dob,

      "profileCompleted": profileCompleted,

      "profileImage": profileImage,

      "fcmToken": fcmToken,
      "crashlyticsUserId": crashlyticsUserId,

      "createdAt": createdAt,
      "lastUpdated": lastUpdated,

      "isOnline": isOnline,
      "lastSeen": lastSeen,
    };
  }

  /// Useful when updating user fields
  AppUser copyWith({
    String? username,
    String? email,
    String? gender,
    String? dob,
    String? firstName,
    String? lastName,
    String? profileImage,
    bool? isOnline,
    String? fcmToken,
    int? lastSeen,
  }) {

    return AppUser(
      uid: uid,
      email: email ?? this.email,
      username: username ?? this.username,

      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      gender: gender ?? this.gender,
      dob: dob ?? this.dob,

      profileCompleted: profileCompleted,

      profileImage: profileImage ?? this.profileImage,

      fcmToken: fcmToken ?? this.fcmToken,
      crashlyticsUserId: crashlyticsUserId,

      createdAt: createdAt,
      lastUpdated: DateTime.now().millisecondsSinceEpoch,

      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,

      lat: lat,
      lng: lng,
    );
  }
}