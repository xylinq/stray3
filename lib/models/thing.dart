class Thing {
  final int id;
  final String desc;
  final String location;
  final String img;
  final String status;
  final String picker;
  final String recipient;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  Thing({
    required this.id,
    required this.desc,
    required this.location,
    required this.img,
    required this.status,
    required this.picker,
    required this.recipient,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Thing.fromJson(Map<String, dynamic> json) {
    return Thing(
      id: json['id'] ?? '',
      desc: json['desc'] ?? '',
      location: json['location'] ?? '',
      img: json['img'] ?? '',
      status: json['status'] ?? '',
      picker: json['picker'] ?? '',
      recipient: json['recipient'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: json['createdAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['createdAt']) : DateTime.now(),
      updatedAt: json['updatedAt'] != null ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt']) : DateTime.now(),
    );
  }

  // 把 Thing 转换成 json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'desc': desc,
      'location': location,
      'img': img,
      'status': status,
      'picker': picker,
      'recipient': recipient,
      'userId': userId,
      'createdAt': createdAt.microsecondsSinceEpoch,
      'updatedAt': updatedAt.microsecondsSinceEpoch,
    };
  }
}
