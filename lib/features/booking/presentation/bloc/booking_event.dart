import '../../data/model/booking.dart';

abstract class BookingEvent {}

class CreateBooking extends BookingEvent {
  final Booking booking;
  CreateBooking(this.booking);
}

class LoadBookings extends BookingEvent {
  final String userId;
  LoadBookings(this.userId);
}

class CancelBooking extends BookingEvent {
  final Booking booking;
  CancelBooking(this.booking);
}