class Therapist {
  final String name;
  final String specialty;
  final String description;
  final double rating;

  const Therapist({
    required this.name,
    required this.specialty,
    required this.description,
    this.rating = 5.0,
  });
}