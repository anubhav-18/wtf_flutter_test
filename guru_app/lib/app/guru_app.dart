import 'package:flutter/material.dart';
import 'package:wtf_shared/wtf_shared.dart';

import '../screens/chat_list_screen.dart';
import '../screens/conversation_screen.dart';
import '../screens/guru_dashboard_screen.dart';
import '../screens/guru_onboarding_screen.dart';
import '../screens/guru_profile_screen.dart';
import '../screens/guru_splash_screen.dart';
import '../screens/my_requests_screen.dart';
import '../screens/post_call_rating_sheet.dart';
import '../screens/schedule_call_screen.dart';
import '../screens/session_logs_screen.dart';
import '../screens/upcoming_calls_screen.dart';

class GuruApp extends StatelessWidget {
  const GuruApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Guru App',
      theme: AppTheme.guru,
      initialRoute: AppRoutes.guruSplash,
      routes: {
        AppRoutes.guruSplash: (_) => const GuruSplashScreen(),
        AppRoutes.guruOnboarding: (_) => const GuruOnboardingScreen(),
        AppRoutes.guruProfile: (_) => const GuruProfileScreen(),
        AppRoutes.guruDashboard: (_) => const GuruDashboardScreen(),
        AppRoutes.guruChats: (_) => const ChatListScreen(),
        AppRoutes.guruConversation: (_) => const ConversationScreen(),
        AppRoutes.guruScheduleCall: (_) => const ScheduleCallScreen(),
        AppRoutes.guruMyRequests: (_) => const MyRequestsScreen(),
        AppRoutes.guruUpcomingCalls: (_) => const UpcomingCallsScreen(),
        AppRoutes.guruPreJoin: (_) => PreJoinScreen(
              inCallRoute: AppRoutes.guruInCall,
            ),
        AppRoutes.guruInCall: (_) => InCallScreen(
              userId: AppConstants.memberId,
              postCallRoute: AppRoutes.guruPostCall,
            ),
        AppRoutes.guruPostCall: (_) => const PostCallRatingSheet(),
        AppRoutes.guruSessions: (_) => const SessionLogsScreen(),
      },
    );
  }
}
