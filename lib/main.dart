import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:romancewhs/Bloc/Import_bloc/import_cubit.dart';
import 'package:romancewhs/Bloc/Transactions_home_bloc/home_cubit.dart';
import 'package:romancewhs/Bloc/Login_bloc/login_cubit.dart';
import 'package:romancewhs/Bloc/Login_bloc/login_page_bloc.dart';
import 'package:romancewhs/Bloc/Trx_Details_bloc/trx_details_cubit.dart';
import 'package:romancewhs/Bloc/barcode_bloc/barcode_cubit.dart';
import 'package:romancewhs/Controllers/barcode_controller.dart';
import 'package:romancewhs/Controllers/import_controller.dart';
import 'package:romancewhs/Controllers/transactions_home_controller.dart';
import 'package:romancewhs/Controllers/login_controller.dart';
import 'package:romancewhs/Controllers/trx_details_controller.dart';
import 'package:romancewhs/Models/Boxes/boxes.dart';
import 'package:romancewhs/Models/Hive/hive_user.dart';
import 'package:romancewhs/Models/menu.dart';
import 'package:romancewhs/UX/Api.dart';
import 'package:romancewhs/UX/global.dart';
import 'package:romancewhs/UX/update.dart';
import 'package:romancewhs/Bloc/Menu_bloc/menu_page_bloc.dart';

import 'UX/LoadEnv.dart';

final mainNavigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  const env = String.fromEnvironment('ENV', defaultValue: 'Debug');
  final config = await EnvConfig.load(env);
  baseUrl = config.baseUrl;
  Hive.registerAdapter(HiveUserAdapter());
  userBox = await Hive.openBox<HiveUser>('userBox');
  checkForUpdate();

  final user = userBox.get('activeUser');
  LoginController loginController;
  if (user != null) {
    final api = API();
    final response = await api.getApiToMap(api.apiBaseUrl, '/auth/login', 'post', {
      'username': user.username,
      'password': '',
      'token': user.token,
    });

    if (response['statusCode'] == 200) {
      List menuItems = response['menus'] ?? [];
      List<Menu> menus = menuItems.map((menu) => Menu.fromJson(menu)).toList();
      loginController = LoginController(token: user.token, menus: menus);
    } else {
      loginController = LoginController();
    }
  } else {
    loginController = LoginController();
  }

  runApp(MultiProvider(
    providers: [
      BlocProvider(
          create: (context) => LoginCubit(
                loginController,
              )),
      BlocProvider(
          create: (context) => TransactionsHomeCubit(
                TransactionsHomeController(
                    selectedEntity: '', selectedType: ''),
              )),
      BlocProvider(
          create: (context) => TrxDetailsCubit(
                TrxDetailsController(headerId: 0),
              )),
      BlocProvider(
          create: (context) => BarcodeCubit(
                BarcodeController(),
              )),
      BlocProvider(
          create: (context) => ImportCubit(
                ImportController(),
              )),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Romance WHS',
      navigatorKey: mainNavigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: BlocBuilder<LoginCubit, LoginController>(
        builder: (context, loginState) {
          if (loginState.isLoggedIn()) {
            return MenuPageBloc(
              menus: loginState.menus ?? [],
            );
          } else {
            return LoginPageBloc();
          }
        },
      ),
    );
  }
}
