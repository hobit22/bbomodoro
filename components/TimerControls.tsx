import React from 'react';
import { View, Text, TouchableOpacity, StyleSheet } from 'react-native';
import { Play, Pause, RotateCcw, SkipForward } from 'lucide-react-native';
import { usePomodoroContext } from '@/contexts/PomodoroContext';

const TimerControls: React.FC = () => {
  const { 
    isActive, 
    isPaused, 
    startTimer, 
    pauseTimer, 
    resetTimer, 
    skipSession,
    currentSession 
  } = usePomodoroContext();

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

  const renderPlayPauseButton = () => {
    const isPlaying = isActive && !isPaused;
    const color = getSessionColor();
    
    return (
      <TouchableOpacity
        style={[styles.primaryButton, { backgroundColor: color }]}
        onPress={isPlaying ? pauseTimer : startTimer}
      >
        {isPlaying ? (
          <Pause size={28} color="#FFFFFF" />
        ) : (
          <Play size={28} color="#FFFFFF" />
        )}
      </TouchableOpacity>
    );
  };

  return (
    <View style={styles.container}>
      <View style={styles.controlsRow}>
        <TouchableOpacity
          style={styles.secondaryButton}
          onPress={resetTimer}
        >
          <RotateCcw size={24} color="#6B7280" />
        </TouchableOpacity>

        {renderPlayPauseButton()}

        <TouchableOpacity
          style={styles.secondaryButton}
          onPress={skipSession}
        >
          <SkipForward size={24} color="#6B7280" />
        </TouchableOpacity>
      </View>
    </View>
  );
};

const styles = StyleSheet.create({
  container: {
    marginTop: 40,
  },
  controlsRow: {
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: 32,
  },
  primaryButton: {
    width: 72,
    height: 72,
    borderRadius: 36,
    justifyContent: 'center',
    alignItems: 'center',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 4,
    },
    shadowOpacity: 0.3,
    shadowRadius: 8,
    elevation: 8,
  },
  secondaryButton: {
    width: 56,
    height: 56,
    borderRadius: 28,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F3F4F6',
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 2,
  },
});

export default TimerControls;