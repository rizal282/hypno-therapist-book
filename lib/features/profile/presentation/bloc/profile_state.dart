import 'package:equatable/equatable.dart';

abstract class ProfileState extends Equatable {
  const ProfileState();
  
  @override
  List<Object?> get props => [];
}

class ProfileInitial extends ProfileState {}

class ProfileLoading extends ProfileState {}

class ProfileLoaded extends ProfileState {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String gender;
  final String birthDate;
  final String? photoUrl;

  const ProfileLoaded({
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.gender,
    required this.birthDate,
    this.photoUrl,
  });

  @override
  List<Object?> get props => [name, email, phone, address, gender, birthDate, photoUrl];
}

class ProfileUpdateSuccess extends ProfileState {}

class ProfileError extends ProfileState {
  final String message;

  const ProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
