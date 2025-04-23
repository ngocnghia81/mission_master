// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
      id: (json['id'] as num?)?.toInt(),
      email: json['email'] as String,
      username: json['username'] as String,
      fullName: json['fullName'] as String,
      role: json['role'] as String,
      avatar: json['avatar'] as String?,
      phone: json['phone'] as String?,
      isActive: json['isActive'] as bool,
      createdAt: json['createdAt'] as String,
      updatedAt: json['updatedAt'] as String,
    );

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
      'id': instance.id,
      'email': instance.email,
      'username': instance.username,
      'fullName': instance.fullName,
      'role': instance.role,
      'avatar': instance.avatar,
      'phone': instance.phone,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt,
      'updatedAt': instance.updatedAt,
    };
