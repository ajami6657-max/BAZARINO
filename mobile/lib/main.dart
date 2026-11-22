import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

const apiBaseUrl = String.fromEnvironment('BAZARINO_API_URL', defaultValue: 'http://10.0.2.2:3000/api/v1');

void main() => runApp(const BazarinoApp());

class BazarinoApp extends StatelessWidget {
  const BazarinoApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'BAZARINO',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFFE8B85B), brightness: Brightness.dark, surface: const Color(0xFF081426)),
      scaffoldBackgroundColor: const Color(0xFF081426),
    ),
    home: const MarketHome(),
  );
}

class MarketHome extends StatefulWidget {
  const MarketHome({super.key});
  @override
  State<MarketHome> createState() => _MarketHomeState();
}

class _MarketHomeState extends State<MarketHome> {
  int selectedTab = 0;
  bool checking = false;
  String apiStatus = 'در حال بررسی اتصال';

  @override
  void initState() {
    super.initState();
    checkApi();
  }

  Future<void> checkApi() async {
    setState(() { checking = true; apiStatus = 'در حال بررسی اتصال'; });
    try {
      final response = await http.get(Uri.parse('$apiBaseUrl/health')).timeout(const Duration(seconds: 8));
      if (response.statusCode == 200) {
        jsonDecode(response.body);
        setState(() => apiStatus = 'سرور متصل است');
      } else {
        setState(() => apiStatus = 'پاسخ سرور: ' + response.statusCode.toString());
      }
    } catch (_) {
      setState(() => apiStatus = 'سرور هنوز تنظیم یا در دسترس نیست');
    } finally {
      if (mounted) setState(() => checking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _homeContent(),
      const _EmptyPage(icon: Icons.storefront_outlined, title: 'بازار کالاها', subtitle: 'کالاها و فروشگاه‌های واقعی پس از اتصال سرویس نمایش داده می‌شوند.'),
      const _EmptyPage(icon: Icons.chat_bubble_outline, title: 'پیام‌ها', subtitle: 'گفت‌وگوی خریدار و فروشنده در این بخش قرار می‌گیرد.'),
      const _EmptyPage(icon: Icons.person_outline, title: 'حساب کاربری', subtitle: 'ورود، ثبت‌نام و تنظیمات حساب کاربری.'),
    ];
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('BAZARINO', style: TextStyle(letterSpacing: 2, fontWeight: FontWeight.w900, color: Color(0xFFE8B85B))),
          actions: [IconButton(onPressed: checkApi, tooltip: 'بررسی اتصال', icon: const Icon(Icons.sync)), const Padding(padding: EdgeInsetsDirectional.only(end: 12), child: Icon(Icons.public, color: Color(0xFFE8B85B)))],
        ),
        body: IndexedStack(index: selectedTab, children: pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: selectedTab,
          onDestinationSelected: (value) => setState(() => selectedTab = value),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'خانه'),
            NavigationDestination(icon: Icon(Icons.storefront_outlined), selectedIcon: Icon(Icons.storefront), label: 'بازار'),
            NavigationDestination(icon: Icon(Icons.chat_outlined), selectedIcon: Icon(Icons.chat), label: 'پیام‌ها'),
            NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'حساب'),
          ],
        ),
      ),
    );
  }

  Widget _homeContent() => ListView(
    padding: const EdgeInsets.all(20),
    children: [
      Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(colors: [Color(0xFF17345A), Color(0xFF0D2039)], begin: Alignment.topRight, end: Alignment.bottomLeft),
          border: Border.all(color: const Color(0x44E8B85B)),
        ),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('بازار جهانی، یک تجربه واحد', style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, height: 1.5)),
          SizedBox(height: 8),
          Text('خرید، فروش و ارتباط میان فروشندگان و مشتریان در کشورهای مختلف.', style: TextStyle(color: Color(0xFFB8C6D9), height: 1.8)),
          SizedBox(height: 18),
          Row(children: [Icon(Icons.language, color: Color(0xFFE8B85B)), SizedBox(width: 8), Text('چندزبانه • چندارزی', style: TextStyle(color: Color(0xFFE8B85B), fontWeight: FontWeight.w600))]),
        ]),
      ),
      const SizedBox(height: 22),
      const Text('دسترسی سریع', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(child: _QuickAction(icon: Icons.search, label: 'جست‌وجوی کالا', onTap: () => setState(() => selectedTab = 1))),
        const SizedBox(width: 12),
        Expanded(child: _QuickAction(icon: Icons.add_business_outlined, label: 'راه‌اندازی فروشگاه', onTap: () => setState(() => selectedTab = 3))),
      ]),
      const SizedBox(height: 22),
      const Text('وضعیت سامانه', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      const SizedBox(height: 12),
      Card(
        color: const Color(0xFF10233D),
        child: ListTile(
          leading: const Icon(Icons.cloud_outlined, color: Color(0xFFE8B85B)),
          title: const Text('اتصال به سرور بازارینو'),
          subtitle: Text(apiStatus),
          trailing: checking ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.circle, color: Color(0xFFE8B85B), size: 10),
        ),
      ),
      const SizedBox(height: 12),
      const Text('فهرست کالاها پس از اتصال API و ثبت آگهی‌های واقعی نمایش داده می‌شود.', style: TextStyle(color: Color(0xFF9EACC0), height: 1.7)),
    ],
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.onTap});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(18),
    child: Ink(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
      decoration: BoxDecoration(color: const Color(0xFF10233D), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0x223F5F83))),
      child: Column(children: [Icon(icon, color: const Color(0xFFE8B85B), size: 28), const SizedBox(height: 10), Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600))]),
    ),
  );
}

class _EmptyPage extends StatelessWidget {
  const _EmptyPage({required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(32),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 58, color: const Color(0xFFE8B85B)),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF9EACC0), height: 1.8)),
      ]),
    ),
  );
}
