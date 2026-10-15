import 'package:flutter/foundation.dart';

enum ItemCategory {
  tools('Інструменти', '🔧'),
  garden('Сад', '🌱'),
  sports('Спорт', '⚽'),
  books('Книги', '📚'),
  games('Ігри', '🎲'),
  kitchen('Кухня', '🍳'),
  electronics('Електроніка', '📱'),
  other('Інше', '📦');

  final String label;
  final String emoji;

  const ItemCategory(this.label, this.emoji);
}

enum ItemStatus {
  available('Доступно'),
  borrowed('Позичено'),
  reserved('Зарезервовано');

  final String label;

  const ItemStatus(this.label);
}

@immutable
class Item {
  final String id;
  final String title;
  final String description;
  final ItemCategory category;
  final ItemStatus status;
  final String ownerId;
  final String ownerName;
  final String? imageUrl;
  final DateTime createdAt;
  final String? borrowedBy;
  final DateTime? returnDate;

  const Item({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.status = ItemStatus.available,
    required this.ownerId,
    required this.ownerName,
    this.imageUrl,
    required this.createdAt,
    this.borrowedBy,
    this.returnDate,
  });

  Item copyWith({
    String? title,
    String? description,
    ItemCategory? category,
    ItemStatus? status,
    String? borrowedBy,
    DateTime? returnDate,
  }) {
    return Item(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      status: status ?? this.status,
      ownerId: ownerId,
      ownerName: ownerName,
      imageUrl: imageUrl,
      createdAt: createdAt,
      borrowedBy: borrowedBy ?? this.borrowedBy,
      returnDate: returnDate ?? this.returnDate,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'category': category.name,
        'status': status.name,
        'ownerId': ownerId,
        'ownerName': ownerName,
        'imageUrl': imageUrl,
        'createdAt': createdAt.toIso8601String(),
        'borrowedBy': borrowedBy,
        'returnDate': returnDate?.toIso8601String(),
      };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        category: ItemCategory.values.firstWhere(
          (c) => c.name == json['category'],
          orElse: () => ItemCategory.other,
        ),
        status: ItemStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => ItemStatus.available,
        ),
        ownerId: json['ownerId'],
        ownerName: json['ownerName'],
        imageUrl: json['imageUrl'],
        createdAt: DateTime.parse(json['createdAt']),
        borrowedBy: json['borrowedBy'],
        returnDate: json['returnDate'] != null
            ? DateTime.parse(json['returnDate'])
            : null,
      );
}