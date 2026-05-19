import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class TicketListScreen extends StatelessWidget {
  const TicketListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tickets = [
      {
        'title': 'Exchange reimbursement',
        'category': 'Reimbursement',
        'status': 'In Review',
        'priority': 'Medium',
      },
      {
        'title': 'Internship approval',
        'category': 'Internship',
        'status': 'Open',
        'priority': 'High',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tickets'),
        actions: [
          IconButton(
            onPressed: () => context.go('/announcements'),
            icon: const Icon(Icons.notifications_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go('/tickets/create'),
        label: const Text('New Ticket'),
        icon: const Icon(Icons.add),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tickets.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final ticket = tickets[index];

          return Card(
            elevation: 0,
            color: Colors.white,
            child: ListTile(
              title: Text(ticket['title']!),
              subtitle: Text(ticket['category']!),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(ticket['status']!),
                  Text(
                    ticket['priority']!,
                    style: const TextStyle(color: Colors.orange),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}