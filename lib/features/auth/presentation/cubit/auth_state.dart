part of 'auth_cubit.dart';

abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthUnauthenticated extends AuthState {}

/// Phone OTP was sent successfully → navigate to OTP screen
class OtpSent extends AuthState {
  final String verificationId;
  final String phoneNumber;
  const OtpSent(this.verificationId, this.phoneNumber);
  @override
  List<Object?> get props => [verificationId, phoneNumber];
}

/// Authenticated via Firebase but citizen profile not created yet
class AuthNeedsRegistration extends AuthState {
  final String uid;
  final String phone;
  const AuthNeedsRegistration({required this.uid, required this.phone});
  @override
  List<Object?> get props => [uid, phone];
}

/// Fully authenticated — both citizen and paramedic land here
class AuthAuthenticated extends AuthState {
  final AppUser user;
  const AuthAuthenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class AuthError extends AuthState {
  final String message;
  const AuthError(this.message);
  @override
  List<Object?> get props => [message];
}
