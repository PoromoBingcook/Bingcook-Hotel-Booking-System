import 'package:bingcook/domain/models/booking.dart';
import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/core/utils/currency_formatter.dart';
import 'package:bingcook/ui/features/checkout/view_models/payment_result_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

typedef PayOSCheckoutBuilder =
    Widget Function(Uri checkoutUri, ValueChanged<String> onPageFinished);

class PaymentResultView extends StatefulWidget {
  const PaymentResultView({
    required this.checkout,
    required this.viewModel,
    required this.onBackToExplore,
    required this.onPaymentConfirmed,
    this.onPaymentExpired,
    this.payOSCheckoutBuilder,
    super.key,
  });

  final BookingCheckout checkout;
  final PaymentResultViewModel viewModel;
  final VoidCallback onBackToExplore;
  final VoidCallback onPaymentConfirmed;
  final VoidCallback? onPaymentExpired;
  final PayOSCheckoutBuilder? payOSCheckoutBuilder;

  @override
  State<PaymentResultView> createState() => _PaymentResultViewState();
}

class _PaymentResultViewState extends State<PaymentResultView> {
  bool _expiryDelivered = false;

  bool get _isPayOS => widget.checkout.paymentMethod.toLowerCase() == 'payos';

  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_handleViewModelChanged);
    _handleViewModelChanged();
  }

  @override
  void didUpdateWidget(covariant PaymentResultView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel != widget.viewModel) {
      oldWidget.viewModel.removeListener(_handleViewModelChanged);
      widget.viewModel.addListener(_handleViewModelChanged);
      _expiryDelivered = false;
      _handleViewModelChanged();
    }
  }

  void _handleViewModelChanged() {
    if (!_expiryDelivered &&
        widget.viewModel.state == PaymentResultState.expired) {
      _expiryDelivered = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onPaymentExpired?.call();
        }
      });
    }
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_handleViewModelChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final checkoutUrl = widget.checkout.checkoutUrl;
    final checkoutUri = _checkoutUri(checkoutUrl);
    final shouldEmbedPayOS = _isPayOS && checkoutUri != null;

    return ColoredBox(
      color: AppColors.gray100,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 448),
            color: AppColors.background,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _PaymentResultHeader(onBack: widget.onBackToExplore),
                if (shouldEmbedPayOS)
                  _EmbeddedPayOSResult(
                    checkout: widget.checkout,
                    checkoutUri: checkoutUri,
                    checkoutBuilder:
                        widget.payOSCheckoutBuilder ??
                        _defaultPayOSCheckoutBuilder,
                    viewModel: widget.viewModel,
                    onPaymentConfirmed: widget.onPaymentConfirmed,
                  )
                else
                  _FallbackPaymentResult(
                    checkout: widget.checkout,
                    isPayOS: _isPayOS,
                    checkoutUrl: checkoutUrl,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Uri? _checkoutUri(String? value) {
    if (value == null) {
      return null;
    }
    final uri = Uri.tryParse(value);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      return null;
    }
    return uri;
  }

  static Widget _defaultPayOSCheckoutBuilder(
    Uri checkoutUri,
    ValueChanged<String> onPageFinished,
  ) {
    return _PayOSCheckoutWebView(
      checkoutUri: checkoutUri,
      onPageFinished: onPageFinished,
    );
  }
}

class _EmbeddedPayOSResult extends StatelessWidget {
  const _EmbeddedPayOSResult({
    required this.checkout,
    required this.checkoutUri,
    required this.checkoutBuilder,
    required this.viewModel,
    required this.onPaymentConfirmed,
  });

  final BookingCheckout checkout;
  final Uri checkoutUri;
  final PayOSCheckoutBuilder checkoutBuilder;
  final PaymentResultViewModel viewModel;
  final VoidCallback onPaymentConfirmed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            child: Column(
              children: [
                const Text(
                  'PayOS checkout ready',
                  key: Key('payment_result_title'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'Manrope',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 12),
                _StatusCard(checkout: checkout),
                const SizedBox(height: 10),
                _PaymentVerificationBanner(
                  viewModel: viewModel,
                  onPaymentConfirmed: onPaymentConfirmed,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFE8F0FE)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: checkoutBuilder(checkoutUri, (url) async {
                final confirmed = await viewModel.handlePageFinished(url);
                if (confirmed) {
                  onPaymentConfirmed();
                }
              }),
            ),
          ),
        ],
      ),
    );
  }
}

class _FallbackPaymentResult extends StatelessWidget {
  const _FallbackPaymentResult({
    required this.checkout,
    required this.isPayOS,
    required this.checkoutUrl,
  });

  final BookingCheckout checkout;
  final bool isPayOS;
  final String? checkoutUrl;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 28),
        children: [
          Icon(
            isPayOS ? Icons.qr_code_2_rounded : Icons.check_circle_rounded,
            color: AppColors.primaryDark,
            size: 56,
          ),
          const SizedBox(height: 14),
          Text(
            isPayOS ? 'PayOS checkout ready' : 'Booking confirmed',
            key: const Key('payment_result_title'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontFamily: 'Manrope',
              fontSize: 24,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            checkout.message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          _StatusCard(checkout: checkout),
          if (checkoutUrl != null) ...[
            const SizedBox(height: 16),
            _CopyValueCard(
              title: 'Checkout URL',
              value: checkoutUrl!,
              buttonLabel: 'Copy PayOS Link',
            ),
          ],
          if (checkout.qrCode != null) ...[
            const SizedBox(height: 16),
            _CopyValueCard(
              title: 'PayOS QR Payload',
              value: checkout.qrCode!,
              buttonLabel: 'Copy QR Payload',
            ),
          ],
        ],
      ),
    );
  }
}

