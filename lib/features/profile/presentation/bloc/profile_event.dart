import 'package:equatable/equatable.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadUserProfile extends ProfileEvent {}

class UpdateUserProfile extends ProfileEvent {
  final String name;
  final String phone;
  final String address;
  final String gender;
  final String birthDate;

  const UpdateUserProfile({
    required this.name,
    required this.phone,
    required this.address,
    required this.gender,
    required this.birthDate,
  });

  @override
  List<Object?> get props => [name, phone, address, gender, birthDate];
}
