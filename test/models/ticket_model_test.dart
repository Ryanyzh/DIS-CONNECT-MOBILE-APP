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

    // ── Bare string fields ─────────────────────────────────────────────────

    // Non-enriched list endpoints return status and category as plain strings,
    // not nested maps. The resolver must handle both shapes transparently.
    test('handles bare string status (non-enriched response)', () {
      final ticket = Ticket.fromJson({
        'ticket_id': 'xyz',
        'subject': 'Test',
        'category': 'Internship',
        'status': 'In Review',
        'priority': '',
        'created_at': null,
      });

      expect(ticket.status, 'In Review');
      expect(ticket.category, 'Internship');
      expect(ticket.createdAt, isNull);
    });

    // An enriched map with no recognised name key (e.g. empty {}) should
    // resolve to an empty string rather than throwing or returning null.
    test('resolves empty map field to empty string', () {
      final ticket = Ticket.fromJson({
        'ticket_id': 't3',
        'subject': 'Test',
        'category': {},
        'status': {},
        'priority': {},
      });

      expect(ticket.category, '');
      expect(ticket.status, '');
      expect(ticket.priority, '');
    });

    // ── Date parsing ───────────────────────────────────────────────────────

    // The API always returns UTC timestamps. The model converts them to local
    // time so the UI displays the user's timezone rather than UTC.
    test('converts UTC created_at to local time', () {
      final ticket = Ticket.fromJson({
        'ticket_id': 't4',
        'subject': 'X',
        'category': '',
        'status': '',
        'priority': '',
        'created_at': '2025-06-01T00:00:00Z',
      });

      expect(ticket.createdAt, isNotNull);
      expect(ticket.createdAt!.isUtc, isFalse);
    });

    // Tickets fetched from a list before they are fully created may have a
    // null date. The model must not throw and must return null.
    test('returns null createdAt for null date field', () {
      final ticket = Ticket.fromJson({
        'ticket_id': 't5',
        'subject': 'X',
        'category': '',
        'status': '',
        'priority': '',
        'created_at': null,
      });

      expect(ticket.createdAt, isNull);
    });

    // updatedAt is optional — tickets that have never been edited will omit
    // the field entirely.
    test('returns null updatedAt when field is absent', () {
      final ticket = Ticket.fromJson({
        'ticket_id': 't6',
        'subject': 'X',
        'category': '',
        'status': '',
        'priority': '',
      });

      expect(ticket.updatedAt, isNull);
    });

    // A corrupt or incorrectly formatted date string must not crash the
    // parser — DateTime.tryParse returns null, which the model propagates.
    test('returns null for unparseable date string', () {
      final ticket = Ticket.fromJson({
        'ticket_id': 't7',
        'subject': 'X',
        'category': '',
        'status': '',
        'priority': '',
        'created_at': 'not-a-date',
      });

      expect(ticket.createdAt, isNull);
    });

    // ── Null safety / missing fields ───────────────────────────────────────

    // A partial JSON object (e.g. a lightweight list projection) must not
    // throw. All text fields should default to empty strings.
    test('produces empty strings for all missing text fields', () {
      final ticket = Ticket.fromJson({'ticket_id': 't8'});

      expect(ticket.title, '');
      expect(ticket.category, '');
      expect(ticket.status, '');
      expect(ticket.priority, '');
      expect(ticket.displayId, '');
    });

    // If neither 'ticket_id' nor 'id' is present the model should return an
    // empty string rather than throwing a null-cast error.
    test('produces empty id when both ticket_id and id are absent', () {
      final ticket = Ticket.fromJson({'subject': 'No id ticket'});
      expect(ticket.id, '');
    });
  });

  // ── toJson round-trip ────────────────────────────────────────────────────────

  group('Ticket.toJson', () {
    // toJson is used when caching tickets locally. Confirm that all scalar
    // fields survive a fromJson → toJson cycle without mutation or loss.
    test(
      'round-trips through fromJson → toJson preserving all scalar fields',
      () {
        final original = Ticket.fromJson({
          'ticket_id': 'rt-1',
          'ticket_code': 'TKT-RT-001',
          'subject': 'Round-trip test',
          'category': 'Policy',
          'status': 'Open',
          'priority': 'Low',
          'created_at': '2025-07-01T12:00:00Z',
        });

        final json = original.toJson();

        expect(json['id'], 'rt-1');
        expect(json['ticket_code'], 'TKT-RT-001');
        expect(json['subject'], 'Round-trip test');
        expect(json['category'], 'Policy');
        expect(json['status'], 'Open');
        expect(json['priority'], 'Low');
      },
    );
  });
}
