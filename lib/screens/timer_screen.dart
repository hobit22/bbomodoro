import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/timer_provider.dart';
import '../providers/pomodoro_provider.dart';
import '../utils/date_utils.dart' as app_date_utils;
import '../constants/app_constants.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../utils/ui_utils.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  @override
  void initState() {
    super.initState();
    // 타이머 초기화 및 콜백 설정
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final timerProvider = Provider.of<TimerProvider>(context, listen: false);
      timerProvider.initialize();
      timerProvider.setPomodoroCompletedCallback(_savePomodoro);
      timerProvider.setMessageCallback(_showCompletionMessage);
    });
    WakelockPlus.enable();
  }

  @override
  void dispose() {
    // 포커스타임 종료 시 화면 꺼짐 허용
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _savePomodoro(DateTime startTime, DateTime endTime) async {
    try {
      final provider = Provider.of<PomodoroProvider>(context, listen: false);
      await provider.addPomodoro(DateTime.now(), startTime, endTime);
    } catch (e) {
      print('뽀모도로 저장 실패: $e');
    }
  }

  void _showCompletionMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.green,
      ),
    );
  }

  String _formatTime(int seconds) {
    return app_date_utils.DateUtils.formatSeconds(seconds);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<TimerProvider, PomodoroProvider>(
      builder: (context, timerProvider, pomodoroProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: Text(timerProvider.getModeTitle()),
            backgroundColor: Color(timerProvider.getProgressColor()),
            foregroundColor: Colors.white,
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 2,
                child: Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: AppConstants.timerCircleSize,
                        height: AppConstants.timerCircleSize,
                        child: CircularProgressIndicator(
                          value: timerProvider.getProgressValue(),
                          strokeWidth: AppConstants.timerStrokeWidth,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Color(timerProvider.getProgressColor()),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatTime(timerProvider.totalSeconds),
                            style: const TextStyle(
                              fontSize: 50,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            timerProvider.getModeTitle(),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      iconSize: AppConstants.largeIconSize,
                      onPressed: () async {
                        if (timerProvider.isRunning) {
                          timerProvider.pauseTimer();
                          await LockTaskUtil.stopLockTask();
                        } else {
                          timerProvider.startTimer();
                          if (timerProvider.currentMode == TimerMode.focus) {
                            await LockTaskUtil.startLockTask();
                          }
                        }
                      },
                      icon: Icon(
                        timerProvider.isRunning
                            ? Icons.pause_circle_filled
                            : Icons.play_circle_filled,
                        color: Color(timerProvider.getProgressColor()),
                      ),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      iconSize: AppConstants.largeIconSize,
                      onPressed: () async {
                        timerProvider.resetTimer();
                        await LockTaskUtil.stopLockTask();
                      },
                      icon: const Icon(Icons.refresh),
                    ),
                    const SizedBox(width: 20),
                    IconButton(
                      iconSize: AppConstants.largeIconSize,
                      onPressed: () async {
                        timerProvider.skipToNext();
                        await LockTaskUtil.stopLockTask();
                      },
                      icon: const Icon(Icons.skip_next),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Pomodoros', style: TextStyle(fontSize: 20)),
                        const SizedBox(width: 10),
                        Text(
                          '${timerProvider.pomodoros}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      '완료된 세션: ${timerProvider.completedSessions}',
                      style: const TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
