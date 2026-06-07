import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/core/widgets/app_bottom_navigation.dart';
import 'package:bingcook/ui/features/explore/views/explore_view.dart';
import 'package:bingcook/ui/features/search/view_models/search_view_model.dart';
import 'package:bingcook/ui/features/search/views/search_view.dart';
import 'package:flutter/material.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  bool _showSearch = false;
  final SearchViewModel _searchViewModel = SearchViewModel();

  static const _pendingDestinations = [
    _PendingDestination(
      icon: Icons.favorite_border_rounded,
      title: 'Saved stays',
    ),
    _PendingDestination(
      icon: Icons.confirmation_number_outlined,
      title: 'Your bookings',
    ),
    _PendingDestination(
      icon: Icons.person_outline_rounded,
      title: 'Your profile',
    ),
  ];

  @override
  void dispose() {
    _searchViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final destinations = [
      if (_showSearch)
        SearchView(
          viewModel: _searchViewModel,
          onClose: () => setState(() => _showSearch = false),
        )
      else
        ExploreView(
          onSearchRequested: () => setState(() => _showSearch = true),
        ),
      ..._pendingDestinations,
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: destinations),
      bottomNavigationBar: AppBottomNavigation(
        selectedIndex: _selectedIndex,
        onSelected: (index) {
          setState(() {
            _selectedIndex = index;
            _showSearch = false;
          });
        },
      ),
    );
  }
}

class _PendingDestination extends StatelessWidget {
  const _PendingDestination({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: AppColors.gray900,
                fontFamily: 'Manrope',
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
