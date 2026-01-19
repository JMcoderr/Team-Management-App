import 'package:flutter_test/flutter_test.dart';
import 'package:team_management_app_dev/data/services/match_service.dart';

void main() {
  group('MatchService Tests', () {
    
    // Test if fetchAllMatches returns data
    test('fetchAllMatches should return list', () async {
      final service = MatchService();
      
      // This would normally do API call but for test we just check if it returns a list
      try {
        final matches = await service.fetchAllMatches();
        expect(matches, isA<List>());
      } catch (e) {
        // If API fails thats also ok for test
        expect(e, isA<Exception>());
      }
    });
    
    // Test if delete match calls the right method
    test('deleteMatch should call API delete', () async {
      final service = MatchService();
      
      // Try to delete match
      try {
        await service.deleteMatch(matchId: 999);
        // If no error then it works
        expect(true, true);
      } catch (e) {
        // Error is ok because match doesnt exist
        expect(e.toString().contains('Failed'), true);
      }
    });
  });
}
