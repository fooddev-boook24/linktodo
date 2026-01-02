import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/theme.dart';
import '../models/link.dart';
import '../providers/link_provider.dart';

class AddLinkModal extends ConsumerStatefulWidget {
  final Link? editLink;
  final String? initialUrl;

  const AddLinkModal({super.key, this.editLink, this.initialUrl});

  @override
  ConsumerState<AddLinkModal> createState() => _AddLinkModalState();
}

class _AddLinkModalState extends ConsumerState<AddLinkModal> {
  final _urlController = TextEditingController();
  final _titleController = TextEditingController();
  DateTime? _selectedDeadline;
  int _selectedQuickDate = -1;

  bool get isEditing => widget.editLink != null;

  @override
  void initState() {
    super.initState();
    if (isEditing) {
      _urlController.text = widget.editLink!.url;
      _titleController.text = widget.editLink!.title;
      _selectedDeadline = widget.editLink!.deadline;
    } else if (widget.initialUrl != null) {
      _urlController.text = widget.initialUrl!;
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ハンドル
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // タイトル
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text('🔗', style: TextStyle(fontSize: 20)),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    isEditing ? 'リンクを編集' : 'リンクを追加',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 28),

              // URL入力
              _buildLabel('URL'),
              const SizedBox(height: 8),
              TextField(
                controller: _urlController,
                decoration: InputDecoration(
                  hintText: 'https://example.com',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('🔗', style: TextStyle(fontSize: 18)),
                  ),
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                  ),
                ),
                keyboardType: TextInputType.url,
                enabled: !isEditing,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 20),

              // タイトル入力
              _buildLabel('タイトル'),
              const SizedBox(height: 8),
              TextField(
                controller: _titleController,
                decoration: InputDecoration(
                  hintText: 'わかりやすい名前をつけよう',
                  prefixIcon: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text('✏️', style: TextStyle(fontSize: 18)),
                  ),
                  filled: true,
                  fillColor: AppTheme.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                  ),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 28),

              // 期限選択
              Row(
                children: [
                  const Text('⏰', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 8),
                  const Text(
                    'いつまでに開く？',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // クイック選択ボタン
              Row(
                children: [
                  _buildQuickDateChip(0, '今日'),
                  const SizedBox(width: 8),
                  _buildQuickDateChip(1, '明日'),
                  const SizedBox(width: 8),
                  _buildQuickDateChip(2, '3日後'),
                  const SizedBox(width: 8),
                  _buildQuickDateChip(3, '1週間'),
                ],
              ),

              const SizedBox(height: 12),

              // カスタム日付選択
              GestureDetector(
                onTap: _selectDateTime,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.background,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _selectedQuickDate == -1 && _selectedDeadline != null
                          ? AppTheme.primary
                          : Colors.transparent,
                      width: 2,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '📅',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _selectedDeadline != null && _selectedQuickDate == -1
                            ? _formatDateTime(_selectedDeadline!)
                            : '日付・時刻を指定する',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: _selectedDeadline != null && _selectedQuickDate == -1
                              ? AppTheme.primary
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // 保存ボタン
              SizedBox(
                width: double.infinity,
                height: 56,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: _canSave()
                        ? AppTheme.primaryGradient
                        : null,
                    color: _canSave() ? null : AppTheme.border,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _canSave()
                        ? [
                      BoxShadow(
                        color: AppTheme.primaryDark.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ]
                        : null,
                  ),
                  child: ElevatedButton(
                    onPressed: _canSave() ? _save : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      disabledBackgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isEditing ? '更新する' : '保存する',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: _canSave() ? Colors.white : AppTheme.textHint,
                          ),
                        ),
                        if (_canSave()) ...[
                          const SizedBox(width: 8),
                          const Text('🎉', style: TextStyle(fontSize: 18)),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppTheme.textSecondary,
      ),
    );
  }

  Widget _buildQuickDateChip(int index, String label) {
    final isSelected = _selectedQuickDate == index;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedQuickDate = index;
            _selectedDeadline = _getDateFromIndex(index);
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.primaryLight : AppTheme.background,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppTheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppTheme.primary : AppTheme.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  DateTime _getDateFromIndex(int index) {
    final now = DateTime.now();
    switch (index) {
      case 0:
        return DateTime(now.year, now.month, now.day, 23, 59);
      case 1:
        return DateTime(now.year, now.month, now.day + 1, 23, 59);
      case 2:
        return DateTime(now.year, now.month, now.day + 3, 23, 59);
      case 3:
        return DateTime(now.year, now.month, now.day + 7, 23, 59);
      default:
        return DateTime(now.year, now.month, now.day, 23, 59);
    }
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDeadline ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primary,
              onPrimary: Colors.white,
              surface: AppTheme.surface,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          _selectedDeadline ?? DateTime.now(),
        ),
        builder: (context, child) {
          return Theme(
            data: Theme.of(context).copyWith(
              colorScheme: const ColorScheme.light(
                primary: AppTheme.primary,
                onPrimary: Colors.white,
                surface: AppTheme.surface,
                onSurface: AppTheme.textPrimary,
              ),
            ),
            child: child!,
          );
        },
      );

      if (time != null) {
        setState(() {
          _selectedQuickDate = -1;
          _selectedDeadline = DateTime(
            date.year,
            date.month,
            date.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.year}/${dateTime.month}/${dateTime.day} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  bool _canSave() {
    return _urlController.text.isNotEmpty &&
        _titleController.text.isNotEmpty &&
        _selectedDeadline != null;
  }

  Future<void> _save() async {
    if (!_canSave()) return;

    if (isEditing) {
      widget.editLink!.title = _titleController.text;
      widget.editLink!.deadline = _selectedDeadline!;
      await ref.read(linkProvider.notifier).update(widget.editLink!);
    } else {
      await ref.read(linkProvider.notifier).add(
        url: _urlController.text,
        title: _titleController.text,
        deadline: _selectedDeadline!,
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}