import 'package:flutter/material.dart';
import '../widgets/stats_card.dart';

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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // greeting text
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

            // stats
            const Text(
              'Quick Stats',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // grid with stats cards
            GridView.count(
              crossAxisCount: 4,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                // teams stat
                StatsCard(
                  title: 'Teams',
                  value: '5',
                  icon: Icons.group,
                ),
                // events stat
                StatsCard(
                  title: 'Events',
                  value: '12',
                  icon: Icons.calendar_today,
                ),
                // this week stat
                StatsCard(
                  title: 'This Week',
                  value: '3',
                  icon: Icons.event_note,
                ),
                // members stat
                StatsCard(
                  title: 'Members',
                  value: '24',
                  icon: Icons.people,
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Upcoming events section
            const Text(
              'Upcoming Events',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // upcoming events
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

  // building event item
  Widget _buildEventItem({
    required String title,
    required String date,
    required String location,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          // icon
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

          // event details
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
