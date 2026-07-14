import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class SearchDestinationField extends StatefulWidget {
  const SearchDestinationField({
    required this.destination,
    required this.onChanged,
    required this.onClear,
    required this.suggestions,
    required this.onSuggestionSelected,
    this.onSubmitted,
    super.key,
  });

  final String destination;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final List<String> suggestions;
  final ValueChanged<String> onSuggestionSelected;
  final ValueChanged<String>? onSubmitted;

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          key: const Key('destination_text_field'),
          controller: _controller,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Tìm thành phố',
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
        ),
        if (widget.suggestions.isNotEmpty) ...[
          const SizedBox(height: 4),
          DecoratedBox(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: AppColors.outline),
              borderRadius: BorderRadius.circular(10),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x14000000),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(10),
              child: Column(
                children: [
                  for (final city in widget.suggestions)
                    ListTile(
                      key: Key('city_suggestion_$city'),
                      dense: true,
                      leading: const Icon(
                        Icons.location_city_outlined,
                        color: AppColors.primaryDark,
                      ),
                      title: Text(city),
                      onTap: () => widget.onSuggestionSelected(city),
                    ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}
