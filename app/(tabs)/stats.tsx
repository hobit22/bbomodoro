import React from 'react';
import { View, Text, StyleSheet, ScrollView } from 'react-native';
import { usePomodoroContext } from '@/contexts/PomodoroContext';

const StatsScreenContent: React.FC = () => {
  const { getTodayStats, getWeekStats } = usePomodoroContext();

  const todayStats = getTodayStats();
  const weekStats = getWeekStats();

  const formatDuration = (seconds: number): string => {
    const hours = Math.floor(seconds / 3600);
    const minutes = Math.floor((seconds % 3600) / 60);
    
    if (hours > 0) {
      return `${hours}h ${minutes}m`;
    }
    return `${minutes}m`;
  };

  const formatDate = (dateString: string): string => {
    const date = new Date(dateString);
    const today = new Date();
    const yesterday = new Date(today);
    yesterday.setDate(today.getDate() - 1);
    
    if (date.toDateString() === today.toDateString()) {
      return 'Today';
    } else if (date.toDateString() === yesterday.toDateString()) {
      return 'Yesterday';
    } else {
      return date.toLocaleDateString('en-US', { weekday: 'short', month: 'short', day: 'numeric' });
    }
  };

  const getWeeklyTotal = () => {
    return weekStats.reduce((total, day) => total + day.completedSessions, 0);
  };

  const getWeeklyFocusTime = () => {
    return weekStats.reduce((total, day) => total + day.totalFocusTime, 0);
  };

  const getDailyAverage = () => {
    const totalSessions = getWeeklyTotal();
    return Math.round(totalSessions / 7);
  };

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <View style={styles.header}>
        <Text style={styles.title}>Statistics</Text>
        <Text style={styles.subtitle}>Track your productivity</Text>
      </View>

      {/* Today's Stats */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Today</Text>
        <View style={styles.statsGrid}>
          <View style={styles.statCard}>
            <Text style={styles.statNumber}>{todayStats.completedSessions}</Text>
            <Text style={styles.statLabel}>Sessions</Text>
          </View>
          <View style={styles.statCard}>
            <Text style={styles.statNumber}>{formatDuration(todayStats.totalFocusTime)}</Text>
            <Text style={styles.statLabel}>Focus Time</Text>
          </View>
        </View>
      </View>

      {/* Weekly Overview */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>This Week</Text>
        <View style={styles.statsGrid}>
          <View style={styles.statCard}>
            <Text style={styles.statNumber}>{getWeeklyTotal()}</Text>
            <Text style={styles.statLabel}>Total Sessions</Text>
          </View>
          <View style={styles.statCard}>
            <Text style={styles.statNumber}>{formatDuration(getWeeklyFocusTime())}</Text>
            <Text style={styles.statLabel}>Total Focus Time</Text>
          </View>
          <View style={styles.statCard}>
            <Text style={styles.statNumber}>{getDailyAverage()}</Text>
            <Text style={styles.statLabel}>Daily Average</Text>
          </View>
        </View>
      </View>

      {/* Weekly Breakdown */}
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Weekly Breakdown</Text>
        <View style={styles.weeklyBreakdown}>
          {weekStats.map((day, index) => (
            <View key={index} style={styles.dayRow}>
              <Text style={styles.dayLabel}>{formatDate(day.date)}</Text>
              <View style={styles.dayStats}>
                <Text style={styles.dayNumber}>{day.completedSessions}</Text>
                <Text style={styles.dayUnit}>sessions</Text>
              </View>
            </View>
          ))}
        </View>
      </View>
    </ScrollView>
  );
};

export default function StatsScreen() {
  return <StatsScreenContent />;
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: '#FAFAFA',
  },
  contentContainer: {
    paddingHorizontal: 24,
    paddingTop: 30,
    paddingBottom: 30,
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
  subtitle: {
    fontSize: 16,
    fontFamily: 'Inter-Medium',
    color: '#6B7280',
  },
  section: {
    marginBottom: 32,
  },
  sectionTitle: {
    fontSize: 20,
    fontFamily: 'Inter-SemiBold',
    color: '#1F2937',
    marginBottom: 16,
  },
  statsGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 16,
  },
  statCard: {
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    padding: 20,
    alignItems: 'center',
    minWidth: 120,
    flex: 1,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 3,
  },
  statNumber: {
    fontSize: 28,
    fontFamily: 'Inter-Bold',
    color: '#DC2626',
    marginBottom: 4,
  },
  statLabel: {
    fontSize: 14,
    fontFamily: 'Inter-Medium',
    color: '#6B7280',
    textAlign: 'center',
  },
  weeklyBreakdown: {
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    padding: 20,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 3,
  },
  dayRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    alignItems: 'center',
    paddingVertical: 12,
    borderBottomWidth: 1,
    borderBottomColor: '#F3F4F6',
  },
  dayLabel: {
    fontSize: 16,
    fontFamily: 'Inter-Medium',
    color: '#1F2937',
  },
  dayStats: {
    flexDirection: 'row',
    alignItems: 'baseline',
    gap: 4,
  },
  dayNumber: {
    fontSize: 18,
    fontFamily: 'Inter-SemiBold',
    color: '#DC2626',
  },
  dayUnit: {
    fontSize: 14,
    fontFamily: 'Inter-Medium',
    color: '#6B7280',
  },
});