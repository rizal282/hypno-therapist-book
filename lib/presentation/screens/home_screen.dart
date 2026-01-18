import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../blocs/therapist/therapist_bloc.dart';
import '../../../../blocs/therapist/therapist_state.dart';
import '../../../../blocs/auth/auth_bloc.dart';
import '../../../../blocs/auth/auth_event.dart';
import '../../../../blocs/booking/booking_bloc.dart';
import '../../../../blocs/booking/booking_event.dart';
import '../../../../blocs/booking/booking_state.dart';
import 'create_appointment_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    if (index == 1) {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        context.read<BookingBloc>().add(LoadBookings(user.uid));
      }
    }
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Halaman 1: Daftar Terapis (Home) dengan BLoC
    final widgetListTerapis = BlocBuilder<TherapistBloc, TherapistState>(
      builder: (context, state) {
        if (state is TherapistLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TherapistLoaded) {
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.therapists.length,
            itemBuilder: (context, index) {
              final therapist = state.therapists[index];
              return Card(
                elevation: 4,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            backgroundColor: Colors.teal,
                            child: Icon(Icons.person, size: 30, color: Colors.white),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  therapist.name,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  therapist.specialty,
                                  style: TextStyle(color: Colors.grey[600]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        therapist.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const CreateAppointmentScreen()),
                            );
                          },
                          icon: const Icon(Icons.calendar_month),
                          label: const Text("Booking Sesi"),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        } else if (state is TherapistError) {
          return Center(child: Text(state.message));
        }
        return const Center(child: Text("Silakan muat data"));
      },
    );

    // Halaman 2: Riwayat Booking
    final widgetRiwayat = BlocBuilder<BookingBloc, BookingState>(
      builder: (context, state) {
        if (state is BookingLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is BookingsLoaded) {
          if (state.bookings.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Belum ada riwayat booking"),
                ],
              ),
            );
          }
          return ListView.builder(
            itemCount: state.bookings.length,
            itemBuilder: (context, index) {
              final booking = state.bookings[index];
              return ListTile(
                leading: const Icon(Icons.calendar_today, color: Colors.teal),
                title: Text(booking.complaint, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                    "${booking.scheduledTime.day}/${booking.scheduledTime.month}/${booking.scheduledTime.year} - ${booking.scheduledTime.hour}:${booking.scheduledTime.minute.toString().padLeft(2, '0')}"),
              );
            },
          );
        } else if (state is BookingFailure) {
          return Center(child: Text("Error: ${state.error}"));
        }
        return const Center(child: Text("Belum ada riwayat booking"));
      },
    );

    // Halaman 3: Profil User
    final user = FirebaseAuth.instance.currentUser;
    final widgetProfil = user == null
        ? const Center(child: Text("User tidak ditemukan"))
        : ListView(
            padding: const EdgeInsets.all(24.0),
            children: [
              const SizedBox(height: 24),
              Center(
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.teal.shade100,
                  backgroundImage:
                      user.photoURL != null ? NetworkImage(user.photoURL!) : null,
                  child: user.photoURL == null
                      ? const Icon(Icons.person, size: 50, color: Colors.teal)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.displayName ?? "Tanpa Nama",
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                user.email ?? "Tanpa Email",
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              SelectableText(
                "ID: ${user.uid}",
                style: TextStyle(color: Colors.grey[400], fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.person_outline, color: Colors.teal),
                title: const Text("Informasi Diri"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.privacy_tip_outlined, color: Colors.teal),
                title: const Text("Kebijakan Privasi"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {},
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.info_outline, color: Colors.teal),
                title: const Text("Tentang Aplikasi"),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  showAboutDialog(
                    context: context,
                    applicationName: "HypnoBook",
                    applicationVersion: "1.0.0",
                    applicationIcon: const Icon(Icons.spa, color: Colors.teal),
                    children: [
                      const Text("Aplikasi booking sesi hipnoterapi."),
                    ],
                  );
                },
              ),
              const Divider(),
            ],
          );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('HypnoBook'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              context.read<AuthBloc>().add(AuthLogoutRequested());
            },
          ),
        ],
      ),
      body: [
        widgetListTerapis,
        widgetRiwayat,
        widgetProfil
      ][_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Riwayat',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        onTap: _onItemTapped,
      ),
    );
  }
}