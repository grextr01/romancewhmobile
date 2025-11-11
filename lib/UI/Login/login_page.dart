import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:romancewhs/Bloc/Login_bloc/login_cubit.dart';
import 'package:romancewhs/Controllers/login_controller.dart';
import 'package:romancewhs/Models/Boxes/boxes.dart';
import 'package:romancewhs/UX/Theme.dart';
import '../Components.dart/custom_button.dart';
import '../Components.dart/custom_textfield.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    setUserName();
    return Scaffold(
        appBar: AppBar(
          elevation: 1,
          backgroundColor: Colors.white,
          shadowColor: const Color.fromRGBO(206, 206, 206, 100),
          title: const Text(
            'Sign In',
            style: TextStyle(
                fontSize: 19, fontWeight: FontWeight.w700, color: primaryColor),
          ),
          centerTitle: true,
        ),
        body: BlocBuilder<LoginCubit, LoginController>(
          builder: (context, state) => Container(
            color: const Color.fromARGB(220, 248, 248, 248),
            child: Column(
              children: [
                Expanded(
                    flex: 1,
                    child: Container(
                      // decoration: const BoxDecoration(
                      //     image: DecorationImage(
                      //         image: AssetImage('assets/LoginBack.png'))),
                      height: double.maxFinite,
                    )),
                Expanded(
                    flex: 3,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.only(left: 20),
                          alignment: Alignment.centerLeft,
                          child: const Text(
                            'Welcome Back !',
                            style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 24,
                                color: secondaryColor),
                          ),
                        ),
                        Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20),
                          child: const Text(
                            'Sign in to continue',
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 18,
                                color: primaryColor),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 20, horizontal: 20),
                            margin: const EdgeInsets.only(top: 20),
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25)),
                            child: AutofillGroup(
                              child: Column(
                                mainAxisSize: MainAxisSize.max,
                                children: [
                                  CustomTextField(
                                    controller: _emailController,
                                    focusNode: _emailFocusNode,
                                    hintText: 'Username..',
                                    autofillHints: const [AutofillHints.email],
                                    prefixIcon: const Icon(
                                      Icons.email,
                                      color: secondaryColor,
                                    ),
                                  ),
                                  const Padding(
                                      padding: EdgeInsets.only(top: 12)),
                                  CustomTextField(
                                    controller: _passwordController,
                                    focusNode: _passwordFocusNode,
                                    autofillHints: const [
                                      AutofillHints.password
                                    ],
                                    hintText: 'Password..',
                                    obscureText: state.obscurePassword,
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        context
                                            .read<LoginCubit>()
                                            .togglePasswordVisibility();
                                        // _passwordFocusNode.requestFocus();
                                      },
                                      icon: Icon(
                                        state.obscurePassword
                                            ? Icons.visibility_off
                                            : Icons.visibility,
                                        color: state.obscurePassword
                                            ? Colors.grey
                                            : Colors.blue,
                                      ),
                                    ),
                                    prefixIcon: const Icon(
                                      Icons.lock,
                                      color: secondaryColor,
                                    ),
                                  ),
                                  Visibility(
                                      visible: state.errorMessage != '',
                                      child: Container(
                                        margin: const EdgeInsets.only(
                                            right: 10, top: 6),
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          state.errorMessage,
                                          style: const TextStyle(
                                              color: erroColor, fontSize: 14),
                                        ),
                                      )),
                                  const Padding(
                                      padding: EdgeInsets.only(top: 12)),
                                  CustomMainButton(
                                      text: 'Sign In',
                                      backgroundColor: secondaryColor,
                                      height: 53,
                                      textColor: Colors.white,
                                      loading: state.loading,
                                      onPressed: () async {
                                        await context.read<LoginCubit>().login(
                                            _emailController.text,
                                            _passwordController.text);
                                      }),
                                  const Padding(
                                      padding: EdgeInsets.only(top: 12)),
                                ],
                              ),
                            ),
                          ),
                        )
                      ],
                    ))
              ],
            ),
          ),
        ));
  }

  void setUserName() {
    var user = userBox.get('activeUser');
    if (user == null) {
      return;
    }
    _emailController.text = user.username;
  }
}
