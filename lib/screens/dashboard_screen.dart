import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:smart_stitched_ai1/providers/bottom_nav_provider.dart';
import 'package:smart_stitched_ai1/screens/profile_screen.dart';
import '../providers/OrderProvider.dart';
import '../utils/app_colors.dart';
import 'home_tab.dart';
import 'package:smart_stitched_ai1/screens/invoices_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with WidgetsBindingObserver {
  final List<Widget> _screens = const[
    HomeTab(),
    InvoicesScreen(),
    ProfileScreen(),
  ];

  final List<String> _titles = const [
    'Dashboard',
    'Digital Invoices',
    'Profile',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheAllIcons();
    });
  }

  @override
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final orderProv = context.read<OrderProvider>();
      if (!orderProv.isStreamActive) {
        orderProv.initOrdersListener();
      }
    }
  }
  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
  void _precacheAllIcons() {
    final List<String> iconPaths = [
      "lib/assets/icons/collar_simple@2x.png",
      "lib/assets/icons/sada_ban@2x.png",
      "lib/assets/icons/sada_patti@2x.png",
      "lib/assets/icons/kurta_patti@2x.png",
      "lib/assets/icons/chak_patti@2x.png",
      "lib/assets/icons/fitt_cuff@2x.png",
      "lib/assets/icons/round_bazu@2x.png",
      "lib/assets/icons/round_daman@2x.png",
      "lib/assets/icons/chauras_daman@2x.png",
      "lib/assets/icons/front_pocket@2x.png",
      "lib/assets/icons/side_pocket@2x.png",
      "lib/assets/icons/shalwar_pocket@2x.png",
    ];

    for (String path in iconPaths) {
      precacheImage(AssetImage(path), context);
    }
    debugPrint("Dashboard: All icons are stored in memory! ");
  }
  @override
  Widget build(BuildContext context) {
    return Selector<BottomNavProvider, int>(
      selector: (_, provider) => provider.currentIndex,
      builder: (context, currentIndex, child) {
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(_titles[currentIndex]),
            backgroundColor: AppColors.primary,
          ),
          body: IndexedStack(
            index: currentIndex,
            children: _screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: currentIndex,
            onTap: (index) {
              Provider.of<BottomNavProvider>(context, listen: false).changeTab(index);
            },
            items: [
              const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
              BottomNavigationBarItem(
                icon: Selector<OrderProvider, int>(
                  selector: (_, prov) => prov.voiceOrders.where((o) => o['isPrinted'] != true).length,
                  builder: (context, count, child) {
                    return Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(Icons.shopping_bag),
                        if (count > 0)
                          Positioned(
                            right: -6,
                            top: -6,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                count.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                label: 'Invoices',
              ),
             const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
            ],
          ),
        );
      },
    );
  }
}