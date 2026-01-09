import '../models/event.dart';

// mock events for testing
class MockData {
  static List<Event> getMockEvents() {
    return [
      Event(
        id: 1,
        title: 'Team DEVSquad vs RedOpps',
        description: 'Championship match - bring your A-game!',
        date: DateTime(2026, 1, 15, 14, 0),
        time: '14:00',
        location: 'Sports Hall A',
        type: 'upcoming',
        iconType: 'match',
      ),
      Event(
        id: 2,
        title: 'Training Session - Offense',
        description: 'Focus on attacking strategies',
        date: DateTime(2026, 1, 10, 18, 0),
        time: '18:00',
        location: 'Practice Field',
        type: 'upcoming',
        iconType: 'training',
      ),
      Event(
        id: 3,
        title: 'Team Meeting - Strategy',
        description: 'Discuss tactics for upcoming matches',
        date: DateTime(2026, 1, 12, 10, 0),
        time: '10:00',
        location: 'Conference Room B',
        type: 'upcoming',
        iconType: 'meeting',
      ),
      Event(
        id: 4,
        title: 'DEVSquad vs BlueTigers',
        description: 'Quarter-final match',
        date: DateTime(2026, 1, 5, 16, 0),
        time: '16:00',
        location: 'Sports Hall C',
        type: 'past',
        iconType: 'match',
      ),
      Event(
        id: 5,
        title: 'Pre-Season Training',
        description: 'Conditioning and warm-up',
        date: DateTime(2026, 1, 2, 9, 0),
        time: '09:00',
        location: 'Training Ground',
        type: 'past',
        iconType: 'training',
      ),
    ];
  }
}
