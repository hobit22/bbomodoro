import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  final bool notifications;
  final bool autoStartBreak;
  final int focusTime;
  final int shortBreak;
  final int longBreak;
  final Function(bool, bool, int, int, int) onSettingsChanged;

  const SettingsScreen({
    super.key,
    required this.notifications,
    required this.autoStartBreak,
    required this.focusTime,
    required this.shortBreak,
    required this.longBreak,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _notifications;
  late bool _autoStartBreak;
  late int _focusTime;
  late int _shortBreak;
  late int _longBreak;

  @override
  void initState() {
    super.initState();
    _notifications = widget.notifications;
    _autoStartBreak = widget.autoStartBreak;
    _focusTime = widget.focusTime;
    _shortBreak = widget.shortBreak;
    _longBreak = widget.longBreak;
  }

  void _showTimePicker(String title, int currentValue, Function(int) onSave) {
    showDialog(
      context: context,
      builder: (context) {
        int selectedValue = currentValue;
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Set $title'),
              content: DropdownButton<int>(
                value: selectedValue,
                items: List.generate(60, (index) => index + 1)
                    .map(
                      (e) => DropdownMenuItem(value: e, child: Text('$e min')),
                    )
                    .toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      selectedValue = value;
                    });
                  }
                },
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    onSave(selectedValue);
                    widget.onSettingsChanged(
                      _notifications,
                      _autoStartBreak,
                      _focusTime,
                      _shortBreak,
                      _longBreak,
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          // 알림 설정
          SwitchListTile(
            title: const Text('알림 활성화'),
            subtitle: const Text('타이머 완료 시 알림을 받습니다'),
            value: _notifications,
            onChanged: (bool value) {
              setState(() {
                _notifications = value;
                widget.onSettingsChanged(
                  _notifications,
                  _autoStartBreak,
                  _focusTime,
                  _shortBreak,
                  _longBreak,
                );
              });
            },
          ),
          const Divider(),
          // 자동 휴식 시작 설정
          SwitchListTile(
            title: const Text('자동 휴식 시작'),
            subtitle: const Text('집중시간 끝나면 자동으로 휴식시간을 시작합니다'),
            value: _autoStartBreak,
            onChanged: (bool value) {
              setState(() {
                _autoStartBreak = value;
                widget.onSettingsChanged(
                  _notifications,
                  _autoStartBreak,
                  _focusTime,
                  _shortBreak,
                  _longBreak,
                );
              });
            },
          ),
          const Divider(),
          // 타이머 설정
          ListTile(
            title: const Text('집중 시간'),
            subtitle: const Text('한 번의 집중 세션 시간'),
            trailing: Text('$_focusTime 분'),
            onTap: () => _showTimePicker('집중 시간', _focusTime, (value) {
              setState(() {
                _focusTime = value;
              });
            }),
          ),
          ListTile(
            title: const Text('짧은 휴식'),
            subtitle: const Text('짧은 휴식 시간'),
            trailing: Text('$_shortBreak 분'),
            onTap: () => _showTimePicker('짧은 휴식', _shortBreak, (value) {
              setState(() {
                _shortBreak = value;
              });
            }),
          ),
          ListTile(
            title: const Text('긴 휴식'),
            subtitle: const Text('긴 휴식 시간'),
            trailing: Text('$_longBreak 분'),
            onTap: () => _showTimePicker('긴 휴식', _longBreak, (value) {
              setState(() {
                _longBreak = value;
              });
            }),
          ),
        ],
      ),
    );
  }
}
