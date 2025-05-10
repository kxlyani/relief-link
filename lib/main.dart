import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
// import 'package:get/get_core/src/get_main.dart';
// import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:relieflink/admin/adminpage.dart';
import 'package:relieflink/login/splash_screen.dart';
import 'package:relieflink/models/LocalString.dart';
import 'package:relieflink/models/database_functions.dart';
import 'package:relieflink/models/notification.dart';
import 'package:relieflink/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  NotiServcie().initNotification();
  await loadAdminStatus();
  await loadLoginStatus();
  await loadIDStatus();
  await loadisNGOStatus();
  await loadLangStatus(); // Ensure language is loaded before the app runs.

  // Apply saved language
  Get.updateLocale(Locale(getLocaleCode(language))); 

  DisasterDataFetcher().fetchAndStoreDisasters();

  // Await OneSignal initialization
  OneSignal.initialize('419ea6c0-3874-4aa5-9e7c-04713d0d063f');
  await OneSignal.Notifications.requestPermission(true);

  // Add observer AFTER ensuring OneSignal is initialized
  OneSignal.User.addObserver((event) {
    print("OneSignal Player ID: $event");
  });

  runApp(const CrisisAssistApp());
}

String getLocaleCode(String lang) {
  switch (lang) {
    case "Hindi":
      return "hi_IN";
    case "Marathi":
      return "mr_IN";
    case "Tamil":
      return "ta_IN";
    case "Kannada":
      return "kn_IN";
    case "German":
      return "de_DE";
    case "French":
      return "fr_FR";
    case "Japanese":
      return "ja_JP";
    case "Chinese":
      return "zh_CN";
    case "Korean":
      return "ko_KR";
    default:
      return "en_US";
  }
}

class CrisisAssistApp extends StatelessWidget {
  const CrisisAssistApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );

    return GetMaterialApp(
      translations: Localstring(),
      locale: Locale('en', 'US'),
      title: 'Crisis Assist',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: const Color(0xFF2D7DD2),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF2D7DD2),
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: const Color(0xFF2D7DD2),
            padding: const EdgeInsets.symmetric(
              vertical: 12.0,
              horizontal: 24.0,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
          ),
        ),
      ),
      home: setInitialScreen(),
      // home: NotiButton(),
    );
  }
}

Widget setInitialScreen() {
  print("Login Status: $logStatus");
  print("Admin Status: $adminLog");

  if (adminLog) {
    return AdminPage(adminType: universalId);
  }
  return const SplashScreen();
}
