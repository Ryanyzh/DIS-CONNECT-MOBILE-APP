import '../../../core/network/api_client.dart';
import '../models/ticket_model.dart';

class TicketRepository {
  final ApiClient apiClient;

  TicketRepository(this.apiClient);

  Future<List<Ticket>> getTickets() async {
    final data = await apiClient.get('/tickets') as List;

    return data.map((item) => Ticket.fromJson(item)).toList();
  }

  Future<Map<String, dynamic>> createTicket({
    required String subject,
    required String categoryId,
    String? description,
    String? priorityId,
    DateTime? dueAt,
  }) async {
    final body = <String, dynamic>{
      'subject': subject,
      'category_id': categoryId,
      'source': 'mobile',
      if (description != null && description.isNotEmpty) 'description': description,
      'priority_id': ?priorityId,
      if (dueAt != null) 'due_at': dueAt.toUtc().toIso8601String(),
    };
    final response = await apiClient.post('/api/v1/tickets', body);
    return response as Map<String, dynamic>;
  }

  Future<void> createAttachment({
    required String ticketId,
    required String fileName,
    required String filePath,
    required String fileType,
    required int fileSize,
  }) async {
    await apiClient.post('/api/v1/tickets/$ticketId/attachments', {
      'file_name': fileName,
      'file_path': filePath,
      'file_type': fileType,
      'file_size': fileSize,
    });
  }
}