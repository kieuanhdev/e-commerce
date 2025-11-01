import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:e_commerce/features/admin/domain/usecase/create_user_by_admin.dart';
import 'package:e_commerce/features/admin/domain/usecase/get_all_users.dart';
import 'package:e_commerce/features/admin/domain/usecase/update_user_status.dart';
import 'package:e_commerce/features/auth/domain/entities/app_user.dart';
import 'package:equatable/equatable.dart';

part 'customers_event.dart';
part 'customers_state.dart';

class CustomersBloc extends Bloc<CustomersEvent, CustomersState> {
  final GetAllUsersUseCase _getAllUsersUseCase;
  final UpdateUserStatusUseCase _updateUserStatusUseCase;
  final CreateUserByAdminUseCase _createUserByAdminUseCase;
  StreamSubscription<List<AppUser>>? _usersSubscription;

  CustomersBloc({
    required GetAllUsersUseCase getAllUsersUseCase,
    required UpdateUserStatusUseCase updateUserStatusUseCase,
    required CreateUserByAdminUseCase createUserByAdminUseCase,
  })  : _getAllUsersUseCase = getAllUsersUseCase,
        _updateUserStatusUseCase = updateUserStatusUseCase,
        _createUserByAdminUseCase = createUserByAdminUseCase,
        super(CustomersInitial()) {
    on<LoadUsers>(_onLoadUsers);
    on<UsersUpdated>(_onUsersUpdated);
    on<ToggleUserStatus>(_onToggleUserStatus);
    on<CreateUser>(_onCreateUser);
  }

  void _onLoadUsers(LoadUsers event, Emitter<CustomersState> emit) {
    _usersSubscription?.cancel();
    _usersSubscription = _getAllUsersUseCase().listen(
      (users) {
        add(UsersUpdated(users));
      },
      onError: (error) {
        emit(CustomersError(error.toString()));
      },
    );
  }

  void _onUsersUpdated(UsersUpdated event, Emitter<CustomersState> emit) {
    emit(CustomersLoaded(event.users));
  }

  Future<void> _onToggleUserStatus(
    ToggleUserStatus event,
    Emitter<CustomersState> emit,
  ) async {
    if (state is CustomersLoaded) {
      final currentState = state as CustomersLoaded;
      final user = currentState.users.firstWhere((u) => u.id == event.userId);
      
      emit(CustomersLoading(currentState.users));
      
      final result = await _updateUserStatusUseCase(
        event.userId,
        !user.isDisabled,
      );
      
      result.fold(
        (failure) => emit(CustomersError(failure.message)),
        (_) {
          // State sẽ được cập nhật tự động qua stream
        },
      );
    }
  }

  Future<void> _onCreateUser(
    CreateUser event,
    Emitter<CustomersState> emit,
  ) async {
    if (state is CustomersLoaded) {
      final currentState = state as CustomersLoaded;
      emit(CustomersLoading(currentState.users));
    } else {
      emit(CustomersLoading([]));
    }

    final result = await _createUserByAdminUseCase(
      email: event.email,
      password: event.password,
      displayName: event.displayName,
      phoneNumber: event.phoneNumber,
      role: event.role,
    );

    result.fold(
      (failure) {
        emit(CustomersError(failure.message));
        // Reload users
        add(const LoadUsers());
      },
      (_) {
        // User sẽ được thêm vào list tự động qua stream
      },
    );
  }

  @override
  Future<void> close() {
    _usersSubscription?.cancel();
    return super.close();
  }
}

