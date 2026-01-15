class Team {
  final int id;
  final String name;
  final int membersCount;
  final String? icon;
  final int ownerId;
  final List<int> memberIds; 

  Team({
    required this.id,
    required this.name,
    required this.membersCount,
    this.icon,
    required this.ownerId,
    required this.memberIds,
  });

  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unnamed',
      membersCount: (json['members'] as List<dynamic>?)?.length ?? 0,
      icon: json['metadata']?['Icon'],
      ownerId: json['ownerId'] ?? 0,
      memberIds: (json['members'] as List<dynamic>?)
              ?.map((m) => m['id'] as int)
              .toList() ??
          [],
    );
  }
}

