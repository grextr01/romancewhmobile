import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:romancewhs/Bloc/Login_bloc/login_page_bloc.dart';
import 'package:romancewhs/Bloc/Menu_bloc/menu_page_bloc.dart';
import 'package:romancewhs/Bloc/Transactions_home_bloc/home_page_bloc.dart';
import 'package:romancewhs/Controllers/login_controller.dart';
import 'package:romancewhs/Models/Boxes/boxes.dart';
import 'package:romancewhs/Models/Hive/hive_user.dart';
import 'package:romancewhs/Models/legal_entity.dart';
import 'package:romancewhs/Models/menu.dart';
import 'package:romancewhs/UX/Api.dart';
import '../../main.dart';

class LoginCubit extends Cubit<LoginController> {
  LoginCubit(super.initialState);

  final _api = API();
void togglePasswordVisibility() {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }
  Future<void> login(String username, String password) async {
    // Start loading
    emit(state.copyWith(loading: true, error: false, errorMessage: ''));

    var response = await _api.getApiToMap(_api.apiBaseUrl, '/auth/login', 'post', {
      'username': username,
      'password': password,
    });

    if (response['statusCode'] == 200) {
      // Handle legal entities
      List entities = response['legalEntities'] ?? [];
      List<LegalEntity> legalEntities = entities
          .map((entity) => LegalEntity(
              leCode: entity['leCode'] ?? '',
              leName: entity['leName'] ?? 'Unknown'))
          .toList();

      // ✅ Handle menus from response
      List menuItems = response['menus'] ?? [];
      List<Menu> menus = menuItems.map((menu) => Menu.fromJson(menu)).toList();

      // Save user info
      var hiveUser = HiveUser(
          token: response['token'],
          firstName: response['firstName'] ?? '',
          lastName: response['lastName'] ?? '',
          userId: response['userID'].toString(),
          username: username);

      userBox.put('activeUser', hiveUser);

      // Emit success
      emit(state.copyWith(
          loading: false,
          token: response['token'],
          legalEntities: legalEntities,
          menus: menus, // Save menus in state
          error: false));

      // ✅ NAVIGATION LOGIC:
      _navigateBasedOnMenus(menus, legalEntities, response['firstName'] ?? username);
          
    } else {
      // Handle login failure
      emit(state.copyWith(
          error: true,
          errorMessage: response['message'] ?? 'Login failed. Please try again.',
          loading: false));
    }
  }

  void _navigateBasedOnMenus(List<Menu> menus, List<LegalEntity> legalEntities, String userName) {
    if (menus.length == 1) {
      final singleMenu = menus[0];
      if (singleMenu.route != null && singleMenu.route!.isNotEmpty) {
        _navigateToRoute(singleMenu.route!, legalEntities);
      } else {
        _handleMenuAction(singleMenu.action);
      }
    } else if (menus.length > 1) {
      mainNavigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => MenuPageBloc(
            menus: menus,
          ),
        ),
        (route) => false,
      );
    } else if (legalEntities.isNotEmpty) {
      mainNavigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => TransactionsHomePageBloc(
            legalEntities: legalEntities,
          ),
        ),
        (route) => false,
      );
    } else {
      mainNavigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(
              title: const Text('Home'),
              backgroundColor: const Color.fromRGBO(37, 91, 181, 1),
            ),
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No Access Available',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Your account does not have access to any features.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 30),
                  ElevatedButton.icon(
                    onPressed: () {
                      logout();
                    },
                    icon: const Icon(Icons.logout),
                    label: const Text('Logout'),
                  )
                ],
              ),
            ),
          ),
        ),
        (route) => false,
      );
    }
  }

  void _navigateToRoute(String route, List<LegalEntity> legalEntities) {
    Widget page;
    switch (route) {
      case '/home':
        page = TransactionsHomePageBloc(
          legalEntities: legalEntities,
        );
        break;
      case '/cycleCount':
        page = Scaffold(
          appBar: AppBar(title: const Text('Cycle Count')),
          body: const Center(child: Text('Cycle Count Page')),
        );
        break;
      case '/barcode':
        page = Scaffold(
          appBar: AppBar(title: const Text('Barcode Scanner')),
          body: const Center(child: Text('Barcode Scanner Page')),
        );
        break;
      default:
        page = Scaffold(
          appBar: AppBar(title: const Text('Unknown Route')),
          body: Center(child: Text('Unknown route: $route')),
        );
    }
    mainNavigatorKey.currentState?.pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => page),
        (route) => false,
      );
  }

  void _handleMenuAction(String action) {
    // Handle menu actions here
  }

  Future<void> logout() async {
    await userBox.delete('activeUser');
    emit(LoginController()); // Reset state
    mainNavigatorKey.currentState?.pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginPageBloc()),
      (route) => false,
    );
  }

  void register(String username, String password) {
    // Implement registration logic here
    emit(state);
  }
}
