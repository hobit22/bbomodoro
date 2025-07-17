import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pomodoro_record.dart';
import '../providers/pomodoro_provider.dart';
import '../utils/date_utils.dart' as app_date_utils;

class PomodoroDetailCard extends StatelessWidget {
  final PomodoroRecord? record;
  final DateTime selectedDate;

  const PomodoroDetailCard({
    super.key,
    required this.record,
    required this.selectedDate,
  });

  @override
  Widget build(BuildContext context) {
    final pomodoroCount = record?.count ?? 0;
    final totalFocusTime = record?.totalFocusTimeString ?? '0분';
    final averageFocusTime = record?.averageFocusTimeString ?? '0분';
    final focusTimes = record?.focusTimes ?? [];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (pomodoroCount > 0) ...[
            // 통계 섹션
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      '총 집중 시간',
                      totalFocusTime,
                      Icons.timer,
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatItem(
                      '평균 집중 시간',
                      averageFocusTime,
                      Icons.av_timer,
                      Colors.red,
                    ),
                  ),
                ],
              ),
            ),

            // 세션 목록 섹션
            if (focusTimes.isNotEmpty) ...[
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.list, size: 20, color: Colors.red.shade600),
                        const SizedBox(width: 8),
                        const Text(
                          '집중 세션',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...focusTimes
                        .asMap()
                        .entries
                        .map(
                          (entry) => _buildCompactFocusTimeItem(
                            context,
                            entry.value,
                            entry.key + 1,
                            entry.key == focusTimes.length - 1,
                            entry.key,
                          ),
                        )
                        .toList(),
                  ],
                ),
              ),
            ],
          ] else ...[
            // 빈 상태
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 48,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '이 날에는 완료된 뽀모도로가 없습니다.',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFocusTimeItem(
    BuildContext context,
    dynamic focusTime,
    int sessionNumber,
    bool isLast,
    int index,
  ) {
    return GestureDetector(
      onLongPress: () => _showDeleteDialog(context, index),
      child: Container(
        margin: EdgeInsets.only(bottom: isLast ? 0 : 8.0),
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            // 세션 번호
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  '$sessionNumber',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red.shade700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // 시간 정보 (한 줄로 통합)
            Expanded(
              child: Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${focusTime.startTimeString} - ${focusTime.endTimeString}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(Icons.timer, size: 14, color: Colors.red.shade600),
                  const SizedBox(width: 4),
                  Text(
                    focusTime.durationString,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('세션 삭제'),
          content: Text('세션 ${index + 1}을(를) 삭제하시겠습니까?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deleteSession(context, index);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('삭제'),
            ),
          ],
        );
      },
    );
  }

  void _deleteSession(BuildContext context, int index) async {
    try {
      final provider = Provider.of<PomodoroProvider>(context, listen: false);
      await provider.deletePomodoroSession(selectedDate, index);

      // 성공 메시지 표시
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('세션이 삭제되었습니다.'),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // 오류 메시지 표시
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('삭제 실패: $e'),
            backgroundColor: Colors.red.shade600,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
