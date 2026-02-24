import 'package:flutter/material.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(icon: const Icon(Icons.settings_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(radius: 50, child: Text('U', style: TextStyle(fontSize: 40))),
            const SizedBox(height: 16),
            Text('User Name', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
            const Text('@username', style: TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Supporter | Helping others overcome medical challenges. Feel free to reach out!',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _StatColumn(label: 'Followers', count: '1.2k'),
                const SizedBox(width: 40),
                _StatColumn(label: 'Following', count: '850'),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  TabBar(
                    tabs: [
                      Tab(text: 'Posts'),
                      Tab(text: 'Replies'),
                    ],
                  ),
                  SizedBox(
                    height: 400, // Fixed height for demo
                    child: TabBarView(
                      children: [
                        Center(child: Text('No posts yet')),
                        Center(child: Text('No replies yet')),
                      ],
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final String label;
  final String count;

  const _StatColumn({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }
}
