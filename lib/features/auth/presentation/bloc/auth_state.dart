import 'package:equatable/equatable.dart';
import '../../domain/entity/auth_entity.dart';

enum AuthStatus { initial, loading, success, failure }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.initial,
    this.items = const [],
    this.message,
  });

  final AuthStatus status;
  final List<AuthEntity> items;
  final String? message;

  AuthState copyWith({
    AuthStatus? status,
    List<AuthEntity>? items,
    String? message,
  }) {
    return AuthState(
      status: status ?? this.status,
      items: items ?? this.items,
      message: message ?? this.message,
    );
  }

  @override
  List<Object?> get props => [status, items, message];
}
