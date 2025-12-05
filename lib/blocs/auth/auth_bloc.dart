import 'package:flutter_bloc/flutter_bloc.dart';
import '../../repositories/auth_repository.dart';
import '../../models/user_model.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitialState()) {
    on<CheckAuthStatusEvent>((event, emit) async {
      try {
        final currentUser = authRepository.currentUser;
        if (currentUser != null) {
          emit(AuthenticatedState(
            user: UserModel.fromFirebaseUser(currentUser),
          ));
        } else {
          emit(UnauthenticatedState());
        }
      } catch (e) {
        emit(UnauthenticatedState());
      }
    });

    on<SignInEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        final user = await authRepository.signInWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(AuthenticatedState(user: user));
      } catch (e) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        emit(AuthErrorState(errorMessage: errorMessage));
      }
    });

    on<SignUpEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        final user = await authRepository.signUpWithEmailAndPassword(
          email: event.email,
          password: event.password,
        );
        emit(AuthenticatedState(user: user));
      } catch (e) {
        final errorMessage = e.toString().replaceAll('Exception: ', '');
        emit(AuthErrorState(errorMessage: errorMessage));
      }
    });

    on<SignOutEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        await authRepository.signOut();
        emit(UnauthenticatedState());
      } catch (e) {
        emit(AuthErrorState(errorMessage: 'Failed to sign out'));
        emit(UnauthenticatedState());
      }
    });
  }
}
