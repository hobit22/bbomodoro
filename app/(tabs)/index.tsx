import React from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { usePomodoroContext } from '@/contexts/PomodoroContext';
import TimerDisplay from '@/components/TimerDisplay';
import TimerControls from '@/components/TimerControls';

const TimerScreenContent: React.FC = () => {
  const { sessionCount, currentSession, timeLeft, settings } = usePomodoroContext();

  const getSessionMessage = () => {
    switch (currentSession) {
      case 'work':
        return 'Time to focus! Minimize distractions and get into flow.';
      case 'shortBreak':
        return 'Take a breather. Stand up, stretch, or grab some water.';
      case 'longBreak':
        return 'Great job! Take a longer break to recharge.';
      default:
        return 'Ready to start your focused work session?';
    }
  };

  return (
    <ScrollView style={styles.container}>
      <View style={styles.contentContainer}>
        <View style={styles.header}>
          <Text style={styles.title}>Pomodoro Timer</Text>
          <Text style={styles.sessionCounter}>
            Session {sessionCount + 1}
          </Text>
        </View>

        <View style={styles.timerSection}>
          <TimerDisplay />
          <TimerControls />
        </View>

        <View style={styles.messageSection}>
          <Text style={styles.message}>
            {getSessionMessage()}
          </Text>
        </View>
      </View>
    </ScrollView>
  );
};

export default function TimerScreen() {
  return <TimerScreenContent />;
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FAFAFA',
  },
  contentContainer: {
    flex: 1,
    paddingHorizontal: 24,
    paddingTop: 30,
    paddingBottom: 30,
    justifyContent: 'space-between',
  },
  header: {
    alignItems: 'center',
    marginBottom: 40,
  },
  title: {
    fontSize: 32,
    fontFamily: 'Inter-Bold',
    color: '#1F2937',
    marginBottom: 8,
  },
  sessionCounter: {
    fontSize: 16,
    fontFamily: 'Inter-Medium',
    color: '#6B7280',
  },
  timerSection: {
    alignItems: 'center',
  },
  messageSection: {
    alignItems: 'center',
    paddingHorizontal: 32,
  },
  message: {
    fontSize: 16,
    fontFamily: 'Inter-Regular',
    color: '#4B5563',
    textAlign: 'center',
    lineHeight: 24,
  },
});