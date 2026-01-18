// stores team info and members for filtering events and permissions
class Team {
  final int id;
  final String name;
  final int membersCount; // total members for display in UI
  final String? icon;
  final String? description; // team description for context
  final int ownerId; // creator of team, has full permissions
  final List<Map<String, dynamic>>? members; // full member objects with id and name

  Team({
    required this.id,
    required this.name,
    required this.membersCount,
    this.icon,
    this.description,
    required this.ownerId,
    this.members,
  });

  // converts JSON from API to Team object
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unnamed',
      membersCount: (json['members'] as List<dynamic>?)?.length ?? 0,
      icon: json['metadata']?['Icon'], // nested in metadata object
      description: json['description'],
      ownerId: json['ownerId'] ?? 0,
      members: (json['members'] as List<dynamic>?)
              ?.map((m) => m as Map<String, dynamic>)
              .toList() ??
          [], // stores full member objects for display
    );
  }

  // extracts member IDs from full member objects for filtering
  List<int> get memberIds {
    return members?.map((m) => m['id'] as int).toList() ?? [];
  }
}
