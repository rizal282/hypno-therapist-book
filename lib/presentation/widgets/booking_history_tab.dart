import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypnotherapist_app/presentation/screens/booking_detail_screen.dart';
import '../../blocs/booking/booking_bloc.dart';
import '../../blocs/booking/booking_state.dart';
import '../../data/models/booking.dart';

class BookingHistoryTab extends StatefulWidget {
  const BookingHistoryTab({super.key});

  @override
  State<BookingHistoryTab> createState() => _BookingHistoryTabState();
}

class _BookingHistoryTabState extends State<BookingHistoryTab> {
  BookingStatus? _selectedFilter;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is BookingsLoaded) {
          if (state.bookings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Belum ada riwayat booking"),
                ],
              ),
            );
          }

          final filteredBookings = _selectedFilter == null
              ? state.bookings
              : state.bookings
                  .where((b) => b.status == _selectedFilter)
                  .toList();

          return Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    _buildFilterChip(null, 'Semua'),
                    _buildFilterChip(BookingStatus.pending, 'Menunggu'),
                    _buildFilterChip(BookingStatus.accepted, 'Diterima'),
                    _buildFilterChip(BookingStatus.completed, 'Selesai'),
                    _buildFilterChip(BookingStatus.cancelled, 'Dibatalkan'),
                  ],
                ),
              ),
              Expanded(
                child: filteredBookings.isEmpty
                    ? const Center(
                        child: Text("Tidak ada booking dengan status ini"),
                      )
                    : ListView.builder(
                        itemCount: filteredBookings.length,
                        itemBuilder: (context, index) {
                          final booking = filteredBookings[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            child: ListTile(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        BookingDetailScreen(booking: booking),
                                  ),
                                );
                              },
                              leading: _buildStatusIcon(booking.status),
                              title: Text(booking.complaint,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                      "${booking.scheduledTime.day}/${booking.scheduledTime.month}/${booking.scheduledTime.year} - ${booking.scheduledTime.hour}:${booking.scheduledTime.minute.toString().padLeft(2, '0')}"),
                                  const SizedBox(height: 4),
                                  Text(
                                    _getStatusText(booking.status),
                                    style: TextStyle(
                                      color: _getStatusColor(booking.status),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('bookings')
                                    .doc(booking.id)
                                    .collection('messages')
                                    .where('isRead', isEqualTo: false)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  int unreadCount = 0;
                                  if (snapshot.hasData) {
                                    // Hitung pesan yang bukan dari user saat ini (pesan masuk)
                                    unreadCount = snapshot.data!.docs
                                        .where((doc) =>
                                            doc['senderId'] !=
                                            FirebaseAuth.instance.currentUser
                                                ?.uid)
                                        .length;
                                  }

                                  return Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      if (unreadCount > 0)
                                        Container(
                                          padding: const EdgeInsets.all(6),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Text(
                                            '$unreadCount',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      if (unreadCount > 0)
                                        const SizedBox(width: 8),
                                      const Icon(Icons.chevron_right),
                                    ],
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        } else if (state is BookingFailure) {
          return Center(child: Text("Error: ${state.error}"));
        }
        return const Center(child: Text("Belum ada riwayat booking"));
      },
    );
  }

  Widget _buildFilterChip(BookingStatus? status, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: ChoiceChip(
        label: Text(label),
        selected: _selectedFilter == status,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedFilter = status;
            });
          }
        },
      ),
    );
  }

  Icon _buildStatusIcon(BookingStatus status) {
    switch (status) {
      case BookingStatus.pending:
        return const Icon(Icons.access_time, color: Colors.orange);
      case BookingStatus.accepted:
        return const Icon(Icons.check_circle, color: Colors.green);
      case BookingStatus.completed:
        return const Icon(Icons.task_alt, color: Colors.blue);
      case BookingStatus.cancelled:
        return const Icon(Icons.cancel, color: Colors.red);
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
