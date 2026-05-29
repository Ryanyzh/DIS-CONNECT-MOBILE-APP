import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:disconnect_mobile/core/theme/design_system.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Swap data with database when backend is ready
// ─────────────────────────────────────────────────────────────────────────────
const _categories = [
  _Category('Reimbursement', Icons.receipt_long_outlined),
  _Category('Internship', Icons.work_outline),
  _Category('Scholarship', Icons.school_outlined),
  _Category('Leave', Icons.calendar_today_outlined),
  _Category('Exchange', Icons.flight_outlined),
  _Category('Policy', Icons.policy_outlined),
];

class _Category {
  final String label;
  final IconData icon;
  const _Category(this.label, this.icon);
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

  // ── Step 1 state ─────────────────────────────────────────────────────────
  final _subjectController = TextEditingController();
  static const int _maxSubjectChars = 200;
  _Category? _selectedCategory;

  // ── Step 2 state ─────────────────────────────────────────────────────────
  final _descController = TextEditingController();

  // ── Step 3 state ─────────────────────────────────────────────────────────

  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _subjectController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // ── Navigation ────────────────────────────────────────────────────────────

  void _goNext() {
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
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) {
      setState(() => _isSubmitting = false);
      context.go('/tickets');
    }
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
        icon: const Icon(Icons.arrow_back, color: AppColors.ink),
        onPressed: null, // TODO: confirm discard if there are unsaved changes
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
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TODO: if user has a profile, show their name/email and pre-fill contact info fields
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
          // TODO: category dropdown, priority selector, subject field
          // ── Section hint ────────────────────────────────────────────────
          _StepHint(
            icon: Icons.edit_note_rounded,
            text:
                'Describe your request clearly. Include any relevant context or reference numbers.',
          ),
          const SizedBox(height: 24),
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
          // TODO: description field, due date picker, file attachments, submit button
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
                        ? const Color(0xFF4338CA)
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
                      ? const Color(0xFF4338CA)
                      : isActive
                      ? const Color(0xFF4338CA)
                      : const Color(0xFFF1F5F9),
                  border: isActive
                      ? Border.all(color: const Color(0xFFE0E7FF), width: 3)
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
                      ? const Color(0xFF4338CA)
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
            child: SizedBox(
              height: 54,
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : onNext,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF3730A3),
                  disabledBackgroundColor: const Color(
                    0xFF3730A3,
                  ).withValues(alpha: 0.6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.wiseLg),
                  ),
                ),
                icon: isSubmitting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Icon(
                        isLast
                            ? Icons.send_rounded
                            : Icons.arrow_forward_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                label: Text(
                  isSubmitting
                      ? 'Submitting...'
                      : isLast
                      ? 'Submit Ticket'
                      : 'Continue',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
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
        border: Border.all(color: const Color(0xFFDDD6FE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: const Color(0xFF7C3AED)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: AppTypography.caption.copyWith(
                color: const Color(0xFF5B21B6),
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
                color: Color(0xFFEDE9FE),
                shape: BoxShape.circle,
              ),
              child: Icon(
                selected?.icon ?? Icons.category_outlined,
                color: const Color(0xFF7C3AED),
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








// ─────────────────────────────────────────────────────────────────────────────
// Step 2 widgets
// ─────────────────────────────────────────────────────────────────────────────









// ─────────────────────────────────────────────────────────────────────────────
// Step 3 widgets
// ─────────────────────────────────────────────────────────────────────────────


