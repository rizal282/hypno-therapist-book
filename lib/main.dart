import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'blocs/therapist/therapist_bloc.dart';
import 'blocs/therapist/therapist_event.dart';
import 'blocs/auth/auth_bloc.dart';
import 'blocs/auth/auth_event.dart';
import 'blocs/auth/auth_state.dart';
import 'blocs/booking/booking_bloc.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Pastikan sudah menjalankan 'flutterfire configure'
  runApp(const HypnotherapistApp());
}

class HypnotherapistApp extends StatelessWidget {
  const HypnotherapistApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthBloc()..add(AuthCheckRequested())),
        BlocProvider(create: (context) => TherapistBloc()..add(LoadTherapists())),
        BlocProvider(create: (context) => BookingBloc()),
      ],
      child: MaterialApp(
        title: 'Hypnotherapist App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is Authenticated) {
              return const HomeScreen();
            } else if (state is Unauthenticated || state is AuthError) {
              return const LoginScreen();
            }
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          },
        ),
      ),
    );
  }
}
