import '../models/event.dart';
import '../services/api_service.dart';
import '../services/mock_data.dart';

// Repository to manage event data
class EventRepository {
  final ApiService _apiService;

  // Cache events to avoid unnecessary API calls
  List<Event>? _cachedEvents;
  DateTime? _lastFetchTime;

  EventRepository(this._apiService);

  // Fetch all events from API
  Future<List<Event>> getEvents({bool forceRefresh = false}) async {
    // Return cached data if it's less than 5 minutes old
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
      _clearCache();  // Clear cache to force refresh
      
      print('✅ Event created successfully: ${newEvent.title}');
      return newEvent;
      
    } catch (e) {
      print('❌ Error creating event: $e');
      throw Exception('Failed to create event: $e');
    }
  }

  // Update an existing event
      print('🌐 Updating event #$id...');
      
      final response = await _apiService.put('/events/$id', data: event.toJson());
      final updatedEvent = Event.fromJson(response.data);
      
      // Clear cache
      _clearCache();
      
      print('✅ Event updated successfully');
      return updatedEvent;
      
    } catch (e) {
      print('❌ Error updating event: $e');
      throw Exception('Failed to update event: $e');
    }
  }

  // ==================== DELETE EVENT ====================
  /// Delete an event
  /// Like asking librarian: "Remove book #5 from collection"
  FutDelete an event
      
      await _apiService.delete('/events/$id');
      
      // Clear cache
      _clearCache();
      
      print('✅ Event deleted successfully');
      
    } catch (e) {
      print('❌ Error deleting event: $e');
      throw Exception('Failed to delete event: $e');
    }
  }

  // ==================== FILTER METHODS ====================
  /// Get only upcoming events
  Future<List<Event>> getUpcomingEvents() async {
    final allEvents = await getEvents();
    return allEvents.where((event) => event.type == 'upcoming').toList();
  }
  /// Get only past events
  Future<List<Event>> getPastEvents() async {
    final allEvents = await getEvents();
    eturn allEvents.where((event) => event.type == 'past').toList();
  }

  /// Search events by query (title or location)
  Future<List<Event>> searchEvents(String query) async {
    final allEvents = await getEvents();
     Search events by title or location
    
    return allEvents.where((event) {
      return event.title.toLowerCase().contains(lowerQuery) ||
             event.location.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // ==================== CACHE MANAGEMENT ====================
  ///Clear cached data
    _cachedEvents = null;
    _lastFetchTime = null;
    print('🗑️ Cache cleared');
  }

  /// Force refresh events (ignore cache)
  Future<List<Event>> refreshEvents() async {
     Force refresh - ignore cache
  }
}
