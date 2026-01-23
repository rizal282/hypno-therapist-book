import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  pending(0),
  accepted(1),
  completed(2),
  cancelled(3);

  final int code;
  const BookingStatus(this.code);

  static BookingStatus fromCode(int code) {
    return BookingStatus.values.firstWhere(
      (e) => e.code == code,
      orElse: () => BookingStatus.pending,
    );
  }
}

class Booking {
  final String? id;
  final String userId;
  String? therapistId;
  final String userName;
  final String phoneNumber;
  final String address;
  final String complaint;
  final DateTime scheduledTime;
  final DateTime createdAt;
  final BookingStatus status;
  final String? rejectionReason;

  Booking({
    this.id,
    required this.userId,
    this.therapistId,
    required this.userName,
    required this.phoneNumber,
    required this.address,
    required this.complaint,
    required this.scheduledTime,
    required this.createdAt,
    this.status = BookingStatus.pending,
    this.rejectionReason,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'therapistId': therapistId,
      'userName': userName,
      'phoneNumber': phoneNumber,
      'address': address,
      'complaint': complaint,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'createdAt': Timestamp.fromDate(createdAt),
      'status': status.code,
      'rejectionReason': rejectionReason,
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map, String id) {
    return Booking(
      id: id,
      userId: map['userId'] ?? '',
      therapistId: map['therapistId'] ?? '',
      userName: map['userName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      complaint: map['complaint'] ?? '',
      scheduledTime: (map['scheduledTime'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      status: BookingStatus.fromCode(map['status'] as int? ?? 0),
      rejectionReason: map['rejectionReason'] as String?,
    );
  }
}