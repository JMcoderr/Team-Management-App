// Team model - represents a team in the app
class Team {
  final int id;
  final String name;
  final String description;
  final int memberCount;
  final String? imageUrl;
  final DateTime createdAt;

  Team({
    required this.id,
    required this.name,
    required this.description,
    required this.memberCount,
    this.imageUrl,
    required this.createdAt,
  });

  // Convert JSON from API to Team object
  factory Team.fromJson(Map<String, dynamic> json) {
    return Team(
      id: json['id'] ?? 0,
      name: json['name'] ?? 'Unknown Team',
      description: json['description'] ?? '',
      memberCount: json['memberCount'] ?? 0,
      imageUrl: json['imageUrl'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  // Convert Team object to JSON for API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'memberCount': memberCount,
      'imageUrl': imageUrl,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Copy team with some changes
  Team copyWith({
    int? id,
    String? name,
    String? description,
    int? memberCount,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return Team(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      memberCount: memberCount ?? this.memberCount,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Team{id: $id, name: $name, members: $memberCount}';
  }
}
