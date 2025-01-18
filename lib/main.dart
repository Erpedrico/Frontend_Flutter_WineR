import 'package:flutter/material.dart';
import 'package:flutter_application_1/providers/perfilProvider.dart';
import 'package:flutter_application_1/conciencia_digital/timerService.dart';
import 'package:flutter_application_1/screen/settings.dart';
import 'package:flutter_application_1/screen/support.dart';
import 'package:flutter_application_1/screen/updateProfile.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import 'package:flutter_application_1/screen/initPage.dart';
import 'package:flutter_application_1/screen/screenWineLover/chat.dart';
import 'package:flutter_application_1/screen/screenWineLover/allChat.dart';
import 'package:flutter_application_1/screen/screenWineLover/allRooms.dart';
import 'package:flutter_application_1/screen/screenWineLover/map.dart';
import 'package:flutter_application_1/screen/screenWineLover/perfilExternalUsuario.dart';
import 'package:flutter_application_1/screen/screenWineLover/logInWL.dart';
import 'package:flutter_application_1/screen/screenWineLover/register.dart';
import 'package:flutter_application_1/widgets/bottomNavigationBarWL.dart';
import 'package:flutter_application_1/widgets/tabBarScaffold.dart';
import 'package:flutter_application_1/screen/screenWineMaker/logInWM.dart';
import 'package:flutter_application_1/screen/screenWineMaker/registerWM.dart';
import 'package:flutter_application_1/widgets/bottomNavigationBarWM.dart';
import 'package:flutter_application_1/widgets/tabBarScaffoldWM.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PerfilProvider()),
        ChangeNotifierProvider(create: (context) => TimerService()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      getPages: [
        GetPage(
          name: '/',
          page: () => InitPage(),
        ),
        // Ruta de inicio de sesión
        GetPage(
          name: '/login',
          page: () => LogInPage(),
        ),
        // Ruta de registro
        GetPage(
          name: '/register',
          page: () => RegisterPage(),
        ),
        GetPage(
          name: '/lyr',
          page: () => TabBarScaffold(),
        ),
        GetPage(
          name: '/lyrWM',
          page: () => TabBarScaffoldWM(),
        ),
        // Ruta para TabBarScaffold
        GetPage(
          name: '/main',
          page: () => BottomNavScaffold(),
        ),
         GetPage(
          name: '/loginWM',
          page: () => LogInPageWM(),
        ),
        // Ruta de registro
        GetPage(
          name: '/registerWM',
          page: () => RegisterPageWM(),
        ),
        // Ruta para TabBarScaffold
        GetPage(
          name: '/mainWM',
          page: () => BottomNavScaffoldWM(),
        ),
        //Ruta para perfil de user
        GetPage(
          name: '/perfilExternalUsuario',
          page: () => PerfilExternalPage(),
        ),
        // Ruta para mapa
        GetPage(
          name: '/mapa',
          page: () => MapPage(),
        ),
        GetPage(
          name: '/chat',
          page: () => chatPage(),
        ),
        GetPage(
          name: '/chatPage',
          page: () => chatPage2(),
        ),
        GetPage(
          name: '/roomPage',
          page: () => RoomPage(),
        ),
        GetPage(
          name: '/settings',
          page: () => SettingsPage(),
        ),
        GetPage(
          name: '/support',
          page: () => SupportPage(),
        ),
        GetPage(
          name: '/updateProfile',
          page: () => UpdateProfilePage(),
        ),
      ],
    );
  }
}


