import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'controller/products_controller.dart';
import 'controller/profile_controller.dart';
import 'data/service/safe_snackbar.dart';
import 'firebase_options.dart';
import 'modules/schedule/schedule_view.dart';
import 'theme/app_theme.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  if (kDebugMode) {
    debugPrint('[Firebase] Default app initialized: ${Firebase.apps.map((a) => a.name).join(", ")}');
  }

  // Initialize Stripe
  // Stripe.publishableKey = "pk_live_51QswX3FSsSDfUKXIQTZK5gnaXKza6kJqL8uN6b1S5Q4QvWD6CioWBFNdBGskXbB5jEO2p52o2Rvfryotbah29rGT00ycgSwYPf";
  Stripe.publishableKey = "pk_test_51PI6AGJ7hx1gScqWJKV3RDwIS2yqfr8aNSZCPE5Z5k7GWtpLrIgxqzIS5cNSK7U5RX89L0WerQY1SwHO8Llu2EX50014wZV6Kj";
  await Stripe.instance.applySettings();
  
  Get.put(ProductsController(), permanent: true);
  Get.put(ProfileController(), permanent: true);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const SampanApp());
}

class SampanApp extends StatelessWidget {
  const SampanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      useInheritedMediaQuery: true,
      builder: (context, child) =>  GetMaterialApp(
        debugShowCheckedModeBanner: false, // 👈 here too
        title: 'Sampan Laundry',
        theme: AppTheme.lightTheme,
        // Global ScaffoldMessenger — used by SafeSnackbar so payment success /
        // failure messages survive Get.offAll() route transitions.
        scaffoldMessengerKey: rootScaffoldMessengerKey,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          // ✅ Handle dynamic route arguments here
          if (settings.name == '/schedule') {
            return MaterialPageRoute(
              builder: (context) => const ScheduleView(),
            );
          }

          // ✅ Handle other static routes
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(builder: (context) => const HomeScreen());
            default:
              return MaterialPageRoute(builder: (context) => const HomeScreen());
          }
        },
      ),
    );
  }
}




