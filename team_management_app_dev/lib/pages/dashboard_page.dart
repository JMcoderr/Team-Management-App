import 'package:flutter/material.dart';
import '../widgets/stats_card.dart';  // Import the StatsCard we just created

class DashboardPage extends StatelessWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        backgroundColor: Colors.blue,
      ),
      body: SingleChildScrollView(
        // SingleChildScrollView = allows scrolling if content is too big
        padding: const EdgeInsets.all(16.0),  // Padding around everything
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // GREETING
            const Text(
              'Welcome Back!',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Here\'s your team overview',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),

            // STATS SECTION - Quick Overview
            const Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // STATS CARDS IN A GRID (4 cards per row)
            GridView.count(
              // GridView.count creates a grid layout
              // crossAxisCount = number of columns
              crossAxisCount: 4,
              crossAxisSpacing: 16,  // Space between columns
              mainAxisSpacing: 16,   // Space between rows
              shrinkWrap: true,      // Don't take full height
              physics: const NeverScrollableScrollPhysics(),  // Don't scroll within grid
              children: [
                // Card 1: Teams
                StatsCard(
                  title: 'Teams',
                  value: '5',
                  icon: Icons.group,
                ),
                // Card 2: Events
                StatsCard(
                  title: 'Events',
                  value: '12',
                  icon: Icons.calendar_today,
                ),
                // Card 3: Upcoming
                StatsCard(
                  title: 'This Week',
                  value: '3',
                  icon: Icons.event_note,
                ),
                // Card 4: Members
                StatsCard(
                  title: 'Members',
                  value: '24',
                  icon: Icons.people,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // UPCOMING EVENTS SECTION
            const Text(
              'Upcoming Events',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // EVENT LIST
            _buildEventItem(
              title: 'Team DEVSquad vs Team RedOpps',
              date: '06/10/2025',
              location: 'Sports Hall A',
            ),
            const SizedBox(height: 12),
            _buildEventItem(
              title: 'Training Session',
              date: '08/10/2025',
              location: 'Practice Field',
            ),
            const SizedBox(height: 12),
            _buildEventItem(
              title: 'Team Meeting',
              date: '10/10/2025',
              location: 'Conference Room',
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to build an event item
  // This keeps code clean by reusing the same layout for all events
  Widget _buildEventItem({
    required String title,
    required String date,
    required String location,
  }) {
    return Container(
      // Container = a box to hold things
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        // BoxDecoration = styling for the container
        color: Colors.grey[100],  // Light grey background
        borderRadius: BorderRadius.circular(8),  // Rounded corners
        border: Border.all(color: Colors.grey[300]!),  // Grey border
      ),
      child: Row(
        children: [
          // Left side: Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.sports_soccer,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // Right side: Event details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      date,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.location_on, size: 12, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        location,
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
