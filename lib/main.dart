import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'features/therapist/presentation/bloc/therapist_bloc.dart';
import 'features/therapist/presentation/bloc/therapist_event.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/auth/presentation/bloc/auth_state.dart';
import 'features/booking/presentation/bloc/booking_bloc.dart';
import 'features/auth/presentation/screen/home_screen.dart';
import 'features/auth/presentation/screen/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); 
  await initializeDateFormatting('id_ID', null);
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
