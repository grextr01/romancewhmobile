import 'package:romancewhs/Models/legal_entity.dart';

class LoginController {
  bool loading = false;
  bool error = false;
  String errorMessage = '';
  String? token;
  bool obscurePassword = true;
  List<LegalEntity>? legalEntities = [];
  LoginController copyWith({
    bool? loading,
    bool? error,
    String? errorMessage,
    String? token,
    bool? obscurePassword,
    List<LegalEntity>? legalEntities,
  }) {
    return LoginController(
      loading: loading ?? this.loading,
      error: error ?? this.error,
      errorMessage: errorMessage ?? this.errorMessage,
      token: token ?? this.token,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      legalEntities: legalEntities ?? this.legalEntities,
    );
  }

  LoginController(
      {this.loading = false,
      this.error = false,
      this.errorMessage = '',
      this.obscurePassword = true,
      this.legalEntities,
      this.token});

  bool isLoggedIn() {
    return token != null;
  }
}
