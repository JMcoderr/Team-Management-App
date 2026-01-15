import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'pages/dashboard_page.dart';
import 'pages/events_page.dart';
import 'pages/schedule_page.dart';
import 'pages/login.dart';
import 'pages/organise_page.dart';
import 'pages/routeplanner_page.dart';
import 'pages/teams_page.dart';

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
  // separate tracking for account/settings pages
  String? _currentPage; // 'account' or 'settings' or null for main pages

  // when clicking main navigation items
  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
      _currentPage = null; // clear account/settings selection
    });
  }
  
  // when clicking account or settings
  void _onBottomItemSelected(String page) {
    setState(() {
      _currentPage = page;
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
            // account and settings buttons at bottom
            leading: null,
            trailing: Expanded(
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // my profile button
                      InkWell(
                        onTap: () => _onBottomItemSelected('account'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: _currentPage == 'account' ? Colors.blue.withOpacity(0.1) : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.account_circle,
                                color: _currentPage == 'account' ? Colors.blue : Colors.grey[700],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'My Profile',
                                style: TextStyle(
                                  color: _currentPage == 'account' ? Colors.blue : Colors.grey[700],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // settings button
                      InkWell(
                        onTap: () => _onBottomItemSelected('settings'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: _currentPage == 'settings' ? Colors.blue.withOpacity(0.1) : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.settings,
                                color: _currentPage == 'settings' ? Colors.blue : Colors.grey[700],
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Settings',
                                style: TextStyle(
                                  color: _currentPage == 'settings' ? Colors.blue : Colors.grey[700],
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
    // check if account or settings is selected
    if (_currentPage == 'account') {
      return const AccountPage();
    } else if (_currentPage == 'settings') {
      return const SettingsPage();
    }
    
    // otherwise show main pages
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
// class TeamsPage extends StatelessWidget {
//   const TeamsPage({Key? key}) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Teams'),
//         backgroundColor: Colors.blue,
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: const [
//             Icon(Icons.group, size: 100, color: Colors.blue),
//             SizedBox(height: 20),
//             Text(
//               'Teams Page',
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Text('Your teams will appear here'),
//           ],
//         ),
//       ),
//     );
//   }
// }

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

// account page - user info and stuff
class AccountPage extends StatelessWidget {
  const AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.account_circle, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Your account details will show here',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

// settings page
class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.settings, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'Settings will show here',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}

