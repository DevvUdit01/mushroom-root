import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'core/controllers/auth_controller.dart';
import 'core/controllers/delivery_controller.dart';
import 'core/theme/app_theme.dart';
import 'views/login_screen.dart';
import 'views/register_partner_screen.dart';
import 'views/home_screen.dart';
import 'views/incoming_order_screen.dart';
import 'views/history_screen.dart';
import 'views/wallet_screen.dart';
import 'views/support_screen.dart';
import 'views/profile_screen.dart';

void main() {
  runApp(const DeliveryApp());
}

class DeliveryApp extends StatelessWidget {
  const DeliveryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'RiFresh Delivery',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      initialRoute: '/splash',
      initialBinding: BindingsBuilder(() {
        Get.put(AuthController(), permanent: true);
      }),
      getPages: [
        GetPage(name: '/splash', page: () => const _SplashScreen()),
        GetPage(name: '/login', page: () => const LoginScreen(), transition: Transition.fadeIn),
        GetPage(name: '/register-partner', page: () => const RegisterPartnerScreen(), transition: Transition.rightToLeft),
        GetPage(name: '/home', page: () => const _HomeWrapper(), transition: Transition.fadeIn),
        GetPage(name: '/incoming-order', page: () => const IncomingOrderScreen(), transition: Transition.downToUp),
        GetPage(name: '/history', page: () => const HistoryScreen(), transition: Transition.rightToLeft),
        GetPage(name: '/wallet', page: () => const WalletScreen(), transition: Transition.rightToLeft),
        GetPage(name: '/support', page: () => const SupportScreen(), transition: Transition.rightToLeft),
      ],
    );
  }
}

// ── Splash ─────────────────────────────────────────────────────────────────
class _SplashScreen extends StatefulWidget {
  const _SplashScreen();
  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen> {
  @override
  void initState() {
    super.initState();
    // AuthController.onInit handles navigation
    Future.delayed(const Duration(seconds: 2), () {
      if (Get.currentRoute == '/splash') Get.offAllNamed('/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: AppTheme.primary.withValues(alpha: 0.15), shape: BoxShape.circle),
            child: const Icon(Icons.delivery_dining_rounded, color: AppTheme.primary, size: 64),
          ),
          const SizedBox(height: 20),
          Text('RiFresh Delivery', style: TextStyle(color: AppTheme.textColor, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Partner App', style: TextStyle(color: AppTheme.textMuted, fontSize: 14)),
          const SizedBox(height: 40),
          const CircularProgressIndicator(color: AppTheme.primary, strokeWidth: 2),
        ]),
      ),
    );
  }
}

// ── Home Wrapper — registers DeliveryController + watches for incoming orders ──
class _HomeWrapper extends StatefulWidget {
  const _HomeWrapper();
  @override
  State<_HomeWrapper> createState() => _HomeWrapperState();
}

class _HomeWrapperState extends State<_HomeWrapper> {
  late final DeliveryController dc;
  String? _lastSeenOrderId;
  int _currentIndex = 0;
  bool _isIncomingOpen = false;

  final List<Widget> _pages = [
    const HomeScreen(),
    const WalletScreen(),
    const HistoryScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    dc = Get.isRegistered<DeliveryController>()
        ? Get.find<DeliveryController>()
        : Get.put(DeliveryController());

    // Watch for new incoming orders and show the full-screen alert
    ever(dc.assignedOrder, (order) {
      if (order == null) { _lastSeenOrderId = null; return; }
      // Only show the incoming screen if this is a NEW order we haven't seen
      if (order.id != _lastSeenOrderId &&
          !dc.declinedOrderIds.contains(order.id) &&
          order.orderStatus == 'ready_for_pickup' &&
          dc.isAvailable.value) {
        _lastSeenOrderId = order.id;
        if (!_isIncomingOpen) {
          _isIncomingOpen = true;
          // Small delay so home screen renders first
          Future.delayed(const Duration(milliseconds: 300), () {
            if (Get.currentRoute != '/incoming-order') {
              Get.toNamed('/incoming-order', arguments: order)?.then((_) {
                _isIncomingOpen = false;
              });
            } else {
              _isIncomingOpen = true;
            }
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppTheme.card,
        selectedItemColor: AppTheme.primary,
        unselectedItemColor: AppTheme.textMuted,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_balance_wallet_outlined),
            activeIcon: Icon(Icons.account_balance_wallet_rounded),
            label: 'Wallet',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history_outlined),
            activeIcon: Icon(Icons.history_rounded),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline_rounded),
            activeIcon: Icon(Icons.person_rounded),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
