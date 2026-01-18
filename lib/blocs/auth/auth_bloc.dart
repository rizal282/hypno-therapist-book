import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;

  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>((event, emit) {
      final user = _auth.currentUser;
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    });

    on<AuthLoginRequested>((event, emit) async {
      emit(AuthLoading());
      try {
        // final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        await _googleSignIn.initialize(
          serverClientId:
              '691132595156-5ekj52hq76c1rvhhjtrc7dcbf7ugi8s8.apps.googleusercontent.com',
        );

        final completer = Completer<User?>();

        final sub = _googleSignIn.authenticationEvents.listen(
          (event) async {
            final user = await _handleAuthenticationEvent(event);

            emit(Authenticated(user!));
            completer.complete(user);
          },
          onError: (err) {
            completer.complete(null);
          },
        );

        _googleSignIn.attemptLightweightAuthentication();

        final googleUser = await completer.future;
        if (googleUser == null) {
          emit(Unauthenticated());

          await sub.cancel();
          // return;
        }
      } catch (e) {
        emit(AuthError(e.toString()));
      }
    });

    on<AuthLogoutRequested>((event, emit) async {
      emit(AuthLoading());
      await _auth.signOut();
      await _googleSignIn.signOut();
      emit(Unauthenticated());
    });
  }

  Future<User?> _handleAuthenticationEvent(
    GoogleSignInAuthenticationEvent event,
  ) async {
    final GoogleSignInAccount? user = switch (event) {
      GoogleSignInAuthenticationEventSignIn() => event.user,
      GoogleSignInAuthenticationEventSignOut() => null,
    };

    // final GoogleSignInClientAuthorization? authorization = await user?.authorizationClient.authorizationForScopes(_scopes);

    if (user == null) return null;

    final GoogleSignInAuthentication googleSignInAuthentication =
        user.authentication;

    final AuthCredential authCredential = GoogleAuthProvider.credential(
      idToken: googleSignInAuthentication.idToken,
      // accessToken: authorization!.accessToken
    );

    final currentUser = await _auth.signInWithCredential(authCredential);

    return currentUser.user;
  }
}
