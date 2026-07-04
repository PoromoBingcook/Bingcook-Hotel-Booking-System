import 'dart:async';

import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/domain/models/product_details.dart';
import 'package:bingcook/domain/models/product_search_query.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/domain/repositories/booking_repository.dart';
import 'package:bingcook/domain/repositories/product_repository.dart';
import 'package:bingcook/ui/core/constants/app_assets.dart';
import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/core/widgets/app_bottom_navigation.dart';
import 'package:bingcook/ui/features/checkout/models/checkout_data.dart';
import 'package:bingcook/ui/features/checkout/view_models/add_card_view_model.dart';
import 'package:bingcook/ui/features/checkout/view_models/checkout_view_model.dart';
import 'package:bingcook/ui/features/checkout/views/add_card_view.dart';
import 'package:bingcook/ui/features/checkout/views/checkout_view.dart';
import 'package:bingcook/ui/features/checkout/views/payment_result_view.dart';
import 'package:bingcook/ui/features/explore/models/stay_card_data.dart';
import 'package:bingcook/ui/features/explore/view_models/explore_view_model.dart';
import 'package:bingcook/ui/features/explore/views/explore_view.dart';
import 'package:bingcook/ui/features/property_details/models/property_details_data.dart';
import 'package:bingcook/ui/features/property_details/view_models/property_details_view_model.dart';
import 'package:bingcook/ui/features/property_details/views/property_details_view.dart';
import 'package:bingcook/ui/features/profile/view_models/profile_view_model.dart';
import 'package:bingcook/ui/features/profile/views/profile_view.dart';
import 'package:bingcook/ui/features/search/view_models/search_view_model.dart';
import 'package:bingcook/ui/features/search/views/search_view.dart';
import 'package:bingcook/ui/features/select_room/models/select_room_data.dart';
import 'package:bingcook/ui/features/select_room/view_models/select_room_view_model.dart';
import 'package:bingcook/ui/features/select_room/views/select_room_view.dart';
import 'package:flutter/material.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    required this.authRepository,
    required this.productRepository,
    required this.bookingRepository,
    required this.onLogoutCompleted,
    this.payOSCheckoutBuilder,
    super.key,
  });

  final AuthRepository authRepository;
  final ProductRepository productRepository;
  final BookingRepository bookingRepository;
  final VoidCallback onLogoutCompleted;
  final PayOSCheckoutBuilder? payOSCheckoutBuilder;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  bool _showSearch = false;
  bool _showSelectRoom = false;
  bool _showCheckout = false;
  bool _showAddCard = false;
  bool _showPaymentResult = false;
  bool _isLoadingPropertyDetails = false;
  PropertyDetailsData? _selectedProperty;
  SelectRoomData? _selectedRoomData;
  CheckoutData? _checkoutData;
  BookingCheckout? _checkoutResult;
  String? _propertyDetailsError;
  final SearchViewModel _searchViewModel = SearchViewModel();
  late final ExploreViewModel _exploreViewModel;
  final PropertyDetailsViewModel _propertyDetailsViewModel =
      PropertyDetailsViewModel();
  late SelectRoomViewModel _selectRoomViewModel;
  late CheckoutViewModel _checkoutViewModel;
  final AddCardViewModel _addCardViewModel = AddCardViewModel();
  late final ProfileViewModel _profileViewModel;

  static const _pendingDestinations = [
    _PendingDestination(
      icon: Icons.favorite_border_rounded,
      title: 'Saved stays',
    ),
    _PendingDestination(
      icon: Icons.confirmation_number_outlined,
      title: 'Your bookings',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _exploreViewModel = ExploreViewModel(
      productRepository: widget.productRepository,
    );
    unawaited(_exploreViewModel.loadProducts());
    _selectRoomViewModel = SelectRoomViewModel(
      nights: 1,
      bookingRepository: widget.bookingRepository,
    );
    _checkoutViewModel = CheckoutViewModel(
      bookingRepository: widget.bookingRepository,
    );
    _profileViewModel = ProfileViewModel(authRepository: widget.authRepository);
  }

  @override
  void dispose() {
    _searchViewModel.dispose();
    _exploreViewModel.dispose();
    _propertyDetailsViewModel.dispose();
    _selectRoomViewModel.dispose();
    _checkoutViewModel.dispose();
    _addCardViewModel.dispose();
    _profileViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final destinations = [
      if (_showPaymentResult)
        PaymentResultView(
          checkout: _checkoutResult!,
          onBackToExplore: _resetExploreFlow,
          payOSCheckoutBuilder: widget.payOSCheckoutBuilder,
        )
      else if (_showAddCard)
        AddCardView(
          viewModel: _addCardViewModel,
          onBack: () => setState(() => _showAddCard = false),
          onSave: () {},
        )
      else if (_showCheckout)
        CheckoutView(
          data: _checkoutData!,
          viewModel: _checkoutViewModel,
          onBack: () => setState(() => _showCheckout = false),
          onAddCard: () => setState(() => _showAddCard = true),
          onConfirmed: (checkout) {
            setState(() {
              _checkoutResult = checkout;
              _showPaymentResult = true;
              _showCheckout = false;
            });
          },
        )
      else if (_showSelectRoom)
        SelectRoomView(
          data: _selectedRoomData!,
          viewModel: _selectRoomViewModel,
          onBack: () => setState(() => _showSelectRoom = false),
          onContinue: () => unawaited(_continueToCheckout()),
        )
      else if (_isLoadingPropertyDetails)
        _DetailsStateView(
          loading: true,
          onBack: () => setState(() => _isLoadingPropertyDetails = false),
        )
      else if (_propertyDetailsError != null)
        _DetailsStateView(
          message: _propertyDetailsError!,
          onBack: () => setState(() => _propertyDetailsError = null),
        )
      else if (_selectedProperty != null)
        PropertyDetailsView(
          data: _selectedProperty!,
          viewModel: _propertyDetailsViewModel,
          onBack: () => setState(() => _selectedProperty = null),
          onBookNow: _openSelectRoom,
        )
      else if (_showSearch)
        SearchView(
          viewModel: _searchViewModel,
          onClose: () => setState(() => _showSearch = false),
          onSearch: _handleSearch,
        )
      else
        ExploreView(
          viewModel: _exploreViewModel,
          onSearchRequested: () => setState(() => _showSearch = true),
          onStaySelected: _handleStaySelected,
        ),
      ..._pendingDestinations,
      ProfileView(
        viewModel: _profileViewModel,
        onLoggedOut: widget.onLogoutCompleted,
      ),
    ];

    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: destinations),
      bottomNavigationBar:
          _showSelectRoom || _showCheckout || _showAddCard || _showPaymentResult
          ? null
          : AppBottomNavigation(
              selectedIndex: _selectedIndex,
              onSelected: (index) {
                setState(() {
                  _selectedIndex = index;
                  _showSearch = false;
                  _showSelectRoom = false;
                  _showCheckout = false;
                  _showAddCard = false;
                  _showPaymentResult = false;
                  _isLoadingPropertyDetails = false;
                  _selectedProperty = null;
                  _selectedRoomData = null;
                  _checkoutData = null;
                  _checkoutResult = null;
                  _propertyDetailsError = null;
                });
              },
            ),
    );
  }

  void _handleSearch(ProductSearchQuery query) {
    setState(() => _showSearch = false);
    unawaited(_exploreViewModel.applySearch(query));
  }

  Future<void> _handleStaySelected(StayCardData stay) async {
    setState(() {
      _showSearch = false;
      _showSelectRoom = false;
      _showCheckout = false;
      _showAddCard = false;
      _showPaymentResult = false;
      _selectedProperty = null;
      _selectedRoomData = null;
      _checkoutData = null;
      _checkoutResult = null;
      _propertyDetailsError = null;
      _isLoadingPropertyDetails = true;
    });

    try {
      final details = await widget.productRepository.fetchProductDetails(
        stay.id,
        query: _exploreViewModel.activeQuery,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedProperty = _toPropertyDetailsData(
          details,
          _exploreViewModel.activeQuery,
        );
        _isLoadingPropertyDetails = false;
      });
    } on ProductRepositoryException catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _propertyDetailsError = error.message;
        _isLoadingPropertyDetails = false;
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _propertyDetailsError = 'Unable to reach BingCook server.';
        _isLoadingPropertyDetails = false;
      });
    }
  }

  void _openSelectRoom() {
    final property = _selectedProperty;
    if (property == null || !property.canBook) {
      return;
    }

    final data = _toSelectRoomData(property, _exploreViewModel.activeQuery);
    _selectRoomViewModel.dispose();
    _selectRoomViewModel = SelectRoomViewModel(
      nights: data.nights,
      bookingRepository: widget.bookingRepository,
    );
    setState(() {
      _selectedRoomData = data;
      _showSelectRoom = true;
    });
  }

  Future<void> _continueToCheckout() async {
    final data = _selectedRoomData;
    if (data == null) {
      return;
    }

    final success = await _selectRoomViewModel.createDraft(data);
    final draft = _selectRoomViewModel.draft;
    if (!success || draft == null || !mounted) {
      return;
    }

    _checkoutViewModel.dispose();
    _checkoutViewModel = CheckoutViewModel(
      bookingRepository: widget.bookingRepository,
    );
    setState(() {
      _checkoutData = _toCheckoutData(draft, data.propertyImageAsset);
      _showCheckout = true;
    });
  }

  void _resetExploreFlow() {
    setState(() {
      _showSearch = false;
      _showSelectRoom = false;
      _showCheckout = false;
      _showAddCard = false;
      _showPaymentResult = false;
      _selectedProperty = null;
      _selectedRoomData = null;
      _checkoutData = null;
      _checkoutResult = null;
      _propertyDetailsError = null;
      _isLoadingPropertyDetails = false;
    });
  }

  PropertyDetailsData _toPropertyDetailsData(
    ProductDetails details,
    ProductSearchQuery query,
  ) {
    final rooms = details.rooms
        .map((room) => _toRoomOption(room, details.rooms.indexOf(room)))
        .toList(growable: false);

    return PropertyDetailsData(
      id: details.id,
      imageAsset: _propertyImageAsset(details.name),
      imageUrls: details.imageUrls,
      type: details.type,
      name: details.name,
      location: details.location,
      description: details.description,
      address: details.address,
      rating: details.rating,
      reviewCount: details.reviewCount,
      pricePerNight: details.pricePerNight.round(),
      status: details.status,
      checkIn: _formatDate(query.checkIn, fallback: 'Select date'),
      checkOut: _formatDate(query.checkOut, fallback: 'Select date'),
      checkInPolicy: details.checkInPolicy,
      checkOutPolicy: details.checkOutPolicy,
      cancellationPolicy: details.cancellationPolicy,
      amenities: details.amenities
          .map(
            (label) =>
                PropertyAmenityData(type: _amenityType(label), label: label),
          )
          .toList(growable: false),
      rooms: rooms,
      ratingDistribution: details.ratingDistribution.isEmpty
          ? _emptyRatingDistribution
          : details.ratingDistribution
                .map(
                  (item) => RatingDistributionData(
                    stars: item.stars,
                    fraction: item.fraction,
                  ),
                )
                .toList(growable: false),
      summaryRating: details.rating,
      summaryReviewCount: details.reviewCount,
      reviews: details.reviews
          .map(
            (review) => GuestReviewData(
              author: review.author,
              rating: review.rating,
              timeAgo: review.timeAgo,
              comment: review.comment,
            ),
          )
          .toList(growable: false),
    );
  }

  SelectRoomData _toSelectRoomData(
    PropertyDetailsData property,
    ProductSearchQuery query,
  ) {
    final checkIn = query.checkIn ?? _fallbackCheckIn();
    final checkOut = query.checkOut ?? checkIn.add(const Duration(days: 1));
    final guests = query.guests ?? 2;
    return SelectRoomData(
      propertyId: property.id,
      propertyName: property.name,
      propertyImageAsset: property.imageAsset,
      dateRange: _dateRangeForDates(checkIn, checkOut),
      checkIn: checkIn,
      checkOut: checkOut,
      adults: guests,
      children: 0,
      roomQuantity: 1,
      guests: guests,
      nights: _nightsForDates(checkIn, checkOut),
      rooms: property.rooms,
    );
  }

  CheckoutData _toCheckoutData(BookingDraft draft, String propertyImageAsset) {
    final session = widget.authRepository.currentSession;
    return CheckoutData(
      bookingId: draft.bookingId,
      propertyName: draft.propertyName,
      propertyImageAsset: propertyImageAsset,
      roomName: draft.roomName,
      checkIn: _formatDate(draft.checkIn),
      checkOut: _formatDate(draft.checkOut),
      nights: draft.nights,
      fullName: session?.user.fullName ?? '',
      email: session?.user.email ?? '',
      phone: session?.user.phone ?? '',
      paymentMethods: const [
        PaymentMethodData(
          type: PaymentMethodType.payOS,
          title: 'PayOS Checkout',
          subtitle: 'Card, wallet, or QR payment',
          iconAsset: AppAssets.checkoutDigitalWallet,
        ),
        PaymentMethodData(
          type: PaymentMethodType.payAtProperty,
          title: 'Pay at Property',
          subtitle: 'Confirm now, pay on arrival',
          iconAsset: AppAssets.checkoutBankTransfer,
        ),
      ],
      priceRows: [
        PriceBreakdownRow(
          label: '${draft.roomName} (${draft.nights} nights)',
          amount: draft.roomSubtotal,
        ),
        if (draft.addOnSubtotal > 0)
          PriceBreakdownRow(label: 'Add-ons', amount: draft.addOnSubtotal),
      ],
      total: draft.totalPrice,
    );
  }

  RoomOptionData _toRoomOption(ProductRoom room, int index) {
    return RoomOptionData(
      id: room.id,
      imageAsset: _roomImageAsset(index),
      imageUrl: room.imageUrl,
      name: room.name,
      maxGuests: room.maxGuests,
      pricePerNight: room.pricePerNight.round(),
      features: room.features,
      policy: room.policy,
      policyPositive: !room.policy.toLowerCase().contains('non-refundable'),
      badge: index == 0 ? RoomBadge.bestSeller : null,
    );
  }

  String _propertyImageAsset(String name) {
    if (name == 'Blue Garden Homestay') {
      return AppAssets.blueGardenHomestay;
    }
    return AppAssets.propertyDetails;
  }

  String _roomImageAsset(int index) {
    return switch (index % 3) {
      0 => AppAssets.deluxeOceanView,
      1 => AppAssets.doubleRoom,
      _ => AppAssets.executiveSuite,
    };
  }

  PropertyAmenityType _amenityType(String label) {
    final normalized = label.toLowerCase();
    if (normalized.contains('pool') || normalized.contains('swim')) {
      return PropertyAmenityType.pool;
    }
    if (normalized.contains('gym') || normalized.contains('fitness')) {
      return PropertyAmenityType.gym;
    }
    if (normalized.contains('parking')) {
      return PropertyAmenityType.parking;
    }
    return PropertyAmenityType.wifi;
  }

  String _dateRangeForDates(DateTime checkIn, DateTime checkOut) {
    return '${_formatDate(checkIn)} - ${_formatDate(checkOut)}';
  }

  int _nightsForDates(DateTime checkIn, DateTime checkOut) {
    final nights = checkOut.difference(checkIn).inDays;
    return nights <= 0 ? 1 : nights;
  }

  DateTime _fallbackCheckIn() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  }

  String _formatDate(DateTime? value, {String fallback = ''}) {
    if (value == null) {
      return fallback;
    }
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[value.month - 1]} ${value.day}';
  }

  static const _emptyRatingDistribution = [
    RatingDistributionData(stars: 5, fraction: 0),
    RatingDistributionData(stars: 4, fraction: 0),
    RatingDistributionData(stars: 3, fraction: 0),
    RatingDistributionData(stars: 2, fraction: 0),
    RatingDistributionData(stars: 1, fraction: 0),
  ];
}

class _DetailsStateView extends StatelessWidget {
  const _DetailsStateView({
    required this.onBack,
    this.loading = false,
    this.message,
  });

  final bool loading;
  final String? message;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading)
                const CircularProgressIndicator()
              else
                const Icon(
                  Icons.wifi_off_rounded,
                  color: AppColors.gray500,
                  size: 40,
                ),
              const SizedBox(height: 16),
              Text(
                loading ? 'Loading property details...' : message!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontFamily: 'Manrope',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              TextButton(onPressed: onBack, child: const Text('Back')),
            ],
          ),
        ),
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
