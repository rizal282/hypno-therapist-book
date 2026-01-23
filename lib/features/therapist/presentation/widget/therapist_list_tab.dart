import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/model/therapist.dart';
import '../bloc/therapist_bloc.dart';
import '../bloc/therapist_state.dart';
import '../screen/therapist_detail_screen.dart';

class TherapistListTab extends StatelessWidget {
  const TherapistListTab({super.key});
  (bool, String) _getAvailabilityStatus(Therapist therapist) {
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

    if (!isPracticeDay) {
      return (false, 'Tidak Tersedia');
    }

    final hourParts = practiceHoursString.split(' - ');
    if (hourParts.length != 2) {
      return (false, 'Jadwal tidak valid');
    }

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
      if (nowInMinutes >= startInMinutes && nowInMinutes < endInMinutes) {
        return (true, 'Tersedia');
      } else {
        return (false, 'Tidak Tersedia');
      }
    } catch (e) {
      return (false, 'Jadwal tidak valid');
    }
  }

  Widget _buildStatusIndicator(bool isAvailable, String statusText) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isAvailable
            ? Colors.green.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isAvailable
              ? Colors.green.withOpacity(0.3)
              : Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: isAvailable ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isAvailable ? Colors.green[800] : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TherapistBloc, TherapistState>(
      builder: (context, state) {
        if (state is TherapistLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TherapistLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.therapists.length,
            itemBuilder: (context, index) {
              final therapist = state.therapists[index];
              final (isAvailable, statusText) = _getAvailabilityStatus(therapist);
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TherapistDetailScreen(therapist: therapist),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.teal,
                              backgroundImage: (therapist.photoUrl != null &&
                                      therapist.photoUrl!.isNotEmpty)
                                  ? NetworkImage(therapist.photoUrl!)
                                  : null,
                              child:
                                  (therapist.photoUrl == null ||
                                      therapist.photoUrl!.isEmpty)
                                  ? const Icon(
                                      Icons.person,
                                      size: 40,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    therapist.name,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.psychology,
                                        size: 16,
                                        color: Colors.teal,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        therapist.specialization,
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  _buildStatusIndicator(isAvailable, statusText),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 14,
                              color: Colors.teal,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              therapist.practiceDays,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 16),
                            const Icon(
                              Icons.access_time,
                              size: 14,
                              color: Colors.teal,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              therapist.practiceHours,
                              style: const TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          therapist.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        } else if (state is TherapistError) {
          return Center(child: Text(state.message));
        }
        return const Center(child: Text("Silakan muat data"));
      },
    );
  }
}
