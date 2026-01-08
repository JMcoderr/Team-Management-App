import 'package:flutter/material.dart';
import '../widgets/event_card.dart';

/// EventsPage - Shows list of all events with filters
class EventsPage extends StatefulWidget {
  const EventsPage({Key? key}) : super(key: key);

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  // STATE: Which filter is selected? (0 = All, 1 = Upcoming, 2 = Past)
  int _selectedFilter = 0;

  // STATE: Search text
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Events'),
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // SEARCH BAR
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: TextField(
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search events...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
              ),
            ),
          ),

          // FILTER TABS (All, Upcoming, Past)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildFilterChip('All', 0),
                const SizedBox(width: 8),
                _buildFilterChip('Upcoming', 1),
                const SizedBox(width: 8),
                _buildFilterChip('Past', 2),
              ],
            ),
          ),

          // EVENT LIST
          Expanded(
            child: _buildEventList(),
          ),
        ],
      ),

      // FLOATING ACTION BUTTON: Add new event
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Open "Add Event" form
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Event - Coming Soon!')),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Helper: Build a filter chip (All/Upcoming/Past button)
  Widget _buildFilterChip(String label, int index) {
    final bool isSelected = _selectedFilter == index;

    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (bool selected) {
        setState(() {
          _selectedFilter = index;
        });
      },
      selectedColor: Colors.blue,
      backgroundColor: Colors.grey[200],
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      checkmarkColor: Colors.white,
    );
  }

  /// Build the list of events
  Widget _buildEventList() {
    // Mock event data (later: get from database)
    final List<Map<String, dynamic>> allEvents = [
      {
        'title': 'Team DEVSquad vs RedOpps',
        'date': '15/01/2026',
        'time': '14:00',
        'location': 'Sports Hall A',
        'icon': Icons.sports_soccer,
        'iconColor': Colors.blue,
        'type': 'upcoming',
      },
      {
        'title': 'Training Session - Offense',
        'date': '10/01/2026',
        'time': '18:00',
        'location': 'Practice Field',
        'icon': Icons.fitness_center,
        'iconColor': Colors.green,
        'type': 'upcoming',
      },
      {
        'title': 'Team Meeting - Strategy',
        'date': '12/01/2026',
        'time': '10:00',
        'location': 'Conference Room B',
        'icon': Icons.meeting_room,
        'iconColor': Colors.orange,
        'type': 'upcoming',
      },
      {
        'title': 'DEVSquad vs BlueTigers',
        'date': '05/01/2026',
        'time': '16:00',
        'location': 'Sports Hall C',
        'icon': Icons.sports_soccer,
        'iconColor': Colors.grey,
        'type': 'past',
      },
      {
        'title': 'Pre-Season Training',
        'date': '02/01/2026',
        'time': '09:00',
        'location': 'Training Ground',
        'icon': Icons.fitness_center,
        'iconColor': Colors.grey,
        'type': 'past',
      },
    ];

    // FILTER: Apply selected filter
    List<Map<String, dynamic>> filteredEvents = allEvents;
    if (_selectedFilter == 1) {
      // Upcoming only
      filteredEvents = allEvents.where((e) => e['type'] == 'upcoming').toList();
    } else if (_selectedFilter == 2) {
      // Past only
      filteredEvents = allEvents.where((e) => e['type'] == 'past').toList();
    }

    // SEARCH: Filter by search query
    if (_searchQuery.isNotEmpty) {
      filteredEvents = filteredEvents.where((event) {
        final title = event['title'].toString().toLowerCase();
        final location = event['location'].toString().toLowerCase();
        final query = _searchQuery.toLowerCase();
        return title.contains(query) || location.contains(query);
      }).toList();
    }

    // If no events match, show empty state
    if (filteredEvents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'No events found',
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    // Show list of events
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: filteredEvents.length,
      itemBuilder: (context, index) {
        final event = filteredEvents[index];
        return EventCard(
          title: event['title'],
          date: event['date'],
          time: event['time'],
          location: event['location'],
          icon: event['icon'],
          iconColor: event['iconColor'],
        );
      },
    );
  }
}
