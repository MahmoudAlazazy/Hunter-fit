class User {
  final String? id;
  final String? name;
  final String? email;
  final String? username;
  final String? photoUrl;
  final String? avatarUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? profileData;

  User({
    this.id,
    this.name,
    this.email,
    this.username,
    this.photoUrl,
    this.avatarUrl,
    this.createdAt,
    this.updatedAt,
    this.profileData,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString(),
      name: json['name'] ?? json['full_name'] ?? json['fullName'],
      email: json['email'],
      username: json['username'] ?? json['user_name'],
      photoUrl: json['photo_url'] ?? json['photoUrl'] ?? json['avatar_url'] ?? json['avatarUrl'],
      avatarUrl: json['avatar_url'] ?? json['avatarUrl'] ?? json['photo_url'] ?? json['photoUrl'],
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      profileData: json['profile'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'username': username,
      'photo_url': photoUrl,
      'avatar_url': avatarUrl,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'profile': profileData,
    };
  }

  User copyWith({
    String? id,
    String? name,
    String? email,
    String? username,
    String? photoUrl,
    String? avatarUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? profileData,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      photoUrl: photoUrl ?? this.photoUrl,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      profileData: profileData ?? this.profileData,
    );
  }
}