import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'dart:collection';
import '../models/pomodoro_record.dart';
import '../utils/date_utils.dart' as app_date_utils;
import '../utils/color_utils.dart';
import '../constants/app_constants.dart';

class PomodoroCalendar extends StatelessWidget {
  final DateTime focusedDay;
  final DateTime? selectedDay;
  final LinkedHashMap<DateTime, PomodoroRecord> pomodoroRecords;
  final Function(DateTime, DateTime) onDaySelected;
  final Function(DateTime) onPageChanged;

  const PomodoroCalendar({
    super.key,
    required this.focusedDay,
    required this.selectedDay,
    required this.pomodoroRecords,
    required this.onDaySelected,
    required this.onPageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TableCalendar<int>(
      firstDay: AppConstants.calendarFirstDay,
      lastDay: AppConstants.calendarLastDay,
      focusedDay: focusedDay,
      selectedDayPredicate: (day) =>
          app_date_utils.DateUtils.isSameDay(selectedDay, day),
      eventLoader: (day) {
        final record = pomodoroRecords[day];
        return [record?.count ?? 0];
      },
      onDaySelected: onDaySelected,
      onPageChanged: onPageChanged,
      calendarStyle: const CalendarStyle(
        markersMaxCount: 0, // 이벤트 마커 제거
      ),
      headerStyle: const HeaderStyle(
        formatButtonVisible: false, // 2 weeks 버튼 제거
        titleCentered: true,
      ),
      calendarBuilders: CalendarBuilders(
        defaultBuilder: (context, day, focusedDay) {
          return _buildDayCell(day, false, false);
        },
        todayBuilder: (context, day, focusedDay) {
          return _buildDayCell(day, true, false);
        },
        selectedBuilder: (context, day, focusedDay) {
          return _buildDayCell(day, false, true);
        },
      ),
    );
  }

  Widget _buildDayCell(DateTime day, bool isToday, bool isSelected) {
    final record = pomodoroRecords[day];
    final pomodoroCount = record?.count ?? 0;
    final backgroundColor = ColorUtils.getPomodoroColor(pomodoroCount);
    final textColor = ColorUtils.getTextColor(pomodoroCount);

    Color borderColor;
    double borderWidth;

    if (isSelected) {
      borderColor = Colors.red.shade600;
      borderWidth = 2.0;
    } else if (isToday) {
      borderColor = Colors.red.shade400;
      borderWidth = 2.0;
    } else {
      borderColor = Colors.grey.shade300;
      borderWidth = 1.0;
    }

    return Container(
      margin: const EdgeInsets.all(2.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: borderColor, width: borderWidth),
      ),
      child: Center(
        child: Text(
          '${day.day}',
          style: TextStyle(
            color: textColor,
            fontWeight: (isSelected || isToday)
                ? FontWeight.bold
                : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}
