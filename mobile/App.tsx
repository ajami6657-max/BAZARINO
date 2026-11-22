import React from 'react';
import { StatusBar } from 'expo-status-bar';
import { SafeAreaView, Text, View, StyleSheet } from 'react-native';

export default function App() {
  return (
    <SafeAreaView style={styles.root}>
      <StatusBar style="light" />
      <View style={styles.content}>
        <Text style={styles.brand}>BAZARINO</Text>
        <Text style={styles.tagline}>Every market. One platform.</Text>
        <Text style={styles.note}>The global marketplace is being prepared.</Text>
      </View>
    </SafeAreaView>
  );
}
const styles = StyleSheet.create({
  root: { flex: 1, backgroundColor: '#081426' },
  content: { flex: 1, alignItems: 'center', justifyContent: 'center', padding: 28 },
  brand: { color: '#E8B85B', fontSize: 34, fontWeight: '800', letterSpacing: 3 },
  tagline: { color: '#F4F7FB', fontSize: 17, marginTop: 12 },
  note: { color: '#9EACC0', fontSize: 13, marginTop: 28, textAlign: 'center' },
});
