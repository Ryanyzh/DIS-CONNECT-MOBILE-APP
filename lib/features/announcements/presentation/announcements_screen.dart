import 'package:flutter/material.dart';

class AnnouncementsScreen extends StatelessWidget {
  const AnnouncementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Announcements'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            color: Colors.white,
            elevation: 0,
            child: ListTile(
              title: Text('Overseas Exchange Briefing'),
              subtitle: Text('Submit required documents by Friday.'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
          SizedBox(height: 12),
          Card(
            color: Colors.white,
            elevation: 0,
            child: ListTile(
              title: Text('Internship Declaration'),
              subtitle: Text('Reminder to update your internship details.'),
              trailing: Icon(Icons.chevron_right),
            ),
          ),
        ],
      ),
    );
  }
}