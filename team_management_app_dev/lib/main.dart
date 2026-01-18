import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/dashboard_page.dart';
import 'pages/events_page.dart';
import 'pages/schedule_page.dart';
import 'pages/organise_page.dart';
import 'pages/matches/organise_match_page.dart';
import 'pages/routeplanner_page.dart';
import 'pages/login.dart';
import 'pages/teams/teams_page.dart';
import 'data/services/auth_service.dart';

void main() {
  // initializes Flutter framework before platform-specific operations
  WidgetsFlutterBinding.ensureInitialized();

  // locks app to portrait orientation only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp, 
    DeviceOrientation.portraitDown, 
  ]);

  runApp(
    // wraps app with ProviderScope for Riverpod state management
    const ProviderScope(child: MyApp()),
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
        useMaterial3: true
      ),
      home: const Login(), // starts at login for authentication
    );
  }
}

// MainNavigation provides app navigation after login
class MainNavigation extends StatefulWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  // tracks currently displayed page index
  int _selectedIndex = 0;

  // updates selected page when user taps navigation item
  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    // gets device screen width for responsive layout decisions
    final screenWidth = MediaQuery.of(context).size.width;

    // determines mobile vs desktop layout
    final isMobile = screenWidth < 600;

    return Scaffold(
      body: Row(
        children: [
          // shows sidebar navigation only on wider screens
          if (!isMobile)
            // NavigationRail creates vertical sidebar with icons and labels
            NavigationRail(
              selectedIndex: _selectedIndex, 
              onDestinationSelected: _onDestinationSelected, 
              labelType: NavigationRailLabelType.all,
              trailing: Expanded(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    // logout button positioned at bottom of sidebar
                    child: IconButton(
                      icon: const Icon(Icons.logout),
                      tooltip: 'Logout',
                      onPressed: () => _showLogoutDialog(context),
                    ),
                  ),
                ),
              ),
              destinations: const [
                // navigation items displayed in sidebar
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
                  label: Text('Organise Event'),
                ),
                NavigationRailDestination(
                  icon: Icon(Icons.emoji_events),
                  label: Text('Organise Match'),
                ),
              ],
            ),

          // vertical line separates sidebar from content
          if (!isMobile) const VerticalDivider(thickness: 1, width: 1),

          // main content area displays selected page
          Expanded(
            child: _buildPage(),
          ),
        ],
      ),

      // bottom navigation bar for mobile devices
      bottomNavigationBar: isMobile
          ? BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              currentIndex: _selectedIndex, 
              onTap: _onDestinationSelected,
              // reduced font sizes fit 7 items on small screens
              selectedFontSize: 12,
              unselectedFontSize: 10,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.dashboard),
                  label: 'Dashboard',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.group),
                  label: 'Teams',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.sports_soccer),
                  label: 'Events', 
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.calendar_today),
                  label: 'Schedule',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: 'Routes',
                ),
                BottomNavigationBarItem(icon: Icon(Icons.add), label: 'Event'),
                BottomNavigationBarItem(
                  icon: Icon(Icons.emoji_events),
                  label: 'Match',
                ),
              ],
            )
          : null,
      // floating action button provides logout on mobile
      floatingActionButton: isMobile
          ? FloatingActionButton(
              onPressed: () => _showLogoutDialog(context),
              tooltip: 'Logout',
              child: const Icon(Icons.logout),
            )
          : null, // hides FAB on desktop
    );
  }

  // shows logout confirmation dialog
  void _showLogoutDialog(BuildContext context) {
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
              Navigator.pop(context); 

              // displays success feedback to user
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Logged out successfully!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );

              // navigates to login and removes navigation history
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
  }

  // returns page widget based on selected navigation index
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
      case 6:
        return const OrganiseMatchPage();
      default:
        return const DashboardPage();
    }
  }
}
