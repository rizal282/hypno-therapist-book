import 'package:flutter/material.dart';
import '../../data/model/therapist.dart';
import '../../../booking/presentation/screen/create_appointment_screen.dart';

class TherapistDetailScreen extends StatelessWidget {
  final Therapist therapist;

  const TherapistDetailScreen({super.key, required this.therapist});

  bool _isTherapistAvailable() {
    final now = DateTime.now();
    final practiceDaysString = therapist.practiceDays.toLowerCase();
    final practiceHoursString = therapist.practiceHours;

    final dayMap = {
      'senin': DateTime.monday,
      'selasa': DateTime.tuesday,
      'rabu': DateTime.wednesday,
      'kamis': DateTime.thursday,
      'jumat': DateTime.friday,
      'sabtu': DateTime.saturday,
      'minggu': DateTime.sunday,
    };

    bool isPracticeDay = false;
    if (practiceDaysString.contains(',')) {
      final days = practiceDaysString.split(',');
      for (var day in days) {
        final dayVal = dayMap[day.trim()];
        if (dayVal != null && now.weekday == dayVal) {
          isPracticeDay = true;
          break;
        }
      }
    } else if (practiceDaysString.contains('-')) {
      final parts = practiceDaysString.split('-');
      if (parts.length == 2) {
        final startDay = dayMap[parts[0].trim()];
        final endDay = dayMap[parts[1].trim()];
        if (startDay != null && endDay != null) {
          if (now.weekday >= startDay && now.weekday <= endDay) {
            isPracticeDay = true;
          }
        }
      }
    }

    if (!isPracticeDay) return false;

    final hourParts = practiceHoursString.split(' - ');
    if (hourParts.length != 2) return false;

    try {
      final startTimeParts = hourParts[0].trim().split(':');
      final endTimeParts = hourParts[1].trim().split(':');
      final startHour = int.parse(startTimeParts[0]);
      final startMinute = int.parse(startTimeParts[1]);
      final endHour = int.parse(endTimeParts[0]);
      final endMinute = int.parse(endTimeParts[1]);
      final nowInMinutes = now.hour * 60 + now.minute;
      final startInMinutes = startHour * 60 + startMinute;
      final endInMinutes = endHour * 60 + endMinute;
      return nowInMinutes >= startInMinutes && nowInMinutes < endInMinutes;
    } catch (e) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAvailable = _isTherapistAvailable();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Therapist'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.teal,
                        backgroundImage: (therapist.photoUrl != null &&
                                therapist.photoUrl!.isNotEmpty)
                            ? NetworkImage(therapist.photoUrl!)
                            : null,
                        child: (therapist.photoUrl == null ||
                                therapist.photoUrl!.isEmpty)
                            ? const Icon(Icons.person, size: 60, color: Colors.white)
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(
                      child: Text(
                        therapist.name,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                      child: Text(
                        therapist.specialization,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Colors.grey[600],
                            ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          therapist.rating.toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Ketersediaan Jadwal',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.teal.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.teal.withOpacity(0.2)),
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(context, Icons.calendar_today, therapist.practiceDays),
                          const SizedBox(height: 8),
                          _buildInfoRow(context, Icons.access_time, therapist.practiceHours),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Kontak',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow(context, Icons.email, therapist.email),
                    const SizedBox(height: 24),
                    Text(
                      'Tentang',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      therapist.description,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: isAvailable ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CreateAppointmentScreen(therapist: therapist,),
                      ),
                    );
                  } : null,
                  icon: const Icon(Icons.calendar_month),
                  label: Text(isAvailable ? "Booking Sesi" : "Terapis Tidak Tersedia"),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.teal),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      ],
    );
  }
}