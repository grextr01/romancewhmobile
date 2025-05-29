import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'package:romancewhs/Bloc/Transactions_home_bloc/home_cubit.dart';
import 'package:romancewhs/Bloc/Login_bloc/login_cubit.dart';
import 'package:romancewhs/Bloc/Login_bloc/login_page_bloc.dart';
import 'package:romancewhs/Bloc/Trx_Details_bloc/trx_details_cubit.dart';
import 'package:romancewhs/Bloc/barcode_bloc/barcode_cubit.dart';
import 'package:romancewhs/Controllers/barcode_controller.dart';
import 'package:romancewhs/Controllers/transactions_home_controller.dart';
import 'package:romancewhs/Controllers/login_controller.dart';
import 'package:romancewhs/Controllers/trx_details_controller.dart';
import 'package:romancewhs/Models/Boxes/boxes.dart';
import 'package:romancewhs/Models/Hive/hive_user.dart';
import 'package:romancewhs/UX/global.dart';

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
  runApp(MultiProvider(
    providers: [
      BlocProvider(
          create: (context) => LoginCubit(
                LoginController(
                  loading: false,
                  error: false,
                  errorMessage: '',
                ),
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
    ],
    child: MyApp(),
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
      home: LoginPageBloc(),
      // home: HomePageBloc(
      //   legalEntities: [LegalEntity(leCode: '159', leName: 'Romance')],
      // ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
