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
        setState(() => apiStatus = 'پاسخ سرور: ${response.statusCode}');
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
      const _MarketPage(),
      const _CartPage(),
      const _SellerPage(),
      const _EmptyPage(icon: Icons.chat_bubble_outline, title: 'پیام‌ها', subtitle: 'گفت‌وگوی خریدار و فروشنده در مرحله بعد متصل می‌شود.'),
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
            NavigationDestination(icon: Icon(Icons.shopping_cart_outlined), selectedIcon: Icon(Icons.shopping_cart), label: 'سبد خرید'),
            NavigationDestination(icon: Icon(Icons.store_mall_directory_outlined), selectedIcon: Icon(Icons.store), label: 'فروشنده'),
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

class _MarketPage extends StatefulWidget {
  const _MarketPage();
  @override
  State<_MarketPage> createState() => _MarketPageState();
}
class _MarketPageState extends State<_MarketPage> {
  final search = TextEditingController();
  List<dynamic> products = [];
  bool loading = false;
  String message = 'در حال دریافت کالاها...';
  @override
  void initState() { super.initState(); load(); }
  Future<void> load() async {
    setState(() => loading = true);
    try {
      final q = search.text.trim();
      final uri = Uri.parse('$apiBaseUrl/listings').replace(queryParameters: q.isEmpty ? null : {'q': q});
      final response = await http.get(uri).timeout(const Duration(seconds: 15));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() { products = data is List ? data : (data['items'] as List? ?? []); message = products.isEmpty ? 'هنوز کالای فعالی ثبت نشده است.' : ''; });
      } else { setState(() => message = 'دریافت کالاها ناموفق بود. کد: ' + response.statusCode.toString()); }
    } catch (_) { setState(() => message = 'سرور بازارینو در دسترس نیست.'); }
    finally { if (mounted) setState(() => loading = false); }
  }
  Future<void> add(Map<String, dynamic> product) async {
    final token = await const FlutterSecureStorage().read(key: 'bazarino_access_token');
    if (token == null) { setState(() => message = 'برای افزودن کالا ابتدا وارد حساب شوید.'); return; }
    try {
      final response = await http.post(Uri.parse('$apiBaseUrl/cart/items'),
        headers: {'Content-Type':'application/json','Authorization':'Bearer ' + token},
        body: jsonEncode({'listingId': product['id'], 'quantity': 1}));
      if (mounted) setState(() => message = response.statusCode >= 200 && response.statusCode < 300 ? 'کالا به سبد خرید اضافه شد.' : 'افزودن کالا ناموفق بود.');
    } catch (_) { if (mounted) setState(() => message = 'ارتباط با سرور برقرار نشد.'); }
  }
  @override
  void dispose() { search.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => Column(children: [
    Padding(padding: const EdgeInsets.all(16), child: Row(children: [
      Expanded(child: TextField(controller: search, textInputAction: TextInputAction.search, onSubmitted: (_) => load(), decoration: const InputDecoration(hintText: 'نام کالا یا برند...', prefixIcon: Icon(Icons.search), border: OutlineInputBorder()))),
      const SizedBox(width: 8), IconButton.filled(onPressed: loading ? null : load, icon: const Icon(Icons.search)),
    ])),
    if (message.isNotEmpty) Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6), child: Text(message, style: const TextStyle(color: Color(0xFFE8B85B)))),
    if (loading) const LinearProgressIndicator(),
    Expanded(child: RefreshIndicator(onRefresh: load, child: ListView.builder(padding: const EdgeInsets.all(12), itemCount: products.length,
      itemBuilder: (context, index) {
        final p = products[index] as Map<String, dynamic>;
        final store = p['store'] as Map<String, dynamic>?;
        return Card(color: const Color(0xFF10233D), child: ListTile(
          title: Text(p['title']?.toString() ?? 'کالا'),
          subtitle: Text((p['price']?.toString() ?? '') + ' ' + (p['currency']?.toString() ?? '') + ' • ' + (store?['name']?.toString() ?? 'فروشگاه')),
          trailing: IconButton(onPressed: () => add(p), icon: const Icon(Icons.add_shopping_cart, color: Color(0xFFE8B85B))),
        ));
      }))),
  ]);
}
class _CartPage extends StatefulWidget {
  const _CartPage();
  @override
  State<_CartPage> createState() => _CartPageState();
}
class _CartPageState extends State<_CartPage> {
  static const storage = FlutterSecureStorage();
  @override
  void initState() { super.initState(); load(); }
  List<dynamic> items = [];
  bool loading = false;
  String message = 'برای مشاهده سبد خرید وارد حساب شوید.';
  Future<void> load() async {
    setState(() => loading = true);
    try {
      final token = await storage.read(key: 'bazarino_access_token');
      if (token == null) { setState(() { items = []; message = 'ابتدا وارد حساب کاربری شوید.'; }); return; }
      final response = await http.get(Uri.parse('$apiBaseUrl/cart'), headers: {'Authorization':'Bearer ' + token});
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        setState(() { items = data['items'] as List? ?? []; message = items.isEmpty ? 'سبد خرید شما خالی است.' : ''; });
      } else { setState(() => message = 'دریافت سبد خرید ناموفق بود.'); }
    } catch (_) { setState(() => message = 'اتصال به سرور برقرار نشد.'); }
    finally { if (mounted) setState(() => loading = false); }
  }
  Future<void> checkout() async {
    final token = await storage.read(key: 'bazarino_access_token');
    if (token == null) return;
    try {
      final response = await http.post(Uri.parse('$apiBaseUrl/cart/checkout'), headers: {'Authorization':'Bearer ' + token});
      if (!mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() => message = 'سفارش‌ها ایجاد شدند؛ پرداخت هنوز به درگاه متصل نیست.');
        await load();
      } else { setState(() => message = 'ثبت سفارش ناموفق بود.'); }
    } catch (_) { if (mounted) setState(() => message = 'ارتباط با سرور برقرار نشد.'); }
  }
  @override
  Widget build(BuildContext context) => Column(children: [
    Padding(padding: const EdgeInsets.all(12), child: Row(children: [const Expanded(child: Text('سبد خرید', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))), IconButton(onPressed: loading ? null : load, icon: const Icon(Icons.refresh))])),
    if (loading) const LinearProgressIndicator(),
    if (message.isNotEmpty) Padding(padding: const EdgeInsets.all(12), child: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFFE8B85B)))),
    Expanded(child: ListView.builder(itemCount: items.length, itemBuilder: (context, i) {
      final line = items[i] as Map<String, dynamic>;
      final listing = line['listing'] as Map<String, dynamic>? ?? {};
      return ListTile(title: Text(listing['title']?.toString() ?? 'کالا'), subtitle: Text('تعداد: ' + (line['quantity']?.toString() ?? '1')));
    })),
    if (items.isNotEmpty) Padding(padding: const EdgeInsets.all(16), child: SizedBox(width: double.infinity, child: FilledButton(onPressed: checkout, child: const Text('ثبت سفارش‌ها')))),
  ]);
}

