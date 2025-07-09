import React from 'react';
import { View, StyleSheet } from 'react-native';
import { PomodoroProvider } from '@/contexts/PomodoroContext';
import { Redirect } from 'expo-router';

export default function Index() {
  return (
    <PomodoroProvider>
      <Redirect href="/(tabs)" />
    </PomodoroProvider>
  );
}