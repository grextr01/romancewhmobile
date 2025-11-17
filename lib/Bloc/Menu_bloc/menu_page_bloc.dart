import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:romancewhs/Bloc/Menu_bloc/menu_cubit.dart';
import 'package:romancewhs/Controllers/menu_controller.dart';
import 'package:romancewhs/Models/Boxes/boxes.dart';
import 'package:romancewhs/Models/Hive/hive_user.dart';
import 'package:romancewhs/Models/legal_entity.dart';
import 'package:romancewhs/Models/menu.dart';
import 'package:romancewhs/Models/menu_item.dart';
import 'package:romancewhs/UI/Home/menu_page.dart';

class MenuPageBloc extends StatelessWidget {
  const MenuPageBloc({
    super.key,
    required this.menus,
    this.legalEntities = const [],
  });
  final List<Menu> menus;
  final List<LegalEntity> legalEntities;

  @override
  Widget build(BuildContext context) {
    final user = userBox.get('activeUser') as HiveUser;
    final List<MenuItem> menuItems = menus
        .map((menu) => MenuItem(
              menuId: menu.menuId,
              description: menu.description,
              route: menu.route,
              action: menu.action,
            ))
        .toList();
    return BlocProvider(
      create: (context) => MenuCubit(
        CustomMenuController(
          menus: menus,
        ),
      ),
      child: MenuPage(
        menus: menuItems,
        userName: user.username,
      ),
    );
  }
}
