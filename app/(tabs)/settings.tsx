import React from 'react';
import { View, Text, StyleSheet, ScrollView, TouchableOpacity, Switch } from 'react-native';
import { usePomodoroContext } from '@/contexts/PomodoroContext';
import { Clock, Coffee, Timer, Volume2 } from 'lucide-react-native';

const SettingsScreenContent: React.FC = () => {
  const { settings, updateSettings, stats } = usePomodoroContext();

  const formatMinutes = (seconds: number): string => {
    return `${Math.floor(seconds / 60)} min`;
  };

  const updateDuration = (key: keyof typeof settings, increment: boolean) => {
    const currentValue = settings[key] as number;
    const change = increment ? 60 : -60; // 1 minute increments
    const newValue = Math.max(60, currentValue + change); // Minimum 1 minute
    updateSettings({ [key]: newValue });
  };

  const DurationSetting: React.FC<{
    title: string;
    subtitle: string;
    value: number;
    settingKey: keyof typeof settings;
    icon: React.ReactNode;
  }> = ({ title, subtitle, value, settingKey, icon }) => (
    <View style={styles.settingItem}>
      <View style={styles.settingContent}>
        <View style={styles.iconContainer}>
          {icon}
        </View>
        <View style={styles.settingText}>
          <Text style={styles.settingTitle}>{title}</Text>
          <Text style={styles.settingSubtitle}>{subtitle}</Text>
        </View>
        <View style={styles.durationControls}>
          <TouchableOpacity
            style={styles.controlButton}
            onPress={() => updateDuration(settingKey, false)}
          >
            <Text style={styles.controlButtonText}>-</Text>
          </TouchableOpacity>
          <Text style={styles.durationText}>{formatMinutes(value)}</Text>
          <TouchableOpacity
            style={styles.controlButton}
            onPress={() => updateDuration(settingKey, true)}
          >
            <Text style={styles.controlButtonText}>+</Text>
          </TouchableOpacity>
        </View>
      </View>
    </View>
  );

  const ToggleSetting: React.FC<{
    title: string;
    subtitle: string;
    value: boolean;
    settingKey: keyof typeof settings;
    icon: React.ReactNode;
  }> = ({ title, subtitle, value, settingKey, icon }) => (
    <View style={styles.settingItem}>
      <View style={styles.settingContent}>
        <View style={styles.iconContainer}>
          {icon}
        </View>
        <View style={styles.settingText}>
          <Text style={styles.settingTitle}>{title}</Text>
          <Text style={styles.settingSubtitle}>{subtitle}</Text>
        </View>
        <Switch
          value={value}
          onValueChange={(newValue) => updateSettings({ [settingKey]: newValue })}
          trackColor={{ false: '#D1D5DB', true: '#DC2626' }}
          thumbColor={value ? '#FFFFFF' : '#FFFFFF'}
        />
      </View>
    </View>
  );

  return (
    <ScrollView style={styles.container} contentContainerStyle={styles.contentContainer}>
      <View style={styles.header}>
        <Text style={styles.title}>Settings</Text>
        <Text style={styles.subtitle}>Customize your Pomodoro experience</Text>
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Timer Duration</Text>
        <DurationSetting
          title="Work Sessions"
          subtitle="Focus time duration"
          value={settings.workDuration}
          settingKey="workDuration"
          icon={<Clock size={24} color="#DC2626" />}
        />
        <DurationSetting
          title="Short Break"
          subtitle="Brief rest period"
          value={settings.shortBreakDuration}
          settingKey="shortBreakDuration"
          icon={<Coffee size={24} color="#059669" />}
        />
        <DurationSetting
          title="Long Break"
          subtitle="Extended rest period"
          value={settings.longBreakDuration}
          settingKey="longBreakDuration"
          icon={<Timer size={24} color="#7C3AED" />}
        />
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Automation</Text>
        <ToggleSetting
          title="Auto-start Breaks"
          subtitle="Automatically start break timers"
          value={settings.autoStartBreaks}
          settingKey="autoStartBreaks"
          icon={<Coffee size={24} color="#059669" />}
        />
        <ToggleSetting
          title="Auto-start Work"
          subtitle="Automatically start work sessions"
          value={settings.autoStartWork}
          settingKey="autoStartWork"
          icon={<Clock size={24} color="#DC2626" />}
        />
      </View>

      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Notifications</Text>
        <ToggleSetting
          title="Sound Notifications"
          subtitle="Play sound when sessions end"
          value={settings.soundEnabled}
          settingKey="soundEnabled"
          icon={<Volume2 size={24} color="#6B7280" />}
        />
      </View>

      <View style={styles.infoSection}>
        <Text style={styles.infoTitle}>Long Break Interval</Text>
        <Text style={styles.infoText}>
          Long breaks occur every {settings.longBreakInterval} completed work sessions.
        </Text>
      </View>
    </ScrollView>
  );
};

export default function SettingsScreen() {
  return <SettingsScreenContent />;
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
  settingItem: {
    backgroundColor: '#FFFFFF',
    borderRadius: 16,
    marginBottom: 12,
    shadowColor: '#000',
    shadowOffset: {
      width: 0,
      height: 2,
    },
    shadowOpacity: 0.1,
    shadowRadius: 8,
    elevation: 3,
  },
  settingContent: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 20,
  },
  iconContainer: {
    marginRight: 16,
  },
  settingText: {
    flex: 1,
  },
  settingTitle: {
    fontSize: 16,
    fontFamily: 'Inter-SemiBold',
    color: '#1F2937',
    marginBottom: 4,
  },
  settingSubtitle: {
    fontSize: 14,
    fontFamily: 'Inter-Regular',
    color: '#6B7280',
  },
  durationControls: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: 16,
  },
  controlButton: {
    width: 32,
    height: 32,
    borderRadius: 16,
    backgroundColor: '#F3F4F6',
    justifyContent: 'center',
    alignItems: 'center',
  },
  controlButtonText: {
    fontSize: 18,
    fontFamily: 'Inter-SemiBold',
    color: '#4B5563',
  },
  durationText: {
    fontSize: 16,
    fontFamily: 'Inter-SemiBold',
    color: '#1F2937',
    minWidth: 50,
    textAlign: 'center',
  },
  infoSection: {
    backgroundColor: '#F0F9FF',
    borderRadius: 16,
    padding: 20,
    marginTop: 16,
  },
  infoTitle: {
    fontSize: 16,
    fontFamily: 'Inter-SemiBold',
    color: '#1F2937',
    marginBottom: 8,
  },
  infoText: {
    fontSize: 14,
    fontFamily: 'Inter-Regular',
    color: '#6B7280',
    lineHeight: 20,
  },
});