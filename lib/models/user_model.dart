class UserModel {
  final String uid;
  final String email;
  final String name;
  final String status;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
      'status': status,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      status: map['status'] ?? 'reguler',
    );
  }
}