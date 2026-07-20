import 'dart:async';

import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/domain/models/chat.dart';
import 'package:bingcook/domain/models/product_details.dart';
import 'package:bingcook/domain/models/product_search_query.dart';
import 'package:bingcook/domain/repositories/auth_repository.dart';
import 'package:bingcook/domain/repositories/booking_repository.dart';
import 'package:bingcook/domain/repositories/chat_repository.dart';
import 'package:bingcook/domain/repositories/notification_repository.dart';
import 'package:bingcook/domain/repositories/product_repository.dart';
import 'package:bingcook/domain/repositories/review_repository.dart';
import 'package:bingcook/domain/repositories/saved_property_repository.dart';
import 'package:bingcook/domain/services/chat_realtime_service.dart';
import 'package:bingcook/ui/core/constants/app_assets.dart';
import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/core/widgets/app_bottom_navigation.dart';
import 'package:bingcook/ui/features/chat/view_models/chat_view_model.dart';
import 'package:bingcook/ui/features/chat/view_models/conversations_view_model.dart';
import 'package:bingcook/ui/features/chat/views/chat_view.dart';
import 'package:bingcook/ui/features/chat/views/conversations_view.dart';
import 'package:bingcook/ui/features/bookings/view_models/bookings_view_model.dart';
import 'package:bingcook/ui/features/bookings/views/bookings_view.dart';
import 'package:bingcook/ui/features/checkout/models/checkout_data.dart';
import 'package:bingcook/ui/features/checkout/view_models/add_card_view_model.dart';
import 'package:bingcook/ui/features/checkout/view_models/checkout_view_model.dart';
import 'package:bingcook/ui/features/checkout/view_models/payment_result_view_model.dart';
import 'package:bingcook/ui/features/checkout/views/add_card_view.dart';
import 'package:bingcook/ui/features/checkout/views/checkout_view.dart';
import 'package:bingcook/ui/features/checkout/views/payment_result_view.dart';
import 'package:bingcook/ui/features/explore/models/stay_card_data.dart';
import 'package:bingcook/ui/features/explore/view_models/explore_view_model.dart';
import 'package:bingcook/ui/features/explore/views/explore_view.dart';
import 'package:bingcook/ui/features/map/views/nearby_map_view.dart';
import 'package:bingcook/ui/features/property_details/models/property_details_data.dart';
import 'package:bingcook/ui/features/property_details/view_models/property_details_view_model.dart';
import 'package:bingcook/ui/features/property_details/views/property_details_view.dart';
import 'package:bingcook/ui/features/notifications/view_models/notifications_view_model.dart';
import 'package:bingcook/ui/features/notifications/views/notifications_view.dart';
import 'package:bingcook/ui/features/profile/view_models/profile_view_model.dart';
import 'package:bingcook/ui/features/profile/views/profile_view.dart';
import 'package:bingcook/ui/features/profile/views/personal_information_view.dart';
import 'package:bingcook/ui/features/search/view_models/search_view_model.dart';
import 'package:bingcook/ui/features/search/views/search_view.dart';
import 'package:bingcook/ui/features/saved/view_models/saved_stays_view_model.dart';
import 'package:bingcook/ui/features/saved/views/saved_stays_view.dart';
import 'package:bingcook/ui/features/select_room/models/select_room_data.dart';
import 'package:bingcook/ui/features/select_room/view_models/select_room_view_model.dart';
import 'package:bingcook/ui/features/select_room/views/select_room_view.dart';
import 'package:flutter/material.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    required this.authRepository,
    required this.productRepository,
    required this.bookingRepository,
    required this.chatRepository,
    required this.notificationRepository,
    required this.savedPropertyRepository,
    required this.reviewRepository,
    required this.onLogoutCompleted,
    this.chatRealtimeService,
    this.payOSCheckoutBuilder,
    super.key,
  });

  final AuthRepository authRepository;
  final ProductRepository productRepository;
  final BookingRepository bookingRepository;
  final ChatRepository chatRepository;
  final NotificationRepository notificationRepository;
  final SavedPropertyRepository savedPropertyRepository;
  final ReviewRepository reviewRepository;
  final VoidCallback onLogoutCompleted;
  final ChatRealtimeService? chatRealtimeService;
  final PayOSCheckoutBuilder? payOSCheckoutBuilder;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;
  int _previousMainIndex = 0;
  bool _showSearch = false;
  bool _showMap = false;
  bool _showSelectRoom = false;
  bool _showCheckout = false;
  bool _showAddCard = false;
  bool _showPaymentResult = false;
  bool _showChat = false;
  bool _showMessages = false;
  bool _showNotifications = false;
  bool _showPersonalInformation = false;
  bool _showPropertyChat = false;
  bool _isLoadingPropertyDetails = false;
  PropertyDetailsData? _selectedProperty;
  SelectRoomData? _selectedRoomData;
  CheckoutData? _checkoutData;
  BookingCheckout? _checkoutResult;
  PaymentResultViewModel? _paymentResultViewModel;
  String? _propertyDetailsError;
  final SearchViewModel _searchViewModel = SearchViewModel();
  late final ExploreViewModel _exploreViewModel;
  late final PropertyDetailsViewModel _propertyDetailsViewModel;
  late SelectRoomViewModel _selectRoomViewModel;
  late CheckoutViewModel _checkoutViewModel;
  final AddCardViewModel _addCardViewModel = AddCardViewModel();
  late final ChatViewModel _chatViewModel;
  late final ConversationsViewModel _conversationsViewModel;
  late final NotificationsViewModel _notificationsViewModel;
  late final SavedStaysViewModel _savedStaysViewModel;
  ChatViewModel? _selectedChatViewModel;
  ChatViewModel? _propertyChatViewModel;
  late final ProfileViewModel _profileViewModel;
  late final BookingsViewModel _bookingsViewModel;

  @override
  void initState() {
    super.initState();
    _exploreViewModel = ExploreViewModel(
      productRepository: widget.productRepository,
    );
    _propertyDetailsViewModel = PropertyDetailsViewModel(
      reviewRepository: widget.reviewRepository,
    );
    unawaited(_exploreViewModel.loadProducts());
    _selectRoomViewModel = SelectRoomViewModel(
      nights: 1,
      bookingRepository: widget.bookingRepository,
    );
    _checkoutViewModel = CheckoutViewModel(
      bookingRepository: widget.bookingRepository,
    );
    _chatViewModel = ChatViewModel(
      chatRepository: widget.chatRepository,
      authRepository: widget.authRepository,
      realtimeService: widget.chatRealtimeService,
    );
    _conversationsViewModel = ConversationsViewModel(
      chatRepository: widget.chatRepository,
    );
    _notificationsViewModel = NotificationsViewModel(
      notificationRepository: widget.notificationRepository,
    );
    unawaited(_notificationsViewModel.load());
    _savedStaysViewModel = SavedStaysViewModel(
      savedPropertyRepository: widget.savedPropertyRepository,
    );
    unawaited(_savedStaysViewModel.load());
    _profileViewModel = ProfileViewModel(authRepository: widget.authRepository);
    _bookingsViewModel = BookingsViewModel(
      bookingRepository: widget.bookingRepository,
    );
    unawaited(_bookingsViewModel.load());
  }

  @override
  void dispose() {
    _searchViewModel.dispose();
    _exploreViewModel.dispose();
    _propertyDetailsViewModel.dispose();
    _selectRoomViewModel.dispose();
    _checkoutViewModel.dispose();
    _paymentResultViewModel?.dispose();
    _addCardViewModel.dispose();
    _chatViewModel.dispose();
    _conversationsViewModel.dispose();
    _notificationsViewModel.dispose();
    _savedStaysViewModel.dispose();
    _selectedChatViewModel?.dispose();
    _propertyChatViewModel?.dispose();
    _profileViewModel.dispose();
    _bookingsViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final destinations = [
      if (_showPaymentResult)
        PaymentResultView(
          checkout: _checkoutResult!,
          viewModel: _paymentResultViewModel!,
          onBackToExplore: () => unawaited(_handlePaymentClosed()),
          onPaymentConfirmed: () => unawaited(_handlePaymentConfirmed()),
          onPaymentExpired: () => unawaited(_handlePaymentExpired()),
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
            _paymentResultViewModel?.dispose();
            _paymentResultViewModel = PaymentResultViewModel(
              bookingId: checkout.bookingId,
              bookingRepository: widget.bookingRepository,
              expiresAt: checkout.expiresAt,
            );
            setState(() {
              _checkoutResult = checkout;
              _showPaymentResult = true;
              _showCheckout = false;
            });
            if (checkout.paymentMethod.toLowerCase() != 'payos') {
              unawaited(_bookingsViewModel.load());
              unawaited(_notificationsViewModel.refresh());
            }
          },
        )
      else if (_showSelectRoom)
        ListenableBuilder(
          listenable: _savedStaysViewModel,
          builder: (context, _) => SelectRoomView(
            data: _selectedRoomData!,
            viewModel: _selectRoomViewModel,
            isSaved: _savedStaysViewModel.isSaved(
              _selectedRoomData!.propertyId,
            ),
            onSavedToggle: () =>
                unawaited(_toggleSaved(_selectedRoomData!.propertyId)),
            onBack: () => setState(() => _showSelectRoom = false),
            onContinue: () => unawaited(_continueToCheckout()),
          ),
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
        ListenableBuilder(
          listenable: _savedStaysViewModel,
          builder: (context, _) => PropertyDetailsView(
            data: _selectedProperty!,
            viewModel: _propertyDetailsViewModel,
            isSaved: _savedStaysViewModel.isSaved(_selectedProperty!.id),
            onSavedToggle: () => unawaited(_toggleSaved(_selectedProperty!.id)),
            onBack: () => setState(() => _selectedProperty = null),
            onBookNow: _openSelectRoom,
            onChat: _openPropertyChat,
            onReviewSaved: _refreshSelectedProperty,
            onStayChanged: () => unawaited(_reloadSelectedProperty()),
          ),
        )
      else if (_showMap)
        NearbyMapView(
          stays: _exploreViewModel.stays,
          onBack: () => setState(() => _showMap = false),
          onStaySelected: _handleStaySelected,
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
          onMapRequested: () => setState(() => _showMap = true),
          onStaySelected: _handleStaySelected,
        ),
      SavedStaysView(
        viewModel: _savedStaysViewModel,
        onStaySelected: (stay) => unawaited(_openSavedStay(stay)),
        onToggleSaved: (propertyId) => unawaited(_toggleSaved(propertyId)),
      ),
      BookingsView(
        viewModel: _bookingsViewModel,
        onResumePayment: _resumePayment,
        onReservationCancelled: () {
          unawaited(_notificationsViewModel.refresh());
        },
      ),
      ListenableBuilder(
        listenable: _notificationsViewModel,
        builder: (context, _) {
          return ProfileView(
            viewModel: _profileViewModel,
            unreadNotifications: _notificationsViewModel.unreadCount,
            onMessagesRequested: _openMessages,
            onNotificationsRequested: _openNotifications,
            onBackRequested: _goBackFromProfile,
            onPersonalInformationRequested: () =>
                setState(() => _showPersonalInformation = true),
            onSupportRequested: () => setState(() => _showChat = true),
            onLoggedOut: widget.onLogoutCompleted,
          );
        },
      ),
    ];

    return Scaffold(
      body: _showPersonalInformation
          ? PersonalInformationView(
              viewModel: _profileViewModel,
              onBack: () => setState(() => _showPersonalInformation = false),
            )
          : _selectedChatViewModel != null
          ? ChatView(
              viewModel: _selectedChatViewModel!,
              onBack: () {
                _selectedChatViewModel!.dispose();
                setState(() => _selectedChatViewModel = null);
                unawaited(_conversationsViewModel.load());
              },
            )
          : _showMessages
          ? ConversationsView(
              viewModel: _conversationsViewModel,
              onBack: () => setState(() => _showMessages = false),
              onConversationSelected: _openConversation,
            )
          : _showNotifications
          ? NotificationsView(
              viewModel: _notificationsViewModel,
              onBack: () => setState(() => _showNotifications = false),
            )
          : _showPropertyChat && _selectedProperty != null
          ? ChatView(
              key: ValueKey('property-chat-${_selectedProperty!.id}'),
              viewModel: _propertyChatViewModel!,
              onBack: () => setState(() => _showPropertyChat = false),
            )
          : _showChat
          ? ChatView(
              viewModel: _chatViewModel,
              onBack: () => setState(() => _showChat = false),
            )
          : IndexedStack(index: _selectedIndex, children: destinations),
      bottomNavigationBar:
          _showSelectRoom ||
              _showCheckout ||
              _showAddCard ||
              _showPaymentResult ||
              _showChat ||
              _showMessages ||
              _showNotifications ||
              _showPersonalInformation ||
              _selectedChatViewModel != null ||
              _showPropertyChat
          ? null
          : AppBottomNavigation(
              selectedIndex: _selectedIndex,
              onSelected: (index) {
                _selectMainDestination(index);
                if (index == 1) {
                  unawaited(_savedStaysViewModel.refresh());
                }
              },
            ),
    );
  }

  void _handleSearch(ProductSearchQuery query) {
    setState(() => _showSearch = false);
    unawaited(_exploreViewModel.applySearch(query));
  }

  void _selectMainDestination(int index) {
    setState(() {
      if (index != _selectedIndex) {
        _previousMainIndex = _selectedIndex;
      }
      _selectedIndex = index;
      _showSearch = false;
      _showMap = false;
      _showSelectRoom = false;
      _showCheckout = false;
      _showAddCard = false;
      _showPaymentResult = false;
      _showChat = false;
      _showMessages = false;
      _showNotifications = false;
      _showPersonalInformation = false;
      _showPropertyChat = false;
      _isLoadingPropertyDetails = false;
      _selectedProperty = null;
      _selectedRoomData = null;
      _checkoutData = null;
      _checkoutResult = null;
      _propertyDetailsError = null;
    });
  }

  void _goBackFromProfile() {
    final destination = _previousMainIndex == 3 ? 0 : _previousMainIndex;
    _selectMainDestination(destination);
  }

  Future<void> _handleStaySelected(StayCardData stay) async {
    _propertyDetailsViewModel.configure(_exploreViewModel.activeQuery);
    final query = _propertyDetailsViewModel.buildQuery(
      _exploreViewModel.activeQuery,
    );
    setState(() {
      _showSearch = false;
      _showSelectRoom = false;
      _showCheckout = false;
      _showAddCard = false;
      _showPaymentResult = false;
      _showChat = false;
      _selectedProperty = null;
      _selectedRoomData = null;
      _checkoutData = null;
      _checkoutResult = null;
      _propertyDetailsError = null;
      _isLoadingPropertyDetails = true;
    });

    await _loadPropertyDetails(stay.id, query);
    if (_selectedProperty?.id == stay.id) {
      unawaited(_propertyDetailsViewModel.loadMyReview(stay.id));
    }
  }

  Future<void> _reloadSelectedProperty() async {
    final property = _selectedProperty;
    if (property == null) {
      return;
    }

    final query = _propertyDetailsViewModel.buildQuery(
      _exploreViewModel.activeQuery,
    );
    setState(() {
      _selectedProperty = null;
      _propertyDetailsError = null;
      _isLoadingPropertyDetails = true;
    });
    await _loadPropertyDetails(property.id, query);
  }

  Future<void> _loadPropertyDetails(
    String propertyId,
    ProductSearchQuery query,
  ) async {
    try {
      final details = await widget.productRepository.fetchProductDetails(
        propertyId,
        query: query,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _selectedProperty = _toPropertyDetailsData(details, query);
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

  Future<void> _openSavedStay(StayCardData stay) async {
    setState(() => _selectedIndex = 0);
    await _handleStaySelected(stay);
  }

  Future<void> _refreshSelectedProperty() async {
    final selected = _selectedProperty;
    if (selected == null) return;
    final query = _propertyDetailsViewModel.buildQuery(
      _exploreViewModel.activeQuery,
    );

    try {
      final details = await widget.productRepository.fetchProductDetails(
        selected.id,
        query: query,
      );
      if (!mounted || _selectedProperty?.id != selected.id) return;
      setState(() {
        _selectedProperty = _toPropertyDetailsData(details, query);
      });
    } on ProductRepositoryException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    }
  }

  Future<void> _toggleSaved(String propertyId) async {
    final success = await _savedStaysViewModel.toggle(propertyId);
    if (success || !mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _savedStaysViewModel.errorMessage ?? 'Unable to update saved stays.',
        ),
      ),
    );
  }

  void _openSelectRoom() {
    final property = _selectedProperty;
    if (property == null || !property.canBook) {
      return;
    }

    final data = _toSelectRoomData(property);
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

  void _openPropertyChat() {
    final property = _selectedProperty;
    if (property == null || property.id.isEmpty) {
      return;
    }

    _propertyChatViewModel?.dispose();
    _propertyChatViewModel = ChatViewModel(
      chatRepository: widget.chatRepository,
      authRepository: widget.authRepository,
      realtimeService: widget.chatRealtimeService,
      initialPropertyId: property.id,
    );
    setState(() => _showPropertyChat = true);
  }

  void _openMessages() {
    setState(() => _showMessages = true);
    unawaited(_conversationsViewModel.load());
  }

  void _openNotifications() {
    setState(() => _showNotifications = true);
    unawaited(_notificationsViewModel.load());
  }

  void _openConversation(ChatConversation conversation) {
    _selectedChatViewModel?.dispose();
    _selectedChatViewModel = ChatViewModel(
      chatRepository: widget.chatRepository,
      authRepository: widget.authRepository,
      realtimeService: widget.chatRealtimeService,
      initialConversation: conversation,
      initialPropertyId: conversation.propertyId,
      initialBookingId: conversation.bookingId,
    );
    setState(() {});
  }

  Future<void> _continueToCheckout() async {
    final data = _selectedRoomData;
    if (data == null) {
      return;
    }

    final success = await _selectRoomViewModel.createDraft(data);
    final draft = _selectRoomViewModel.draft;
    if (!success) {
      final existingBookingId = _selectRoomViewModel.pendingPaymentBookingId;
      if (existingBookingId != null) {
        await _bookingsViewModel.load();
        if (!mounted) {
          return;
        }
        final reservation = _bookingsViewModel.findReservation(
          existingBookingId,
        );
        if (reservation != null &&
            _bookingsViewModel.canResumePayment(reservation)) {
          _resumePayment(reservation);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Continuing your existing pending payment.'),
            ),
          );
        }
      }
      return;
    }
    if (draft == null || !mounted) {
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

  Future<void> _handlePaymentClosed() async {
    _paymentResultViewModel?.dispose();
    _paymentResultViewModel = null;
    _bookingsViewModel.selectTab(BookingListTab.active);
    setState(() {
      _selectedIndex = 2;
      _showSearch = false;
      _showMap = false;
      _showSelectRoom = false;
      _showCheckout = false;
      _showAddCard = false;
      _showPaymentResult = false;
      _showChat = false;
      _selectedProperty = null;
      _selectedRoomData = null;
      _checkoutData = null;
      _checkoutResult = null;
      _propertyDetailsError = null;
      _isLoadingPropertyDetails = false;
    });
    await _bookingsViewModel.load();
  }

  void _resumePayment(BookingReservation reservation) {
    final checkoutUrl = reservation.checkoutUrl;
    if (checkoutUrl == null ||
        !reservation.canResumePaymentAt(DateTime.now())) {
      unawaited(_bookingsViewModel.load());
      return;
    }

    _paymentResultViewModel?.dispose();
    final checkout = BookingCheckout(
      bookingId: reservation.bookingId,
      bookingStatus: reservation.bookingStatus,
      paymentMethod: reservation.paymentMethod ?? 'PayOS',
      paymentStatus: reservation.paymentStatus ?? 'Pending',
      amount: reservation.totalPrice,
      transactionCode: reservation.transactionCode,
      paymentLinkId: null,
      checkoutUrl: checkoutUrl,
      qrCode: null,
      expiresAt: reservation.expiresAt,
      message: 'Continue your existing PayOS payment.',
    );
    _paymentResultViewModel = PaymentResultViewModel(
      bookingId: reservation.bookingId,
      bookingRepository: widget.bookingRepository,
      expiresAt: reservation.expiresAt,
    );
    setState(() {
      _checkoutResult = checkout;
      _showPaymentResult = true;
      _selectedIndex = 0;
    });
  }

  Future<void> _handlePaymentExpired() async {
    _bookingsViewModel.selectTab(BookingListTab.active);
    await _bookingsViewModel.load();
    if (!mounted) {
      return;
    }

    _paymentResultViewModel?.dispose();
    _paymentResultViewModel = null;
    setState(() {
      _selectedIndex = 2;
      _showSearch = false;
      _showMap = false;
      _showSelectRoom = false;
      _showCheckout = false;
      _showAddCard = false;
      _showPaymentResult = false;
      _showChat = false;
      _selectedProperty = null;
      _selectedRoomData = null;
      _checkoutData = null;
      _checkoutResult = null;
      _propertyDetailsError = null;
      _isLoadingPropertyDetails = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Payment time expired. The room is available again.'),
      ),
    );
  }

  Future<void> _handlePaymentConfirmed() async {
    _bookingsViewModel.selectTab(BookingListTab.active);
    await Future.wait([
      _bookingsViewModel.load(),
      _notificationsViewModel.refresh(),
    ]);
    if (!mounted) {
      return;
    }

    _paymentResultViewModel?.dispose();
    _paymentResultViewModel = null;
    setState(() {
      _selectedIndex = 2;
      _showSearch = false;
      _showSelectRoom = false;
      _showCheckout = false;
      _showAddCard = false;
      _showPaymentResult = false;
      _showChat = false;
      _selectedProperty = null;
      _selectedRoomData = null;
      _checkoutData = null;
      _checkoutResult = null;
      _propertyDetailsError = null;
      _isLoadingPropertyDetails = false;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Room booked successfully.')));
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
      latitude: details.latitude,
      longitude: details.longitude,
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
              id: review.id,
              author: review.author,
              rating: review.rating,
              timeAgo: review.timeAgo,
              comment: review.comment,
            ),
          )
          .toList(growable: false),
    );
  }

  SelectRoomData _toSelectRoomData(PropertyDetailsData property) {
    final checkIn = _propertyDetailsViewModel.checkIn;
    final checkOut = _propertyDetailsViewModel.checkOut;
    final guests = _propertyDetailsViewModel.guests;
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
      availableRooms: room.availableRooms,
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
