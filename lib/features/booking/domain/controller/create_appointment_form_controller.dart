import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:hypnotherapist_app/features/therapist/data/model/therapist.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../data/model/booking.dart';

class CreateAppointmentFormController extends ChangeNotifier {
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController complaintController = TextEditingController();

  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  bool isLoadingLocation = false;

  CreateAppointmentFormController() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && user.displayName != null) {
      nameController.text = user.displayName!;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    complaintController.dispose();
    super.dispose();
  }

  Future<void> getCurrentLocation(BuildContext context) async {
    isLoadingLocation = true;
    notifyListeners();

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Layanan lokasi tidak aktif');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak secara permanen');
      }

      Position position = await Geolocator.getCurrentPosition();
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks[0];
        String address = [
          place.street,
          place.subLocality,
          place.locality,
          place.postalCode,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
        addressController.text = address;
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      isLoadingLocation = false;
      notifyListeners();
    }
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate) {
      selectedDate = picked;
      notifyListeners();
    }
  }

  Future<void> pickTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && picked != selectedTime) {
      selectedTime = picked;
      notifyListeners();
    }
  }

  Booking? validateAndCreateBooking(Therapist therapist) {
    if (formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      return Booking(
        userId: user.uid,
        therapistId: therapist.uid,
        userName: nameController.text,
        phoneNumber: phoneController.text,
        address: addressController.text,
        complaint: complaintController.text,
        scheduledTime: DateTime(
          selectedDate.year,
          selectedDate.month,
          selectedDate.day,
          selectedTime.hour,
          selectedTime.minute,
        ),
        createdAt: DateTime.now(),
        status: BookingStatus.pending,
      );
    }
    return null;
  }

  Future<void> sendEmailToTherapist(BuildContext context, Therapist therapist) async {
    final String subject = 'Permintaan Booking Terapi - ${nameController.text}';
    final String body =
        '''
            Halo,

            Saya ${nameController.text} ingin mengajukan jadwal sesi terapi.
            Berikut adalah detail data diri saya:

            Nama: ${nameController.text}
            No HP: ${phoneController.text}
            Alamat: ${addressController.text}
            Keluhan: ${complaintController.text}
            Jadwal yang diinginkan: ${selectedDate.day}/${selectedDate.month}/${selectedDate.year} Pukul ${selectedTime.format(context)}

            Mohon informasinya untuk ketersediaan jadwal tersebut. Terima kasih.
            ''';

    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: therapist.email,
      query: _encodeQueryParameters(<String, String>{
        'subject': subject,
        'body': body,
      }),
    );

    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (MapEntry<String, String> e) =>
              '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}',
        )
        .join('&');
  }
}
