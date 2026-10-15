import 'package:flutter/foundation.dart';

enum RequestStatus {
  pending('Очікує'),
  approved('Схвалено'),
  rejected('Відхилено'),
  returned('Повернено');

  final String label;
  const RequestStatus(this.label);
}

@immutable
class BorrowRequest {
  final String id;
  final String itemId;
  final String itemTitle;
  final String requesterId;
  final String requesterName;
  final String ownerId;
  final DateTime requestDate;
  final DateTime returnDate;
  final RequestStatus status;
  final String? message;

  const BorrowRequest({
    required this.id,
    required this.itemId,
    required this.itemTitle,
    required this.requesterId,
    required this.requesterName,
    required this.ownerId,
    required this.requestDate,
    required this.returnDate,
    this.status = RequestStatus.pending,
    this.message,
  });

  BorrowRequest copyWith({RequestStatus? status}) {
    return BorrowRequest(
      id: id,
      itemId: itemId,
      itemTitle: itemTitle,
      requesterId: requesterId,
      requesterName: requesterName,
      ownerId: ownerId,
      requestDate: requestDate,
      returnDate: returnDate,
      status: status ?? this.status,
      message: message,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'itemId': itemId,
        'itemTitle': itemTitle,
        'requesterId': requesterId,
        'requesterName': requesterName,
        'ownerId': ownerId,
        'requestDate': requestDate.toIso8601String(),
        'returnDate': returnDate.toIso8601String(),
        'status': status.name,
        'message': message,
      };

  factory BorrowRequest.fromJson(Map<String, dynamic> json) => BorrowRequest(
        id: json['id'],
        itemId: json['itemId'],
        itemTitle: json['itemTitle'],
        requesterId: json['requesterId'],
        requesterName: json['requesterName'],
        ownerId: json['ownerId'],
        requestDate: DateTime.parse(json['requestDate']),
        returnDate: DateTime.parse(json['returnDate']),
        status: RequestStatus.values.firstWhere(
          (s) => s.name == json['status'],
          orElse: () => RequestStatus.pending,
        ),
        message: json['message'],
      );
}