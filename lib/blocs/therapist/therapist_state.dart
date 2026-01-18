import '../../../../data/models/therapist.dart';

abstract class TherapistState {}

class TherapistInitial extends TherapistState {}

class TherapistLoading extends TherapistState {}

class TherapistLoaded extends TherapistState {
  final List<Therapist> therapists;
  TherapistLoaded(this.therapists);
}

class TherapistError extends TherapistState {
  final String message;
  TherapistError(this.message);
}