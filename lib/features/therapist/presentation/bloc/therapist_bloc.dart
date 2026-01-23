import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'therapist_event.dart';
import 'therapist_state.dart';
import '../../data/model/therapist.dart';

class TherapistBloc extends Bloc<TherapistEvent, TherapistState> {
  TherapistBloc() : super(TherapistInitial()) {
    on<LoadTherapists>((event, emit) async {
      emit(TherapistLoading());
      try {
        // Mengambil data dari koleksi 'therapists' di Firestore
        final snapshot = await FirebaseFirestore.instance.collection('therapists').get();

        final therapists = snapshot.docs.map((doc) {
          final data = doc.data();
          return Therapist(
            uid: data['mitraId'] as String? ?? '',
            name: data['name'] as String? ?? '',
            specialization: data['specialization'] as String,
            description: data['description'] as String? ?? '',
            email: data['email'] as String? ?? '',
            photoUrl: data['photoUrl'] as String?,
            rating: (data['rating'] as num?)?.toDouble() ?? 5.0,
            practiceDays: data['practiceDays'] as String,
            practiceHours: data['practiceHours'] as String,
          );
        }).toList();
        
        emit(TherapistLoaded(therapists));
      } catch (e) {
        emit(TherapistError("Gagal memuat data terapis"));
      }
    });
  }
}