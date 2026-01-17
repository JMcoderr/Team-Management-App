class Event {
  final int id;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final String location;
  final String type; //upcoming or past determines filtering
  final String
  iconType; // soccer, training, meeting determines icon shown
  final int?
  teamId; // links event to specific team, nullable for events without team
  final double? latitude; // location coordinates from API
  final double? longitude;
  final String? googleMapsLink; // place link for viewing location
  final String? directionsLink; // directions link for navigation

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.type,
    this.iconType = 'event', // default icon if not specified
    this.teamId,
    this.latitude,
    this.longitude,
    this.googleMapsLink,
    this.directionsLink,
  });

  // converts JSON from API to Event object
  factory Event.fromJson(Map<String, dynamic> json) {
    // parse date and time from API response
    DateTime eventDate;
    String eventTime;
    String locationString;
    double? lat;
    double? lng;

    // handle different date formats from API
    if (json['datetimeStart'] != null) {
      eventDate = DateTime.parse(json['datetimeStart']);
      eventTime = _extractTime(json['datetimeStart']);
    } else if (json['date'] != null) {
      eventDate = DateTime.parse(json['date']);
      eventTime = json['time'] ?? _extractTime(json['date']);
    } else {
      eventDate = DateTime.now();
      eventTime = '00:00';
    }

    // location can be string or object with coordinates
    if (json['location'] is Map) {
      lat = (json['location']['latitude'] as num?)?.toDouble();
      lng = (json['location']['longitude'] as num?)?.toDouble();
      locationString = 'Location';
    } else {
      locationString = json['location'] ?? 'TBD';
    }

    return Event(
      id: json['id'] ?? 0,
      title: json['title'] ?? 'Untitled Event',
      description: json['description'] ?? '',
      date: eventDate,
      time: eventTime,
      location: locationString,
      type: _determineType(eventDate.toIso8601String()),
      iconType: _determineIconType(json['title'] ?? ''),
      teamId: json['teamId'],
      latitude: lat,
      longitude: lng,
      googleMapsLink: json['googleMapsLink'] as String?,
      directionsLink: json['directionsLink'] as String?,
    );
  }

  // converts Event object to JSON for sending to API
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

  // extracts time string from datetime
  // returns HH:mm format (24-hour)
  static String _extractTime(String? dateString) {
    if (dateString == null) return '00:00';
    try {
      final date = DateTime.parse(dateString);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '00:00';
    }
  }

  // compares event date with current time to determine if upcoming or past
  static String _determineType(String? dateString) {
    if (dateString == null) return 'upcoming';
    try {
      final eventDate = DateTime.parse(dateString);
      return eventDate.isAfter(DateTime.now()) ? 'upcoming' : 'past';
    } catch (e) {
      return 'upcoming'; // default to upcoming if date parsing fails
    }
  }

  // analyzes title to determine event type icon
  static String _determineIconType(String title) {
    final lowerTitle = title.toLowerCase();

    if (lowerTitle.contains('training') || lowerTitle.contains('practice')) {
      return 'training';
    } else if (lowerTitle.contains('meeting') ||
        lowerTitle.contains('discussion')) {
      return 'meeting';
    } else if (lowerTitle.contains('match') ||
        lowerTitle.contains('game') ||
        lowerTitle.contains('vs')) {
      return 'match';
    } else {
      return 'event';
    }
  }

  // creates new Event with some fields modified
  // useful for updating events without recreating entire object
  Event copyWith({
    int? id,
    String? title,
    String? description,
    DateTime? date,
    String? time,
    String? location,
    String? type,
    String? iconType,
    int? teamId,
    double? latitude,
    double? longitude,
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
      teamId: teamId ?? this.teamId,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
    );
  }

  // readable string representation for debugging and logging
  @override
  String toString() {
    return 'Event{id: $id, title: $title, date: $date, location: $location}';
  }
}
