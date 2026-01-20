import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'booking_event.dart';
import 'booking_state.dart';
import '../../data/models/booking.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  BookingBloc() : super(BookingInitial()) {
    on<CreateBooking>(_onCreateBooking);
    on<LoadBookings>(_onLoadBookings);
    on<CancelBooking>(_onCancelBooking);
  }

  Future<void> _onCreateBooking(
      CreateBooking event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      await _firestore.collection('bookings').add(event.booking.toMap());
      // Simulasi delay agar loading terlihat
      await Future.delayed(const Duration(milliseconds: 500));
      emit(BookingSuccess());
    } catch (e) {
      emit(BookingFailure(e.toString()));
    }
  }

  Future<void> _onLoadBookings(
      LoadBookings event, Emitter<BookingState> emit) async {
    emit(BookingLoading());
    try {
      final querySnapshot = await _firestore
          .collection('bookings')
          .where('userId', isEqualTo: event.userId)
          .get();

      final bookings = querySnapshot.docs
          .map((doc) => Booking.fromMap(doc.data(), doc.id))
          .toList();

      bookings.sort((a, b) => b.scheduledTime.compareTo(a.scheduledTime));
      emit(BookingsLoaded(bookings));
    } catch (e) {
      emit(BookingFailure(e.toString()));
    }
  }

  Future<void> _onCancelBooking(
      CancelBooking event, Emitter<BookingState> emit) async {
    try {
      await _firestore
          .collection('bookings')
          .doc(event.booking.id)
          .update({'status': BookingStatus.cancelled.code});
      add(LoadBookings(event.booking.userId));
    } catch (e) {
      emit(BookingFailure(e.toString()));
    }
  }
}