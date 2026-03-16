import 'package:get/get.dart';
import '../bindings/laundry_binding.dart';
import '../controller/order_history_controller.dart';
import '../modules/home/home_binding.dart';
import '../modules/home/home_view.dart';
import '../modules/login/login_binding.dart';
import '../modules/login/login_view.dart';
import '../modules/recover_acc/forgot_pass.dart';
import '../modules/signup/signup_binding.dart';
import '../modules/signup/signup_view.dart';
import '../modules/schedule/schedule_binding.dart';
import '../modules/schedule/schedule_view.dart';
import '../screens/order_history_screen.dart';
import '../widgets/laundry_how_it_works.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = Routes.HOME;

  static final routes = [
    GetPage(name: Routes.HOME, page: () => HomeView(), binding: HomeBinding(),),
    GetPage(name: Routes.LOGIN, page: () => LoginView(), binding: LoginBinding(),),
    GetPage(name: Routes.SIGNUP, page: () => SignupView(), binding: SignupBinding(),),
    GetPage(name: Routes.SCHEDULE, page: () => ScheduleView(), binding: ScheduleBinding(),),
    GetPage(name: '/forgot-password', page: () => ForgetPasswordScreen()),
  GetPage(name: Routes.LAUNDRY,page: () => const LaundryHowItWorksPage(),binding: LaundryBinding(),                 // injects OrderSummaryController
  ),
    GetPage(name: Routes.SCHEDULE, page: () => const ScheduleView(), binding: ScheduleBinding(),),
    GetPage(
      name: Routes.ORDER_HISTORY,
      page: () => const OrderHistoryScreen(),
      binding: BindingsBuilder(() {
        Get.lazyPut<OrderHistoryController>(() => OrderHistoryController());
      }),
    ),
  ];
}
