import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

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
      const _AuthPage(),
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


class _AuthPage extends StatefulWidget {
  const _AuthPage();
  @override
  State<_AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<_AuthPage> {
  static const storage = FlutterSecureStorage();
  final identifier = TextEditingController();
  final password = TextEditingController();
  final displayName = TextEditingController();
  bool registering = false;
  bool busy = false;
  String message = '';
  String? token;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final saved = await storage.read(key: 'bazarino_access_token');
    if (mounted) setState(() => token = saved);
  }

  Future<void> _submit() async {
    final id = identifier.text.trim();
    if (id.isEmpty || password.text.length < 8) {
      setState(() => message = 'ایمیل یا شماره تلفن و رمز حداقل ۸ کاراکتری وارد کنید.');
      return;
    }
    setState(() { busy = true; message = ''; });
    try {
      final path = registering ? '/auth/register' : '/auth/login';
      final payload = registering
          ? <String, dynamic>{
              if (id.contains('@')) 'email': id else 'phone': id,
              'password': password.text,
              if (displayName.text.trim().isNotEmpty) 'displayName': displayName.text.trim(),
            }
          : <String, dynamic>{'identifier': id, 'password': password.text};
      final response = await http.post(
        Uri.parse('$apiBaseUrl$path'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      ).timeout(const Duration(seconds: 15));
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      if (response.statusCode >= 200 && response.statusCode < 300 && data['accessToken'] is String) {
        await storage.write(key: 'bazarino_access_token', value: data['accessToken'] as String);
        if (mounted) setState(() { token = data['accessToken'] as String; message = 'ورود با موفقیت انجام شد.'; });
      } else {
        final raw = data['message'];
        setState(() => message = raw is String ? raw : 'عملیات ناموفق بود. اطلاعات را بررسی کنید.');
      }
    } catch (_) {
      setState(() => message = 'اتصال به سرور برقرار نشد. آدرس API و سرور را بررسی کنید.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> _logout() async {
    await storage.delete(key: 'bazarino_access_token');
    if (mounted) setState(() { token = null; message = 'از حساب خارج شدید.'; });
  }

  @override
  void dispose() {
    identifier.dispose();
    password.dispose();
    displayName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (token != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.verified_user_outlined, color: Color(0xFFE8B85B), size: 58),
            const SizedBox(height: 16),
            const Text('نشست کاربری ذخیره شده است', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('توکن ورود به‌صورت امن روی دستگاه نگهداری می‌شود.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF9EACC0))),
            const SizedBox(height: 20),
            OutlinedButton(onPressed: _logout, child: const Text('خروج از حساب')),
          ]),
        ),
      );
    }
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.account_circle_outlined, color: Color(0xFFE8B85B), size: 54),
        const SizedBox(height: 12),
        Text(registering ? 'ساخت حساب بازارینو' : 'ورود به بازارینو', textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 22),
        if (registering) ...[
          TextField(controller: displayName, decoration: const InputDecoration(labelText: 'نام نمایشی', border: OutlineInputBorder())),
          const SizedBox(height: 12),
        ],
        TextField(
          controller: identifier,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'ایمیل یا شماره تلفن', border: OutlineInputBorder(), prefixIcon: Icon(Icons.alternate_email)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: password,
          obscureText: true,
          decoration: const InputDecoration(labelText: 'رمز عبور (حداقل ۸ کاراکتر)', border: OutlineInputBorder(), prefixIcon: Icon(Icons.lock_outline)),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: busy ? null : _submit,
          child: busy ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2)) : Text(registering ? 'ثبت‌نام' : 'ورود'),
        ),
        TextButton(onPressed: busy ? null : () => setState(() { registering = !registering; message = ''; }), child: Text(registering ? 'حساب دارید؟ وارد شوید' : 'حساب ندارید؟ ثبت‌نام کنید')),
        if (message.isNotEmpty) Padding(padding: const EdgeInsets.only(top: 10), child: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFE8B85B)))),
      ],
    );
  }
}
