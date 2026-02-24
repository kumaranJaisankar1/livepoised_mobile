import 'package:flutter/material.dart';

class AllyView extends StatelessWidget {
  const AllyView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Find Allies')),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 5,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: const CircleAvatar(child: Text('A')),
              title: Text('Ally Candidate ${index + 1}'),
              subtitle: const Text('Category: Oncology | Active 2h ago'),
              trailing: ElevatedButton(
                onPressed: () {},
                child: const Text('Follow'),
              ),
            ),
          );
        },
      ),
    );
  }
}
