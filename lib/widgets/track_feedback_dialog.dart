import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/track.dart';
import '../models/track_feedback.dart';
import '../models/feedback_option.dart';
import '../constants/app_theme.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class TrackFeedbackDialog extends StatefulWidget {
  final Track track;
  final Function(TrackFeedback feedback) onSubmitFeedback;
  final bool? initialIsPositive;

  const TrackFeedbackDialog({
    super.key,
    required this.track,
    required this.onSubmitFeedback,
    this.initialIsPositive,
  });

  @override
  State<TrackFeedbackDialog> createState() => _TrackFeedbackDialogState();
}

class _TrackFeedbackDialogState extends State<TrackFeedbackDialog>
    with TickerProviderStateMixin {
  FeedbackStep _currentStep = FeedbackStep.initial;
  bool? _isPositive;
  Set<String> _selectedOptions = <String>{};  // final 제거
  final TextEditingController _textController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    
    // 상태 초기화 (새로운 다이얼로그마다 깨끗한 상태로 시작)
    _currentStep = FeedbackStep.initial;
    _isPositive = null;
    _selectedOptions = <String>{};  // 새로운 Set 할당으로 완전 초기화
    _textController.clear();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    
    // 초기값이 설정된 경우 바로 detailed 단계로 이동
    if (widget.initialIsPositive != null) {
      _isPositive = widget.initialIsPositive;
      _currentStep = FeedbackStep.detailed;
    }
    
    // 20초 후 자동으로 모달 닫기
    _startAutoCloseTimer();
  }

  @override
  void dispose() {
    _autoCloseTimer?.cancel();
    _animationController.dispose();
    _textController.dispose();
    super.dispose();
  }

  void _startAutoCloseTimer() {
    _autoCloseTimer = Timer(const Duration(seconds: 20), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _cancelAutoCloseTimer() {
    _autoCloseTimer?.cancel();
  }

  void _onInitialFeedback(bool isPositive) {
    _cancelAutoCloseTimer(); // 기존 타이머 취소
    HapticFeedback.lightImpact();
    setState(() {
      _isPositive = isPositive;
      _currentStep = FeedbackStep.detailed;
    });
    _startAutoCloseTimer(); // 새로운 20초 타이머 시작
  }

  void _toggleOption(String optionId) {
    _cancelAutoCloseTimer(); // 사용자 액션 시 타이머 취소
    HapticFeedback.selectionClick();
    setState(() {
      if (_selectedOptions.contains(optionId)) {
        _selectedOptions.remove(optionId);
      } else {
        _selectedOptions.add(optionId);
      }
    });
  }

  void _submitFeedback() {
    _cancelAutoCloseTimer(); // 사용자 액션 시 타이머 취소
    
    // 카카오 사용자 ID 또는 Supabase ID 또는 랜덤 UUID 사용
    final authProvider = context.read<AuthProvider>();
    final kakaoUserId = authProvider.user?.id.toString();
    final userId = kakaoUserId ?? 
                   Supabase.instance.client.auth.currentUser?.id ?? 
                   const Uuid().v4();
    
    // 현재 선택된 테마 ID 가져오기
    final themeProvider = context.read<ThemeProvider>();
    final themeId = themeProvider.selectedTheme?.id.toString();
    
    final feedback = TrackFeedback.now(
      trackId: widget.track.id.toString(),  // id를 문자열로 변환
      themeId: themeId,  // 테마 ID (없으면 null)
      userId: userId,
      isPositive: _isPositive!,
      selectedOptions: _selectedOptions.toList(),
      feedbackText: _textController.text.trim().isEmpty 
          ? null 
          : _textController.text.trim(),
    );
    
    // 피드백 제출 후 즉시 상태 초기화
    setState(() {
      _selectedOptions = <String>{};
      _textController.clear();
      _isPositive = null;
      _currentStep = FeedbackStep.initial;
    });
    
    widget.onSubmitFeedback(feedback);
    _showThankYou();
  }

  void _showThankYou() {
    setState(() {
      _currentStep = FeedbackStep.thankYou;
    });
    
    // 2초 후 닫기
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  void _skipFeedback() {
    _cancelAutoCloseTimer(); // 사용자 액션 시 타이머 취소
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 400,
            maxHeight: 600, // 최대 높이 제한
          ),
          decoration: BoxDecoration(
            color: _isPositive == null 
                ? Colors.white
                : _isPositive! 
                    ? const Color(0xFFE8F5E8)  // 연한 초록색
                    : const Color(0xFFFFF3E0), // 연한 주황색
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _buildCurrentStep(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep() {
    switch (_currentStep) {
      case FeedbackStep.initial:
        return _buildInitialStep();
      case FeedbackStep.detailed:
        return _buildDetailedStep();
      case FeedbackStep.thankYou:
        return _buildThankYouStep();
    }
  }

  Widget _buildInitialStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.music_note,
          size: 48,
          color: AppTheme.primaryColor,
        ),
        const SizedBox(height: 16),
        Text(
          '"${widget.track.title}"',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          '재생이 끝났습니다',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        Text(
          '음악이 어떠셨나요?',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: _buildFeedbackButton(
                onPressed: () => _onInitialFeedback(true),
                icon: '👍',
                label: '좋았어요',
                color: Colors.green.shade100,
                borderColor: Colors.green.shade300,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildFeedbackButton(
                onPressed: () => _onInitialFeedback(false),
                icon: '👎',
                label: '별로예요',
                color: Colors.orange.shade100,
                borderColor: Colors.orange.shade300,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        TextButton(
          onPressed: _skipFeedback,
          child: Text(
            '다음에 하기',
            style: TextStyle(
              color: AppTheme.textSecondaryColor,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailedStep() {
    final options = FeedbackOptions.getOptions(
      _isPositive! ? FeedbackType.positive : FeedbackType.negative
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Text(
              _isPositive! ? '👍' : '👎',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _isPositive! 
                    ? '좋았다니 다행이에요!'
                    : '아쉬웠네요...',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          _isPositive!
              ? '어떤 점이 좋았나요?'
              : '어떤 점이 좋지 않았나요?',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '(여러 개 선택 가능)',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 24),
        ...options.map((option) => _buildOptionTile(option)),
        const SizedBox(height: 24),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: _textController,
            maxLines: 3,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: _isPositive!
                  ? '더 하고 싶은 말이 있으시면 적어주세요 (선택사항)'
                  : '개선사항이 있다면 알려주세요 (선택사항)',
              hintStyle: TextStyle(
                color: AppTheme.textSecondaryColor,
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 32),
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 56, // 고정 높이
                child: OutlinedButton(
                  onPressed: _skipFeedback,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: Colors.grey.shade400),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '건너뛰기',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondaryColor,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SizedBox(
                height: 56, // 고정 높이
                child: ElevatedButton(
                  onPressed: _selectedOptions.isNotEmpty || _textController.text.trim().isNotEmpty
                      ? _submitFeedback
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    '완료',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildThankYouStep() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green.shade100,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.check,
            size: 48,
            color: Colors.green.shade700,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          '소중한 의견 감사합니다!',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimaryColor,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          '더 나은 수면 음악을 위해\n활용하겠습니다',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: AppTheme.textSecondaryColor,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildFeedbackButton({
    required VoidCallback onPressed,
    required String icon,
    required String label,
    required Color color,
    required Color borderColor,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Column(
          children: [
            Text(
              icon,
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionTile(FeedbackOption option) {
    final isSelected = _selectedOptions.contains(option.id);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _toggleOption(option.id),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected 
                ? AppTheme.primaryColor.withValues(alpha: 0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected 
                  ? AppTheme.primaryColor
                  : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? AppTheme.primaryColor : Colors.grey.shade400,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check,
                        color: Colors.white,
                        size: 16,
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Text(
                option.icon,
                style: const TextStyle(fontSize: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  option.optionText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                    color: isSelected 
                        ? AppTheme.primaryColor 
                        : AppTheme.textPrimaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum FeedbackStep {
  initial,
  detailed,
  thankYou,
}