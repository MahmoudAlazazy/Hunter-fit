import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/social_media_provider.dart';
import '../core/models/post_model.dart';
import '../core/models/comment_model.dart';

class PostDetailScreen extends StatefulWidget {
  final Post post;

  const PostDetailScreen({Key? key, required this.post}) : super(key: key);

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isPostingComment = false;
  String _currentUserId = '';
  bool _isLiked = false;
  bool _isBookmarked = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadPostDetails();
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      setState(() {
        _currentUserId = user.id;
      });
    }
  }

  void _loadPostDetails() async {
    final socialProvider = Provider.of<SocialMediaProvider>(context, listen: false);
    
    // Load comments
    await socialProvider.fetchComments(widget.post.id!);
    
    // Check like status
    final liked = await socialProvider.isLikedByUser(_currentUserId, postId: widget.post.id);
    setState(() {
      _isLiked = liked;
    });
    
    // Check bookmark status
    final bookmarked = await socialProvider.isPostBookmarked(widget.post.id!, _currentUserId);
    setState(() {
      _isBookmarked = bookmarked;
    });
    
    // Record post view
    await socialProvider.recordPostView(widget.post.id!, userId: _currentUserId);
  }

  Future<void> _postComment() async {
    if (_commentController.text.trim().isEmpty) return;

    setState(() {
      _isPostingComment = true;
    });

    try {
      final socialProvider = Provider.of<SocialMediaProvider>(context, listen: false);
      
      // Validate inputs before creating comment
      if (_currentUserId.isEmpty || widget.post.id == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: User not logged in or invalid post')),
          );
        }
        return;
      }
      
      final success = await socialProvider.createComment(
        postId: widget.post.id!,
        userId: _currentUserId,
        content: _commentController.text.trim(),
      );

      if (success) {
        _commentController.clear();
        // Scroll to bottom to show new comment
        Future.delayed(const Duration(milliseconds: 100), () {
          if (_scrollController.hasClients) {
            _scrollController.animateTo(
              _scrollController.position.maxScrollExtent,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            );
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting comment: $e')),
      );
    } finally {
      setState(() {
        _isPostingComment = false;
      });
    }
  }

  Future<void> _toggleLike() async {
    final socialProvider = Provider.of<SocialMediaProvider>(context, listen: false);
    final newLikeStatus = await socialProvider.toggleLike(_currentUserId, postId: widget.post.id);
    setState(() {
      _isLiked = newLikeStatus;
    });
  }

  Future<void> _toggleBookmark() async {
    final socialProvider = Provider.of<SocialMediaProvider>(context, listen: false);
    final newBookmarkStatus = await socialProvider.toggleBookmark(widget.post.id!, _currentUserId);
    setState(() {
      _isBookmarked = newBookmarkStatus;
    });
  }

  void _sharePost() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Share functionality coming soon!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Post'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SocialMediaProvider>(
        builder: (context, socialProvider, child) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: Column(
                    children: [
                      _buildPostHeader(),
                      if (widget.post.content.isNotEmpty) _buildPostContent(),
                      if (widget.post.imagePath != null) _buildPostImage(),
                      _buildPostActions(socialProvider),
                      const Divider(height: 32),
                      _buildCommentsSection(socialProvider),
                    ],
                  ),
                ),
              ),
              _buildCommentInput(),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPostHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundImage: widget.post.userPhotoUrl != null
                ? CachedNetworkImageProvider(widget.post.userPhotoUrl!)
                : null,
            child: widget.post.userPhotoUrl == null
                ? Text(widget.post.userName?.substring(0, 1).toUpperCase() ?? 'U')
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.post.userName ?? 'Unknown User',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  _formatDate(widget.post.createdAt),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          if (!widget.post.isPublic)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Private',
                style: TextStyle(fontSize: 10, color: Colors.grey),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPostContent() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        widget.post.content,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildPostImage() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          widget.post.imagePath!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              height: 300,
              child: const Center(
                child: Icon(Icons.image, size: 64, color: Colors.grey),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPostActions(SocialMediaProvider socialProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          IconButton(
            onPressed: _toggleLike,
            icon: Icon(
              _isLiked ? Icons.favorite : Icons.favorite_border,
              color: _isLiked ? Colors.red : null,
            ),
          ),
          Text('${widget.post.likesCount}'),
          const SizedBox(width: 16),
          IconButton(
            onPressed: () {
              // Focus on comment input
              FocusScope.of(context).requestFocus(FocusNode());
            },
            icon: const Icon(Icons.comment_outlined),
          ),
          Text('${widget.post.commentsCount}'),
          const SizedBox(width: 16),
          IconButton(
            onPressed: _sharePost,
            icon: const Icon(Icons.share_outlined),
          ),
          const Spacer(),
          IconButton(
            onPressed: _toggleBookmark,
            icon: Icon(
              _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsSection(SocialMediaProvider socialProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Comments (${widget.post.commentsCount})',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
        ),
        const SizedBox(height: 16),
        if (socialProvider.isLoadingComments && socialProvider.comments.isEmpty)
          const Center(child: CircularProgressIndicator())
        else if (socialProvider.commentsError != null)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Error loading comments: ${socialProvider.commentsError}',
              style: TextStyle(color: Colors.red[400]),
            ),
          )
        else if (socialProvider.comments.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text('No comments yet. Be the first to comment!'),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: socialProvider.comments.length,
            itemBuilder: (context, index) {
              final comment = socialProvider.comments[index];
              return CommentCard(
                comment: comment,
                currentUserId: _currentUserId,
                onLike: () => _toggleCommentLike(comment.id!),
                onReply: () => _replyToComment(comment),
                onDelete: comment.userId == _currentUserId
                    ? () => _deleteComment(comment.id!)
                    : null,
                onCreateReply: (parentCommentId, content) async {
                  final socialProvider = Provider.of<SocialMediaProvider>(context, listen: false);
                  await socialProvider.createReply(
                    postId: widget.post.id!,
                    userId: _currentUserId,
                    content: content,
                    parentCommentId: parentCommentId,
                  );
                },
              );
            },
          ),
      ],
    );
  }

  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage: Supabase.instance.client.auth.currentUser?.userMetadata?['avatar_url'] != null
                ? NetworkImage(Supabase.instance.client.auth.currentUser!.userMetadata!['avatar_url']!)
                : null,
            child: Supabase.instance.client.auth.currentUser?.userMetadata?['avatar_url'] == null
                ? Text(Supabase.instance.client.auth.currentUser?.userMetadata?['username']?.substring(0, 1).toUpperCase() ?? 'U')
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey[300]!),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Colors.blue),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _isPostingComment ? null : _postComment,
            icon: _isPostingComment
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleCommentLike(String commentId) async {
    final socialProvider = Provider.of<SocialMediaProvider>(context, listen: false);
    await socialProvider.toggleLike(_currentUserId, commentId: commentId);
  }

  void _replyToComment(Comment comment) {
    // Set focus to comment input and prefill with reply
    _commentController.text = '@${comment.userName} ';
    FocusScope.of(context).requestFocus(FocusNode());
  }

  Future<void> _deleteComment(String commentId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final socialProvider = Provider.of<SocialMediaProvider>(context, listen: false);
      final success = await socialProvider.deleteComment(commentId, _currentUserId, widget.post.id!);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Comment deleted successfully')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete comment')),
        );
      }
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}

