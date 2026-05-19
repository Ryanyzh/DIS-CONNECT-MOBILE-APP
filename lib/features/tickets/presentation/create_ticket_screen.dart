import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CreateTicketScreen extends StatelessWidget {
  const CreateTicketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Ticket'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                labelText: 'Ticket Title',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'Reimbursement',
                  child: Text('Reimbursement'),
                ),
                DropdownMenuItem(
                  value: 'Exchange',
                  child: Text('Exchange'),
                ),
                DropdownMenuItem(
                  value: 'Internship',
                  child: Text('Internship'),
                ),
                DropdownMenuItem(
                  value: 'Policy',
                  child: Text('Policy'),
                ),
              ],
              onChanged: (_) {},
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              maxLines: 5,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => context.go('/tickets'),
                child: const Text('Submit Ticket'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}