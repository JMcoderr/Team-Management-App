import '../models/event.dart';
import '../services/api_service.dart';
import '../services/mock_data.dart';

// managing event data
class EventRepository {
  final ApiService _apiService;

  // cache to avoid spamming api
  List<Event>? _cachedEvents;
  DateTime? _lastFetchTime;

  EventRepository(this._apiService);

  // getting all events
  Future<List<Event>> getEvents({bool forceRefresh = false}) async {
    // use cache if fresh
    if (!forceRefresh && 
        _cachedEvents != null && 
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < const Duration(minutes: 5)) {
      print('📚 Using cached events (${_cachedEvents!.length} events)');
      return _cachedEvents!;
    }

    try {
      print('🌐 Fetching events from API...');
      
      final response = await _apiService.get('/events');
      
      // API wraps response in {"data": [...]}
      final responseData = response.data is Map && response.data['data'] != null
          ? response.data['data']
          : response.data;
      
      final List<dynamic> jsonList = responseData is List ? responseData : [];
      final events = jsonList.map((json) => Event.fromJson(json)).toList();
      
      _cachedEvents = events;
      _lastFetchTime = DateTime.now();
      
      print('✅ Fetched ${events.length} events successfully');
      return events;
      
    } catch (e) {
      print('❌ Error fetching events from API: $e');
      print('📦 Using mock data as fallback...');
      
      // Try to return cached data if available
      if (_cachedEvents != null) {
        print('📚 Returning cached events as fallback');
        return _cachedEvents!;
      }
      
      // Last resort: return mock data
      print('✅ Returning mock data (${MockData.getMockEvents().length} events)');
      return MockData.getMockEvents();
    }
  }

  // Get a single event by ID
  Future<Event> getEventById(int id) async {
    try {
      print('🌐 Fetching event #$id from API...');
      
      final response = await _apiService.get('/events/$id');
      final event = Event.fromJson(response.data);
      
      print('✅ Fetched event: ${event.title}');
      return event;
      
    } catch (e) {
      print('❌ Error fetching event #$id: $e');
      throw Exception('Failed to load event: $e');
    }
  }

  // Create a new event
  Future<Event> createEvent(Event event) async {
    try {
      print('🌐 Creating new event: ${event.title}...');
      
      // API v2 requires datetimeStart, datetimeEnd, and teamId
      final datetimeStart = event.date.toIso8601String();
      // Default end time is 2 hours after start
      final datetimeEnd = event.date.add(const Duration(hours: 2)).toIso8601String();
      
      // For now, use teamId 1 as default (TODO: let user select team)
      final eventData = {
        'title': event.title,
        'description': event.description,
        'datetimeStart': datetimeStart,
        'datetimeEnd': datetimeEnd,
        'location': {
          'latitude': event.latitude ?? 0.0,  // Default to 0,0 if not provided
          'longitude': event.longitude ?? 0.0,
        },
        'teamId': event.teamId ?? 1,  // Use provided teamId or default to 1
        'metadata': {},
      };
      
      print('📤 Sending data: $eventData');
      
      final response = await _apiService.post('/events', data: eventData);
      
      print('📥 Response data: ${response.data}');
      
      // check if response has data field (API might wrap response)
      final responseData = response.data is Map && response.data['data'] != null 
          ? response.data['data'] 
          : response.data;
      
      final newEvent = Event.fromJson(responseData);
      
      // Clear cache so next getEvents() fetches fresh data
      _clearCache();
      
      print('✅ Event created successfully: ${newEvent.title}');
      return newEvent;
      
    } catch (e) {
      print('❌ Error creating event: $e');
      
      // if auth error, add to mock data locally
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        print('📦 Working in offline mode - adding to local data');
        
        // add to cache so it shows up
        if (_cachedEvents == null) {
          _cachedEvents = MockData.getMockEvents();
        }
        _cachedEvents!.add(event);
        
        return event;
      }
      
      throw Exception('Failed to create event: $e');
    }
  }

  // Update an existing event
  Future<Event> updateEvent(int id, Event event) async {
    try {
      print('🌐 Updating event #$id...');
      
      // only send fields that can be updated
      final eventData = {
        'title': event.title,
        'description': event.description,
        'date': event.date.toIso8601String(),
        'location': event.location,
      };
      
      final response = await _apiService.put('/events/$id', data: eventData);
      
      print('📥 Update response: ${response.data}');
      
      // check if response has data field
      final responseData = response.data is Map && response.data['data'] != null 
          ? response.data['data'] 
          : response.data;
      
      final updatedEvent = Event.fromJson(responseData);
      
      // Clear cache
      _clearCache();
      
      print('✅ Event updated successfully');
      return updatedEvent;
      
    } catch (e) {
      print('❌ Error updating event: $e');
      
      // if auth error, update in local cache
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        print('📦 Working in offline mode - updating local data');
        
        if (_cachedEvents != null) {
          final index = _cachedEvents!.indexWhere((e) => e.id == id);
          if (index != -1) {
            _cachedEvents![index] = event;
          }
        }
        
        return event;
      }
      
      throw Exception('Failed to update event: $e');
    }
  }

  // Delete an event
  Future<void> deleteEvent(int id) async {
    try {
      print('🌐 Deleting event #$id...');
      
      await _apiService.delete('/events/$id');
      
      // Clear cache
      _clearCache();
      
      print('✅ Event deleted successfully');
      
    } catch (e) {
      print('❌ Error deleting event: $e');
      
      // if auth error, delete from local cache
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        print('📦 Working in offline mode - deleting from local data');
        
        if (_cachedEvents != null) {
          _cachedEvents!.removeWhere((event) => event.id == id);
        }
        
        return;
      }
      
      throw Exception('Failed to delete event: $e');
    }
  }

  //FILTER METHODS
  /// Get only upcoming events
  Future<List<Event>> getUpcomingEvents() async {
    final allEvents = await getEvents();
    return allEvents.where((event) => event.type == 'upcoming').toList();
  }
  // Get only past events
  Future<List<Event>> getPastEvents() async {
    final allEvents = await getEvents();
    return allEvents.where((event) => event.type == 'past').toList();
  }

  // Search events by query (title or location)
  Future<List<Event>> searchEvents(String query) async {
    final allEvents = await getEvents();
    final lowerQuery = query.toLowerCase();
    
    return allEvents.where((event) {
      return event.title.toLowerCase().contains(lowerQuery) ||
             event.location.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Clear cached data
  void _clearCache() {
    _cachedEvents = null;
    _lastFetchTime = null;
    print('🗑️ Cache cleared');
  }

  // Force refresh events (ignore cache)
  Future<List<Event>> refreshEvents() async {
    _clearCache();
    return await getEvents();
  }
}
