class UserModel {
  final String id;
  final String email;
  final String name;
  final String? avatar;
  final String? phone;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isEmailVerified;
  final String? gender;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    this.avatar,
    this.phone,
    required this.createdAt,
    required this.updatedAt,
    this.isEmailVerified = false,
    this.gender,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      avatar: json['avatar'],
      phone: json['phone'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      isEmailVerified: json['isEmailVerified'] ?? false,
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar': avatar,
      'phone': phone,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isEmailVerified': isEmailVerified,
      'gender': gender,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? name,
    String? avatar,
    String? phone,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isEmailVerified,
    String? gender,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatar: avatar ?? this.avatar,
      phone: phone ?? this.phone,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      gender: gender ?? this.gender,
    );
  }
}

class AuthResponse {
  final UserModel user;
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn;

  AuthResponse({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      user: UserModel.fromJson(json['user'] ?? {}),
      accessToken: json['accessToken'] ?? json['access_token'] ?? '',
      refreshToken: json['refreshToken'] ?? json['refresh_token'] ?? '',
      tokenType: json['tokenType'] ?? json['token_type'] ?? 'Bearer',
      expiresIn: json['expiresIn'] ?? json['expires_in'] ?? 3600,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user': user.toJson(),
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'tokenType': tokenType,
      'expiresIn': expiresIn,
    };
  }
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() {
    return {'email': email, 'password': password};
  }
}

class RegisterRequest {
  final String email;
  final String password;
  final String name;
  final String? phone;
  final String? gender;

  RegisterRequest({
    required this.email,
    required this.password,
    required this.name,
    this.phone,
    this.gender,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'email': email,
      'password': password,
      'name': name,
    };

    // Only include phone and gender if they are not null and not empty
    if (phone != null && phone!.isNotEmpty) {
      data['phone'] = phone;
    }
    if (gender != null && gender!.isNotEmpty) {
      data['gender'] = gender;
    }

    return data;
  }
}

class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {'currentPassword': currentPassword, 'newPassword': newPassword};
  }
}

class UpdateProfileRequest {
  final String? name;
  final String? phone;
  final String? gender;

  UpdateProfileRequest({this.name, this.phone, this.gender});

  Map<String, dynamic> toJson() {
    return {'name': name, 'phone': phone, 'gender': gender};
  }
}
