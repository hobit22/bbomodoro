import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:bbomodoro/screens/timer_screen.dart';
import 'package:bbomodoro/screens/settings_screen.dart';
import 'package:bbomodoro/screens/stats_screen.dart';
import 'package:bbomodoro/providers/pomodoro_provider.dart';
import 'package:bbomodoro/providers/timer_provider.dart';
import 'package:bbomodoro/providers/timer_provider.dart' show TimerMode;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PomodoroProvider()),
        ChangeNotifierProvider(create: (context) => TimerProvider()),
      ],
      child: MaterialApp(
        title: 'Pomodoro Timer',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const MainScreen(),
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  bool _notifications = true;
  bool _autoStartBreak = true; // 자동 휴식 시작 기본값
  int _focusTime = 25;
  int _shortBreak = 5;
  int _longBreak = 15;

  void _updateSettings(
    bool notifications,
    bool autoStartBreak,
    int focusTime,
    int shortBreak,
    int longBreak,
  ) {
    setState(() {
      _notifications = notifications;
      _autoStartBreak = autoStartBreak;
      _focusTime = focusTime;
      _shortBreak = shortBreak;
      _longBreak = longBreak;
    });

    // TimerProvider에 설정 업데이트
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    timerProvider.updateSettings(
      focusTime: focusTime,
      shortBreak: shortBreak,
      longBreak: longBreak,
      autoStartBreak: autoStartBreak,
    );
  }

  void _onItemTapped(int index) {
    final timerProvider = Provider.of<TimerProvider>(context, listen: false);
    final isFocusMode =
        timerProvider.isRunning && timerProvider.currentMode == TimerMode.focus;
    if (isFocusMode) {
      // 포커스 모드 실행 중에는 타이머 탭(0)만 허용
      if (index == 0) {
        setState(() {
          _selectedIndex = index;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('집중해야지?'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _widgetOptions = <Widget>[
      const TimerScreen(),
      const StatsScreen(),
      SettingsScreen(
        notifications: _notifications,
        autoStartBreak: _autoStartBreak,
        focusTime: _focusTime,
        shortBreak: _shortBreak,
        longBreak: _longBreak,
        onSettingsChanged: _updateSettings,
      ),
    ];

    return Scaffold(
      body: Center(child: _widgetOptions.elementAt(_selectedIndex)),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.timer), label: 'Timer'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Stats'),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.redAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}
