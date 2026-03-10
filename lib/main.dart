import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:farmconnect/core/theme/app_theme.dart';
import 'package:farmconnect/core/services/supabase_service.dart';
import 'package:farmconnect/core/l10n/app_localizations.dart';
import 'package:farmconnect/features/auth/presentation/login_screen.dart';
import 'package:farmconnect/features/consumer/presentation/main_screen.dart';
import 'package:farmconnect/features/auth/data/language_provider.dart';
import 'package:farmconnect/features/farmer/presentation/home_screen.dart';
import 'package:farmconnect/features/auth/data/profile_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: SupabaseConfig.url,
    anonKey: SupabaseConfig.anonKey,
  );

  runApp(const ProviderScope(child: FarmConnectApp()));
}

class FarmConnectApp extends ConsumerStatefulWidget {
  const FarmConnectApp({super.key});

  @override
  ConsumerState<FarmConnectApp> createState() => _FarmConnectAppState();
}

class _FarmConnectAppState extends ConsumerState<FarmConnectApp> {
  @override
  Widget build(BuildContext context) {
    final locale = ref.watch(localeProvider);

    return ScreenUtilInit(
      designSize: const Size(390, 844), // iPhone 13/14 design size
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'FarmConnect',
          theme: AppTheme.lightTheme,
          debugShowCheckedModeBanner: false,
          locale: locale,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaler: TextScaler.noScaling,
              ),
              child: child!,
            );
          },
          supportedLocales: [
            const Locale('en'),
            const Locale('ta'),
            const Locale('hi'),
            const Locale('kn'),
            const Locale('te'),
            const Locale('ml'),
          ],
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: const AuthWrapper(),
        );
      },
    );
  }
}

class AuthWrapper extends ConsumerWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return authState.when(
      data: (state) {
        final user = state.session?.user;
        if (user != null) {
          final profileAsync = ref.watch(userProfileProvider);
          
          return profileAsync.when(
            data: (profile) {
              if (profile == null) return const LoginScreen();
              
              if (profile['role'] == 'farmer') {
                return const FarmerHomeScreen();
              } else {
                return const ConsumerMainScreen();
              }
            },
            loading: () => const Scaffold(
              backgroundColor: Color(0xFFF8FAF8),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF28D339)),
              ),
            ),
            error: (e, s) => const LoginScreen(),
          );
        }
        return const LoginScreen();
      },
      loading: () => const Scaffold(
        backgroundColor: Color(0xFFF8FAF8),
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFF28D339)),
        ),
      ),
      error: (e, s) => const LoginScreen(),
    );
  }
}
