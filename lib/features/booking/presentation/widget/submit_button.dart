import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypnotherapist_app/features/booking/presentation/bloc/booking_bloc.dart';
import 'package:hypnotherapist_app/features/booking/presentation/bloc/booking_state.dart';

class SubmitButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SubmitButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: BlocBuilder<BookingBloc, BookingState>(
        builder: (context, state) {
          if (state is BookingLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          return FilledButton(
            onPressed: onPressed,
            child: const Text('Konfirmasi Booking'),
          );
        },
      ),
    );
  }
}