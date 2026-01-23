import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../../data/model/booking.dart';
import '../../../chat/presentation/page/chat_screen.dart';

class BookingDetailScreen extends StatelessWidget {
  final Booking booking;

  const BookingDetailScreen({super.key, required this.booking});

  @override
  Widget build(BuildContext context) {
    final formattedDate =
        DateFormat('d MMMM yyyy', 'id_ID').format(booking.scheduledTime);
    final formattedTime = DateFormat('HH:mm').format(booking.scheduledTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Booking'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (booking.status == BookingStatus.accepted)
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('bookings')
                  .doc(booking.id)
                  .collection('messages')
                  .where('isRead', isEqualTo: false)
                  .snapshots(),
              builder: (context, snapshot) {
                int unreadCount = 0;
                if (snapshot.hasData) {
                  unreadCount = snapshot.data!.docs
                      .where((doc) =>
                          doc['senderId'] !=
                          FirebaseAuth.instance.currentUser?.uid)
                      .length;
                }
                return Stack(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.chat),
                      tooltip: 'Chat dengan Therapist',
                      onPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => ChatScreen(booking: booking)));
                      },
                    ),
                    if (unreadCount > 0)
                      Positioned(
                        right: 8,
                        top: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                );
              },
            ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(context, 'Keluhan:', booking.complaint),
                      _buildDetailRow(
                          context, 'Jadwal:', '$formattedDate - $formattedTime'),
                      _buildDetailRow(
                        context,
                        'Status:',
                        _getStatusText(booking.status),
                        valueColor: _getStatusColor(booking.status),
                      ),
                      const Divider(height: 32, thickness: 1),
                      Text(
                        'Detail Pemesan',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(context, 'Nama:', booking.userName),
                      _buildDetailRow(context, 'No. HP:', booking.phoneNumber),
                      _buildDetailRow(context, 'Alamat:', booking.address),
                    ],
                  ),
                ),
              ),
              if (booking.status == BookingStatus.pending) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  icon: const Icon(Icons.cancel_outlined),
                  label: const Text('Batalkan Booking'),
                  onPressed: () => _showCancelDialog(context, booking),
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value,
      {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style:
                  Theme.of(context).textTheme.bodyLarge?.copyWith(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelDialog(BuildContext context, Booking booking) async {
    final rejectionReason = await showDialog<String>(
      context: context,
      builder: (context) => const _CancelBookingDialog(),
    );

    if (rejectionReason != null && context.mounted) {
      final updatedBooking = Booking(
        id: booking.id,
        userId: booking.userId,
        userName: booking.userName,
        phoneNumber: booking.phoneNumber,
        address: booking.address,
        complaint: booking.complaint,
        scheduledTime: booking.scheduledTime,
        createdAt: booking.createdAt,
        status: BookingStatus.cancelled,
        rejectionReason: rejectionReason,
      );
      context.read<BookingBloc>().add(CancelBooking(updatedBooking));
      Navigator.of(context).pop();
    }
  }

  String _getStatusText(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return 'Menunggu Konfirmasi';
      case BookingStatus.accepted:
        return 'Diterima';
      case BookingStatus.completed:
        return 'Selesai';
      case BookingStatus.cancelled:
        return 'Dibatalkan';
    }
  }

  Color _getStatusColor(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return Colors.orange;
      case BookingStatus.accepted:
        return Colors.green;
      case BookingStatus.completed:
        return Colors.blue;
      case BookingStatus.cancelled:
        return Colors.red;
    }
  }
}

class _CancelBookingDialog extends StatefulWidget {
  const _CancelBookingDialog({super.key});

  @override
  State<_CancelBookingDialog> createState() => _CancelBookingDialogState();
}

class _CancelBookingDialogState extends State<_CancelBookingDialog> {
  late final TextEditingController _reasonController;

  @override
  void initState() {
    super.initState();
    _reasonController = TextEditingController();
  }

  @override
  void dispose() {
    _reasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Batalkan Booking'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Apakah Anda yakin ingin membatalkan sesi ini?'),
          const SizedBox(height: 16),
          TextField(
            controller: _reasonController,
            decoration: const InputDecoration(
              labelText: 'Alasan Pembatalan',
              hintText: 'Masukkan alasan pembatalan...',
              border: OutlineInputBorder(),
            ),
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Tidak'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(_reasonController.text);
          },
          child: const Text('Ya, Batalkan'),
        ),
      ],
    );
  }
}