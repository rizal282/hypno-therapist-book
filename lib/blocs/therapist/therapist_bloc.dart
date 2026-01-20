import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'therapist_event.dart';
import 'therapist_state.dart';
import '../../../../data/models/therapist.dart';

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
            name: data['name'] as String? ?? '',
            specialty: data['specialty'] as String? ?? '',
            description: data['description'] as String? ?? '',
            email: data['email'] as String? ?? '',
          );
        }).toList();
        
        emit(TherapistLoaded(therapists));
      } catch (e) {
        emit(TherapistError("Gagal memuat data terapis"));
      }
    });
  }
}