class _SellerPage extends StatefulWidget {
  const _SellerPage();
  @override
  State<_SellerPage> createState() => _SellerPageState();
}
class _SellerPageState extends State<_SellerPage> {
  static const storage = FlutterSecureStorage();
  final storeName = TextEditingController();
  final storeDescription = TextEditingController();
  final productTitle = TextEditingController();
  final productDescription = TextEditingController();
  final productPrice = TextEditingController();
  final productCategory = TextEditingController();
  final countryCode = TextEditingController(text: 'IR');
  Map<String, dynamic>? store;
  List<dynamic> listings = [];
  List<dynamic> orders = [];
  bool loading = false;
  bool saving = false;
  String message = '';
  String? get token => _token;
  String? _token;

  @override
  void initState() { super.initState(); load(); }

  Future<void> load() async {
    setState(() { loading = true; message = ''; });
    try {
      _token = await storage.read(key: 'bazarino_access_token');
      if (_token == null) { setState(() => message = 'برای ورود به پنل فروشنده ابتدا وارد حساب شوید.'); return; }
      final headers = {'Authorization': 'Bearer ' + _token!};
      final responses = await Future.wait([
        http.get(Uri.parse('$apiBaseUrl/stores/me'), headers: headers),
        http.get(Uri.parse('$apiBaseUrl/listings/mine'), headers: headers),
        http.get(Uri.parse('$apiBaseUrl/orders/seller'), headers: headers),
      ]);
      if (!mounted) return;
      if (responses[0].statusCode == 200) {
        final data = jsonDecode(responses[0].body);
        store = data is Map<String, dynamic> ? data : null;
      } else if (responses[0].statusCode == 404) { store = null; }
      if (responses[1].statusCode == 200) {
        final data = jsonDecode(responses[1].body);
        listings = data is List ? data : [];
      }
      if (responses[2].statusCode == 200) {
        final data = jsonDecode(responses[2].body);
        orders = data is List ? data : [];
      }
      setState(() => message = store == null ? 'فروشگاه رایگان خود را بسازید.' : '');
    } catch (_) { if (mounted) setState(() => message = 'ارتباط با سرور برقرار نشد.'); }
    finally { if (mounted) setState(() => loading = false); }
  }

