class Post {
  final String? id;
  final String userId;
  final String content;
  final String? imagePath;
  final String? imageUrl;
  final bool isPublic;
  final int likesCount;
  final int commentsCount;
  final int viewsCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // User information for display
  final String? userName;
  final String? userPhotoUrl;
  
  // Sharing and visibility
  final bool isShared;
  final String? originalPostId;
  final String? sharedByUserId;
  final DateTime? sharedAt;
  
  // Original post data for shared posts
  final Post? originalPost;
  
  // Additional metadata
  final List<String>? tags;
  final String? location;
  final bool isDeleted;

  Post({
    this.id,
    required this.userId,
    required this.content,
    this.imagePath,
    this.imageUrl,
    this.isPublic = true,
    this.likesCount = 0,
    this.commentsCount = 0,
    this.viewsCount = 0,
    this.createdAt,
    this.updatedAt,
    this.userName,
    this.userPhotoUrl,
    this.isShared = false,
    this.originalPostId,
    this.sharedByUserId,
    this.sharedAt,
    this.originalPost,
    this.tags,
    this.location,
    this.isDeleted = false,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id']?.toString(),
      userId: (json['user_id'] ?? json['userId'])?.toString() ?? '',
      content: json['content'] ?? '',
      imagePath: json['image_path'] ?? json['imagePath'],
      imageUrl: json['image_url'] ?? json['imageUrl'],
      isPublic: json['is_public'] ?? json['isPublic'] ?? true,
      likesCount: json['likes_count'] ?? json['likesCount'] ?? 0,
      commentsCount: json['comments_count'] ?? json['commentsCount'] ?? 0,
      viewsCount: json['views_count'] ?? json['viewsCount'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      userName: json['user_name'] ?? json['userName'] ?? json['profiles']?['username'],
      userPhotoUrl: json['user_photo_url'] ?? json['userPhotoUrl'] ?? json['profiles']?['avatar_url'],
      isShared: json['is_shared'] ?? json['isShared'] ?? false,
      originalPostId: (json['original_post_id'] ?? json['originalPostId'])?.toString(),
      sharedByUserId: (json['shared_by_user_id'] ?? json['sharedByUserId'])?.toString(),
      sharedAt: json['shared_at'] != null ? DateTime.parse(json['shared_at']) : null,
      originalPost: json['original_post'] != null ? Post.fromJson(json['original_post']) : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      location: json['location'],
      isDeleted: json['is_deleted'] ?? json['isDeleted'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'content': content,
      'image_path': imagePath,
      'image_url': imageUrl,
      'is_public': isPublic,
      'likes_count': likesCount,
      'comments_count': commentsCount,
      'views_count': viewsCount,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'is_shared': isShared,
      'original_post_id': originalPostId,
      'shared_by_user_id': sharedByUserId,
      'shared_at': sharedAt?.toIso8601String(),
      'tags': tags,
      'location': location,
      'is_deleted': isDeleted,
    };
  }

  Post copyWith({
    String? id,
    String? userId,
    String? content,
    String? imagePath,
    String? imageUrl,
    bool? isPublic,
    int? likesCount,
    int? commentsCount,
    int? viewsCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    String? userPhotoUrl,
    bool? isShared,
    String? originalPostId,
    String? sharedByUserId,
    DateTime? sharedAt,
    Post? originalPost,
    List<String>? tags,
    String? location,
    bool? isDeleted,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      imagePath: imagePath ?? this.imagePath,
      imageUrl: imageUrl ?? this.imageUrl,
      isPublic: isPublic ?? this.isPublic,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      viewsCount: viewsCount ?? this.viewsCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      isShared: isShared ?? this.isShared,
      originalPostId: originalPostId ?? this.originalPostId,
      sharedByUserId: sharedByUserId ?? this.sharedByUserId,
      sharedAt: sharedAt ?? this.sharedAt,
      originalPost: originalPost ?? this.originalPost,
      tags: tags ?? this.tags,
      location: location ?? this.location,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}