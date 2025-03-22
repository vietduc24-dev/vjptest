import 'package:flutter/material.dart';
import 'package:vjptest/common/widgets/page_wrapper.dart';

class GroupListScreen extends StatelessWidget {
  const GroupListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return PageWrapper(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Groups'),
          automaticallyImplyLeading: false,
        ),
        body: ListView.builder(
          itemCount: 5,
          itemBuilder: (context, index) {
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.primaries[index % Colors.primaries.length],
                  child: Text('G${index + 1}'),
                ),
                title: Text('Group ${index + 1}'),
                subtitle: Text('${3 + index} members'),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    // TODO: Show group options
                  },
                ),
                onTap: () {
                  // TODO: Navigate to group details
                },
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Create new group
          },
          child: const Icon(Icons.add),
        ),
      ),
    );
  }
} 