import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:romancewhs/Controllers/menu_controller.dart';
import 'package:romancewhs/Models/menu.dart';

class MenuCubit extends Cubit<CustomMenuController> {
  MenuCubit(super.initialState);

  void setMenus(List<Menu> menus) {
    emit(state.copyWith(menus: menus));
  }

  void setLoading(bool loading) {
    emit(state.copyWith(loading: loading));
  }
}
