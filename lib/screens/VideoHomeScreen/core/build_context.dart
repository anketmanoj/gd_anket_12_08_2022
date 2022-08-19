import 'package:diamon_rose_app/screens/VideoHomeScreen/injection.dart';
import 'package:diamon_rose_app/screens/VideoHomeScreen/service/navigation_service.dart';
import 'package:flutter/material.dart';

/// Global BuildContext
final BuildContext context =
    getIt<NavigationService>().navigationKey.currentContext!;
