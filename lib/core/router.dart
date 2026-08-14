import 'package:go_router/go_router.dart';
import '../features/onboarding/screens/splash_screen.dart';
import '../features/onboarding/screens/onboarding_screen.dart';
import '../features/dashboard/screens/main_navigation_container.dart';
import '../features/scan/screens/crop_selection_screen.dart';
import '../features/scan/screens/result_screen.dart';
import '../features/scan/screens/pest_scanner_screen.dart';
import '../features/scan/screens/weed_scanner_screen.dart';
import '../features/recommendation/screens/crop_recommendation_screen.dart';
import '../features/community/screens/community_screen.dart';
import '../features/history/screens/history_detail_screen.dart';
import 'models/scan_record.dart';
import '../features/guide/screens/crop_guide_screen.dart';
import '../features/guide/screens/crop_detail_screen.dart';
import '../features/profile/screens/login_screen.dart';
import '../features/profile/screens/signup_screen.dart';
import '../features/profile/providers/app_provider.dart';
import 'models/disease_info.dart';

class AppRouter {
  static GoRouter getRouter(AppProvider appProvider) {
    return GoRouter(
      initialLocation: '/splash',
      refreshListenable: appProvider,
      redirect: (context, state) {
        final isLoggedIn = appProvider.isLoggedIn;
        final isOnboardingCompleted = appProvider.isOnboardingCompleted;
        final path = state.uri.path;

        final goingToSplash = path == '/splash';
        final goingToOnboarding = path == '/onboarding';
        final goingToLogin = path == '/login';
        final goingToSignup = path == '/signup';

        // 1. Splash screen bypass
        if (goingToSplash) return null;

        // 2. Onboarding constraint
        if (!isOnboardingCompleted) {
          if (goingToOnboarding) return null;
          return '/onboarding';
        }

        // 3. Authentication constraint
        if (!isLoggedIn) {
          if (goingToLogin || goingToSignup) return null;
          return '/login';
        }

        // 4. Prevent accessing login/signup when already logged in
        if (isLoggedIn && (goingToLogin || goingToSignup)) {
          return '/';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/splash',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/onboarding',
          builder: (context, state) => const OnboardingScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) {
            final tabParam = state.uri.queryParameters['tab'];
            final initialTab = int.tryParse(tabParam ?? '') ?? 0;
            return MainNavigationContainer(initialTab: initialTab);
          },
        ),
        GoRoute(
          path: '/pest-scan',
          builder: (context, state) => const PestScannerScreen(),
        ),
        GoRoute(
          path: '/weed-scan',
          builder: (context, state) => const WeedScannerScreen(),
        ),
        GoRoute(
          path: '/crop-recommendation',
          builder: (context, state) => const CropRecommendationScreen(),
        ),
        GoRoute(
          path: '/community',
          builder: (context, state) => const CommunityScreen(),
        ),
        GoRoute(
          path: '/crop-selection',
          builder: (context, state) => const CropSelectionScreen(),
        ),
        GoRoute(
          path: '/result',
          builder: (context, state) => const ResultScreen(),
        ),
        GoRoute(
          path: '/history-detail',
          builder: (context, state) {
            final record = state.extra as ScanRecord;
            return HistoryDetailScreen(record: record);
          },
        ),
        GoRoute(
          path: '/crop-guide',
          builder: (context, state) => const CropGuideScreen(),
        ),
        GoRoute(
          path: '/crop-detail',
          builder: (context, state) {
            final disease = state.extra as DiseaseInfo;
            return CropDetailScreen(disease: disease);
          },
        ),
      ],
    );
  }
}
