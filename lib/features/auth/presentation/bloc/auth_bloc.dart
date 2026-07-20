import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecase/auth_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._useCase) : super(const AuthState()) {
    on<LoadAuth>(_onLoad);
    add(const LoadAuth());
  }

  final AuthUseCase _useCase;

  Future<void> _onLoad(
    LoadAuth event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.loading));
    final result = await _useCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: AuthStatus.failure,
          message: failure.message,
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: AuthStatus.success,
          items: data,
        ),
      ),
    );
  }
}
