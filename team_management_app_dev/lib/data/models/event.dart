// event model
class Event {
  final int id;
  final String title;
  final String description;
  final DateTime date;
  final String time;
  final String location;
  final String type;  // 'upcoming' or 'past'
  final String iconType;  // 'soccer', 'training', 'meeting'
  final int? teamId;  // Added for API v2
  final double? latitude;  // Added for API v2 location
  final double? longitude;  // Added for API v2 location

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.location,
    required this.type,
    this.iconType = 'event',
    this.teamId,
    this.latitude,
    this.longitude,
  });

  // json to event object
  factory Event.fromJson(Map<String, dynamic> json) {
    // Handle API v2 format with datetimeStart and location object
    DateTime eventDate;
    String eventTime;
    String locationString;
    double? lat;
    double? lng;
    
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
    
    // Handle location (can be string or object)
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
    );
  }

  // event to json for api
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

  // HELPER METHODS
  
  // Helper: extract time from date string
  static String _extractTime(String? dateString) {
    if (dateString == null) return '00:00';
    try {
      final date = DateTime.parse(dateString);
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } catch (e) {
      return '00:00';
    }
  }

  // check if event is upcoming or past
  static String _determineType(String? dateString) {
    if (dateString == null) return 'upcoming';
    try {
      final eventDate = DateTime.parse(dateString);
      return eventDate.isAfter(DateTime.now()) ? 'upcoming' : 'past';
    } catch (e) {
      return 'upcoming';
    }
  }

  // getting icon based on title
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

  // Create a copy with some fields changed
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

  // for debugging
  @override
  String toString() {
    return 'Event{id: $id, title: $title, date: $date, location: $location}';
  }
}
