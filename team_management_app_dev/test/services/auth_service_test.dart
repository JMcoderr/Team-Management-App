import 'package:flutter_test/flutter_test.dart';
import 'package:team_management_app_dev/data/services/auth_service.dart';

void main() {
  group('AuthService Tests', () {
    
    // Test if AuthService singleton works
    test('AuthService should be singleton', () {
      final auth1 = AuthService();
      final auth2 = AuthService();
      
      // Both should be same instance
      expect(auth1, same(auth2));
    });
    
    // Test if logout clears token
    test('logout should clear token', () {
      final auth = AuthService();
      
      // Logout
      auth.logout();
      
      // Token should be gone so exception
      expect(() => auth.token, throwsException);
      expect(() => auth.userId, throwsException);
    });
    
    // Test if login throws exception without server
    test('login should throw exception on bad credentials', () async {
      final auth = AuthService();
      
      // Try to login with wrong data
      try {
        await auth.login('wrong', 'wrong');
        fail('Should have thrown exception');
      } catch (e) {
        // Exception is good
        expect(e, isA<Exception>());
      }
    });
  });
}
