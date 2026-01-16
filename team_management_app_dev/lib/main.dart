import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/dashboard_page.dart';
import 'pages/events_page.dart';
import 'pages/schedule_page.dart';
import 'pages/organise_page.dart';
import 'pages/routeplanner_page.dart';
import 'pages/login.dart';
import 'pages/teams/teams_page.dart';
import 'data/services/auth_service.dart';

void main() {
  runApp(
    // Wrap app with ProviderScope for Riverpod state management
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Team Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // Always show login page first - Jay's auth flow handles navigation
      home: const Login(),
    );
  }
}

// This widget manages navigation between pages
class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // 0 = Dashboard, 1 = Teams, 2 = Events, 3 = Schedule, 4 = Routeplanner, 5 = Organise
  int _selectedIndex = 0;

  // when clicking main navigation items
  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // LEFT SIDE: Navigation Rail (Sidebar)
          NavigationRail(
            selectedIndex: _selectedIndex,  // which item is highlighted
            onDestinationSelected: _onDestinationSelected,  // what happens on click
            labelType: NavigationRailLabelType.all,  // show labels always
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: IconButton(
                    icon: const Icon(Icons.logout),
                    tooltip: 'Logout',
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Logout'),
                          content: const Text('Are you sure you want to logout?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () {
                                AuthService().logout();
                                Navigator.pop(context); // Close dialog
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Login()),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Logout'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            destinations: const [
              // main menu items at top
              NavigationRailDestination(
                icon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.group),
                label: Text('Teams'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.sports_soccer),
                label: Text('Events/matches'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.calendar_today),
                label: Text('Schedule'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.map),
                label: Text('Routeplanner'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.event_available),
                label: Text('Organise'),
              ),
            ],
          ),
          
          // DIVIDER: Vertical line between sidebar and content
          const VerticalDivider(thickness: 1, width: 1),
          
          // RIGHT SIDE: Main content area
          Expanded(
            child: _buildPage(),  // shows page based on selection
          ),
        ],
      ),
    );
  }

  // shows correct page based on what u clicked
  Widget _buildPage() {
    switch (_selectedIndex) {
      case 0:
        return const DashboardPage();
      case 1:
        return const TeamsPage();
      case 2:
        return const EventsPage();
      case 3:
        return const SchedulePage();
      case 4:
        return const RouteplannerPage();
      case 5:
        return const OrganisePage();
      default:
        return const DashboardPage();
    }
  }
}



