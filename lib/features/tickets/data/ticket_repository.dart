import '../../../core/network/api_client.dart';
import '../models/ticket_model.dart';

class TicketRepository {
  final ApiClient apiClient;

  TicketRepository(this.apiClient);

  Future<List<Ticket>> getTickets() async {
    final data = await apiClient.get('/tickets') as List;

    return data.map((item) => Ticket.fromJson(item)).toList();
  }

  Future<void> createTicket({
    required String title,
    required String category,
    required String description,
  }) async {
    await apiClient.post('/tickets', {
      'title': title,
      'category': category,
      'description': description,
    });
  }
}