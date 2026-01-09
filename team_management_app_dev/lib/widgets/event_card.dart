import 'package:flutter/material.dart';

// event card widget
class EventCard extends StatelessWidget {
  final String title;
  final String date;
  final String time;
  final String location;
  final IconData icon;
  final Color iconColor;

  const EventCard({
    Key? key,
    required this.title,
    required this.date,
    required this.time,
    required this.location,
    required this.icon,
    this.iconColor = Colors.blue,  // Default color is blue
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      // Card = rounded box with shadow
      elevation: 2,  // Subtle shadow (less than StatsCard)
      margin: const EdgeInsets.only(bottom: 12),  // Space between cards
      child: InkWell(
        // InkWell = makes the card clickable with ripple effect
        onTap: () {
          // Clear any existing snackbar first (instant dismiss)
          ScaffoldMessenger.of(context).clearSnackBars();
          // Show new snackbar with 1 second duration
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Clicked: $title'),
              duration: const Duration(seconds: 1),
            ),
          );
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: iconColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Event info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Event Title
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Date and time row
                    Row(
                      children: [
                        // Date
                        const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          date,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                        const SizedBox(width: 16),

                        // Time
                        const Icon(Icons.access_time, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: const TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // Location row
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
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

              // Arrow icon
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
