import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/core/widgets/app_bottom_navigation.dart';
import 'package:bingcook/ui/features/checkout/models/checkout_content.dart';
import 'package:bingcook/ui/features/checkout/view_models/checkout_view_model.dart';
import 'package:bingcook/ui/features/checkout/views/checkout_view.dart';
import 'package:bingcook/ui/features/explore/views/explore_view.dart';
import 'package:bingcook/ui/features/property_details/models/property_details_content.dart';
import 'package:bingcook/ui/features/property_details/models/property_details_data.dart';
import 'package:bingcook/ui/features/property_details/view_models/property_details_view_model.dart';
import 'package:bingcook/ui/features/property_details/views/property_details_view.dart';
import 'package:bingcook/ui/features/search/view_models/search_view_model.dart';
import 'package:bingcook/ui/features/search/views/search_view.dart';
import 'package:bingcook/ui/features/select_room/models/select_room_content.dart';
import 'package:bingcook/ui/features/select_room/view_models/select_room_view_model.dart';
import 'package:bingcook/ui/features/select_room/views/select_room_view.dart';
import 'package:flutter/material.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  bool _showSearch = false;
  bool _showSelectRoom = false;
  bool _showCheckout = false;
  PropertyDetailsData? _selectedProperty;
  final SearchViewModel _searchViewModel = SearchViewModel();
  final PropertyDetailsViewModel _propertyDetailsViewModel =
      PropertyDetailsViewModel();
  final SelectRoomViewModel _selectRoomViewModel = SelectRoomViewModel(
    nights: SelectRoomContent.oceanPearl.nights,
  );
  final CheckoutViewModel _checkoutViewModel = CheckoutViewModel();

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
    _propertyDetailsViewModel.dispose();
    _selectRoomViewModel.dispose();
    _checkoutViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final destinations = [
      if (_showCheckout)
        CheckoutView(
          data: CheckoutContent.oceanPearl,
          viewModel: _checkoutViewModel,
          onBack: () => setState(() => _showCheckout = false),
          onConfirm: () {},
        )
      else if (_showSelectRoom)
        SelectRoomView(
          data: SelectRoomContent.oceanPearl,
          viewModel: _selectRoomViewModel,
          onBack: () => setState(() => _showSelectRoom = false),
          onContinue: () => setState(() => _showCheckout = true),
        )
      else if (_selectedProperty != null)
        PropertyDetailsView(
          data: _selectedProperty!,
          viewModel: _propertyDetailsViewModel,
          onBack: () => setState(() => _selectedProperty = null),
          onBookNow: () => setState(() => _showSelectRoom = true),
        )
      else if (_showSearch)
        SearchView(
          viewModel: _searchViewModel,
          onClose: () => setState(() => _showSearch = false),
        )
      else
        ExploreView(
          onSearchRequested: () => setState(() => _showSearch = true),
          onStaySelected: (_) {
            setState(() {
              _showSearch = false;
              _selectedProperty = PropertyDetailsContent.oceanPearl;
            });
          },
        ),
      ..._pendingDestinations,
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: destinations),
      bottomNavigationBar: _showSelectRoom || _showCheckout
          ? null
          : AppBottomNavigation(
              selectedIndex: _selectedIndex,
              onSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                  _showSearch = false;
                  _showSelectRoom = false;
                  _showCheckout = false;
                  _selectedProperty = null;
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