class _PayOSCheckoutWebView extends StatefulWidget {
  const _PayOSCheckoutWebView({
    required this.checkoutUri,
    required this.onPageFinished,
  });

  final Uri checkoutUri;
  final ValueChanged<String> onPageFinished;

  @override
  State<_PayOSCheckoutWebView> createState() => _PayOSCheckoutWebViewState();
}

class _PayOSCheckoutWebViewState extends State<_PayOSCheckoutWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _errorMessage = null;
              });
            }
          },
          onPageFinished: (url) {
            if (mounted) {
              setState(() => _isLoading = false);
            }
            widget.onPageFinished(url);
          },
          onWebResourceError: (_) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _errorMessage = 'Unable to load PayOS checkout.';
              });
            }
          },
        ),
      )
      ..loadRequest(widget.checkoutUri);
  }

  @override
  void didUpdateWidget(covariant _PayOSCheckoutWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.checkoutUri != widget.checkoutUri) {
      _controller.loadRequest(widget.checkoutUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(
          key: const Key('payos_checkout_webview'),
          controller: _controller,
        ),
        if (_isLoading)
          const Align(
            alignment: Alignment.topCenter,
            child: LinearProgressIndicator(minHeight: 2),
          ),
        if (_errorMessage != null)
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              color: AppColors.textPrimary,
              child: Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PaymentVerificationBanner extends StatelessWidget {
  const _PaymentVerificationBanner({
    required this.viewModel,
    required this.onPaymentConfirmed,
  });

  final PaymentResultViewModel viewModel;
  final VoidCallback onPaymentConfirmed;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        final (icon, message, color) = switch (viewModel.state) {
          PaymentResultState.waiting => (
            Icons.hourglass_top_rounded,
            'Waiting for PayOS confirmation.',
            AppColors.textSecondary,
          ),
          PaymentResultState.checking => (
            Icons.sync_rounded,
            'Confirming payment with BingCook...',
            AppColors.primaryDark,
          ),
          PaymentResultState.confirmed => (
            Icons.check_circle_rounded,
            'Payment confirmed. Opening Bookings...',
            const Color(0xFF11875D),
          ),
          PaymentResultState.canceled => (
            Icons.cancel_rounded,
            'PayOS checkout was canceled.',
            const Color(0xFFC2413A),
          ),
          PaymentResultState.expired => (
            Icons.timer_off_rounded,
            'The payment link has expired.',
            const Color(0xFFC2413A),
          ),
          PaymentResultState.failed => (
            Icons.error_rounded,
            'PayOS could not complete this payment.',
            const Color(0xFFC2413A),
          ),
          PaymentResultState.error => (
            Icons.wifi_off_rounded,
            viewModel.errorMessage ?? 'Unable to confirm payment status.',
            const Color(0xFFC2413A),
          ),
        };

        return Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message,
                      style: TextStyle(
                        color: color,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (viewModel.hasExpiry) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Payment expires in ${viewModel.formattedRemaining}',
                        key: const Key('payment_expiry_countdown'),
                        style: TextStyle(
                          color: color,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (viewModel.canRetry)
                TextButton(
                  key: const Key('check_payment_status_button'),
                  onPressed: () async {
                    final confirmed = await viewModel.checkStatus();
                    if (confirmed) {
                      onPaymentConfirmed();
                    }
                  },
                  child: const Text('Check'),
                ),
              if (viewModel.isChecking)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: SizedBox.square(
                    dimension: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _PaymentResultHeader extends StatelessWidget {
  const _PaymentResultHeader({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(bottom: BorderSide(color: Color(0xFFE8F0FE))),
      ),
      child: Row(
        children: [
          IconButton(
            key: const Key('payment_result_back_button'),
            onPressed: onBack,
            tooltip: 'Back to Explore',
            icon: const Icon(Icons.close_rounded, size: 20),
            color: AppColors.primaryDark,
          ),
          const Text(
            'BingCook',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontFamily: 'Manrope',
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusCard extends StatelessWidget {
  const _StatusCard({required this.checkout});

  final BookingCheckout checkout;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray100,
        border: Border.all(color: const Color(0xFFE8F0FE)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _StatusRow(label: 'Booking', value: checkout.bookingStatus),
          const SizedBox(height: 10),
          _StatusRow(label: 'Payment', value: checkout.paymentStatus),
          const SizedBox(height: 10),
          _StatusRow(label: 'Amount', value: _money(checkout.amount)),
          if (checkout.transactionCode != null) ...[
            const SizedBox(height: 10),
            _StatusRow(label: 'Code', value: checkout.transactionCode!),
          ],
        ],
      ),
    );
  }

  static String _money(double value) => formatVnd(value);
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _CopyValueCard extends StatelessWidget {
  const _CopyValueCard({
    required this.title,
    required this.value,
    required this.buttonLabel,
  });

  final String title;
  final String value;
  final String buttonLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE8F0FE)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          SelectableText(
            value,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: value));
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('$title copied')));
              }
            },
            icon: const Icon(Icons.copy_rounded, size: 16),
            label: Text(buttonLabel),
          ),
        ],
      ),
    );
  }
}
