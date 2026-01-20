import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/therapist/therapist_bloc.dart';
import '../../blocs/therapist/therapist_state.dart';
import '../screens/therapist_detail_screen.dart';

class TherapistListTab extends StatelessWidget {
  const TherapistListTab({super.key});

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
                            const CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.teal,
                              child: Icon(Icons.person,
                                  size: 30, color: Colors.white),
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
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    therapist.specialty,
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
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
