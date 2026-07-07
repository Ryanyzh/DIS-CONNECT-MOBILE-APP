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

    // ── getTicket ──────────────────────────────────────────────────────────────

    group('getTicket', () {
      // getTicket returns the raw map (not a typed object) because the detail
      // screen parses it into TicketDetailData separately. Confirm the correct
      // endpoint is called and the raw map is returned unchanged.
      test('calls correct endpoint and returns raw map', () async {
        final raw = _ticketJson(id: 'detail-1');
        when(
          () => mockClient.get('/api/v1/tickets/detail-1'),
        ).thenAnswer((_) async => raw);

        final result = await repo.getTicket('detail-1');

        expect(result['ticket_id'], 'detail-1');
      });
    });

    // ── createTicket ───────────────────────────────────────────────────────────

    group('createTicket', () {
      // The most critical createTicket constraint: due_at must be sent as a
      // local YYYY-MM-DD string. Sending a UTC ISO timestamp shifts the date
      // for users in UTC+ timezones (e.g. midnight SGT becomes the previous
      // day in UTC). Using the local calendar date avoids this bug.
      test(
        'sends YYYY-MM-DD local date for due_at — not a UTC timestamp',
        () async {
          final capturedBodies = <Map<String, dynamic>>[];

          when(
            () => mockClient.post(
              '/api/v1/tickets',
              any(that: isA<Map<String, dynamic>>()),
            ),
          ).thenAnswer((invocation) async {
            capturedBodies.add(
              invocation.positionalArguments[1] as Map<String, dynamic>,
            );
            return {'ticket_id': 'new-1'};
          });

          // UTC+8 locale: midnight local = previous day in UTC.
          // The date string must reflect the LOCAL date (2025-08-01), not UTC.
          final dueAt = DateTime(2025, 8, 1); // local midnight

          await repo.createTicket(
            subject: 'Test',
            categoryId: 'cat-1',
            dueAt: dueAt,
          );

          expect(capturedBodies.length, 1);
          final sent = capturedBodies.first['due_at'] as String;
          // Expect exactly 10 characters: YYYY-MM-DD
          expect(sent.length, 10);
          expect(sent, '2025-08-01');
        },
      );

      // When the user leaves the due date picker empty, due_at must be absent
      // from the request body entirely (not sent as null or empty string).
      test('omits due_at from body when not provided', () async {
        final capturedBodies = <Map<String, dynamic>>[];

        when(
          () => mockClient.post(
            '/api/v1/tickets',
            any(that: isA<Map<String, dynamic>>()),
          ),
        ).thenAnswer((invocation) async {
          capturedBodies.add(
            invocation.positionalArguments[1] as Map<String, dynamic>,
          );
          return {'ticket_id': 'new-2'};
        });

        await repo.createTicket(subject: 'No due date', categoryId: 'cat-1');

        expect(capturedBodies.first.containsKey('due_at'), isFalse);
      });

      // source = 'mobile' tells the backend which client created the ticket.
      // It must always be present so the officer dashboard can filter by origin.
      test('always includes source = mobile', () async {
        final capturedBodies = <Map<String, dynamic>>[];

        when(
          () => mockClient.post(any(), any(that: isA<Map<String, dynamic>>())),
        ).thenAnswer((invocation) async {
          capturedBodies.add(
            invocation.positionalArguments[1] as Map<String, dynamic>,
          );
          return {'ticket_id': 'new-3'};
        });

        await repo.createTicket(subject: 'S', categoryId: 'cat-2');

        expect(capturedBodies.first['source'], 'mobile');
      });

      // An empty description string should be treated as "no description" and
      // omitted from the request body to avoid storing blank entries.
      test('omits description when blank', () async {
        final capturedBodies = <Map<String, dynamic>>[];

        when(
          () => mockClient.post(any(), any(that: isA<Map<String, dynamic>>())),
        ).thenAnswer((invocation) async {
          capturedBodies.add(
            invocation.positionalArguments[1] as Map<String, dynamic>,
          );
          return {'ticket_id': 'new-4'};
        });

        await repo.createTicket(
          subject: 'S',
          categoryId: 'cat-3',
          description: '',
        );

        expect(capturedBodies.first.containsKey('description'), isFalse);
      });

      // A non-empty description must be included in the request body verbatim
      // so the officer sees the full context when reviewing the ticket.
      test('includes description when non-empty', () async {
        final capturedBodies = <Map<String, dynamic>>[];

        when(
          () => mockClient.post(any(), any(that: isA<Map<String, dynamic>>())),
        ).thenAnswer((invocation) async {
          capturedBodies.add(
            invocation.positionalArguments[1] as Map<String, dynamic>,
          );
          return {'ticket_id': 'new-5'};
        });

        await repo.createTicket(
          subject: 'S',
          categoryId: 'cat-4',
          description: 'Detailed description here.',
        );

        expect(
          capturedBodies.first['description'],
          'Detailed description here.',
        );
      });

      // Server-side validation errors (e.g. 422 Unprocessable Entity) are
      // thrown by ApiClient and must surface to the create-ticket screen.
      test('propagates exception from ApiClient', () {
        when(
          () => mockClient.post(any(), any(that: isA<Map<String, dynamic>>())),
        ).thenThrow(Exception('POST failed: 500'));

        expect(
          () => repo.createTicket(subject: 'S', categoryId: 'cat-5'),
          throwsException,
        );
      });
    });
  });

  // ── getStatuses / getCategories / getPriorities ────────────────────────────

  group('getStatuses', () {
    // getStatuses drives the status picker in the officer update-status flow.
    // Verify the list response is cast to the expected typed list.
    test('casts list response to List<Map>', () async {
      when(() => mockClient.get('/api/v1/tickets/statuses')).thenAnswer(
        (_) async => [
          {'id': 's1', 'status_name': 'Open'},
          {'id': 's2', 'status_name': 'Closed'},
        ],
      );

      final statuses = await repo.getStatuses();

      expect(statuses.length, 2);
      expect(statuses[0]['status_name'], 'Open');
    });
  });

  group('getCategories', () {
    // getCategories populates the category dropdown in the create-ticket form.
    test('returns list of category maps', () async {
      when(() => mockClient.get('/api/v1/categories')).thenAnswer(
        (_) async => [
          {'id': 'c1', 'category_name': 'Finance'},
        ],
      );

      final categories = await repo.getCategories();

      expect(categories.first['category_name'], 'Finance');
    });
  });

  group('getPriorities', () {
    // getPriorities populates the priority dropdown in the create-ticket form.
    test('returns list of priority maps', () async {
      when(() => mockClient.get('/api/v1/priorities')).thenAnswer(
        (_) async => [
          {'id': 'p1', 'priority_name': 'High', 'color_code': '#EF4444'},
        ],
      );

      final priorities = await repo.getPriorities();

      expect(priorities.first['priority_name'], 'High');
    });
  });

  // ── getMessages ────────────────────────────────────────────────────────────

  group('getMessages', () {
    // The messages endpoint returns a 'messages' envelope. The repository
    // unwraps it and returns the inner list. Verify count and a sample field.
    test('returns messages from nested messages key', () async {
      when(() => mockClient.get('/api/v1/tickets/t1/messages')).thenAnswer(
        (_) async => {
          'messages': [
            {'id': 'm1', 'message_text': 'Hello'},
            {'id': 'm2', 'message_text': 'Update'},
          ],
        },
      );

      final messages = await repo.getMessages('t1');

      expect(messages.length, 2);
      expect(messages[0]['message_text'], 'Hello');
    });
  });
}
