abstract class AuthEvent {}

class AuthCheckRequested extends AuthEvent {}
class AuthLoginRequested extends AuthEvent {}
class AuthLogoutRequested extends AuthEvent {}