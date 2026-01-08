import 'package:flutter/material.dart';

/// StatsCard is a reusable widget that displays a statistic
/// 
/// Example usage:
///   StatsCard(
///     title: 'Teams',
///     value: '5',
///     icon: Icons.group,
///   )
class StatsCard extends StatelessWidget {
  // These are the "inputs" to the widget - we pass them when creating the widget
  final String title;      // Example: 'Teams'
  final String value;      // Example: '5'
  final IconData icon;     // Example: Icons.group

  // Constructor - this is how we pass data to the widget
  const StatsCard({
    Key? key,
    required this.title,   // "required" means you MUST provide this
    required this.value,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      // Card creates a nice rounded box with shadow
      elevation: 4,  // elevation = shadow depth (higher = more shadow)
      child: Padding(
        // Padding = empty space inside the card
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Column = stack things vertically
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Icon at the top
            Icon(
              icon,
              size: 50,
              color: Colors.blue,
            ),
            const SizedBox(height: 12),  // Empty space
            
            // Value (the big number)
            Text(
              value,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 8),  // Empty space
            
            // Title (label)
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
