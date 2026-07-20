import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecase/profile_usecase.dart';
import 'profile_event.dart';
import 'profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc(this._useCase) : super(const ProfileState()) {
    on<LoadProfile>(_onLoad);
    add(const LoadProfile());
  }

  final ProfileUseCase _useCase;

  Future<void> _onLoad(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading));
    final result = await _useCase();
    result.fold(
      (failure) => emit(
        state.copyWith(
          status: ProfileStatus.failure,
          message: failure.message,
        ),
      ),
      (data) => emit(
        state.copyWith(
          status: ProfileStatus.success,
          items: data,
        ),
      ),
    );
  }
}
