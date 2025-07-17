import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:collection';
import '../models/pomodoro_record.dart';
import '../providers/pomodoro_provider.dart';
import '../widgets/pomodoro_calendar.dart';
import '../widgets/pomodoro_detail_card.dart';
import '../utils/date_utils.dart' as app_date_utils;

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  PomodoroRecord? _selectedRecord;

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;

    // Provider에서 초기 데이터 로드
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<PomodoroProvider>(context, listen: false);
      print('통계 화면 초기화 - 데이터 로드 시작');
      provider.loadPomodoroRecords().then((_) {
        print('통계 화면 데이터 로드 완료');
      });
    });
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!app_date_utils.DateUtils.isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      // Provider에서 선택된 날짜의 기록 가져오기
      final provider = Provider.of<PomodoroProvider>(context, listen: false);
      _selectedRecord = provider.getRecordForDate(selectedDay);
    }
  }

  void _onPageChanged(DateTime focusedDay) {
    setState(() {
      _focusedDay = focusedDay;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PomodoroProvider>(
      builder: (context, provider, child) {
        // 선택된 날짜의 기록 업데이트
        if (_selectedDay != null) {
          _selectedRecord = provider.getRecordForDate(_selectedDay!);
        }

        if (provider.isLoading) {
          return Scaffold(
            appBar: AppBar(title: const Text('Statistics')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Statistics'),
            actions: [
              // IconButton(
              //   icon: const Icon(Icons.refresh),
              //   onPressed: () => provider.addDummyData(),
              // ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              children: [
                // 캘린더 섹션
                Container(
                  height: 350, // 고정 높이로 설정
                  child: PomodoroCalendar(
                    focusedDay: _focusedDay,
                    selectedDay: _selectedDay,
                    pomodoroRecords: provider.pomodoroRecords,
                    onDaySelected: _onDaySelected,
                    onPageChanged: _onPageChanged,
                  ),
                ),
                const SizedBox(height: 8.0),
                // 상세 정보 섹션
                PomodoroDetailCard(
                  record: _selectedRecord,
                  selectedDate: _selectedDay!,
                ),
                const SizedBox(height: 16.0), // 하단 여백
              ],
            ),
          ),
        );
      },
    );
  }
}
