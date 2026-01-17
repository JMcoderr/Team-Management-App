// stores team info and members for filtering events and permissions
class Team {
  final int id;
  final String name;
  final int membersCount; // total members for display in UI
  final String? icon;
  final int ownerId; // creator of team, has full permissions
  final List<int> memberIds; // list of user IDs in team for filtering

  Team({
    required this.id,
    required this.name,
    required this.membersCount,
    this.icon,
    required this.ownerId,
    required this.memberIds,
  });

  // converts JSON from API to Team object
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unnamed',
      membersCount: (json['members'] as List<dynamic>?)?.length ?? 0,
      icon: json['metadata']?['Icon'], // nested in metadata object
      ownerId: json['ownerId'] ?? 0,
      memberIds:
          (json['members'] as List<dynamic>?)
              ?.map((m) => m['id'] as int)
              .toList() ??
          [], // extract just IDs from full member objects
    );
  }
}
