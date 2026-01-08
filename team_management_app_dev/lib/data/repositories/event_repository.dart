import '../models/event.dart';
import '../services/api_service.dart';
import '../services/mock_data.dart';

/// EventRepository - The "Librarian" who manages all event data
/// 
/// Instead of asking the API directly every time, you ask the librarian
/// The librarian keeps track of events, caches them, and handles errors
class EventRepository {
  // The waiter (API service) that talks to the server
  final ApiService _apiService;

  // Cache: Like the librarian's memory of books already fetched
  List<Event>? _cachedEvents;
  DateTime? _lastFetchTime;

  // Constructor: Give the librarian an API service to work with
  EventRepository(this._apiService);

  // ==================== GET ALL EVENTS ====================
  /// Fetch all events from the API
  /// 
  /// The librarian checks:
  /// 1. "Do I remember these events from recently?" → Return from cache
  /// 2. "No? Let me ask the waiter (API)" → Fetch from server
  Future<List<Event>> getEvents({bool forceRefresh = false}) async {
    // If we have cached events and they're fresh (< 5 minutes old), use cache
    if (!forceRefresh && 
        _cachedEvents != null && 
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!) < const Duration(minutes: 5)) {
      print('📚 Using cached events (${_cachedEvents!.length} events)');
      return _cachedEvents!;
    }

    try {
      print('🌐 Fetching events from API...');
      
      // Ask the waiter (API) for events
      final response = await _apiService.get('/events');
      
      // Convert JSON response to List of Event objects
      final List<dynamic> jsonList = response.data;
      final events = jsonList.map((json) => Event.fromJson(json)).toList();
      
      // Save to cache (librarian remembers for next time)
      _cachedEvents = events;
      _lastFetchTime = DateTime.now();
      
      print('✅ Fetched ${events.length} events successfully');
      return events;
      
    } catch (e) {
      print('❌ Error fetching events from API: $e');
      print('📦 Using mock data as fallback...');
      
      // If fetch fails but we have cached events, return those
      if (_cachedEvents != null) {
        print('📚 Returning cached events as fallback');
        return _cachedEvents!;
      }
      
      // No cache available, use mock data
      print('✅ Returning mock data (${MockData.getMockEvents().length} events)');
      return MockData.getMockEvents();
    }
  }

  // ==================== GET SINGLE EVENT ====================
  /// Fetch one specific event by ID
  /// Like asking librarian: "Show me book #5"
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

  // ==================== CREATE EVENT ====================
  /// Create a new event
  /// Like asking librarian: "Add this new book to the collection"
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
      throw Exception('Failed to create event: $e');
    }
  }

  // ==================== UPDATE EVENT ====================
  /// Update an existing event
  /// Like asking librarian: "Update the info for book #5"
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
      throw Exception('Failed to update event: $e');
    }
  }

  // ==================== DELETE EVENT ====================
  /// Delete an event
  /// Like asking librarian: "Remove book #5 from collection"
  Future<void> deleteEvent(int id) async {
    try {
      print('🌐 Deleting event #$id...');
      
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
    return allEvents.where((event) => event.type == 'past').toList();
  }

  /// Search events by query (title or location)
  Future<List<Event>> searchEvents(String query) async {
    final allEvents = await getEvents();
    final lowerQuery = query.toLowerCase();
    
    return allEvents.where((event) {
      return event.title.toLowerCase().contains(lowerQuery) ||
             event.location.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // ==================== CACHE MANAGEMENT ====================
  /// Clear the cache (force next fetch to get fresh data)
  void _clearCache() {
    _cachedEvents = null;
    _lastFetchTime = null;
    print('🗑️ Cache cleared');
  }

  /// Force refresh events (ignore cache)
  Future<List<Event>> refreshEvents() async {
    return getEvents(forceRefresh: true);
  }
}
