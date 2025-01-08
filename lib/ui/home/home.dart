import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io'; // Để sử dụng File
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

class SocialHomePage extends StatefulWidget {
  const SocialHomePage({super.key});

  @override
  State<SocialHomePage> createState() => _SocialHomePageState();
}

class _SocialHomePageState extends State<SocialHomePage> {
  final List<Map<String, String>> posts = [
    {
      'user': 'John Doe',
      'text': 'This is my first post!',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'user': 'Jane Smith',
      'text': 'Loving the new features on this app.',
      'image': 'https://via.placeholder.com/150',
    },
    {
      'user': 'Bob Marley',
      'text': 'Here is a cool photo from my trip.',
      'image': 'https://via.placeholder.com/150',
    },
  ];

  File? _imageFile;

  // Xử lý việc chọn ảnh từ thư viện hoặc chụp ảnh
  final ImagePicker _picker = ImagePicker();
  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = File(image.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      navigationBar: const CupertinoNavigationBar(
        middle: Text('Social App'),
      ),
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.album), label: 'Discovery'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
            BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          return index == 0
              ? HomeTab(posts: posts, onPickImage: _pickImage, imageFile: _imageFile)
              : index == 1
              ? StoryTab() // Thêm tab xem Story
              : Scaffold();
        },
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  final List<Map<String, String>> posts;
  final Future<void> Function() onPickImage;
  final File? imageFile;

  const HomeTab({
    super.key,
    required this.posts,
    required this.onPickImage,
    this.imageFile,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Social Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_a_photo),
            onPressed: onPickImage,
          ),
        ],
      ),
      body: Column(
        children: [
          // Form đăng bài
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Avatar người dùng
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage('https://via.placeholder.com/150'), // Thay bằng ảnh người dùng
                ),
                const SizedBox(height: 10),
                // TextField nhập nội dung
                TextField(
                  decoration: const InputDecoration(hintText: 'Write something...'),
                ),
                const SizedBox(height: 10),
                imageFile == null
                    ? Container()
                    : Image.file(imageFile!),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    // Thực hiện hành động đăng bài ở đây
                  },
                  child: const Text('Post'),
                ),
              ],
            ),
          ),
          // Hiển thị danh sách bài đăng
          Expanded(
            child: ListView.builder(
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                return PostCard(
                  post: post,
                  onTapAvatar: () {
                    // Chuyển đến trang cá nhân khi nhấn vào avatar
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfilePage(user: post['user']!, imageUrl: post['image']!),
                      ),
                    );
                  },
                  onTapImage: () {
                    // Phóng to ảnh khi nhấn vào ảnh
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PhotoViewPage(imageUrl: post['image']!),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class PostCard extends StatelessWidget {
  final Map<String, String> post;
  final VoidCallback onTapAvatar;
  final VoidCallback onTapImage;

  const PostCard({
    super.key,
    required this.post,
    required this.onTapAvatar,
    required this.onTapImage,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: GestureDetector(
              onTap: onTapAvatar, // Gọi hàm khi nhấn vào avatar
              child: CircleAvatar(
                backgroundImage: NetworkImage(post['image']!),
              ),
            ),
            title: Text(post['user']!),
            subtitle: const Text('Just now'),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(post['text']!),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GestureDetector(
              onTap: onTapImage, // Gọi hàm khi nhấn vào ảnh để phóng to
              child: Image.network(post['image']!),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.thumb_up),
                      onPressed: () {},
                    ),
                    const Text('Like'),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.comment),
                      onPressed: () {},
                    ),
                    const Text('Comment'),
                  ],
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.share),
                      onPressed: () {},
                    ),
                    const Text('Share'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  final String user;
  final String imageUrl;

  const ProfilePage({
    super.key,
    required this.user,
    required this.imageUrl,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool isFollowing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user),
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(widget.imageUrl),
          ),
          const SizedBox(height: 20),
          Text(widget.user, style: const TextStyle(fontSize: 24)),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              setState(() {
                isFollowing = !isFollowing;
              });
            },
            child: Text(isFollowing ? 'Unfollow' : 'Follow'),
          ),
        ],
      ),
    );
  }
}

class PhotoViewPage extends StatelessWidget {
  final String imageUrl;

  const PhotoViewPage({super.key, required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Image View")),
      body: PhotoViewGallery.builder(
        itemCount: 1,
        builder: (context, index) {
          return PhotoViewGalleryPageOptions(
            imageProvider: NetworkImage(imageUrl),
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered,
          );
        },
        scrollPhysics: BouncingScrollPhysics(),
        backgroundDecoration: BoxDecoration(
          color: Colors.black,
        ),
      ),
    );
  }
}

class StoryTab extends StatelessWidget {
  final List<String> stories = [
    'https://via.placeholder.com/150',
    'https://via.placeholder.com/150',
    'https://via.placeholder.com/150',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stories'),
      ),
      body: ListView.builder(
        itemCount: stories.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundImage: NetworkImage(stories[index]),
                ),
                const SizedBox(height: 5),
                const Text('User Story'),
              ],
            ),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(const SocialApp());
}

class SocialApp extends StatelessWidget {
  const SocialApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Social App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SocialHomePage(),
    );
  }
}