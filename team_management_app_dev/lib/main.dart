import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'pages/dashboard_page.dart';
import 'pages/events_page.dart';
import 'pages/schedule_page.dart';
import 'pages/organise_page.dart';
import 'pages/routeplanner_page.dart';
import 'pages/login.dart';
import 'data/services/api_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // check if user is already logged in
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString('auth_token');
  
  // if token exists, set it in api service
  if (token != null) {
    ApiService().setAuthToken(token);
  }
  
  runApp(
    // Wrap app with ProviderScope for Riverpod state management
    ProviderScope(
      child: MyApp(isLoggedIn: token != null),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  
  const MyApp({Key? key, required this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Team Management App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      // show login
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

// Teams page
class TeamsPage extends StatelessWidget {
  const TeamsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teams'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.group, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Teams Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Your teams will appear here'),
          ],
        ),
      ),
    );
  }
}

// Rosters page
class RoostersPage extends StatelessWidget {
  const RoostersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.calendar_today, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Rosters',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Your schedule will appear here'),
          ],
        ),
      ),
    );
  }
}

