import '../../../core/network/api_client.dart';
import '../models/ticket_model.dart';

class TicketRepository {
  final ApiClient apiClient;

  TicketRepository(this.apiClient);

  // Fetches the list of tickets for the current user
  Future<List<Ticket>> getTickets() async {
    final response =
        await apiClient.get('/api/v1/tickets') as Map<String, dynamic>;
    final list = response['tickets'] as List;
    return list
        .map((item) => Ticket.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  // Fetches the details of a specific ticket by its ID
  Future<Map<String, dynamic>> getTicket(String ticketId) async {
    return await apiClient.get('/api/v1/tickets/$ticketId')
        as Map<String, dynamic>;
  }

  // Creates a new ticket with the provided details
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
      if (description != null && description.isNotEmpty)
        'description': description,
      'priority_id': ?priorityId,
      if (dueAt != null) 'due_at': dueAt.toIso8601String().substring(0, 10),
    };
    final response = await apiClient.post('/api/v1/tickets', body);
    return response as Map<String, dynamic>;
  }

  // Fetches the statuses for tickets
  Future<List<Map<String, dynamic>>> getStatuses() async {
    final response = await apiClient.get('/api/v1/tickets/statuses') as List;
    return response.cast<Map<String, dynamic>>();
  }

  // Fetches the categories for tickets
  Future<List<Map<String, dynamic>>> getCategories() async {
    final response = await apiClient.get('/api/v1/categories') as List;
    return response.cast<Map<String, dynamic>>();
  }

  // Fetches the priorities for tickets
  Future<List<Map<String, dynamic>>> getPriorities() async {
    final response = await apiClient.get('/api/v1/priorities') as List;
    return response.cast<Map<String, dynamic>>();
  }

  // Updates the status of a specific ticket, optionally assigning it to a user
  Future<void> updateTicketStatus(
    String ticketId,
    String statusId, {
    String? assignedTo,
  }) async {
    await apiClient.post('/api/v1/tickets/$ticketId/status', {
      'status_id': statusId,
      'assigned_to': ?assignedTo,
    });
  }

  // Fetches the messages for a specific ticket
  Future<List<Map<String, dynamic>>> getMessages(String ticketId) async {
    final response =
        await apiClient.get('/api/v1/tickets/$ticketId/messages')
            as Map<String, dynamic>;
    return (response['messages'] as List).cast<Map<String, dynamic>>();
  }

  // Sends a message for a specific ticket
  Future<void> sendMessage(String ticketId, String messageText) async {
    // The backend writes the message to Realtime Database directly,
    // so the RTDB listener in the conversation screen picks it up automatically.
    await apiClient.post('/api/v1/tickets/$ticketId/messages', {
      'message_text': messageText,
    });
  }

  // Fetches the history of a specific ticket, including status changes and messages
  Future<List<Map<String, dynamic>>> getHistory(String ticketId) async {
    final response =
        await apiClient.get('/api/v1/tickets/$ticketId/history')
            as Map<String, dynamic>;
    return (response['history'] as List).cast<Map<String, dynamic>>();
  }

  // Creates an attachment for a specific ticket
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
