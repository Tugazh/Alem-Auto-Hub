class CommunityModel {
  final String id;
  final String name;
  final String description;
  final String emoji;
  final int membersCount;
  final bool isJoined;
  final bool isVerified;
  final String? coverUrl;

  const CommunityModel({
    required this.id,
    required this.name,
    required this.description,
    required this.emoji,
    required this.membersCount,
    required this.isJoined,
    required this.isVerified,
    this.coverUrl,
  });

  factory CommunityModel.fromJson(Map<String, dynamic> json) {
    return CommunityModel(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '🚗',
      membersCount: (json['membersCount'] as num?)?.toInt() ?? 0,
      isJoined: json['isJoined'] as bool? ?? false,
      isVerified: json['isVerified'] as bool? ?? false,
      coverUrl: json['coverUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'emoji': emoji,
      'membersCount': membersCount,
      'isJoined': isJoined,
      'isVerified': isVerified,
      'coverUrl': coverUrl,
    };
  }

  CommunityModel copyWith({
    String? id,
    String? name,
    String? description,
    String? emoji,
    int? membersCount,
    bool? isJoined,
    bool? isVerified,
    String? coverUrl,
  }) {
    return CommunityModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      emoji: emoji ?? this.emoji,
      membersCount: membersCount ?? this.membersCount,
      isJoined: isJoined ?? this.isJoined,
      isVerified: isVerified ?? this.isVerified,
      coverUrl: coverUrl ?? this.coverUrl,
    );
  }
}

class CommunityMember {
  final String id;
  final String name;
  final String? avatarUrl;

  const CommunityMember({required this.id, required this.name, this.avatarUrl});

  factory CommunityMember.fromJson(Map<String, dynamic> json) {
    return CommunityMember(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      avatarUrl: json['avatarUrl']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'avatarUrl': avatarUrl};
  }
}
