import 'package:flutter_bloc/flutter_bloc.dart';
import 'therapist_event.dart';
import 'therapist_state.dart';
import '../../../../data/models/therapist.dart';

class TherapistBloc extends Bloc<TherapistEvent, TherapistState> {
  TherapistBloc() : super(TherapistInitial()) {
    on<LoadTherapists>((event, emit) async {
      emit(TherapistLoading());
      try {
        // Simulasi delay network/database
        await Future.delayed(const Duration(seconds: 1));
        
        // MVP 1 Data (Hardcoded untuk sekarang)
        final therapists = [
          const Therapist(
            name: "Dr. Rizal, C.Ht",
            specialty: "Spesialis: Anxiety & Stress Management",
            description: "Membantu Anda mengatasi kecemasan dan stres dengan metode hipnoterapi klinis yang terbukti efektif.",
          ),
        ];
        
        emit(TherapistLoaded(therapists));
      } catch (e) {
        emit(TherapistError("Gagal memuat data terapis"));
      }
    });
  }
}