import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io';
import '../../core/models/post_model.dart';

class PostCardWidget extends StatefulWidget {
  final Post post;
  final VoidCallback? onLike;
  final VoidCallback? onComment;
  final VoidCallback? onShare;
  final bool isLiked;

  const PostCardWidget({
    Key? key,
    required this.post,
    this.onLike,
    this.onComment,
    this.onShare,
    this.isLiked = false,
  }) : super(key: key);

  @override
  State<PostCardWidget> createState() => _PostCardWidgetState();
}

class _PostCardWidgetState extends State<PostCardWidget> {
  bool _isLiked = false;
  int _likeCount = 0;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.isLiked;
    _likeCount = widget.post.likesCount;
  }

  String _formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _handleLike() {
    setState(() {
      if (_isLiked) {
        _isLiked = false;
        _likeCount--;
      } else {
        _isLiked = true;
        _likeCount++;
      }
    });
    widget.onLike?.call();
  }

  ImageProvider? _getImageProvider(String imageUrl) {
    try {
      // Check if it's a local file path
      if (imageUrl.startsWith('/') || imageUrl.startsWith('file://')) {
        return FileImage(File(imageUrl.replaceFirst('file://', '')));
      }
      // Check if it's a network URL
      else if (imageUrl.startsWith('http')) {
        return CachedNetworkImageProvider(imageUrl);
      }
      // Otherwise, assume it's a local asset
      else {
        return AssetImage(imageUrl);
      }
    } catch (e) {
      print('Error loading image: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.grey[50]!,
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with user info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // User avatar
                  Container(
                    width: 48.0,
                    height: 48.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blue[100]!,
                        width: 2.0,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 24.0,
                      backgroundImage: widget.post.userPhotoUrl != null
                          ? _getImageProvider(widget.post.userPhotoUrl!)
                          : null,
                      backgroundColor: Colors.blue[100],
                      child: widget.post.userPhotoUrl == null
                          ? Text(
                              widget.post.userName?.substring(0, 1).toUpperCase() ?? 'U',
                              style: TextStyle(
                                color: Colors.blue[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 18.0,
                              ),
                            )
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12.0),
                  
                  // User name and time
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.userName ?? 'Unknown User',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16.0,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 2.0),
                        Row(
                          children: [
                            if (widget.post.isShared) ...[
                              Icon(
                                Icons.share,
                                size: 12.0,
                                color: Colors.blue[600],
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                'Shared',
                                style: TextStyle(
                                  color: Colors.blue[600],
                                  fontSize: 11.0,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 8.0),
                            ],
                            Icon(
                              Icons.access_time,
                              size: 12.0,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4.0),
                            Text(
                              _formatTimeAgo(widget.post.createdAt),
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12.0,
                              ),
                            ),
                            if (widget.post.location != null) ...[
                              const SizedBox(width: 8.0),
                              Icon(
                                Icons.location_on,
                                size: 12.0,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4.0),
                              Text(
                                widget.post.location!,
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12.0,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // More options button
                  IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                    onPressed: () {
                      // Show more options
                      _showMoreOptions(context);
                    },
                  ),
                ],
              ),
            ),
            
            // Shared post indicator and original post
            if (widget.post.isShared && widget.post.originalPost != null) ...[
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12.0),
                  color: Colors.grey[50],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Original post header
                    Row(
                      children: [
                        Container(
                          width: 32.0,
                          height: 32.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.grey[300]!, width: 1.0),
                          ),
                          child: CircleAvatar(
                            radius: 16.0,
                            backgroundImage: widget.post.originalPost!.userPhotoUrl != null
                                ? _getImageProvider(widget.post.originalPost!.userPhotoUrl!)
                                : null,
                            backgroundColor: Colors.grey[200],
                            child: widget.post.originalPost!.userPhotoUrl == null
                                ? Text(
                                    widget.post.originalPost!.userName?.substring(0, 1).toUpperCase() ?? 'U',
                                    style: TextStyle(
                                      fontSize: 12.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.post.originalPost!.userName ?? 'Unknown User',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14.0,
                                  color: Colors.black87,
                                ),
                              ),
                              Text(
                                _formatTimeAgo(widget.post.originalPost!.createdAt),
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 11.0,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8.0),
                    // Original post content
                    if (widget.post.originalPost!.content.isNotEmpty)
                      Text(
                        widget.post.originalPost!.content,
                        style: const TextStyle(
                          fontSize: 14.0,
                          color: Colors.black87,
                          height: 1.4,
                        ),
                      ),
                    // Original post image
                    if (widget.post.originalPost!.imageUrl != null)
                      Container(
                        margin: const EdgeInsets.only(top: 8.0),
                        height: 200.0,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          image: DecorationImage(
                            image: _getImageProvider(widget.post.originalPost!.imageUrl!)!,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8.0),
            ],
            
            // Post content
            if (widget.post.content.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  widget.post.content,
                  style: const TextStyle(
                    fontSize: 15.0,
                    color: Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),
            
            // Post image
            if (widget.post.imageUrl != null)
              Padding(
                padding: const EdgeInsets.only(top: 12.0),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.0),
                    boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8.0,
                          offset: const Offset(0, 4),
                        ),
                      ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12.0),
                    child: Image(
                      image: _getImageProvider(widget.post.imageUrl!) ?? const NetworkImage(''),
                      width: double.infinity,
                      height: 200.0,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          height: 200.0,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 200.0,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              size: 48.0,
                              color: Colors.grey,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            
            const SizedBox(height: 16.0),
            
            // Interaction stats
            if (_likeCount > 0 || widget.post.commentsCount > 0 || widget.post.viewsCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    if (_likeCount > 0) ...[
                      Icon(
                        Icons.favorite,
                        size: 16.0,
                        color: Colors.red[400],
                      ),
                      const SizedBox(width: 4.0),
                      Text(
                        '$_likeCount',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 6.0,
                        ),
                      ),
                    ],
                    const Spacer(),
                    if (widget.post.commentsCount > 0)
                      Text(
                        '${widget.post.commentsCount}comment',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 5.0,
                        ),
                      ),
                    if (widget.post.commentsCount > 0 && widget.post.viewsCount > 0)
                      Text(
                        ' • ',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 6.0,
                        ),
                      ),
                    if (widget.post.viewsCount > 0)
                      Text(
                        '${widget.post.viewsCount} views',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 6.0,
                        ),
                      ),
                  ],
                ),
              ),
            
            // Interaction buttons
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: Colors.grey[200]!,
                    width: 1.0,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Like button
                  Expanded(
                    child: TextButton.icon(
                      onPressed: _handleLike,
                      icon: Icon(
                        _isLiked ? Icons.favorite : Icons.favorite_border,
                        color: _isLiked ? Colors.red[400] : Colors.grey[600],
                        size: 20.0,
                      ),
                      label: Text(
                        widget.post.likesCount > 0 ? '${widget.post.likesCount} Likes' : 'Like',
                        style: TextStyle(
                          color: _isLiked ? Colors.red[400] : Colors.grey[600],
                          fontSize: 9.0,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  
                  // Comment button
                  Expanded(
                    child: TextButton.icon(
                      onPressed: widget.onComment,
                      icon: Icon(
                        Icons.comment,
                        color: Colors.grey[600],
                        size: 20.0,
                      ),
                      label: Text(
                        widget.post.commentsCount > 0 ? '${widget.post.commentsCount} Comments' : 'Comment',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 9.0,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                  
                  // Share button
                  Expanded(
                    child: TextButton.icon(
                      onPressed: widget.onShare,
                      icon: Icon(
                        Icons.share,
                        color: Colors.grey[600],
                        size: 20.0,
                      ),
                      label: Text(
                        'Share',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 9.0,
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.0,
                height: 4.0,
                margin: const EdgeInsets.symmetric(vertical: 12.0),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.0),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.share),
                      title: const Text('Share'),
                      onTap: () {
                        Navigator.pop(context);
                        widget.onShare?.call();
                      },
                    ),
                    if (widget.post.isShared) ...[
                      ListTile(
                        leading: const Icon(Icons.link),
                        title: const Text('View Original Post'),
                        onTap: () {
                          Navigator.pop(context);
                          // Navigate to original post
                        },
                      ),
                    ],
                    ListTile(
                      leading: const Icon(Icons.bookmark_border),
                      title: const Text('Bookmark'),
                      onTap: () {
                        Navigator.pop(context);
                        // Bookmark logic
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.flag_outlined),
                      title: const Text('Report'),
                      onTap: () {
                        Navigator.pop(context);
                        // Report logic
                      },
                    ),
                    if (widget.post.userId == Supabase.instance.client.auth.currentUser?.id) ...[
                      ListTile(
                        leading: const Icon(Icons.delete, color: Colors.red),
                        title: const Text('Delete', style: TextStyle(color: Colors.red)),
                        onTap: () {
                          Navigator.pop(context);
                          // Delete post logic
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}