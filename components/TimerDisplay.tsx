import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { usePomodoroContext } from '@/contexts/PomodoroContext';
import CircularProgress from './CircularProgress';

const TimerDisplay: React.FC = () => {
  const { timeLeft, currentSession, settings } = usePomodoroContext();
  
  const getDurationForSession = () => {
    switch (currentSession) {
      case 'work':
        return settings.workDuration;
      case 'shortBreak':
        return settings.shortBreakDuration;
      case 'longBreak':
        return settings.longBreakDuration;
      default:
        return settings.workDuration;
    }
  };

  const getSessionColor = () => {
    switch (currentSession) {
      case 'work':
        return '#DC2626';
      case 'shortBreak':
        return '#059669';
      case 'longBreak':
        return '#7C3AED';
      default:
        return '#DC2626';
    }
  };

  const getSessionTitle = () => {
    switch (currentSession) {
      case 'work':
        return 'Focus Time';
      case 'shortBreak':
        return 'Short Break';
      case 'longBreak':
        return 'Long Break';
      default:
        return 'Focus Time';
    }
  };

  const formatTime = (seconds: number): string => {
    const mins = Math.floor(seconds / 60);
    const secs = seconds % 60;
    return `${mins.toString().padStart(2, '0')}:${secs.toString().padStart(2, '0')}`;
  };

  const totalDuration = getDurationForSession();
  const progress = (totalDuration - timeLeft) / totalDuration;

  return (
    <View style={styles.container}>
      <View style={styles.progressContainer}>
        <CircularProgress
          progress={progress}
          size={280}
          strokeWidth={8}
          color={getSessionColor()}
        />
        <View style={styles.timerContent}>
          <Text style={[styles.sessionTitle, { color: getSessionColor() }]}>
            {getSessionTitle()}
          </Text>
          <Text style={styles.timeDisplay}>
            {formatTime(timeLeft)}
          </Text>
        </View>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    alignItems: 'center',
    justifyContent: 'center',
  },
  progressContainer: {
    position: 'relative',
    justifyContent: 'center',
    alignItems: 'center',
  },
  timerContent: {
    position: 'absolute',
    alignItems: 'center',
    justifyContent: 'center',
  },
  sessionTitle: {
    fontSize: 18,
    fontFamily: 'Inter-Medium',
    marginBottom: 8,
  },
  timeDisplay: {
    fontSize: 48,
    fontFamily: 'Inter-Bold',
    color: '#1F2937',
  },
});

export default TimerDisplay;