  Future<void> createStore() async {
    final name = storeName.text.trim();
    final country = countryCode.text.trim().toUpperCase();
    if (name.length < 2 || !RegExp(r'^[A-Z]{2}$').hasMatch(country)) {
      setState(() => message = 'نام فروشگاه و کد کشور دوحرفی معتبر وارد کنید.');
      return;
    }
    await _send('/stores', {'name': name, 'description': storeDescription.text.trim(), 'countryCode': country, 'defaultCurrency': country == 'IR' ? 'IRR' : 'USD'}, 'فروشگاه ساخته شد.');
  }

  Future<void> createProduct() async {
    final price = double.tryParse(productPrice.text.trim());
    if (productTitle.text.trim().length < 2 || productCategory.text.trim().length < 2 || price == null || price <= 0) {
      setState(() => message = 'عنوان، دسته‌بندی و قیمت معتبر وارد کنید.');
      return;
    }
    await _send('/listings', {
      'title': productTitle.text.trim(), 'description': productDescription.text.trim(),
      'price': price, 'category': productCategory.text.trim(),
    }, 'محصول به‌صورت پیش‌نویس ثبت شد.');
    productTitle.clear(); productDescription.clear(); productPrice.clear(); productCategory.clear();
  }

  Future<void> _send(String path, Map<String, dynamic> body, String success) async {
    final authToken = _token ?? await storage.read(key: 'bazarino_access_token');
    if (authToken == null) { setState(() => message = 'ابتدا وارد حساب شوید.'); return; }
    setState(() { saving = true; message = ''; });
    try {
      final response = await http.post(Uri.parse('$apiBaseUrl$path'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer ' + authToken},
        body: jsonEncode(body));
      if (!mounted) return;
      if (response.statusCode >= 200 && response.statusCode < 300) {
        setState(() => message = success);
        await load();
      } else {
        String error = 'عملیات ناموفق بود (' + response.statusCode.toString() + ')';
        try { final data = jsonDecode(response.body); if (data['message'] is String) error = data['message']; } catch (_) {}
        setState(() => message = error);
      }
    } catch (_) { if (mounted) setState(() => message = 'ارتباط با سرور برقرار نشد.'); }
    finally { if (mounted) setState(() => saving = false); }
  }

  Future<void> changeListing(String id, String action) async {
    final authToken = _token;
    if (authToken == null) return;
    try {
      final response = await http.patch(Uri.parse('$apiBaseUrl/listings/$id/$action'), headers: {'Authorization': 'Bearer ' + authToken});
      if (response.statusCode >= 200 && response.statusCode < 300) { await load(); }
      else if (mounted) setState(() => message = 'تغییر وضعیت محصول انجام نشد.');
    } catch (_) { if (mounted) setState(() => message = 'ارتباط با سرور برقرار نشد.'); }
  }

  @override
  void dispose() {
    storeName.dispose(); storeDescription.dispose(); productTitle.dispose(); productDescription.dispose();
    productPrice.dispose(); productCategory.dispose(); countryCode.dispose(); super.dispose();
  }

  Widget field(TextEditingController controller, String label, {TextInputType type = TextInputType.text, int lines = 1}) =>
    Padding(padding: const EdgeInsets.only(bottom: 10), child: TextField(controller: controller, keyboardType: type, maxLines: lines,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true)));

