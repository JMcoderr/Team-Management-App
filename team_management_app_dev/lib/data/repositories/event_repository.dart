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
      final List<dynamic> jsonList = response.data;
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
      
      final response = await _apiService.post('/events', data: event.toJson());
      final newEvent = Event.fromJson(response.data);
      
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
      
      final response = await _apiService.put('/events/$id', data: event.toJson());
      final updatedEvent = Event.fromJson(response.data);
      
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
