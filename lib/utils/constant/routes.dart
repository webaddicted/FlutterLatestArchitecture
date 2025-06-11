import 'package:get/route_manager.dart';
import 'package:pingmexx/utils/constant/routers_const.dart';
import 'package:pingmexx/view/home_page/home_page.dart';
import 'package:pingmexx/view/splash/onboarding_page.dart';
import 'package:pingmexx/view/splash/splash_page.dart';
import 'package:pingmexx/view/chat/chat_list_screen.dart';
import 'package:pingmexx/view/chat/friend_requests_screen.dart';
import 'package:pingmexx/view/chat/all_user_screen.dart';
import 'package:pingmexx/view/auth/login_screen.dart';
import 'package:pingmexx/view/auth/register_screen.dart';
import 'package:pingmexx/view/auth/welcome_screen.dart';

List<GetPage> routes() => [
      GetPage(name: RoutersConst.initialRoute, page: () => const SplashPage()),
      GetPage(name: RoutersConst.onboardPage, page: () => OnboardingPage()),
      GetPage(name: RoutersConst.welcome, page: () => const WelcomeScreen()),
      GetPage(name: RoutersConst.home, page: () => HomePage()),
      GetPage(name: RoutersConst.chatList, page: () => const ChatListScreen()),
      GetPage(name: RoutersConst.friendRequests, page: () => const FriendRequestsScreen()),
      GetPage(name: RoutersConst.allUser, page: () => const AllUsersScreen()),
      GetPage(name: RoutersConst.login, page: () => const LoginScreen()),
      GetPage(name: RoutersConst.register, page: () => const RegisterScreen()),
    ];
