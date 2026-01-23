import '../../data/model/booking.dart';

abstract class BookingState {}

class BookingInitial extends BookingState {}
class BookingLoading extends BookingState {}
class BookingSuccess extends BookingState {}
class BookingFailure extends BookingState {
  final String error;
  BookingFailure(this.error);
}

class BookingsLoaded extends BookingState {
  final List<Booking> bookings;
  BookingsLoaded(this.bookings);
}