class Therapist {
  final String uid;
  final String name;
  final String specialization;
  final String description;
  final String email;
  final String? photoUrl;
  final double rating;
  final String practiceDays;
  final String practiceHours;

  const Therapist({
    required this.uid,
    required this.name,
    required this.specialization,
    required this.description,
    required this.email,
    this.photoUrl,
    this.rating = 5.0,
    this.practiceDays = 'Senin - Jumat',
    this.practiceHours = '09:00 - 17:00',
  });
}