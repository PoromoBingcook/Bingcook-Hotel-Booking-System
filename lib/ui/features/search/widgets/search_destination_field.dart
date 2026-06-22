import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SearchDestinationField extends StatefulWidget {
  const SearchDestinationField({
    required this.destination,
    required this.onChanged,
    required this.onClear,
    super.key,
  });

  final String destination;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  State<SearchDestinationField> createState() => _SearchDestinationFieldState();
}

class _SearchDestinationFieldState extends State<SearchDestinationField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.destination);
  }

  @override
  void didUpdateWidget(SearchDestinationField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.destination != _controller.text) {
      _controller.text = widget.destination;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const Key('destination_text_field'),
      controller: _controller,
      onChanged: widget.onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Add destination',
        prefixIcon: const Icon(
          Icons.location_on_outlined,
          size: 20,
          color: AppColors.slate500,
        ),
        suffixIcon: widget.destination.isEmpty
            ? null
            : IconButton(
                key: const Key('destination_clear_button'),
                onPressed: widget.onClear,
                tooltip: 'Clear destination',
                icon: const Icon(Icons.cancel_outlined, size: 18),
                color: AppColors.slate500,
              ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 13,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryDark),
        ),
      ),
      style: const TextStyle(
        color: AppColors.slate800,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
