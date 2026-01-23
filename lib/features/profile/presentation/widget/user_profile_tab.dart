import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hypnotherapist_app/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:hypnotherapist_app/features/profile/presentation/bloc/profile_event.dart';
import 'package:hypnotherapist_app/features/profile/presentation/screen/personal_info_screen.dart';

class UserProfileTab extends StatelessWidget {
  const UserProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.userChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        if (user == null) {
          return const Center(child: Text("User tidak ditemukan"));
        }

        return ListView(
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
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BlocProvider(
                      create: (context) => ProfileBloc()..add(LoadUserProfile()),
                      child: const PersonalInfoScreen(),
                    ),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading:
                  const Icon(Icons.privacy_tip_outlined, color: Colors.teal),
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
      },
    );
  }
}
