import 'package:cloud_firestore/cloud_firestore.dart';

class Booking {
  final String? id;
  final String userId;
  final String userName;
  final String phoneNumber;
  final String address;
  final String complaint;
  final DateTime scheduledTime;
  final DateTime createdAt;

  Booking({
    this.id,
    required this.userId,
    required this.userName,
    required this.phoneNumber,
    required this.address,
    required this.complaint,
    required this.scheduledTime,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'userName': userName,
      'phoneNumber': phoneNumber,
      'address': address,
      'complaint': complaint,
      'scheduledTime': Timestamp.fromDate(scheduledTime),
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory Booking.fromMap(Map<String, dynamic> map, String id) {
    return Booking(
      id: id,
      userId: map['userId'] ?? '',
      userName: map['userName'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      address: map['address'] ?? '',
      complaint: map['complaint'] ?? '',
      scheduledTime: (map['scheduledTime'] as Timestamp).toDate(),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
    );
  }
}