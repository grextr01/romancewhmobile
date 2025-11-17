import 'package:romancewhs/Models/legal_entity.dart';
import 'package:romancewhs/Models/menu.dart';

class LoginController {
  final bool loading;
  final bool error;
  final String errorMessage;
  final String? token;
  final bool obscurePassword;
  final List<LegalEntity>? legalEntities;
  final List<Menu>? menus;

  LoginController({
    this.loading = false,
    this.error = false,
    this.errorMessage = '',
    this.token,
    this.obscurePassword = true,
    this.legalEntities,
    this.menus,
  });

  LoginController copyWith({
    bool? loading,
    bool? error,
    String? errorMessage,
    String? token,
    bool? obscurePassword,
    List<LegalEntity>? legalEntities,
    List<Menu>? menus,
  }) {
    return LoginController(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      errorMessage: errorMessage ?? this.errorMessage,
      token: token ?? this.token,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      legalEntities: legalEntities ?? this.legalEntities,
      menus: menus ?? this.menus,
    );
  }

  bool isLoggedIn() {
    return token != null;
  }
}