  @override
  Widget build(BuildContext context) => RefreshIndicator(
    onRefresh: load,
    child: ListView(padding: const EdgeInsets.all(16), children: [
      Row(children: [const Expanded(child: Text('پنل فروشنده', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))), IconButton(onPressed: loading ? null : load, icon: const Icon(Icons.refresh))]),
      if (loading) const LinearProgressIndicator(),
      if (message.isNotEmpty) Padding(padding: const EdgeInsets.symmetric(vertical: 10), child: Text(message, style: const TextStyle(color: Color(0xFFE8B85B)))),
      if (_token == null) ...[
        const Text('ورود به حساب از بخش «حساب» لازم است.'),
      ] else if (store == null) ...[
        const Text('ساخت فروشگاه رایگان است؛ فقط از فروش موفق کمیسیون ۰٫۵٪ دریافت می‌شود.', style: TextStyle(height: 1.8)),
        const SizedBox(height: 12),
        field(storeName, 'نام فروشگاه'),
        field(storeDescription, 'توضیحات فروشگاه', lines: 3),
        field(countryCode, 'کد کشور (مثلاً IR)'),
        FilledButton(onPressed: saving ? null : createStore, child: const Text('ساخت فروشگاه رایگان')),
      ] else ...[
        Card(color: const Color(0xFF10233D), child: ListTile(
          leading: const Icon(Icons.store, color: Color(0xFFE8B85B)),
          title: Text(store!['name']?.toString() ?? 'فروشگاه من'),
          subtitle: Text('کشور: ' + (store!['countryCode']?.toString() ?? '') + ' • ارز: ' + (store!['defaultCurrency']?.toString() ?? '')),
        )),
        const SizedBox(height: 16),
        const Text('ثبت محصول جدید', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        field(productTitle, 'عنوان محصول'),
        field(productDescription, 'توضیحات', lines: 3),
        field(productCategory, 'دسته‌بندی'),
        field(productPrice, 'قیمت', type: const TextInputType.numberWithOptions(decimal: true)),
        FilledButton.icon(onPressed: saving ? null : createProduct, icon: const Icon(Icons.add), label: const Text('ثبت محصول')),
        const SizedBox(height: 22),
        Text('محصولات من (' + listings.length.toString() + ')', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (listings.isEmpty) const Padding(padding: EdgeInsets.all(12), child: Text('هنوز محصولی ثبت نکرده‌اید.')),
        ...listings.map((raw) {
          final p = raw as Map<String, dynamic>;
          final id = p['id']?.toString() ?? '';
          final status = p['status']?.toString() ?? '';
          return Card(color: const Color(0xFF10233D), child: ListTile(
            title: Text(p['title']?.toString() ?? 'محصول'),
            subtitle: Text((p['price']?.toString() ?? '') + ' ' + (p['currency']?.toString() ?? '') + ' • ' + status),
            trailing: status == 'ACTIVE'
              ? IconButton(tooltip: 'بایگانی', onPressed: () => changeListing(id, 'archive'), icon: const Icon(Icons.archive_outlined))
              : IconButton(tooltip: 'انتشار', onPressed: () => changeListing(id, 'publish'), icon: const Icon(Icons.publish, color: Color(0xFFE8B85B))),
          ));
        }),
        const SizedBox(height: 22),
        Text('سفارش‌های دریافتی (' + orders.length.toString() + ')', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (orders.isEmpty) const Padding(padding: EdgeInsets.all(12), child: Text('هنوز سفارشی دریافت نشده است.')),
        ...orders.map((raw) {
          final order = raw as Map<String, dynamic>;
          final listing = order['listing'] as Map<String, dynamic>?;
          return Card(color: const Color(0xFF10233D), child: ListTile(
            title: Text(listing?['title']?.toString() ?? 'سفارش'),
            subtitle: Text('وضعیت: ' + (order['status']?.toString() ?? '') + ' • مبلغ: ' + (order['subtotal']?.toString() ?? '')),
          ));
        }),
      ],
    ]),
  );
}
