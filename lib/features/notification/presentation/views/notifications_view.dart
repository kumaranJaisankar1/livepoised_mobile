import 'package:flutter/material.dart';

class NotificationsView extends StatelessWidget {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView.separated(
        itemCount: 10,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          return ListTile(
            leading: const CircleAvatar(child: Icon(Icons.favorite, color: Colors.red, size: 20)),
            title: Text('Someone liked your post at index $index'),
            subtitle: const Text('2 hours ago'),
            onTap: () {},
          );
        },
      ),
    );
  }
}
