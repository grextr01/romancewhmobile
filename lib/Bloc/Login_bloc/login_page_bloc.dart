import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:romancewhs/Bloc/Login_bloc/login_cubit.dart';
import 'package:romancewhs/Controllers/login_controller.dart';
import 'package:romancewhs/UI/Login/login_page.dart';

class LoginPageBloc extends StatelessWidget {
  const LoginPageBloc({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LoginCubit(
        LoginController(
          loading: false,
          error: false,
          errorMessage: '',
        ),
      ),
      child: LoginPage(),
    );
  }
}
