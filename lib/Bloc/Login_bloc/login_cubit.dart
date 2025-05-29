import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:romancewhs/Bloc/Transactions_home_bloc/home_page_bloc.dart';
import 'package:romancewhs/Controllers/login_controller.dart';
import 'package:romancewhs/Models/Boxes/boxes.dart';
import 'package:romancewhs/Models/Hive/hive_user.dart';
import 'package:romancewhs/Models/legal_entity.dart';
import 'package:romancewhs/UX/Api.dart';
import '../../main.dart';

class LoginCubit extends Cubit<LoginController> {
  LoginCubit(super.initialState);

  final _api = API();
  Future<void> login(String username, String password) async {
    emit(state.copyWith(loading: true, error: false, errorMessage: ''));
    var response =
        await _api.getApiToMap(_api.apiBaseUrl, '/auth/login', 'post', {
      'username': username,
      'password': password,
    });
    state.loading = false;
    emit(state.copyWith(loading: false));
    if (response['statusCode'] == 200) {
      state.token = response['token'];
      List entities = response['legalEntities'];
      state.legalEntities = entities
          .map((entity) =>
              LegalEntity(leCode: entity['leCode'], leName: entity['leName']))
          .toList();
      var hiveUser = HiveUser(
          token: response['token'],
          firstName: response['firstName'],
          lastName: response['lastName'],
          userId: response['userID'].toString());
      userBox.put('activeUser', hiveUser);
      emit(state.copyWith(
          token: response['token'], legalEntities: state.legalEntities));
      mainNavigatorKey.currentState?.pushAndRemoveUntil(
          MaterialPageRoute(
              builder: (context) => TransactionsHomePageBloc(
                    legalEntities: state.legalEntities!,
                  )),
          (route) => false);
    } else {
      state.error = true;
      state.errorMessage = response['message'];
      emit(state.copyWith(error: true, errorMessage: state.errorMessage));
    }
    // if (state.isLoggedIn()) {
    //   // Save the token to the user box
    //   userBox.put('activeUser', state.token);
    // }
  }

  void logout() {
    emit(state);
  }

  void togglePasswordVisibility() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  bool isLoggedIn() {
    return state.isLoggedIn();
  }

  void register(String username, String password) {
    emit(state);
  }
}
