import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/assignment_provider.dart';
import 'providers/session_provider.dart';
import 'providers/student_provider.dart';
import 'screens/assignments_screen.dart';
import 'screens/assignment_form_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/schedule_screen.dart';
import 'screens/session_form_screen.dart';
import 'screens/splash_screen.dart';
import 'services/course_service.dart';
import 'services/storage_service.dart';
import 'theme/app_theme.dart';
import 'widgets/attendance_warning_banner.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final storageService = await StorageService.getInstance();
  await CourseService.instance.loadCourses();
  
  runApp(GradeGuardianApp(storageService: storageService));
}

class GradeGuardianApp extends StatelessWidget {
  final StorageService storageService;
  
  const GradeGuardianApp({super.key, required this.storageService});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => StudentProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => AssignmentProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => SessionProvider(storageService),
        ),
      ],
      child: MaterialApp(
        title: 'GradeGuardian',
        theme: AppTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        home: const AppWrapper(),
      ),
    );
  }
}

class AppWrapper extends StatefulWidget {
  const AppWrapper({super.key});

  @override
  State<AppWrapper> createState() => _AppWrapperState();
}

class _AppWrapperState extends State<AppWrapper> {
  bool _showSplash = true;

  void _onSplashComplete() {
    if (mounted) {
      setState(() => _showSplash = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_showSplash) {
      return SplashScreen(onComplete: _onSplashComplete);
    }

    return Consumer<StudentProvider>(
      builder: (context, studentProvider, child) {
        if (studentProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!studentProvider.isLoggedIn) {
          return const LoginScreen();
        }

        return const MainScreen();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    AssignmentsScreen(),
    ScheduleScreen(),
  ];

  final List<String> _titles = const [
    'Dashboard',
    'Assignments',
    'Schedule',
  ];

  @override
  Widget build(BuildContext context) {
    return Consumer<SessionProvider>(
      builder: (context, sessionProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(_titles[_currentIndex]),
            centerTitle: true,
            actions: [
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'logout') {
                    _showLogoutDialog(context);
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'logout',
                    child: Row(
                      children: [
                        Icon(Icons.logout, size: 20),
                        SizedBox(width: 8),
                        Text('Logout'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              AttendanceWarningBanner(
                attendancePercentage: sessionProvider.attendancePercentage,
              ),
              Expanded(
                child: IndexedStack(
                  index: _currentIndex,
                  children: _screens,
                ),
              ),
            ],
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.dashboard_outlined),
                activeIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.assignment_outlined),
                activeIcon: Icon(Icons.assignment),
                label: 'Assignments',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.schedule_outlined),
                activeIcon: Icon(Icons.schedule),
                label: 'Schedule',
              ),
            ],
          ),
          floatingActionButton: _buildFAB(),
        );
      },
    );
  }

  Widget? _buildFAB() {
    if (_currentIndex == 0) return null;
    
    return FloatingActionButton(
      onPressed: () {
        if (_currentIndex == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AssignmentFormScreen(),
            ),
          );
        } else if (_currentIndex == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const SessionFormScreen(),
            ),
          );
        }
      },
      child: const Icon(Icons.add),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout? All your data will be cleared.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await context.read<StudentProvider>().logout();
              if (context.mounted) {
                context.read<AssignmentProvider>().clear();
                context.read<SessionProvider>().clear();
              }
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text(
              'Logout',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
