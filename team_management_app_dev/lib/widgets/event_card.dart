import 'package:flutter/material.dart';

/// EventCard - Reusable widget for displaying event information
/// Just like StatsCard, but for events!
class EventCard extends StatelessWidget {
  // PROPERTIES: What data does this card need?
  final String title;          // Event name: "Team DEVSquad vs RedOpps"
  final String date;           // Date: "06/10/2025"
  final String time;           // Time: "14:00"
  final String location;       // Location: "Sports Hall A"
  final IconData icon;         // Icon to show (soccer, calendar, etc.)
  final Color iconColor;       // Color for the icon background

  // CONSTRUCTOR: When creating an EventCard, you MUST provide these
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
          // TODO: Navigate to event details page
          // For now, just show a message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Clicked: $title')),
          );
        },
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // LEFT: Icon in a colored box
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

              // MIDDLE: Event details (title, date, time, location)
              Expanded(
                // Expanded = take up remaining space
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

                    // Date, Time, Location in a Row
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

                    // Location
                    Row(
                      children: [
                        const Icon(Icons.location_on, size: 14, color: Colors.grey),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            location,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                            overflow: TextOverflow.ellipsis,  // Cut off if too long
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // RIGHT: Arrow icon (shows it's clickable)
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
