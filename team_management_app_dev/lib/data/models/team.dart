// Team model represents a team in the application
class Team {
  final int id;
  final String name;
  final int membersCount;
  final String? icon;
  final String? description;
  final int ownerId;
  final List<Map<String, dynamic>>? members;

  Team({
    required this.id,
    required this.name,
    required this.membersCount,
    this.icon,
    this.description,
    required this.ownerId,
    this.members,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unnamed',
      membersCount: (json['members'] as List<dynamic>?)?.length ?? 0,
      icon: json['metadata']?['Icon'],
      description: json['description'],
      ownerId: json['ownerId'] ?? 0,
      members: (json['members'] as List<dynamic>?)
              ?.map((m) => m as Map<String, dynamic>)
              .toList() ??
          [],
    );
  }

  // Extract member IDs
  List<int> get memberIds {
    return members?.map((m) => m['id'] as int).toList() ?? [];
  }
}
