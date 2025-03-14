class UserModel {
  final String userId;
  final String userName;
  final String userImage;
  final String userEmail;
  final String createdAt;
  final List<dynamic> userCart;
  final List<dynamic> userWish;

  UserModel({
    required this.userId,
    required this.userName,
    required this.userImage,
    required this.userEmail,
    required this.createdAt,
    required this.userCart,
    required this.userWish,
  });
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['userId'] ?? '',
      userName: json['userName'] ?? '',
      userEmail: json['userEmail'] ?? '',
      userImage: json['userImage'] ?? '',
      userWish: json['userWish'] ?? [],
      userCart: json['userCart'] ?? [],
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'userName': userName,
      'userEmail': userEmail,
      'userImage': userImage,
      'userWish': userWish,
      'userCart': userCart,
      'createdAt': createdAt,
    };
  }
}
