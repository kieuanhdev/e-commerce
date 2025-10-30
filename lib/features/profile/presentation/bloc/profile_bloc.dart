import 'package:flutter_bloc/flutter_bloc.dart';
import 'profile_event.dart';
import 'profile_state.dart';
import 'package:e_commerce/features/auth/domain/repository/auth_repository.dart'; // Dùng chung repo user
import 'dart:async';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final IAuthRepository authRepository;
  StreamSubscription? _userSub;
  ProfileBloc({required this.authRepository}) : super(ProfileInitial()) {
    on<LoadProfile>((event, emit) async {
      emit(ProfileLoading());
      await emit.forEach(
        authRepository.authStateChanges,
        onData: (user) {
          if (user == null) {
            return const ProfileError('Bạn chưa đăng nhập!');
          } else {
            return ProfileLoaded(user);
          }
        },
      );
    });
    // on<UpdateProfile> ...
  }

  @override
  Future<void> close() {
    _userSub?.cancel();
    return super.close();
  }
}
