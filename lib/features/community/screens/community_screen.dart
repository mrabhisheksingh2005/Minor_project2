import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../profile/providers/app_provider.dart';

class CommunityPost {
  final String id;
  final String authorName;
  final String authorTitle;
  final String content;
  final String timestamp;
  final List<String> tags;
  int likes;
  bool isLiked;
  final List<String> comments;

  CommunityPost({
    required this.id,
    required this.authorName,
    required this.authorTitle,
    required this.content,
    required this.timestamp,
    required this.tags,
    required this.likes,
    this.isLiked = false,
    required this.comments,
  });
}

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final List<CommunityPost> _posts = [
    CommunityPost(
      id: '1',
      authorName: 'Ramesh Singh',
      authorTitle: 'Wheat Farmer • Punjab',
      content: 'Has anyone seen these dark spots on late wheat leaf tips? Appears after the heavy morning mist last week. Is it wheat rust or standard blight?',
      timestamp: '2 hours ago',
      tags: ['#WheatRust', '#FarmingQueries'],
      likes: 12,
      comments: [
        'Looks like Early Stage Rust. Spray propiconazole soon.',
        'Same issue in Bhatinda! It is due to high moisture.'
      ],
    ),
    CommunityPost(
      id: '2',
      authorName: 'Anil K. Verma',
      authorTitle: 'Horticulture • Haryana',
      content: 'Successfully managed aphids on my pepper crops using organic garlic-neem solution! Extremely cheap and took only 3 sprays.',
      timestamp: '1 day ago',
      tags: ['#OrganicPestControl', '#EcoFarming'],
      likes: 38,
      comments: [
        'Can you share the exact recipe ratio?',
        'Yes, neem works wonders if combined with mild soap.'
      ],
    ),
    CommunityPost(
      id: '3',
      authorName: 'Savita Devi',
      authorTitle: 'Tomato Grower • UP',
      content: 'Highly recommend using the Crop Recommendation tool on the home dashboard. Pre-populated soil pH checks helped me switch to legumes this cycle and soil texture is much healthier!',
      timestamp: '3 days ago',
      tags: ['#CropRotation', '#SoilAdvisory'],
      likes: 45,
      comments: [
        'Legumes replenish nitrogen! Great move.'
      ],
    ),
  ];

  final _postController = TextEditingController();
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _postController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  void _createNewPost(String farmerName, String farmerLocation) {
    if (_postController.text.trim().isEmpty) return;

    setState(() {
      _posts.insert(
        0,
        CommunityPost(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          authorName: farmerName,
          authorTitle: 'Farmer • $farmerLocation',
          content: _postController.text.trim(),
          timestamp: 'Just now',
          tags: ['#FarmerShare'],
          likes: 0,
          comments: [],
        ),
      );
    });

    _postController.clear();
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Your update was shared with the AgriVision Community!')),
    );
  }

  void _showAddPostDialog(String farmerName, String farmerLocation) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Share Farming Update'),
          content: TextField(
            controller: _postController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: "What's happening in your fields today? Share a tip or ask a query...",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => _createNewPost(farmerName, farmerLocation),
              child: const Text('Post Update'),
            ),
          ],
        );
      },
    );
  }

  void _showCommentsDialog(CommunityPost post) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Replies (${post.comments.length})',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const Divider(height: 24),
                  if (post.comments.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.0),
                      child: Center(child: Text('No replies yet. Be the first to answer!')),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 250),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: post.comments.length,
                        itemBuilder: (context, idx) {
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            leading: const CircleAvatar(
                              child: Icon(Icons.account_circle_outlined, size: 24),
                            ),
                            title: Text(
                              post.comments[idx],
                              style: const TextStyle(fontSize: 13),
                            ),
                          );
                        },
                      ),
                    ),
                  const Divider(),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: 'Add an advisory reply...',
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: () {
                          final text = _commentController.text.trim();
                          if (text.isNotEmpty) {
                            setState(() {
                              post.comments.add(text);
                            });
                            setModalState(() {});
                            _commentController.clear();
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agri Community Forum'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _posts.length,
        itemBuilder: (context, index) {
          final post = _posts[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.withOpacity(0.15)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author Info
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: colorScheme.primary.withOpacity(0.1),
                        child: Icon(Icons.person, color: colorScheme.primary),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              post.authorName,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              post.authorTitle,
                              style: TextStyle(color: theme.hintColor, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        post.timestamp,
                        style: TextStyle(color: theme.hintColor, fontSize: 11),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Content
                  Text(
                    post.content,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                  const SizedBox(height: 12),

                  // Tags
                  Wrap(
                    spacing: 8,
                    children: post.tags.map((tag) {
                      return Chip(
                        label: Text(tag, style: const TextStyle(fontSize: 10)),
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        backgroundColor: colorScheme.primary.withOpacity(0.08),
                        side: BorderSide.none,
                      );
                    }).toList(),
                  ),
                  const Divider(height: 24),

                  // Action Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        icon: Icon(
                          post.isLiked ? Icons.favorite : Icons.favorite_border,
                          color: post.isLiked ? Colors.red : Colors.grey,
                          size: 20,
                        ),
                        label: Text(
                          '${post.likes} Likes',
                          style: TextStyle(color: post.isLiked ? Colors.red : theme.hintColor, fontSize: 12),
                        ),
                        onPressed: () {
                          setState(() {
                            post.isLiked = !post.isLiked;
                            if (post.isLiked) {
                              post.likes++;
                            } else {
                              post.likes--;
                            }
                          });
                        },
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.mode_comment_outlined, color: Colors.grey, size: 20),
                        label: Text(
                          '${post.comments.length} Replies',
                          style: TextStyle(color: theme.hintColor, fontSize: 12),
                        ),
                        onPressed: () => _showCommentsDialog(post),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add),
        label: const Text('Ask Community'),
        onPressed: () => _showAddPostDialog(appProvider.farmerName, appProvider.farmerLocation),
      ),
    );
  }
}
