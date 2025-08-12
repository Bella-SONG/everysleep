import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../providers/font_size_provider.dart';
import '../../constants/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nicknameController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _loadUserProfile() {
    final userProfile = context.read<UserProvider>().userProfile;
    if (userProfile != null) {
      _nicknameController.text = userProfile.nickname;
      _selectedDate = userProfile.birthDate;
      _selectedGender = userProfile.gender;
    }
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().subtract(const Duration(days: 365 * 30)),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
      locale: const Locale('ko', 'KR'),
      helpText: '생년월일을 선택해주세요',
      cancelText: '취소',
      confirmText: '확인',
      fieldLabelText: '생년월일',
      fieldHintText: 'yyyy/mm/dd',
      errorFormatText: '올바른 날짜 형식을 입력해주세요',
      errorInvalidText: '유효한 날짜를 입력해주세요',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme.copyWith(
              primary: AppTheme.primaryColor,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  String _getGenderDisplayText(String gender) {
    switch (gender) {
      case 'male':
        return '남성';
      case 'female':
        return '여성';
      case 'other':
        return '기타';
      default:
        return gender;
    }
  }

  void _showGenderBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                '성별을 선택해주세요',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 20),
              _buildGenderOption('male', '남성', Icons.male),
              _buildGenderOption('female', '여성', Icons.female),
              _buildGenderOption('other', '기타', Icons.people),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGenderOption(String value, String label, IconData icon) {
    final isSelected = _selectedGender == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedGender = value;
        });
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.grey.shade50,
          border: Border.all(
            color: isSelected ? AppTheme.primaryColor : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey.shade600,
              size: 24,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppTheme.primaryColor : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: AppTheme.primaryColor,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProfile() async {
    // 필수 필드 유효성 검사
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('닉네임을 입력해주세요'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('생년월일을 선택해주세요'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }
    
    if (_selectedGender == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('성별을 선택해주세요'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
      return;
    }

    try {
      final userProvider = context.read<UserProvider>();
      final success = await userProvider.updateUserProfile(
        nickname: _nicknameController.text.trim(),
        birthDate: _selectedDate!,
        gender: _selectedGender!,
      );

      if (mounted) {
        if (success) {
          // 저장 성공 시 편집모드 해제
          setState(() {
            _isEditing = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                '프로필이 업데이트되었습니다',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              backgroundColor: AppTheme.primaryColor,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: const EdgeInsets.all(16),
              elevation: 4,
              duration: const Duration(seconds: 2),
            ),
          );
        } else {
          // 저장 실패 시 편집모드 유지하고 오류 메시지
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('프로필 업데이트에 실패했습니다. 다시 시도해주세요.'),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('오류가 발생했습니다. 다시 시도해주세요.'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  Future<void> _handleLogout() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('로그아웃'),
        content: const Text('정말 로그아웃하시겠습니까?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              // BuildContext를 미리 저장
              final authProvider = context.read<AuthProvider>();
              final userProvider = context.read<UserProvider>();
              final router = GoRouter.of(context);
              
              // 로그아웃 처리
              await authProvider.signOut();
              await userProvider.clearUserProfile();
              
              if (mounted) {
                router.go('/login');
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorColor,
            ),
            child: const Text('로그아웃'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final authProvider = context.watch<AuthProvider>();
    final fontSizeProvider = context.watch<FontSizeProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('내 정보'),
        automaticallyImplyLeading: false,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingL),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacingL),
                decoration: BoxDecoration(
                  color: AppTheme.surfaceColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        size: 40,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingM),
                    Text(
                      authProvider.user?.userMetadata?['name'] ?? authProvider.user?.email?.split('@')[0] ?? '사용자',
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              // 닉네임 입력 필드
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: _isEditing 
                      ? Border.all(
                          color: AppTheme.primaryColor.withValues(alpha: 0.3),
                          width: 1.5,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  color: _isEditing ? Colors.white : AppTheme.cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: _isEditing 
                          ? AppTheme.primaryColor 
                          : Colors.grey.shade400,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '닉네임',
                            style: TextStyle(
                              fontSize: 12,
                              color: _isEditing 
                                  ? AppTheme.primaryColor 
                                  : Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          _isEditing
                              ? TextFormField(
                                  controller: _nicknameController,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                    hintText: '닉네임을 입력해주세요',
                                    hintStyle: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '닉네임을 입력해주세요';
                                    }
                                    return null;
                                  },
                                )
                              : Text(
                                  _nicknameController.text.isNotEmpty
                                      ? _nicknameController.text
                                      : '닉네임을 입력해주세요',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _nicknameController.text.isNotEmpty
                                        ? Colors.black87
                                        : Colors.grey.shade700,
                                    fontWeight: _nicknameController.text.isNotEmpty 
                                        ? FontWeight.w500 
                                        : FontWeight.w500,
                                  ),
                                ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              // 생년월일 입력 필드
              GestureDetector(
                onTap: _isEditing ? () => _selectDate(context) : null,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: _isEditing 
                        ? Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            width: 1.5,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    color: _isEditing ? Colors.white : AppTheme.cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        color: _isEditing 
                            ? AppTheme.primaryColor 
                            : Colors.grey.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '생년월일',
                              style: TextStyle(
                                fontSize: 12,
                                color: _isEditing 
                                    ? AppTheme.primaryColor 
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedDate != null
                                  ? DateFormat('yyyy년 MM월 dd일').format(_selectedDate!)
                                  : '생년월일을 선택해주세요',
                              style: TextStyle(
                                fontSize: 16,
                                color: _selectedDate != null
                                    ? Colors.black87
                                    : Colors.grey.shade700,
                                fontWeight: _selectedDate != null 
                                    ? FontWeight.w500 
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isEditing)
                        Icon(
                          Icons.arrow_drop_down,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingM),
              // 성별 선택 필드
              GestureDetector(
                onTap: _isEditing ? () => _showGenderBottomSheet() : null,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    border: _isEditing 
                        ? Border.all(
                            color: AppTheme.primaryColor.withValues(alpha: 0.3),
                            width: 1.5,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    color: _isEditing ? Colors.white : AppTheme.cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.people,
                        color: _isEditing 
                            ? AppTheme.primaryColor 
                            : Colors.grey.shade400,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '성별',
                              style: TextStyle(
                                fontSize: 12,
                                color: _isEditing 
                                    ? AppTheme.primaryColor 
                                    : Colors.grey.shade600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _selectedGender != null
                                  ? _getGenderDisplayText(_selectedGender!)
                                  : '성별을 선택해주세요',
                              style: TextStyle(
                                fontSize: 16,
                                color: _selectedGender != null
                                    ? Colors.black87
                                    : Colors.grey.shade700,
                                fontWeight: _selectedGender != null 
                                    ? FontWeight.w500 
                                    : FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_isEditing)
                        Icon(
                          Icons.arrow_drop_down,
                          color: AppTheme.primaryColor,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacingL),
              _buildFontSizeSection(fontSizeProvider),
              if (_isEditing) ...[
                const SizedBox(height: AppTheme.spacingXL),
                Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _isEditing = false;
                            _loadUserProfile();
                          });
                        },
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            border: Border.all(color: Colors.grey.shade400),
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: const Center(
                            child: Text(
                              '취소',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingM),
                    Expanded(
                      child: InkWell(
                        onTap: userProvider.isLoading ? null : _saveProfile,
                        borderRadius: BorderRadius.circular(25),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: userProvider.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                  )
                                : const Text(
                                    '저장',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: AppTheme.spacingXL * 2),
              TextButton.icon(
                onPressed: _handleLogout,
                icon: const Icon(Icons.logout),
                label: const Text('로그아웃'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.errorColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFontSizeSection(FontSizeProvider fontSizeProvider) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.text_fields,
                color: AppTheme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: AppTheme.spacingS),
              Text(
                '글자 크기',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            '현재 설정: ${fontSizeProvider.currentLevelName}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondaryColor,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Text(
            '미리보기: 안녕하세요! EverySleep입니다.',
            style: fontSizeProvider.applyFontSize(
              Theme.of(context).textTheme.bodyLarge,
            ),
          ),
          const SizedBox(height: AppTheme.spacingM),
          Wrap(
            spacing: AppTheme.spacingS,
            children: FontSizeLevel.values.map((level) {
              final isSelected = fontSizeProvider.currentLevel == level;
              return ChoiceChip(
                label: Text(_getFontSizeLevelName(level)),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    fontSizeProvider.setFontSize(level);
                  }
                },
                selectedColor: AppTheme.primaryColor.withValues(alpha: 0.2),
                checkmarkColor: AppTheme.primaryColor,
                labelStyle: TextStyle(
                  color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondaryColor,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  String _getFontSizeLevelName(FontSizeLevel level) {
    switch (level) {
      case FontSizeLevel.small:
        return '작게';
      case FontSizeLevel.normal:
        return '보통';
      case FontSizeLevel.large:
        return '크게';
      case FontSizeLevel.extraLarge:
        return '매우 크게';
    }
  }
}