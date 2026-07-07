import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:disconnect_mobile/core/network/api_client.dart';
import 'package:disconnect_mobile/features/tickets/data/ticket_repository.dart';

class MockApiClient extends Mock implements ApiClient {}

// Minimal ticket map for getTickets() response.
Map<String, dynamic> _ticketJson({String id = 't1', String status = 'Open'}) =>
    {
      'ticket_id': id,
      'ticket_code': 'TKT-$id',
      'subject': 'Test ticket $id',
      'category': 'Policy',
      'status': status,
      'priority': '',
      'created_at': '2025-06-01T10:00:00Z',
    };

void main() {
  late MockApiClient mockClient;
  late TicketRepository repo;

  setUp(() {
    mockClient = MockApiClient();
    repo = TicketRepository(mockClient);
  });

  // ── getTickets ─────────────────────────────────────────────────────────────

  group('getTickets', () {
    // The repository unwraps the 'tickets' key from the response envelope and
    // maps each item to a Ticket domain object. Verify count and IDs.
    test('returns list of Ticket objects mapped from response', () async {
      when(() => mockClient.get('/api/v1/tickets')).thenAnswer(
        (_) async => {
          'tickets': [_ticketJson(id: 'a'), _ticketJson(id: 'b')],
        },
      );

      final tickets = await repo.getTickets();

      expect(tickets.length, 2);
      expect(tickets[0].id, 'a');
      expect(tickets[1].id, 'b');
    });

    // Confirm that the status string from the API is preserved on the mapped
    // Ticket so status badges render the correct label.
    test('maps status field from response', () async {
      when(() => mockClient.get('/api/v1/tickets')).thenAnswer(
        (_) async => {
          'tickets': [_ticketJson(id: 'x', status: 'In Review')],
        },
      );

      final tickets = await repo.getTickets();

      expect(tickets.first.status, 'In Review');
    });

    // An empty tickets array (e.g. a new user with no tickets yet) should
    // return an empty list rather than throwing a cast error.
    test('returns empty list when tickets array is empty', () async {
      when(
        () => mockClient.get('/api/v1/tickets'),
      ).thenAnswer((_) async => {'tickets': []});

      final tickets = await repo.getTickets();

      expect(tickets, isEmpty);
    });

    // Network errors or auth failures are thrown by ApiClient. The repository
    // must not swallow them — they propagate to the screen for error handling.
    test('propagates exception thrown by ApiClient', () async {
      when(
        () => mockClient.get('/api/v1/tickets'),
      ).thenThrow(Exception('GET /api/v1/tickets failed: 401'));

      expect(() => repo.getTickets(), throwsException);
    });

    // The model converts UTC timestamps to local time. Confirm this happens
    // end-to-end through the repository layer.
    test('createdAt is converted to local time', () async {
      when(() => mockClient.get('/api/v1/tickets')).thenAnswer(
        (_) async => {
          'tickets': [_ticketJson()],
        },
      );

      final tickets = await repo.getTickets();

      expect(tickets.first.createdAt, isNotNull);
      expect(tickets.first.createdAt!.isUtc, isFalse);
    });
  });
}
