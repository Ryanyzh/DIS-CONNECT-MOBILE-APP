import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';
import 'package:disconnect_mobile/core/network/api_client.dart';
import 'package:disconnect_mobile/features/tickets/data/ticket_repository.dart';

// ── Category / Priority models ────────────────────────────────────────────────

class _Category {
  final String label;
  final IconData icon;
  final String id;
  const _Category(this.label, this.icon, this.id);

  factory _Category.fromJson(Map<String, dynamic> json) => _Category(
        json['category_name'] as String? ?? '',
        _iconForCategory(json['category_name'] as String? ?? ''),
        json['category_id'] as String? ?? '',
      );
}

class _Priority {
  final String label;
  final IconData icon;
  final Color color;
  final String id;
  const _Priority(this.label, this.icon, this.color, this.id);

  factory _Priority.fromJson(Map<String, dynamic> json) => _Priority(
        json['priority_name'] as String? ?? '',
        _iconForPriority(json['priority_name'] as String? ?? ''),
        _parseHexColor(json['color_code'] as String? ?? '#94A3B8'),
        json['priority_id'] as String? ?? '',
      );
}

IconData _iconForCategory(String name) {
  switch (name) {
    case 'Reimbursement':
      return Icons.receipt_long_outlined;
    case 'Internship':
      return Icons.work_outline;
    case 'Scholarship':
      return Icons.school_outlined;
    case 'Leave':
      return Icons.calendar_today_outlined;
    case 'Exchange':
      return Icons.flight_outlined;
    case 'Policy':
      return Icons.policy_outlined;
    default:
      return Icons.category_outlined;
  }
}

IconData _iconForPriority(String name) {
  switch (name) {
    case 'Low':
      return Icons.arrow_downward_rounded;
    case 'Medium':
      return Icons.remove_rounded;
    case 'High':
      return Icons.arrow_upward_rounded;
    case 'Critical':
      return Icons.priority_high_rounded;
    default:
      return Icons.flag_outlined;
  }
}

Color _parseHexColor(String hex) {
  final clean = hex.replaceAll('#', '');
  return Color(int.parse('FF$clean', radix: 16));
}

class _AttachedFile {
  final String name;
  final Uint8List bytes;
  final String mimeType;
  int get sizeBytes => bytes.length;
  int get sizeKb => (bytes.length / 1024).ceil();
  _AttachedFile({
    required this.name,
    required this.bytes,
    required this.mimeType,
  });
}

String _mimeFromExtension(String ext) {
  switch (ext.toLowerCase()) {
    case 'pdf':
      return 'application/pdf';
    case 'jpg':
    case 'jpeg':
      return 'image/jpeg';
    case 'png':
      return 'image/png';
    case 'doc':
      return 'application/msword';
    case 'docx':
      return 'application/vnd.openxmlformats-officedocument.wordprocessingml.document';
    case 'xls':
      return 'application/vnd.ms-excel';
    case 'xlsx':
      return 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';
    default:
      return 'application/octet-stream';
  }
}

IconData _fileIcon(String mimeType) {
  if (mimeType.startsWith('image/')) return Icons.image_outlined;
  if (mimeType == 'application/pdf') return Icons.picture_as_pdf_outlined;
  if (mimeType.contains('sheet') || mimeType.contains('excel')) {
    return Icons.table_chart_outlined;
  }
  return Icons.description_outlined;
}

Color _fileIconColor(String mimeType) {
  if (mimeType.startsWith('image/')) return const Color(0xFF3B82F6);
  if (mimeType == 'application/pdf') return const Color(0xFFEF4444);
  if (mimeType.contains('sheet') || mimeType.contains('excel')) {
    return const Color(0xFF22C55E);
  }
  return const Color(0xFF4C39F2);
}

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class CreateTicketScreen extends StatefulWidget {
  const CreateTicketScreen({super.key});

  @override
  State<CreateTicketScreen> createState() => _CreateTicketScreenState();
}

class _CreateTicketScreenState extends State<CreateTicketScreen> {
  static const int _totalSteps = 3;

  late final PageController _pageController;
  int _currentStep = 0; // 0-indexed

  // ── Lookup state ─────────────────────────────────────────────────────────
  List<_Category> _categories = [];
  List<_Priority> _priorities = [];
  bool _loadingLookups = true;

