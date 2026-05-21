import 'package:flutter/material.dart';
import 'package:wtf_shared/wtf_shared.dart';

import '../screens/members_screen.dart';
import '../screens/member_detail_screen.dart';
import '../screens/post_call_notes_sheet.dart';
import '../screens/trainer_chat_list_screen.dart';
import '../screens/trainer_conversation_screen.dart';
import '../screens/trainer_dashboard_screen.dart';
import '../screens/trainer_login_screen.dart';
import '../screens/trainer_requests_screen.dart';
import '../screens/trainer_session_logs_screen.dart';
import '../screens/trainer_splash_screen.dart';
import '../screens/trainer_upcoming_calls_screen.dart';

class TrainerApp extends StatelessWidget {
  const TrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trainer App',
      theme: AppTheme.trainer,
      initialRoute: AppRoutes.trainerSplash,
      routes: {
        AppRoutes.trainerSplash: (_) => const TrainerSplashScreen(),
        AppRoutes.trainerLogin: (_) => const TrainerLoginScreen(),
        AppRoutes.trainerDashboard: (_) => const TrainerDashboardScreen(),
        AppRoutes.trainerMembers: (_) => const MembersScreen(),
        AppRoutes.trainerChats: (_) => const TrainerChatListScreen(),
        AppRoutes.trainerConversation: (_) => const TrainerConversationScreen(),
        AppRoutes.trainerRequests: (_) => const TrainerRequestsScreen(),
        AppRoutes.trainerUpcomingCalls: (_) => const TrainerUpcomingCallsScreen(),
        AppRoutes.trainerPreJoin: (_) => PreJoinScreen(
              inCallRoute: AppRoutes.trainerInCall,
            ),
        AppRoutes.trainerInCall: (_) => InCallScreen(
              userId: AppConstants.trainerId,
              postCallRoute: AppRoutes.trainerPostCall,
            ),
        AppRoutes.trainerPostCall: (_) => const PostCallNotesSheet(),
        AppRoutes.trainerSessions: (_) => const TrainerSessionLogsScreen(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == AppRoutes.trainerMemberDetail) {
          final member = settings.arguments! as AppUser;
          return MaterialPageRoute<void>(
            builder: (_) => MemberDetailScreen(member: member),
            settings: settings,
          );
        }
        return null;
      },
    );
  }
}
