class ReshareModel {
  final String reshareId;
  final String uid;
  final String username;
  final int createdAt;

  ReshareModel({
    required this.reshareId,
    required this.uid,
    required this.username,
    required this.createdAt,
  });

  /// FROM MAP
  factory ReshareModel.fromMap(Map<String, dynamic> data) {
    return ReshareModel(
      reshareId: data['reshareId']?.toString() ?? '',
      uid: data['uid']?.toString() ?? '',
      username: data['username']?.toString() ?? '',
      createdAt: _parseInt(data['createdAt']),
    );
  }

  /// TO MAP
  Map<String, dynamic> toMap() {
    return {
      "reshareId": reshareId,
      "uid": uid,
      "username": username,
      "createdAt": createdAt,
    };
  }

  /// SAFE INT
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}