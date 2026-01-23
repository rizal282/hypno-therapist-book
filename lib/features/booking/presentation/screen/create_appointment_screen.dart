import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypnotherapist_app/features/therapist/data/model/therapist.dart';
import 'package:hypnotherapist_app/features/booking/presentation/widget/personal_data_section_book.dart';
import 'package:hypnotherapist_app/features/booking/presentation/widget/schedule_section_book.dart';
import 'package:hypnotherapist_app/features/booking/presentation/widget/submit_button.dart';
import '../bloc/booking_bloc.dart';
import '../bloc/booking_event.dart';
import '../bloc/booking_state.dart';
import '../../domain/controller/create_appointment_form_controller.dart';

class CreateAppointmentScreen extends StatefulWidget {
  final Therapist therapist;

  const CreateAppointmentScreen({super.key, required this.therapist});

  @override
  State<CreateAppointmentScreen> createState() =>
      _CreateAppointmentScreenState();
}

class _CreateAppointmentScreenState extends State<CreateAppointmentScreen> {
  late final CreateAppointmentFormController _controller;

  @override
  void initState() {
    super.initState();
    _controller = CreateAppointmentFormController();
    _loadUserData();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Isi nama awal dari Auth jika ada
      if (user.displayName != null) {
        _controller.nameController.text = user.displayName!;
      }

      // Ambil data lengkap dari Firestore (yang disimpan di Informasi Diri)
      try {
        final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          if (data['displayName'] != null) _controller.nameController.text = data['displayName'];
          if (data['phoneNumber'] != null) _controller.phoneController.text = data['phoneNumber'];
          if (data['address'] != null) _controller.addressController.text = data['address'];
        }
      } catch (_) {}
    }
  }

  void _submitBooking() {
    final booking = _controller.validateAndCreateBooking(widget.therapist);
    if (booking != null) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Konfirmasi Booking'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    'Mohon periksa kembali data berikut sebelum mengirim:'),
                const SizedBox(height: 16),
                _buildPreviewRow('Nama', booking.userName),
                _buildPreviewRow('No. HP', booking.phoneNumber),
                _buildPreviewRow('Alamat', booking.address),
                _buildPreviewRow('Keluhan', booking.complaint),
                const Divider(),
                _buildPreviewRow(
                    'Tanggal',
                    '${_controller.selectedDate.day}/${_controller.selectedDate.month}/${_controller.selectedDate.year}'),
                _buildPreviewRow(
                    'Jam', _controller.selectedTime.format(context)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Edit'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<BookingBloc>().add(CreateBooking(booking));
              },
              child: const Text('Kirim'),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildPreviewRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final therapist = widget.therapist;

    return BlocListener<BookingBloc, BookingState>(
      listener: (context, state) {
        if (state is BookingSuccess) {
          _controller.sendEmailToTherapist(context, therapist);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Booking berhasil disimpan!')),
          );
          Navigator.pop(context);
        } else if (state is BookingFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Gagal: ${state.error}')));
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Booking Sesi Terapi'),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _controller.formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PersonalDataSectionBook(
                      nameController: _controller.nameController,
                      phoneController: _controller.phoneController,
                      addressController: _controller.addressController,
                      complaintController: _controller.complaintController,
                      isLoadingLocation: _controller.isLoadingLocation,
                      onGetLocation: () =>
                          _controller.getCurrentLocation(context),
                    ),
                    const SizedBox(height: 24),
                    ScheduleSectionBook(
                      selectedDate: _controller.selectedDate,
                      selectedTime: _controller.selectedTime,
                      onPickDate: () => _controller.pickDate(context),
                      onPickTime: () => _controller.pickTime(context),
                    ),
                    const SizedBox(height: 32),
                    SubmitButton(onPressed: _submitBooking),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
