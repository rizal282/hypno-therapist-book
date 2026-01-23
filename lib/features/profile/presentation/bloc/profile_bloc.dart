import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  ProfileBloc() : super(ProfileInitial()) {
    on<LoadUserProfile>(_onLoadUserProfile);
    on<UpdateUserProfile>(_onUpdateUserProfile);
  }

  Future<void> _onLoadUserProfile(
    LoadUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        String phone = '';
        String address = '';
        String gender = '';
        String birthDate = '';
        
        if (doc.exists) {
          final data = doc.data() as Map<String, dynamic>;
          phone = data['phoneNumber'] ?? '';
          address = data['address'] ?? '';
          gender = data['gender'] ?? '';
          birthDate = data['birthDate'] ?? '';
        }

        emit(ProfileLoaded(
          name: user.displayName ?? '',
          email: user.email ?? '',
          phone: phone,
          address: address,
          gender: gender,
          birthDate: birthDate,
          photoUrl: user.photoURL,
        ));
      } else {
        emit(const ProfileError('User tidak ditemukan'));
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }

  Future<void> _onUpdateUserProfile(
    UpdateUserProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(ProfileLoading());
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // 1. Update Firebase Auth Profile (Nama)
        if (user.displayName != event.name) {
          await user.updateDisplayName(event.name);
        }

        // 2. Update Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'displayName': event.name,
          'email': user.email,
          'phoneNumber': event.phone,
          'address': event.address,
          'gender': event.gender,
          'birthDate': event.birthDate,
          'photoURL': user.photoURL,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        emit(ProfileUpdateSuccess());
      }
    } catch (e) {
      emit(ProfileError(e.toString()));
    }
  }
}
