import 'package:e_commerce/core/routing/app_go_router.dart';
import 'package:e_commerce/di.dart';
import 'package:e_commerce/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthBloc>(
      create: (_) => sl<AuthBloc>(),
      child: Builder(
        builder: (context) => MaterialApp.router(
          title: 'Shopping Clothes',
          theme: ThemeData(primarySwatch: Colors.green),
          debugShowCheckedModeBanner: false,
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {
              PointerDeviceKind.touch,
              PointerDeviceKind.mouse,
              PointerDeviceKind.trackpad,
              PointerDeviceKind.stylus,
            },
          ),
          routerConfig: AppGoRouter.create(context),
        ),
      ),
    );
  }
}
