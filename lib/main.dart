import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'core/di/injection.dart';
import 'core/navigation/app_router.dart';
import 'core/navigation/navigation_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';
import 'features/authentication/presentation/bloc/auth_bloc.dart';
import 'features/authentication/presentation/bloc/auth_event.dart';
import 'features/authentication/presentation/bloc/auth_state.dart';
import 'features/authentication/presentation/pages/login_page.dart';
import 'features/authentication/presentation/pages/dashboard_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection
  await configureDependencies();

  // Initialize theme provider
  final themeProvider = ThemeProvider();
  await themeProvider.initialize(GetIt.instance<SharedPreferences>());

  runApp(MyApp(themeProvider: themeProvider));
}

class MyApp extends StatelessWidget {
  final ThemeProvider themeProvider;

  const MyApp({super.key, required this.themeProvider});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) =>
              GetIt.instance<AuthBloc>()..add(const AuthCheckRequested()),
        ),
      ],
      child: AnimatedBuilder(
        animation: themeProvider,
        builder: (context, child) {
          return ScreenUtilInit(
            designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) {
              return MaterialApp(
                title: 'School Daily Fee App',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeProvider.themeMode,
                navigatorKey: NavigationService.navigatorKey,
                onGenerateRoute: AppRouter.generateRoute,
                home: BlocListener<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthOTPSent) {
                      Navigator.pushNamed(
                        context,
                        AppRouter.otpVerification,
                        arguments: {'phoneNumber': state.phoneNumber},
                      );
                    }
                  },
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state is AuthLoading) {
                        return const Scaffold(
                          body: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      } else if (state is AuthAuthenticated) {
                        return const DashboardPage();
                      } else {
                        return const LoginPage();
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
