import 'package:flutter/widgets.dart';
import 'package:home_rs/app/ui/pages/home/home_page.dart';
import 'package:home_rs/app/ui/pages/request_permission/request_permission_page.dart';
import 'package:home_rs/app/ui/pages/splash/splash_page.dart';
import 'package:home_rs/app/ui/routes/routes.dart';

Map<String, Widget Function(BuildContext)> appRoutes(){
  return{
    Routes.SPLASH:(_)=>const SplashPage(),
    Routes.PERMISSION:(_)=>const RequestPermissionPage(),
    Routes.HOME:(_)=>const HomePage(),
  };
}