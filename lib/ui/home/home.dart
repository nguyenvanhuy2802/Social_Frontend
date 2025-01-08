import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import "package:social_app/ui/discovery/discovery.dart";
import "package:social_app/ui/setting/setting.dart";
import "package:social_app/ui/follower/follower.dart";
import "package:social_app/ui/user/user.dart";

class SocialHomePage extends StatefulWidget {
  const SocialHomePage({super.key});

  @override
  State<SocialHomePage> createState() => _SocialHomePageState();
}

class _SocialHomePageState extends State<SocialHomePage> {
  final List<Widget> _tabs = [
    const HomeTab(),
    const FollowerTab(),
    const DiscoveryTab(),
    const AccountTab(),
    const SettingTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return CupertinoPageScaffold(
      child: CupertinoTabScaffold(
        tabBar: CupertinoTabBar(
          backgroundColor: Theme.of(context).colorScheme.onInverseSurface,
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.person_add), label: 'Followers'),
            BottomNavigationBarItem(
                icon: Icon(Icons.album), label: 'Discovery'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Account'),
            BottomNavigationBarItem(
                icon: Icon(Icons.settings), label: 'Settings'),
          ],
        ),
        tabBuilder: (BuildContext context, int index) {
          return _tabs[index];
        },
      ),
    );
  }
}

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Status Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 24,
                        backgroundImage: AssetImage(
                            'assets/avatar.png'), // Replace with user's avatar
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "What's on your mind?",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.deepPurple),
                        onPressed: () {
                          // Handle post submission
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Post Moment Video Section
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Post a Moment Video',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Handle video upload
                        },
                        icon: const Icon(Icons.video_camera_back),
                        label: const Text('Upload'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Moment Videos Section
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Moments',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 5, // Replace with actual moment video count
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Card(
                        elevation: 4,
                        child: Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: Text('Moment Video'),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Posts Section
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'Your Posts and Friends\' Posts',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            // Posts Section with Reaction, Comment, and Share Buttons
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: 1, // Replace with actual post count
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 4.0),
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Post Header
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 20,
                                backgroundImage: AssetImage(
                                    'assets/avatar.png'), // Replace with post owner's avatar
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'User Name',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              const Spacer(),
                              Text(
                                '2h ago', // Replace with post time
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Post Content
                          const Text(
                            'This is a sample post content. Replace this with the actual post.',
                          ),
                          const SizedBox(height: 10),

                          // Post Media
                          Container(
                            height: 200,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Center(
                              child: Text('Post Image/Video'),
                            ),
                          ),
                          const SizedBox(height: 10),

                          // Reaction, Comment, and Share Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Reaction Button
                              TextButton.icon(
                                onPressed: () {
                                  // Handle reaction (e.g., show a popup for emoji selection)
                                },
                                icon: const Icon(Icons.favorite,
                                    color: Colors.red),
                                label: const Text('React'),
                              ),

                              // Comment Button
                              TextButton.icon(
                                onPressed: () {
                                  // Handle comment (e.g., navigate to comment section)
                                },
                                icon: const Icon(Icons.comment,
                                    color: Colors.blue),
                                label: const Text('Comment'),
                              ),

                              // Share Button
                              TextButton.icon(
                                onPressed: () {
                                  // Handle share (e.g., invoke share functionality)
                                },
                                icon: const Icon(Icons.share,
                                    color: Colors.green),
                                label: const Text('Share'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
