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
import 'package:romancewhs/UX/cacheHelper.dart';
import 'dart:convert';
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

    try {
      // Try to login with API first
      var response = await _api.getApiToMap(_api.apiBaseUrl, '/auth/login', 'post', {
        'username': username,
        'password': password,
      });

      // Cast response to Map<String, dynamic>
      final Map<String, dynamic> apiResponse = Map<String, dynamic>.from(response);

      if (apiResponse['statusCode'] == 200) {
        // Handle legal entities
        List entities = apiResponse['legalEntities'] ?? [];
        List<LegalEntity> legalEntities = entities
            .map((entity) => LegalEntity(
                leCode: (entity['leCode'] ?? '').toString(),
                leName: (entity['leName'] ?? 'Unknown').toString()))
            .toList();

        // Handle menus from response
        List menuItems = apiResponse['menus'] ?? [];
        List<Menu> menus = menuItems.map((menu) => Menu.fromJson(menu as Map<String, dynamic>)).toList();

        // Save user info to Hive
        var hiveUser = HiveUser(
            token: apiResponse['token']?.toString() ?? '',
            firstName: apiResponse['firstName']?.toString() ?? '',
            lastName: apiResponse['lastName']?.toString() ?? '',
            userId: apiResponse['userID']?.toString() ?? '',
            username: username);

        userBox.put('activeUser', hiveUser);

        // Cache credentials and data for offline login
        await _cacheLoginData(username, password, apiResponse, legalEntities, menus);

        // Emit success
        emit(state.copyWith(
            loading: false,
            token: apiResponse['token']?.toString(),
            legalEntities: legalEntities,
            menus: menus,
            error: false));

        // NAVIGATION LOGIC
        _navigateBasedOnMenus(menus, legalEntities, apiResponse['firstName']?.toString() ?? username);
           
      } else {
        // API failed - try offline login
        await _tryOfflineLogin(username, password);
      }
    } catch (e) {
      // Network error - try offline login
      print('API Error: ${e.toString()}');
      await _tryOfflineLogin(username, password);
    }
  }

  /// Cache login data for offline access
  Future<void> _cacheLoginData(
    String username,
    String password,
    Map<String, dynamic> response,
    List<LegalEntity> legalEntities,
    List<Menu> menus,
  ) async {
    try {
      await CacheData.setData('cached_username', username);
      await CacheData.setData('cached_password', password);
      await CacheData.setData('cached_token', response['token']?.toString() ?? '');
      await CacheData.setData('cached_firstName', response['firstName']?.toString() ?? '');
      await CacheData.setData('cached_lastName', response['lastName']?.toString() ?? '');
      await CacheData.setData('cached_userID', response['userID']?.toString() ?? '');
     
      // Cache menus as JSON string
      String menusJson = jsonEncode(menus.map((m) => {
        'menuId': m.menuId,
        'description': m.description,
        'route': m.route,
        'action': m.action,
      }).toList());
      await CacheData.setData('cached_menus', menusJson);
     
      // Cache legal entities as JSON string
      String entitiesJson = jsonEncode(legalEntities.map((e) => {
        'leCode': e.leCode,
        'leName': e.leName,
      }).toList());
      await CacheData.setData('cached_legalEntities', entitiesJson);
     
      print('✓ Login data cached successfully');
    } catch (e) {
      print('✗ Error caching login data: $e');
    }
  }

  /// Attempt offline login using cached credentials
  Future<void> _tryOfflineLogin(String username, String password) async {
    try {
      final cachedUsername = CacheData.getData('cached_username');
      final cachedPassword = CacheData.getData('cached_password');
      final cachedToken = CacheData.getData('cached_token');
      final cachedFirstName = CacheData.getData('cached_firstName') ?? '';
      final cachedLastName = CacheData.getData('cached_lastName') ?? '';
      final cachedUserID = CacheData.getData('cached_userID') ?? '';

      // Verify credentials match
      if (cachedUsername != null &&
          cachedPassword != null &&
          cachedUsername == username &&
          cachedPassword == password &&
          cachedToken != null) {
       
        // Restore cached user data
        var hiveUser = HiveUser(
          token: cachedToken.toString(),
          firstName: cachedFirstName.toString(),
          lastName: cachedLastName.toString(),
          userId: cachedUserID.toString(),
          username: username,
        );
       
        userBox.put('activeUser', hiveUser);

        // Retrieve cached menus and entities
        String? menusJson = CacheData.getData('cached_menus');
        String? entitiesJson = CacheData.getData('cached_legalEntities');
       
        List<Menu> menus = [];
        List<LegalEntity> legalEntities = [];
       
        if (menusJson != null) {
          try {
            List<dynamic> decoded = jsonDecode(menusJson.toString());
            menus = decoded.map((item) => Menu(
              menuId: item['menuId'] as int,
              description: item['description'] as String,
              route: item['route'] as String?,
              action: item['action'] as String,
            )).toList();
          } catch (e) {
            print('Error decoding menus: $e');
          }
        }
       
        if (entitiesJson != null) {
          try {
            List<dynamic> decoded = jsonDecode(entitiesJson.toString());
            legalEntities = decoded.map((item) => LegalEntity(
              leCode: item['leCode'] as String,
              leName: item['leName'] as String,
            )).toList();
          } catch (e) {
            print('Error decoding entities: $e');
          }
        }

        // Emit success with offline indicator
        emit(state.copyWith(
          loading: false,
          token: cachedToken.toString(),
          legalEntities: legalEntities,
          menus: menus,
          error: false,
          errorMessage: 'Logged in offline mode',
        ));

        // Navigate
        _navigateBasedOnMenus(menus, legalEntities, cachedFirstName.toString() ?? username);
      } else {
        // Credentials don't match or no cached data
        emit(state.copyWith(
          error: true,
          errorMessage: 'Login failed. No internet connection and no cached credentials found.',
          loading: false,
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        error: true,
        errorMessage: 'Login failed: ${e.toString()}',
        loading: false,
      ));
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
    // Clear active user from Hive
    await userBox.delete('activeUser');
   
    // Clear cache (optional - you might want to keep it for offline login)
    // await CacheData.deleteItem('cached_username');
    // await CacheData.deleteItem('cached_password');
    // etc.
   
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