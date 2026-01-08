/// Event Model - Recipe card that describes what an event looks like
/// 
/// When the API sends event data, this class helps us understand it
class Event {
  // PROPERTIES: What info does an event have?
  final int id;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final String location;
  final String type;  // 'upcoming' or 'past'
  final String iconType;  // 'soccer', 'training', 'meeting', etc.

  // CONSTRUCTOR: How to create an Event
  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.type,
    this.iconType = 'event',
  });

  // ==================== FROM JSON ====================
  // This is like reading a recipe written in another language
  // JSON = JavaScript Object Notation (the language APIs speak)
  
  /// Convert JSON (text) → Event (Dart object)
  /// 
  /// Example JSON from API:
  /// {
  ///   "id": 1,
  ///   "title": "Game vs RedOpps",
  ///   "description": "Championship match",
  ///   "date": "2026-01-15T14:00:00Z",
  ///   "location": "Sports Hall A"
  /// }
  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Untitled Event',
      description: json['description'] ?? '',
      date: json['date'] != null 
          ? DateTime.parse(json['date'])
          : DateTime.now(),
      time: json['time'] ?? _extractTime(json['date']),
      location: json['location'] ?? 'TBD',
      type: _determineType(json['date']),
      iconType: _determineIconType(json['title'] ?? ''),
    );
  }

  // ==================== TO JSON ====================
  // Convert Event (Dart object) → JSON (text) to send to API
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'time': time,
      'location': location,
      'type': type,
    };
  }

  // ==================== HELPER METHODS ====================
  
  /// Extract time from date string (e.g., "2026-01-15T14:00:00Z" → "14:00")
  static String _extractTime(String? dateString) {
    if (dateString == null) return '00:00';
    try {
      final date = DateTime.parse(dateString);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '00:00';
    }
  }

  /// Determine if event is upcoming or past
  static String _determineType(String? dateString) {
    if (dateString == null) return 'upcoming';
    try {
      final eventDate = DateTime.parse(dateString);
      return eventDate.isAfter(DateTime.now()) ? 'upcoming' : 'past';
    } catch (e) {
      return 'upcoming';
    }
  }

  /// Determine icon type based on title keywords
  static String _determineIconType(String title) {
    final lowerTitle = title.toLowerCase();
    
    if (lowerTitle.contains('training') || lowerTitle.contains('practice')) {
      return 'training';
    } else if (lowerTitle.contains('meeting') || lowerTitle.contains('discussion')) {
      return 'meeting';
    } else if (lowerTitle.contains('match') || lowerTitle.contains('game') || lowerTitle.contains('vs')) {
      return 'match';
    } else {
      return 'event';
    }
  }

  // ==================== COPY WITH ====================
  // Create a copy of this event with some values changed
  // Like "Same order, but change the drink"
  
  Event copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? date,
    String? time,
    String? location,
    String? type,
    String? iconType,
  }) {
    return Event(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      date: date ?? this.date,
      time: time ?? this.time,
      location: location ?? this.location,
      type: type ?? this.type,
      iconType: iconType ?? this.iconType,
    );
  }

  // ==================== TO STRING ====================
  // For debugging - print event in readable format
  
  @override
  String toString() {
    return 'Event{id: $id, title: $title, date: $date, location: $location}';
  }
}
