import 'package:flutter/foundation.dart';

@immutable
class User {
  final String id;
  final String name;
  final String apartment;
  final String? phone;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.name,
    required this.apartment,
    this.phone,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'apartment': apartment,
        'phone': phone,
        'avatarUrl': avatarUrl,
      };

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json['id'],
        name: json['name'],
        apartment: json['apartment'],
        phone: json['phone'],
        avatarUrl: json['avatarUrl'],
      );
}