class CommentCard extends StatefulWidget {
  final Comment comment;
  final String currentUserId;
  final VoidCallback onLike;
  final VoidCallback onReply;
  final VoidCallback? onDelete;
  final Function(String parentCommentId, String content) onCreateReply;

  const CommentCard({
    Key? key,
    required this.comment,
    required this.currentUserId,
    required this.onLike,
    required this.onReply,
    this.onDelete,
    required this.onCreateReply,
  }) : super(key: key);

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool _isExpanded = false;
  bool _isLoadingReplies = false;
  List<Comment> _replies = [];
  final TextEditingController _replyController = TextEditingController();
  bool _isPostingReply = false;

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _loadReplies() async {
    if (!_isExpanded && widget.comment.repliesCount > 0) {
      setState(() {
        _isLoadingReplies = true;
      });

      try {
        final socialProvider = Provider.of<SocialMediaProvider>(context, listen: false);
        final replies = await socialProvider.fetchCommentReplies(widget.comment.id!);
        setState(() {
          _replies = replies;
          _isLoadingReplies = false;
          _isExpanded = true;
        });
      } catch (e) {
        setState(() {
          _isLoadingReplies = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading replies: $e')),
        );
      }
    } else {
      setState(() {
        _isExpanded = !_isExpanded;
      });
    }
  }

  Future<void> _postReply() async {
    if (_replyController.text.trim().isEmpty) return;

    setState(() {
      _isPostingReply = true;
    });

    try {
      await widget.onCreateReply(widget.comment.id!, _replyController.text.trim());
      _replyController.clear();
      
      // Reload replies to show the new one
      if (_isExpanded) {
        _loadReplies();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error posting reply: $e')),
      );
    } finally {
      setState(() {
        _isPostingReply = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SocialMediaProvider>(
      builder: (context, socialProvider, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: widget.comment.userPhotoUrl != null
                        ? CachedNetworkImageProvider(widget.comment.userPhotoUrl!)
                        : null,
                    child: widget.comment.userPhotoUrl == null
                        ? Text(widget.comment.userName?.substring(0, 1).toUpperCase() ?? 'U')
                        : null,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              widget.comment.userName ?? 'Unknown User',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _formatDate(widget.comment.createdAt),
                              style: TextStyle(color: Colors.grey[600], fontSize: 12),
                            ),
                            const Spacer(),
                            if (widget.onDelete != null)
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'delete') {
                                    widget.onDelete!();
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Text('Delete'),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(widget.comment.content),
                        if (widget.comment.commentImage != null) ...[
                          const SizedBox(height: 8),
                          SizedBox(
                            height: 150,
                            width: double.infinity,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                widget.comment.commentImage!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(Icons.image, color: Colors.grey),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            FutureBuilder<bool>(
                              future: socialProvider.isLikedByUser(widget.currentUserId, commentId: widget.comment.id),
                              builder: (context, snapshot) {
                                final isLiked = snapshot.data ?? false;
                                return GestureDetector(
                                  onTap: widget.onLike,
                                  child: Row(
                                    children: [
                                      Icon(
                                        isLiked ? Icons.favorite : Icons.favorite_border,
                                        size: 16,
                                        color: isLiked ? Colors.red : null,
                                      ),
                                      const SizedBox(width: 4),
                                      Text('${widget.comment.likesCount}'),
                                    ],
                                  ),
                                );
                              },
                            ),
                            const SizedBox(width: 16),
                            if (widget.comment.repliesCount > 0)
                              GestureDetector(
                                onTap: _loadReplies,
                                child: Row(
                                  children: [
                                    Icon(
                                      _isExpanded ? Icons.expand_less : Icons.expand_more,
                                      size: 16,
                                    ),
                                    const SizedBox(width: 4),
                                    Text('${widget.comment.repliesCount} replies'),
                                  ],
                                ),
                              )
                            else
                              GestureDetector(
                                onTap: widget.onReply,
                                child: const Row(
                                  children: [
                                    Icon(Icons.reply, size: 16),
                                    SizedBox(width: 4),
                                    Text('Reply'),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (_isExpanded) ...[
                const SizedBox(height: 8),
                if (_isLoadingReplies)
                  const Padding(
                    padding: EdgeInsets.only(left: 28.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else if (_replies.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 28.0),
                    child: Column(
                      children: _replies.map((reply) => _buildReplyCard(reply, socialProvider)).toList(),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 28.0, top: 8.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundImage: Supabase.instance.client.auth.currentUser?.userMetadata?['avatar_url'] != null
                            ? NetworkImage(Supabase.instance.client.auth.currentUser!.userMetadata!['avatar_url']!)
                            : null,
                        child: Supabase.instance.client.auth.currentUser?.userMetadata?['avatar_url'] == null
                            ? Text(Supabase.instance.client.auth.currentUser?.userMetadata?['username']?.substring(0, 1).toUpperCase() ?? 'U')
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _replyController,
                          decoration: InputDecoration(
                            hintText: 'Write a reply...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide(color: Colors.grey[300]!),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: const BorderSide(color: Colors.blue),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          ),
                          maxLines: null,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: _isPostingReply ? null : _postReply,
                        icon: _isPostingReply
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(Icons.send, size: 16, color: Colors.blue),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildReplyCard(Comment reply, SocialMediaProvider socialProvider) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundImage: reply.userPhotoUrl != null
                ? CachedNetworkImageProvider(reply.userPhotoUrl!)
                : null,
            child: reply.userPhotoUrl == null
                ? Text(reply.userName?.substring(0, 1).toUpperCase() ?? 'U')
                : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      reply.userName ?? 'Unknown User',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatDate(reply.createdAt),
                      style: TextStyle(color: Colors.grey[600], fontSize: 10),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(reply.content, style: const TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  children: [
                    FutureBuilder<bool>(
                      future: socialProvider.isLikedByUser(widget.currentUserId, commentId: reply.id),
                      builder: (context, snapshot) {
                        final isLiked = snapshot.data ?? false;
                        return GestureDetector(
                          onTap: () => socialProvider.toggleLike(widget.currentUserId, commentId: reply.id),
                          child: Row(
                            children: [
                              Icon(
                                isLiked ? Icons.favorite : Icons.favorite_border,
                                size: 12,
                                color: isLiked ? Colors.red : null,
                              ),
                              const SizedBox(width: 2),
                              Text('${reply.likesCount}', style: const TextStyle(fontSize: 10)),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