  // ── Step 1 state ─────────────────────────────────────────────────────────
  final _subjectController = TextEditingController();
  static const int _maxSubjectChars = 200;
  _Category? _selectedCategory;
  _Priority? _selectedPriority;

  // ── Step 2 state ─────────────────────────────────────────────────────────
  final _descController = TextEditingController();
  static const int _maxDescChars = 1000;
  DateTime? _dueDate;

  // ── Step 3 state ─────────────────────────────────────────────────────────
  final List<_AttachedFile> _attachments = [];

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadLookups();
  }

  Future<void> _loadLookups() async {
    try {
      final repo = TicketRepository(ApiClient());
      final results = await Future.wait([repo.getCategories(), repo.getPriorities()]);
      if (mounted) {
        setState(() {
          _categories = results[0].map(_Category.fromJson).toList();
          _priorities = results[1].map(_Priority.fromJson).toList();
          _loadingLookups = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _loadingLookups = false);
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _subjectController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ── Validation ────────────────────────────────────────────────────────────

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        if (_subjectController.text.trim().isEmpty) {
          _snack('Please enter a subject');
          return false;
        }
        if (_selectedCategory == null) {
          _snack('Please select a category');
          return false;
        }
        return true;
      case 1:
        if (_descController.text.trim().isEmpty) {
          _snack('Please add a description');
          return false;
        }
        return true;
      default:
        return true; // attachments optional
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _goNext() {
    if (!_validateCurrentStep()) return;
    if (_currentStep < _totalSteps - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
      setState(() => _currentStep++);
    } else {
      _submit();
    }
  }

  void _goBack() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
      );
      setState(() => _currentStep--);
    } else {
      Navigator.of(context).maybePop();
    }
  }

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);
    try {
      final repo = TicketRepository(ApiClient());

      // Step 1 — create ticket, get ticket_id back
      final response = await repo.createTicket(
        subject: _subjectController.text.trim(),
        categoryId: _selectedCategory!.id,
        description: _descController.text.trim().isEmpty
            ? null
            : _descController.text.trim(),
        priorityId: _selectedPriority?.id,
        dueAt: _dueDate,
      );
      // Steps 2 & 3 — only needed when the user attached files
      if (_attachments.isNotEmpty) {
        final ticketId = response['ticket']['ticket_id'] as String;

        for (final file in _attachments) {
          final storagePath = 'tickets/$ticketId/${file.name}';

          await FirebaseStorage.instance
              .ref(storagePath)
              .putData(
                file.bytes,
                SettableMetadata(contentType: file.mimeType),
              );

          await repo.createAttachment(
            ticketId: ticketId,
            fileName: file.name,
            filePath: storagePath,
            fileType: file.mimeType,
            fileSize: file.sizeBytes,
          );
        }
      }

      if (mounted) context.pop();
    } catch (e) {
      debugPrint('Ticket submission error: $e');
      if (mounted) _snack('Failed to submit ticket. Please try again.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  // ── Category sheet ────────────────────────────────────────────────────────

  void _showCategorySheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppBorderRadius.wiseXl),
        ),
      ),
      builder: (_) => _CategorySheet(
        categories: _categories,
        selected: _selectedCategory,
        onSelect: (c) {
          setState(() => _selectedCategory = c);
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // ── Date picker ───────────────────────────────────────────────────────────

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now.add(const Duration(days: 7)),
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFF4C39F2),
            onPrimary: Colors.white,
            surface: Colors.white,
            onSurface: Color(0xFF1E293B),
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  // ── Attachment ────────────────────────────────────────────────────────────

  Future<void> _addAttachment() async {
    final result = await FilePicker.pickFiles(
      withData: true,
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'jpg',
        'jpeg',
        'png',
        'doc',
        'docx',
        'xls',
        'xlsx',
      ],
    );
    if (result == null || result.files.isEmpty) return;
    final file = result.files.first;
    if (file.bytes == null) return;

    if (file.size > 10 * 1024 * 1024) {
      _snack('File exceeds the 10 MB limit');
      return;
    }

    setState(() {
      _attachments.add(
        _AttachedFile(
          name: file.name,
          bytes: file.bytes!,
          mimeType: _mimeFromExtension(file.extension ?? ''),
        ),
      );
    });
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          // ── Step indicator ──────────────────────────────────────────────
          _StepIndicator(current: _currentStep, total: _totalSteps),

          // ── Page content ────────────────────────────────────────────────
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [_buildStep1(), _buildStep2(), _buildStep3()],
            ),
          ),

          // ── Bottom navigation ───────────────────────────────────────────
          _BottomNav(
            currentStep: _currentStep,
            totalSteps: _totalSteps,
            isSubmitting: _isSubmitting,
            onBack: _goBack,
            onNext: _goNext,
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    const stepTitles = ['Ticket Info', 'Details', 'Review & Attach'];
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      shadowColor: Colors.black.withValues(alpha: 0.08),
      leading: IconButton(
        icon: const GradientIcon(icon: Icons.arrow_back),
        onPressed: () {
          if (_currentStep > 0) {
            _goBack();
          } else {
            Navigator.of(context).maybePop();
          }
        },
      ),
      title: Column(
        children: [
          Text(
            'New Ticket',
            style: AppTypography.bodyMd.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.ink,
              fontSize: 17,
            ),
          ),
          Text(
            stepTitles[_currentStep],
            style: AppTypography.caption.copyWith(
              color: AppColors.mute,
              fontSize: 11,
            ),
          ),
        ],
      ),
      centerTitle: true,
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Step pages
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildStep1() {
    if (_loadingLookups) {
      return const Center(child: CircularProgressIndicator());
    }
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section hint ────────────────────────────────────────────────
          _StepHint(
            icon: Icons.info_outline_rounded,
            text:
                'Start by classifying your request so we can route it to the right team.',
          ),
          const SizedBox(height: 24),

          // ── Subject ─────────────────────────────────────────────────────
          const _FieldLabel(label: 'Subject', required: true),
          const SizedBox(height: 8),
          _SubjectField(
            controller: _subjectController,
            maxChars: _maxSubjectChars,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 24),

          // ── Category ────────────────────────────────────────────────────
          const _FieldLabel(label: 'Category', required: true),
          const SizedBox(height: 8),
          _CategoryDropdown(
            selected: _selectedCategory,
            onTap: _showCategorySheet,
          ),
          const SizedBox(height: 24),

          // ── Priority ────────────────────────────────────────────────────
          const _FieldLabel(label: 'Priority'),
          const SizedBox(height: 4),
          Text(
            'How urgently do you need this resolved?',
            style: AppTypography.caption.copyWith(color: AppColors.mute),
          ),
          const SizedBox(height: 10),
          _PrioritySelector(
            priorities: _priorities,
            selected: _selectedPriority,
            onSelect: (p) => setState(() => _selectedPriority = p),
          ),
          const SizedBox(height: 14),

          // ── Requested Due Date ───────────────────────────────────────────
          const _FieldLabel(label: 'Requested Due Date'),
          const SizedBox(height: 4),
          Text(
            'Optional — let us know if you have a deadline.',
            style: AppTypography.caption.copyWith(color: AppColors.mute),
          ),
          const SizedBox(height: 10),
          _DueDatePicker(
            selectedDate: _dueDate,
            onTap: _pickDueDate,
            onClear: () => setState(() => _dueDate = null),
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section hint ────────────────────────────────────────────────
          _StepHint(
            icon: Icons.edit_note_rounded,
            text:
                'Describe your request clearly. Include any relevant context or reference numbers.',
          ),
          const SizedBox(height: 24),

          // ── Description ──────────────────────────────────────────────────
          const _FieldLabel(label: 'Description', required: true),
          const SizedBox(height: 8),
          _DescriptionField(
            controller: _descController,
            maxChars: _maxDescChars,
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 28),

          // ── Attachments ──────────────────────────────────────────────────
          const _FieldLabel(label: 'Attachments'),
          const SizedBox(height: 4),
          Text(
            'Upload any supporting documents (max 5 files, 10 MB each).',
            style: AppTypography.caption.copyWith(color: AppColors.mute),
          ),
          const SizedBox(height: 10),
          _AttachmentsBox(
            files: _attachments,
            onRemove: (i) => setState(() => _attachments.removeAt(i)),
            onAdd: _addAttachment,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildStep3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Review divider ───────────────────────────────────────────────
          Row(
            children: [
              const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'REVIEW BEFORE SUBMITTING',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                    letterSpacing: 0.8,
                    color: AppColors.mute,
                  ),
                ),
              ),
              const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
            ],
          ),
          const SizedBox(height: 16),

          // ── Review card ──────────────────────────────────────────────────
          _ReviewCard(
            subject: _subjectController.text,
            category: _selectedCategory,
            priority: _selectedPriority,
            description: _descController.text,
            dueDate: _dueDate,
            attachmentCount: _attachments.length,
          ),
          const SizedBox(height: 16),

          // ── Auto-set fields note ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
              border: Border.all(color: const Color(0xFFBBF7D0)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF16A34A),
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Status will be set to Open and your ticket will be assigned shortly after submission.',
                    style: AppTypography.caption.copyWith(
                      color: const Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step indicator
// ─────────────────────────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  final int current; // 0-indexed
  final int total;
  const _StepIndicator({required this.current, required this.total});

  static const _labels = ['Ticket Info', 'Details', 'Review'];

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFF1F5F9))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: List.generate(total * 2 - 1, (i) {
          // Even indices → step circles; odd indices → connector lines
          if (i.isOdd) {
            final stepBefore = i ~/ 2;
            final isDone = current > stepBefore;
            // top: (circle radius 15) − (half line height 1) = 14
            // keeps the connector centred on the circle, not the whole Column
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDone
                        ? const Color(0xFF4C39F2)
                        : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(9999),
                  ),
                ),
              ),
            );
          }

          final step = i ~/ 2;
          final isDone = current > step;
          final isActive = current == step;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isDone
                      ? const Color(0xFF4C39F2)
                      : isActive
                      ? const Color(0xFF4C39F2)
                      : const Color(0xFFF1F5F9),
                  border: isActive
                      ? Border.all(color: const Color(0xFFE4DCFF), width: 3)
                      : null,
                ),
                child: Center(
                  child: isDone
                      ? const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        )
                      : Text(
                          '${step + 1}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isActive
                                ? Colors.white
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _labels[step],
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive
                      ? const Color(0xFF4C39F2)
                      : isDone
                      ? AppColors.body
                      : AppColors.mute,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Bottom navigation
// ─────────────────────────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool isSubmitting;
  final VoidCallback onBack;
  final VoidCallback onNext;
  const _BottomNav({
    required this.currentStep,
    required this.totalSteps,
    required this.isSubmitting,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final isLast = currentStep == totalSteps - 1;
    final safeBottom = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + safeBottom),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.black.withValues(alpha: 0.07)),
        ),
      ),
      child: Row(
        children: [
          // Back button (ghost)
          if (currentStep > 0) ...[
            Expanded(
              child: SizedBox(
                height: 54,
                child: OutlinedButton(
                  onPressed: isSubmitting ? null : onBack,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFFE2E8F0)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppBorderRadius.wiseLg,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Back',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.body,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],

          // Next / Submit button
          Expanded(
            flex: currentStep == 0 ? 1 : 2,
            child: GradientButton(
              onPressed: onNext,
              loading: isSubmitting,
              icon: isLast ? Icons.send_rounded : Icons.arrow_forward_rounded,
              label: isLast ? 'Submit Ticket' : 'Continue',
              loadingLabel: 'Submitting...',
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared field widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StepHint extends StatelessWidget {
  final IconData icon;
  final String text;
  const _StepHint({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
        border: Border.all(color: const Color(0xFFDDD0FF)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF9A32F8)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(
                color: const Color(0xFF6A2FF3),
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _FieldLabel({required this.label, this.required = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: AppTypography.bodySm.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        if (required)
          const Text(
            ' *',
            style: TextStyle(
              color: Color(0xFFEF4444),
              fontWeight: FontWeight.w700,
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 1 widgets
// ─────────────────────────────────────────────────────────────────────────────

class _SubjectField extends StatelessWidget {
  final TextEditingController controller;
  final int maxChars;
  final ValueChanged<String> onChanged;
  const _SubjectField({
    required this.controller,
    required this.maxChars,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            maxLines: 1,
            maxLength: maxChars,
            buildCounter:
                (_, {required currentLength, required isFocused, maxLength}) =>
                    const SizedBox.shrink(),
            onChanged: onChanged,
            style: AppTypography.bodySm.copyWith(color: AppColors.ink),
            decoration: InputDecoration(
              hintText: 'Brief summary of your request...',
              hintStyle: AppTypography.bodySm.copyWith(
                color: const Color(0xFFADB5BD),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${controller.text.length}/$maxChars',
          style: AppTypography.caption.copyWith(fontSize: 11),
        ),
      ],
    );
  }
}

class _CategoryDropdown extends StatelessWidget {
  final _Category? selected;
  final VoidCallback onTap;
  const _CategoryDropdown({required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
          border: Border.all(color: const Color(0xFFE2E8F0)),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: const BoxDecoration(
                color: Color(0xFFF0ECFF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                selected?.icon ?? Icons.category_outlined,
                color: const Color(0xFF9A32F8),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selected?.label ?? 'Select category',
                style: AppTypography.bodySm.copyWith(
                  color: selected != null
                      ? AppColors.ink
                      : const Color(0xFFADB5BD),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(
              Icons.keyboard_arrow_down,
              color: AppColors.mute,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _CategorySheet extends StatelessWidget {
  final List<_Category> categories;
  final _Category? selected;
  final ValueChanged<_Category> onSelect;
  const _CategorySheet({
    required this.categories,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Category',
            style: AppTypography.bodyMd.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 16),
          ...categories.map(
            (c) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: Color(0xFFF0ECFF),
                  shape: BoxShape.circle,
                ),
                child: Icon(c.icon, color: const Color(0xFF9A32F8), size: 18),
              ),
              title: Text(
                c.label,
                style: AppTypography.bodySm.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              trailing: selected?.label == c.label
                  ? const Icon(Icons.check, color: Color(0xFF4C39F2), size: 18)
                  : null,
              onTap: () => onSelect(c),
            ),
          ),
        ],
      ),
    );
  }
}

class _PrioritySelector extends StatelessWidget {
  final List<_Priority> priorities;
  final _Priority? selected;
  final ValueChanged<_Priority> onSelect;
  const _PrioritySelector({
    required this.priorities,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    if (priorities.isEmpty) {
      return const SizedBox.shrink();
    }
    return Row(
      children: priorities.map((p) {
        final isSelected = selected?.label == p.label;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(right: p == priorities.last ? 0 : 8),
            child: GestureDetector(
              onTap: () => onSelect(p),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? p.color.withValues(alpha: 0.1)
                      : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
                  border: Border.all(
                    color: isSelected ? p.color : const Color(0xFFE2E8F0),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(p.icon, color: p.color, size: 18),
                    const SizedBox(height: 4),
                    Text(
                      p.label,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected ? p.color : AppColors.body,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 2 widgets
// ─────────────────────────────────────────────────────────────────────────────

class _DescriptionField extends StatelessWidget {
  final TextEditingController controller;
  final int maxChars;
  final ValueChanged<String> onChanged;
  const _DescriptionField({
    required this.controller,
    required this.maxChars,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: TextField(
            controller: controller,
            maxLines: 9,
            maxLength: maxChars,
            buildCounter:
                (_, {required currentLength, required isFocused, maxLength}) =>
                    const SizedBox.shrink(),
            onChanged: onChanged,
            style: AppTypography.bodySm.copyWith(color: AppColors.ink),
            decoration: InputDecoration(
              hintText:
                  'Describe your request in detail — include any reference numbers, dates, or relevant context...',
              hintStyle: AppTypography.bodySm.copyWith(
                color: const Color(0xFFADB5BD),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.fromLTRB(14, 32, 14, 14),
            ),
          ),
        ),
        Positioned(
          top: 10,
          right: 12,
          child: Text(
            '${controller.text.length}/$maxChars',
            style: AppTypography.caption.copyWith(fontSize: 11),
          ),
        ),
      ],
    );
  }
}

class _DueDatePicker extends StatelessWidget {
  final DateTime? selectedDate;
  final VoidCallback onTap;
  final VoidCallback onClear;
  const _DueDatePicker({
    required this.selectedDate,
    required this.onTap,
    required this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    final hasDate = selectedDate != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
          border: Border.all(
            color: hasDate ? const Color(0xFF4C39F2) : const Color(0xFFE2E8F0),
            width: hasDate ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: hasDate
                    ? const Color(0xFFE4DCFF)
                    : const Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.event_rounded,
                color: hasDate ? const Color(0xFF4C39F2) : AppColors.mute,
                size: 17,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasDate
                    ? DateFormat('EEEE, d MMMM yyyy').format(selectedDate!)
                    : 'Select a date (optional)',
                style: AppTypography.bodySm.copyWith(
                  color: hasDate
                      ? const Color(0xFF6A2FF3)
                      : const Color(0xFFADB5BD),
                  fontWeight: hasDate ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
            if (hasDate)
              GestureDetector(
                onTap: onClear,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Color(0xFFF1F5F9),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    size: 13,
                    color: AppColors.body,
                  ),
                ),
              )
            else
              const Icon(
                Icons.keyboard_arrow_down,
                color: AppColors.mute,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Step 3 widgets
// ─────────────────────────────────────────────────────────────────────────────

class _AttachmentsBox extends StatelessWidget {
  final List<_AttachedFile> files;
  final ValueChanged<int> onRemove;
  final VoidCallback onAdd;
  const _AttachmentsBox({
    required this.files,
    required this.onRemove,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        children: [
          ...files.asMap().entries.map((e) {
            final i = e.key;
            final f = e.value;
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _fileIcon(f.mimeType),
                        color: _fileIconColor(f.mimeType),
                        size: 26,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              f.name,
                              style: AppTypography.bodySm.copyWith(
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                            Text(
                              '${f.sizeKb} KB',
                              style: AppTypography.caption,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => onRemove(i),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: const BoxDecoration(
                            color: Color(0xFFF1F5F9),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 14,
                            color: AppColors.body,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFF1F5F9),
                ),
              ],
            );
          }),
          if (files.length < 5)
            GestureDetector(
              onTap: onAdd,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: const BoxDecoration(
                        color: Color(0xFFF0ECFF),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.attach_file_rounded,
                        color: Color(0xFF9A32F8),
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add attachment',
                          style: AppTypography.bodySm.copyWith(
                            color: AppColors.body,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Max 5 files · up to 10 MB each',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Review card ───────────────────────────────────────────────────────────────

class _ReviewCard extends StatelessWidget {
  final String subject;
  final _Category? category;
  final _Priority? priority;
  final String description;
  final DateTime? dueDate;
  final int attachmentCount;

  const _ReviewCard({
    required this.subject,
    required this.category,
    required this.priority,
    required this.description,
    required this.dueDate,
    required this.attachmentCount,
  });

  @override
  Widget build(BuildContext context) {
    final hasSubject = subject.trim().isNotEmpty;
    final hasDesc = description.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(AppBorderRadius.wiseMd),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0ECFF),
                  borderRadius: BorderRadius.circular(9999),
                ),
                child: const Text(
                  'DRAFT',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF9A32F8),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.visibility_outlined,
                size: 14,
                color: AppColors.mute,
              ),
              const SizedBox(width: 4),
              Text(
                'Preview',
                style: AppTypography.caption.copyWith(
                  color: AppColors.mute,
                  fontSize: 11,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Subject
          Text(
            hasSubject ? subject : 'No subject entered',
            style: AppTypography.bodyMd.copyWith(
              fontWeight: FontWeight.w700,
              color: hasSubject ? AppColors.ink : AppColors.mute,
            ),
          ),
          const SizedBox(height: 10),

          // Category + Priority chips
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              if (category != null)
                _ReviewChip(
                  icon: category!.icon,
                  label: category!.label,
                  bg: const Color(0xFFF0ECFF),
                  color: const Color(0xFF9A32F8),
                )
              else
                _ReviewChip(
                  icon: Icons.category_outlined,
                  label: 'No category',
                  bg: const Color(0xFFF1F5F9),
                  color: AppColors.mute,
                ),
              if (priority != null)
                _ReviewChip(
                  icon: priority!.icon,
                  label: priority!.label,
                  bg: priority!.color.withValues(alpha: 0.1),
                  color: priority!.color,
                ),
            ],
          ),

          // Description preview
          if (hasDesc) ...[
            const SizedBox(height: 12),
            Text(
              description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.bodySm.copyWith(
                color: AppColors.body,
                height: 1.55,
              ),
            ),
          ],

          // Due date
          if (dueDate != null) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(
                  Icons.event_outlined,
                  size: 14,
                  color: Color(0xFF4C39F2),
                ),
                const SizedBox(width: 6),
                Text(
                  'Due ${DateFormat('d MMM yyyy').format(dueDate!)}',
                  style: AppTypography.caption.copyWith(
                    color: const Color(0xFF4C39F2),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],

          // Attachments
          if (attachmentCount > 0) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.attach_file_rounded,
                  size: 14,
                  color: AppColors.mute,
                ),
                const SizedBox(width: 6),
                Text(
                  '$attachmentCount attachment${attachmentCount > 1 ? 's' : ''}',
                  style: AppTypography.caption,
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _ReviewChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color bg;
  final Color color;
  const _ReviewChip({
    required this.icon,
    required this.label,
    required this.bg,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(9999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
