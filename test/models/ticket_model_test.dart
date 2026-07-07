import 'package:flutter_test/flutter_test.dart';
import 'package:disconnect_mobile/features/tickets/models/ticket_model.dart';

void main() {
  group('Ticket.fromJson', () {
    // ── Happy path ─────────────────────────────────────────────────────────

    // The enriched API response wraps category, status, and priority in nested
    // objects. Verify every scalar field is extracted from the right key.
    test(
      'parses enriched nested-object response (ticket_id, category map, status map)',
      () {
        final ticket = Ticket.fromJson({
          'ticket_id': 'abc-123',
          'ticket_code': 'TKT-2025-001',
          'subject': 'Medical reimbursement',
          'category': {'category_name': 'Reimbursement'},
          'status': {'status_name': 'Open'},
          'priority': {'priority_name': 'High'},
          'created_at': '2025-06-01T10:00:00Z',
          'updated_at': '2025-06-02T08:30:00Z',
        });

        expect(ticket.id, 'abc-123');
        expect(ticket.displayId, 'TKT-2025-001');
        expect(ticket.title, 'Medical reimbursement');
        expect(ticket.category, 'Reimbursement');
        expect(ticket.status, 'Open');
        expect(ticket.priority, 'High');
        expect(ticket.createdAt, isNotNull);
        expect(ticket.updatedAt, isNotNull);
      },
    );

    // Older API responses may use 'id' instead of 'ticket_id'. The model
    // should prefer ticket_id but fall back gracefully.
    test('falls back to id field when ticket_id is absent', () {
      final ticket = Ticket.fromJson({
        'id': 'fallback-id',
        'subject': 'Test',
        'category': 'Policy',
        'status': 'Open',
        'priority': '',
        'created_at': null,
      });

      expect(ticket.id, 'fallback-id');
    });

    // Some responses use 'display_id' rather than 'ticket_code' for the
    // human-readable ticket reference shown in the UI.
    test('falls back to display_id when ticket_code is absent', () {
      final ticket = Ticket.fromJson({
        'ticket_id': 't1',
        'display_id': 'TKT-001',
        'subject': 'Test',
        'category': '',
        'status': '',
        'priority': '',
      });

      expect(ticket.displayId, 'TKT-001');
    });

    // Some endpoints return 'title' instead of 'subject' for the ticket name.
    test('falls back to title field when subject is absent', () {
      final ticket = Ticket.fromJson({
        'ticket_id': 't2',
        'title': 'Exchange programme query',
        'category': '',
        'status': '',
        'priority': '',
      });

      expect(ticket.title, 'Exchange programme query');
    });
  });
}
