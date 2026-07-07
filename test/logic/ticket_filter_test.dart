import 'package:flutter_test/flutter_test.dart';
import 'package:disconnect_mobile/features/tickets/models/ticket_model.dart';

// Mirror of _TicketListScreenState's private filter helpers so they can be
// unit-tested without spinning up a widget tree.

bool isDone(Ticket t) {
  final s = t.status.toLowerCase();
  return s == 'resolved' || s == 'closed';
}

List<Ticket> visible(List<Ticket> tickets, String query) {
  if (query.isEmpty) return tickets;
  final q = query.toLowerCase();
  return tickets
      .where(
        (t) =>
            t.title.toLowerCase().contains(q) ||
            t.displayId.toLowerCase().contains(q) ||
            t.category.toLowerCase().contains(q) ||
            t.status.toLowerCase().contains(q),
      )
      .toList();
}

List<Ticket> active(List<Ticket> tickets, String query) =>
    visible(tickets, query).where((t) => !isDone(t)).toList();

List<Ticket> resolved(List<Ticket> tickets, String query) =>
    visible(tickets, query).where(isDone).toList();

Ticket _t({
  String id = 't1',
  String displayId = 'TKT-001',
  String title = 'Test ticket',
  String category = 'Reimbursement',
  String status = 'Open',
}) => Ticket(
  id: id,
  displayId: displayId,
  title: title,
  category: category,
  status: status,
  priority: '',
);

void main() {
  // ── isDone ─────────────────────────────────────────────────────────────────

  group('isDone', () {
    // 'resolved' is the lowercase API value for tickets that have been
    // answered and closed by an officer.
    test('"resolved" status is done', () {
      expect(isDone(_t(status: 'resolved')), isTrue);
    });

    // Status values from the API may be title-cased. The check must be
    // case-insensitive to handle both 'resolved' and 'Resolved'.
    test('"Resolved" (title-case) is done', () {
      expect(isDone(_t(status: 'Resolved')), isTrue);
    });

    // 'closed' is the other terminal status, used when a ticket is manually
    // closed without a formal resolution.
    test('"closed" status is done', () {
      expect(isDone(_t(status: 'closed')), isTrue);
    });

    // Upper-case must also be handled in case the backend changes casing.
    test('"CLOSED" (upper-case) is done', () {
      expect(isDone(_t(status: 'CLOSED')), isTrue);
    });

    // 'Open' is the initial status when a ticket is first submitted.
    // It is an active (not done) state and should appear in the active tab.
    test('"Open" is not done', () {
      expect(isDone(_t(status: 'Open')), isFalse);
    });

    // 'In Review' means an officer has picked up the ticket but not yet
    // resolved it. The ticket is still active.
    test('"In Review" is not done', () {
      expect(isDone(_t(status: 'In Review')), isFalse);
    });

    // 'Waiting' is used when the officer is waiting for more info from the
    // user. The ticket is still active.
    test('"Waiting" is not done', () {
      expect(isDone(_t(status: 'Waiting')), isFalse);
    });

    // An empty status string (e.g. a partial API response) must not be
    // treated as done; it should appear in the active list for visibility.
    test('empty status is not done', () {
      expect(isDone(_t(status: '')), isFalse);
    });
  });

  // ── visible (search filtering) ─────────────────────────────────────────────

  group('visible', () {
    final tickets = [
      _t(
        id: '1',
        title: 'Medical reimbursement',
        category: 'Finance',
        status: 'Open',
      ),
      _t(
        id: '2',
        title: 'Exchange programme',
        category: 'Internship',
        status: 'In Review',
      ),
      _t(
        id: '3',
        title: 'Allowance query',
        displayId: 'TKT-99',
        category: 'Finance',
        status: 'Resolved',
      ),
    ];

    // An empty search query means "show everything" — no filtering applied.
    test('empty query returns all tickets', () {
      expect(visible(tickets, ''), hasLength(3));
    });

    // Title is the most natural search target for users looking for a
    // specific ticket. Match must be case-insensitive.
    test('matches by title (case-insensitive)', () {
      final r = visible(tickets, 'medical');
      expect(r.length, 1);
      expect(r.first.id, '1');
    });

    // Users may search by the ticket reference code (e.g. "TKT-99") copied
    // from an email or notification.
    test('matches by displayId', () {
      final r = visible(tickets, 'TKT-99');
      expect(r.length, 1);
      expect(r.first.id, '3');
    });

    // displayId search must be case-insensitive (users may type "tkt-99").
    test('displayId match is case-insensitive', () {
      final r = visible(tickets, 'tkt-99');
      expect(r.length, 1);
    });

    // Searching by category lets users quickly find all tickets of the same
    // type (e.g. "Finance" to see all financial requests).
    test('matches by category', () {
      final r = visible(tickets, 'finance');
      // Both ticket 1 and ticket 3 have category = 'Finance'.
      expect(r.length, 2);
    });

    // Searching by status lets users quickly find all tickets in a particular
    // workflow state (e.g. "in review" to see what is being processed).
    test('matches by status', () {
      final r = visible(tickets, 'in review');
      expect(r.length, 1);
      expect(r.first.id, '2');
    });

    // A query that does not match any field must return an empty list so the
    // screen can show an appropriate "no results" message.
    test('query matching no ticket returns empty list', () {
      expect(visible(tickets, 'zzznomatch'), isEmpty);
    });

    // Partial word matches should work — users rarely type full words when
    // scanning a list.
    test('partial title match works', () {
      final r = visible(tickets, 'programme');
      expect(r.length, 1);
      expect(r.first.id, '2');
    });
  });
}
