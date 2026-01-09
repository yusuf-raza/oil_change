import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../constants/app_colors.dart';
import '../../constants/app_strings.dart';
import '../../services/offline_sync_service.dart';
import '../oil_change/oil_change_screen.dart';
import '../tour/tour_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      context.read<OfflineSyncService>().syncAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(AppColors.transparent),
      body: IndexedStack(
        index: _selectedIndex,
        children: const [TourScreen(), OilChangeScreen()],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          final navigator = Navigator.of(context);
          if (navigator.canPop()) {
            navigator.popUntil((route) => route.isFirst);
          }
          FocusManager.instance.primaryFocus?.unfocus();
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.map_outlined), label: AppStrings.tourTab),
          BottomNavigationBarItem(icon: Icon(Icons.oil_barrel_outlined), label: AppStrings.appTitle),
        ],
      ),
    );
  }
}
