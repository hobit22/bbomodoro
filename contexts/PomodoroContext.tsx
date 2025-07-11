import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import { AppState } from 'react-native';

export type SessionType = 'work' | 'shortBreak' | 'longBreak';

interface PomodoroSettings {
  workDuration: number;
  shortBreakDuration: number;
  longBreakDuration: number;
  longBreakInterval: number;
  autoStartBreaks: boolean;
  autoStartWork: boolean;
  soundEnabled: boolean;
}

interface SessionStats {
  date: string;
  completedSessions: number;
  totalFocusTime: number;
}

interface PomodoroContextType {
  // Timer state
  timeLeft: number;
  isActive: boolean;
  isPaused: boolean;
  currentSession: SessionType;
  sessionCount: number;
  
  // Settings
  settings: PomodoroSettings;
  updateSettings: (newSettings: Partial<PomodoroSettings>) => void;
  
  // Timer controls
  startTimer: () => void;
  pauseTimer: () => void;
  resetTimer: () => void;
  skipSession: () => void;
  
  // Statistics
  stats: SessionStats[];
  getTodayStats: () => SessionStats;
  getWeekStats: () => SessionStats[];
}

const defaultSettings: PomodoroSettings = {
  workDuration: 25 * 60, // 25 minutes
  shortBreakDuration: 5 * 60, // 5 minutes
  longBreakDuration: 15 * 60, // 15 minutes
  longBreakInterval: 4, // Every 4 work sessions
  autoStartBreaks: true,
  autoStartWork: true,
  soundEnabled: true,
};

const PomodoroContext = createContext<PomodoroContextType | undefined>(undefined);

export const usePomodoroContext = () => {
  const context = useContext(PomodoroContext);
  if (!context) {
    throw new Error('usePomodoroContext must be used within a PomodoroProvider');
  }
  return context;
};

interface PomodoroProviderProps {
  children: ReactNode;
}

