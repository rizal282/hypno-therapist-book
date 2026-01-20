class Therapist {
  final String name;
  final String specialty;
  final String description;
  final String email;
  final double rating;

  const Therapist({
    required this.name,
    required this.specialty,
    required this.description,
    required this.email,
    this.rating = 5.0,
  });
}