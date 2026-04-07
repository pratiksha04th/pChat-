class FriendRequestModel {
  final String requestId;
  final String fromUid;
  final String toUid;
  final String status;

  String? fromName;
  String? toName;


  FriendRequestModel({
    required this.requestId,
    required this.fromUid,
    required this.toUid,
    required this.status,
  });

  factory FriendRequestModel.fromMap(String id, Map data) {
    return FriendRequestModel(
      requestId: id,
      fromUid: data['fromUid'] ?? '',
      toUid: data['toUid'] ?? '',
      status: data['status'] ?? 'pending',
    );
  }
  FriendRequestModel copyWith({
    String? requestId,
    String? fromUid,
    String? toUid,
    String? status,
  }) {
    return FriendRequestModel(
      requestId: requestId ?? this.requestId,
      fromUid: fromUid ?? this.fromUid,
      toUid: toUid ?? this.toUid,
      status: status ?? this.status,
    );
  }
}