export const PomodoroProvider: React.FC<PomodoroProviderProps> = ({ children }) => {
  const [timeLeft, setTimeLeft] = useState(defaultSettings.workDuration);
  const [isActive, setIsActive] = useState(false);
  const [isPaused, setIsPaused] = useState(false);
  const [currentSession, setCurrentSession] = useState<SessionType>('work');
  const [sessionCount, setSessionCount] = useState(0);
  const [settings, setSettings] = useState<PomodoroSettings>(defaultSettings);
  const [stats, setStats] = useState<SessionStats[]>([]);
  const [lastActiveTime, setLastActiveTime] = useState<number | null>(null);

  // Load stats from AsyncStorage on mount
  useEffect(() => {
    loadStatsFromStorage();
  }, []);

  const loadStatsFromStorage = async () => {
    try {
      const storedStats = await AsyncStorage.getItem('pomodoro_stats');
      if (storedStats) {
        const parsedStats = JSON.parse(storedStats);
        // Clean old data (keep only last 90 days)
        const cleanedStats = cleanOldStats(parsedStats);
        if (cleanedStats.length !== parsedStats.length) {
          await AsyncStorage.setItem('pomodoro_stats', JSON.stringify(cleanedStats));
        }
        setStats(cleanedStats);
      }
    } catch (error) {
      console.error('Error loading stats from AsyncStorage:', error);
    }
  };

  const cleanOldStats = (stats: SessionStats[]): SessionStats[] => {
    const ninetyDaysAgo = new Date();
    ninetyDaysAgo.setDate(ninetyDaysAgo.getDate() - 90);
    const cutoffDate = ninetyDaysAgo.toISOString().split('T')[0];
    return stats.filter(stat => stat.date >= cutoffDate);
  };

  // Initialize timer with current session duration
  useEffect(() => {
    if (!isActive) {
      const duration = getDurationForSession(currentSession);
      setTimeLeft(duration);
    }
  }, [currentSession, settings, isActive]);

  // Timer countdown logic
  useEffect(() => {
    let interval: number;
    if (isActive && !isPaused && timeLeft > 0) {
      interval = setInterval(() => {
        setTimeLeft(prev => prev - 1);
      }, 1000);
    } else if (timeLeft === 0 && isActive) {
      handleSessionComplete();
    }
    return () => clearInterval(interval);
  }, [isActive, isPaused, timeLeft]);

  useEffect(() => {
    const subscription = AppState.addEventListener('change', (nextAppState) => {
      if (nextAppState === 'background') {
        // 백그라운드로 갈 때 현재 시간 저장
        setLastActiveTime(Date.now());
      }
      if (nextAppState === 'active' && lastActiveTime && isActive && !isPaused) {
        // 다시 활성화될 때 시간 차이만큼 타이머 보정
        const now = Date.now();
        const diff = Math.floor((now - lastActiveTime) / 1000); // 초 단위
        setTimeLeft(prev => Math.max(prev - diff, 0));
        setLastActiveTime(null);
      }
    });
    return () => subscription.remove();
  }, [lastActiveTime, isActive, isPaused]);

  const getDurationForSession = (session: SessionType): number => {
    switch (session) {
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

  const handleSessionComplete = () => {
    setIsActive(false);
    setIsPaused(false);
    if (settings.soundEnabled) {
      playNotificationSound();
    }
    if (currentSession === 'work') {
      updateStats();
      setSessionCount(prev => prev + 1);
    }
    const nextSession = getNextSession();
    setCurrentSession(nextSession);
    if (shouldAutoStartNextSession(nextSession)) {
      setTimeout(() => {
        setIsActive(true);
      }, 1000);
    }
  };

  const getNextSession = (): SessionType => {
    if (currentSession === 'work') {
      const completedWorkSessions = sessionCount + 1;
      if (completedWorkSessions % settings.longBreakInterval === 0) {
        return 'longBreak';
      } else {
        return 'shortBreak';
      }
    } else {
      return 'work';
    }
  };

  const shouldAutoStartNextSession = (nextSession: SessionType): boolean => {
    if (nextSession === 'work') {
      return settings.autoStartWork;
    } else {
      return settings.autoStartBreaks;
    }
  };

  const playNotificationSound = () => {
    if (typeof window !== 'undefined' && window.Audio) {
      const audioContext = new (window.AudioContext || (window as any).webkitAudioContext)();
      const oscillator = audioContext.createOscillator();
      const gainNode = audioContext.createGain();
      oscillator.connect(gainNode);
      gainNode.connect(audioContext.destination);
      oscillator.frequency.value = 800;
      oscillator.type = 'sine';
      gainNode.gain.setValueAtTime(0.3, audioContext.currentTime);
      gainNode.gain.exponentialRampToValueAtTime(0.01, audioContext.currentTime + 0.5);
      oscillator.start(audioContext.currentTime);
      oscillator.stop(audioContext.currentTime + 0.5);
    }
  };

  const updateStats = async () => {
    const today = new Date().toISOString().split('T')[0];
    const existingStats = stats.find(s => s.date === today);
    const newStats = existingStats
      ? stats.map(s =>
          s.date === today
            ? {
                ...s,
                completedSessions: s.completedSessions + 1,
                totalFocusTime: s.totalFocusTime + settings.workDuration
              }
            : s
        )
      : [...stats, {
          date: today,
          completedSessions: 1,
          totalFocusTime: settings.workDuration
        }];
    setStats(newStats);
    try {
      await AsyncStorage.setItem('pomodoro_stats', JSON.stringify(newStats));
    } catch (error) {
      console.error('Error updating stats in AsyncStorage:', error);
    }
  };

  const startTimer = () => {
    setIsActive(true);
    setIsPaused(false);
  };

  const pauseTimer = () => {
    setIsPaused(true);
  };

  const resetTimer = () => {
    setIsActive(false);
    setIsPaused(false);
    const duration = getDurationForSession(currentSession);
    setTimeLeft(duration);
  };

  const skipSession = () => {
    setIsActive(false);
    setIsPaused(false);
    const nextSession = getNextSession();
    setCurrentSession(nextSession);
  };

  const updateSettings = (newSettings: Partial<PomodoroSettings>) => {
    setSettings(prev => ({ ...prev, ...newSettings }));
  };

  const getTodayStats = (): SessionStats => {
    const today = new Date().toISOString().split('T')[0];
    return stats.find(s => s.date === today) || {
      date: today,
      completedSessions: 0,
      totalFocusTime: 0
    };
  };

  const getWeekStats = (): SessionStats[] => {
    const today = new Date();
    const weekStats: SessionStats[] = [];
    for (let i = 6; i >= 0; i--) {
      const date = new Date(today);
      date.setDate(today.getDate() - i);
      const dateString = date.toISOString().split('T')[0];
      const existingStats = stats.find(s => s.date === dateString);
      weekStats.push(existingStats || {
        date: dateString,
        completedSessions: 0,
        totalFocusTime: 0
      });
    }
    return weekStats;
  };

  return (
    <PomodoroContext.Provider
      value={{
        timeLeft,
        isActive,
        isPaused,
        currentSession,
        sessionCount,
        settings,
        updateSettings,
        startTimer,
        pauseTimer,
        resetTimer,
        skipSession,
        stats,
        getTodayStats,
        getWeekStats,
      }}
    >
      {children}
    </PomodoroContext.Provider>
  );
};