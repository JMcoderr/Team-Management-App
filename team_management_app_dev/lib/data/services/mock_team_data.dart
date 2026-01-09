import '../models/team.dart';

// Mock data for teams when API is down
class MockTeamData {
  static List<Team> getMockTeams() {
    return [
      Team(
        id: 1,
        name: 'Dragons FC',
        description: 'Competitive soccer team based in Amsterdam',
        memberCount: 15,
        createdAt: DateTime(2025, 9, 1),
      ),
      Team(
        id: 2,
        name: 'Code Warriors',
        description: 'Gaming team focused on competitive esports',
        memberCount: 8,
        createdAt: DateTime(2025, 10, 15),
      ),
      Team(
        id: 3,
        name: 'Study Group A',
        description: 'HBO students working together on projects',
        memberCount: 12,
        createdAt: DateTime(2025, 11, 3),
      ),
      Team(
        id: 4,
        name: 'Basketball Legends',
        description: 'Amateur basketball team for fun matches',
        memberCount: 10,
        createdAt: DateTime(2025, 9, 20),
      ),
      Team(
        id: 5,
        name: 'Yoga Enthusiasts',
        description: 'Weekly yoga sessions and wellness activities',
        memberCount: 20,
        createdAt: DateTime(2025, 12, 1),
      ),
    ];
  }
}
