import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:disconnect_mobile/features/announcements/presentation/announcements_screen.dart';

void main() {
  // ── AnnouncementEntry.fromJson ─────────────────────────────────────────────

  group('AnnouncementEntry.fromJson — basic fields', () {
    // Confirm every field is read correctly when the API returns a complete
    // announcement entry, including the tags list.
    test('parses all fields from complete json', () {
      final e = AnnouncementEntry.fromJson({
        'id': 'ann-1',
        'title': 'Results Released',
        'body': 'Check your portal.',
        'date': '2025-08-15T09:00:00Z',
        'author': 'NUS Office',
        'authorRole': 'Admin',
        'category': 'Result',
        'tags': ['important', 'results'],
      });

      expect(e.id, 'ann-1');
      expect(e.title, 'Results Released');
      expect(e.body, 'Check your portal.');
      expect(e.author, 'NUS Office');
      expect(e.authorRole, 'Admin');
      expect(e.category, 'Result');
      expect(e.tags, ['important', 'results']);
    });

    // When the API omits 'author', the announcement card should still show a
    // recognisable sender instead of an empty string.
    test('defaults author to Scholarship Office when absent', () {
      final e = AnnouncementEntry.fromJson({
        'id': 'ann-2',
        'title': 'T',
        'date': '2025-01-01T00:00:00Z',
      });
      expect(e.author, 'Scholarship Office');
    });

    // authorRole is shown as a subtitle under the author name in the card.
    // It should always have a readable default.
    test('defaults authorRole to Administration when absent', () {
      final e = AnnouncementEntry.fromJson({
        'id': 'ann-3',
        'title': 'T',
        'date': '2025-01-01T00:00:00Z',
      });
      expect(e.authorRole, 'Administration');
    });

    // Category controls badge colour and icon. A missing category should not
    // crash the badge lookup; it falls back to the General style.
    test('defaults category to General when absent', () {
      final e = AnnouncementEntry.fromJson({
        'id': 'ann-4',
        'title': 'T',
        'date': '2025-01-01T00:00:00Z',
      });
      expect(e.category, 'General');
    });

    // Tags are rendered as chips beneath the announcement body. A missing
    // tags field must produce an empty list, not null, to avoid a null-spread.
    test('defaults tags to empty list when absent', () {
      final e = AnnouncementEntry.fromJson({
        'id': 'ann-5',
        'title': 'T',
        'date': '2025-01-01T00:00:00Z',
      });
      expect(e.tags, isEmpty);
    });

    // A missing title should not throw; it defaults to an empty string so
    // the card still renders (even if visually empty).
    test('produces empty string for missing title', () {
      final e = AnnouncementEntry.fromJson({
        'id': 'ann-6',
        'date': '2025-01-01T00:00:00Z',
      });
      expect(e.title, '');
    });
  });

  group('AnnouncementEntry.fromJson — date parsing', () {
    // The announcement list is sorted by date. The model converts the UTC
    // ISO 8601 string to local time so comparisons are in the user's timezone.
    test('parses ISO 8601 date string to local time', () {
      final e = AnnouncementEntry.fromJson({
        'id': 'ann-7',
        'title': 'T',
        'date': '2025-06-15T12:00:00Z',
      });
      expect(e.date.isUtc, isFalse);
      expect(e.date.year, 2025);
      expect(e.date.month, 6);
    });

    // A null date field must not throw. The model falls back to DateTime.now()
    // so the entry still appears in the list (at the top, as most recent).
    test('falls back to DateTime.now() for null date', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final e = AnnouncementEntry.fromJson({
        'id': 'ann-8',
        'title': 'T',
        'date': null,
      });
      expect(e.date.isAfter(before), isTrue);
    });

    // An unparseable date string (e.g. a placeholder from the CMS) must
    // also fall back to now() rather than throwing a FormatException.
    test('falls back to DateTime.now() for unparseable date', () {
      final before = DateTime.now().subtract(const Duration(seconds: 1));
      final e = AnnouncementEntry.fromJson({
        'id': 'ann-9',
        'title': 'T',
        'date': 'not-a-date',
      });
      expect(e.date.isAfter(before), isTrue);
    });

    // Date-only strings (no time component) are valid ISO 8601 and may be
    // returned by some CMS backends. DateTime.tryParse supports them.
    test('date-only string (YYYY-MM-DD) is parsed correctly', () {
      final e = AnnouncementEntry.fromJson({
        'id': 'ann-10',
        'title': 'T',
        'date': '2025-09-30',
      });
      expect(e.date.year, 2025);
      expect(e.date.month, 9);
      expect(e.date.day, 30);
    });
  });

  // ── announcementCategoryStyle ──────────────────────────────────────────────

  group('announcementCategoryStyle', () {
    // Each category maps to a specific colour palette and icon used in the
    // badge. Verify the full style for Deadline (red theme).
    test('Deadline — badge bg is red tint', () {
      final s = announcementCategoryStyle('Deadline');
      expect(s.badgeBg, const Color(0xFFFEE2E2));
      expect(s.badgeText, const Color(0xFFDC2626));
      expect(s.icon, Icons.timer_outlined);
    });

    // The switch uses category.toLowerCase(), so 'deadline' must map to the
    // same style as 'Deadline'. Ensures the API can send any casing.
    test('deadline is case-insensitive', () {
      final s = announcementCategoryStyle('deadline');
      expect(s.badgeBg, const Color(0xFFFEE2E2));
    });

    // Upper-case input must also be handled correctly.
    test('DEADLINE uppercase also works', () {
      final s = announcementCategoryStyle('DEADLINE');
      expect(s.badgeBg, const Color(0xFFFEE2E2));
    });

    // Event category uses the brand purple palette and a calendar icon.
    test('Event — badge bg is purple tint', () {
      final s = announcementCategoryStyle('Event');
      expect(s.badgeBg, const Color(0xFFE4DCFF));
      expect(s.icon, Icons.event_outlined);
    });

    // Maintenance uses a neutral slate palette to convey a system/admin tone.
    test('Maintenance — badge bg is slate tint', () {
      final s = announcementCategoryStyle('Maintenance');
      expect(s.badgeBg, const Color(0xFFF1F5F9));
      expect(s.icon, Icons.build_outlined);
    });

    // Urgent uses orange to indicate high importance without implying an error.
    test('Urgent — badge bg is orange tint', () {
      final s = announcementCategoryStyle('Urgent');
      expect(s.badgeBg, const Color(0xFFFFEDD5));
      expect(s.icon, Icons.warning_amber_rounded);
    });

    // Result uses green to signal a positive outcome (e.g. scholarship awarded).
    test('Result — badge bg is green tint', () {
      final s = announcementCategoryStyle('Result');
      expect(s.badgeBg, const Color(0xFFD1FAE5));
      expect(s.icon, Icons.check_circle_outline_rounded);
    });

    // General is the explicit default category.
    test('General (default) — badge bg is brand purple tint', () {
      final s = announcementCategoryStyle('General');
      expect(s.badgeBg, const Color(0xFFE4DCFF));
      expect(s.icon, Icons.campaign_outlined);
    });

    // Any unknown string (e.g. a new category added to the backend before the
    // app is updated) must fall through to the General style rather than
    // throwing a StateError.
    test('unknown category falls through to General style', () {
      final s = announcementCategoryStyle('Foobar');
      expect(s.icon, Icons.campaign_outlined);
    });
  });
}
