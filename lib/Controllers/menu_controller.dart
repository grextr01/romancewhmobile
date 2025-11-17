import 'package:romancewhs/Models/menu.dart';

class CustomMenuController {
  List<Menu>? menus;
  bool loading;
  bool error;
  String errorMessage;

  CustomMenuController({
    this.menus,
    this.loading = false,
    this.error = false,
    this.errorMessage = '',
  });

  CustomMenuController copyWith({
    List<Menu>? menus,
    bool? loading,
    bool? error,
    String? errorMessage,
  }) {
    return CustomMenuController(
      menus: menus ?? this.menus,
      loading: loading ?? this.loading,
      error: error ?? this.error,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
