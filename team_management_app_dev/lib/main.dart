import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/dashboard_page.dart';
import 'pages/events_page.dart';

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
      home: const MainNavigation(),
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
  // STATE: This remembers which page we're on (0-5)
  // 0 = Dashboard, 1 = Teams, 2 = Events, 3 = Roosters, 4 = Routeplanner, 5 = Profile
  int _selectedIndex = 0;

  // This function runs when user clicks a navigation item
  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;  // Update the selected page
      // setState() tells Flutter to rebuild the widget with new state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // LEFT SIDE: Navigation Rail (Sidebar)
          NavigationRail(
            selectedIndex: _selectedIndex,  // Which item is highlighted
            onDestinationSelected: _onDestinationSelected,  // What happens on click
            labelType: NavigationRailLabelType.all,  // Show labels always
            destinations: const [
              // Each NavigationRailDestination is a menu item
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
                label: Text('Roosters'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.map),
                label: Text('Routeplanner'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.person),
                label: Text('Profile'),
              ),
            ],
          ),
          
          // DIVIDER: Vertical line between sidebar and content
          const VerticalDivider(thickness: 1, width: 1),
          
          // RIGHT SIDE: Main content area
          Expanded(
            child: _buildPage(_selectedIndex),  // Show different page based on selection
          ),
        ],
      ),
    );
  }

  // This function returns the correct page widget based on selected index
  Widget _buildPage(int index) {
    switch (index) {
      case 0:
        return const DashboardPage();
      case 1:
        return const TeamsPage();
      case 2:
        return const EventsPage();
      case 3:
        return const RoostersPage();
      case 4:
        return const RouteplannerPage();
      case 5:
        return const ProfilePage();
      default:
        return const DashboardPage();
    }
  }
}

// TEAMS PAGE (Placeholder)
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

// ROOSTERS PAGE (Placeholder)
class RoostersPage extends StatelessWidget {
  const RoostersPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Roosters'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.calendar_today, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Roosters',
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

// ROUTEPLANNER PAGE (Placeholder)
class RouteplannerPage extends StatelessWidget {
  const RouteplannerPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Routeplanner'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.map, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Route Planner',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Plan your routes here'),
          ],
        ),
      ),
    );
  }
}

// PROFILE PAGE (Placeholder)
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.person, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'My Profile',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text('Your profile information will appear here'),
          ],
        ),
      ),
    );
  }
}