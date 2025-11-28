class Comment {
  final String? id;
  final String postId;
  final String userId;
  final String content;
  final String? commentImage;
  final int likesCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  
  // User information for display
  final String? userName;
  final String? userPhotoUrl;
  
  // Reply support
  final String? parentCommentId;
  final bool isReply;
  final int repliesCount;
  
  // Additional metadata
  final bool isEdited;
  final bool isDeleted;
  final String? editReason;

  Comment({
    this.id,
    required this.postId,
    required this.userId,
    required this.content,
    this.commentImage,
    this.likesCount = 0,
    this.createdAt,
    this.updatedAt,
    this.userName,
    this.userPhotoUrl,
    this.parentCommentId,
    this.isReply = false,
    this.repliesCount = 0,
    this.isEdited = false,
    this.isDeleted = false,
    this.editReason,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      postId: json['post_id'] ?? json['postId'],
      userId: json['user_id'] ?? json['userId'],
      content: json['content'] ?? '',
      commentImage: json['comment_image'] ?? json['commentImage'],
      likesCount: json['likes_count'] ?? json['likesCount'] ?? 0,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at']) : null,
      userName: json['user_name'] ?? json['userName'] ?? json['profiles']?['username'],
      userPhotoUrl: json['user_photo_url'] ?? json['userPhotoUrl'] ?? json['profiles']?['avatar_url'],
      parentCommentId: json['parent_comment_id'] ?? json['parentCommentId'],
      isReply: json['is_reply'] ?? json['isReply'] ?? false,
      repliesCount: json['replies_count'] ?? json['repliesCount'] ?? 0,
      isEdited: json['is_edited'] ?? json['isEdited'] ?? false,
      isDeleted: json['is_deleted'] ?? json['isDeleted'] ?? false,
      editReason: json['edit_reason'] ?? json['editReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'post_id': postId,
      'user_id': userId,
      'content': content,
      'comment_image': commentImage,
      'likes_count': likesCount,
      'parent_comment_id': parentCommentId,
      'is_reply': isReply,
      'replies_count': repliesCount,
      'is_edited': isEdited,
      'is_deleted': isDeleted,
      'edit_reason': editReason,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Comment copyWith({
    String? id,
    String? postId,
    String? userId,
    String? content,
    String? commentImage,
    int? likesCount,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? userName,
    String? userPhotoUrl,
    String? parentCommentId,
    bool? isReply,
    int? repliesCount,
    bool? isEdited,
    bool? isDeleted,
    String? editReason,
  }) {
    return Comment(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      commentImage: commentImage ?? this.commentImage,
      likesCount: likesCount ?? this.likesCount,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      parentCommentId: parentCommentId ?? this.parentCommentId,
      isReply: isReply ?? this.isReply,
      repliesCount: repliesCount ?? this.repliesCount,
      isEdited: isEdited ?? this.isEdited,
      isDeleted: isDeleted ?? this.isDeleted,
      editReason: editReason ?? this.editReason,
    );
  }
}