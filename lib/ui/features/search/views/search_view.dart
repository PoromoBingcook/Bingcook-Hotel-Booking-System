import 'package:bingcook/domain/models/product_search_query.dart';
import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/search/view_models/search_view_model.dart';
import 'package:bingcook/ui/features/search/widgets/amenity_selector.dart';
import 'package:bingcook/ui/features/search/widgets/guest_counter_card.dart';
import 'package:bingcook/ui/features/search/widgets/search_calendar.dart';
import 'package:bingcook/ui/features/search/widgets/search_destination_field.dart';
import 'package:flutter/material.dart';

class SearchView extends StatelessWidget {
  const SearchView({
    required this.viewModel,
    required this.onClose,
    required this.onSearch,
    super.key,
  });

  final SearchViewModel viewModel;
  final VoidCallback onClose;
  final ValueChanged<ProductSearchQuery> onSearch;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppColors.gray100,
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 480),
            color: AppColors.background,
            child: ListenableBuilder(
              listenable: viewModel,
              builder: (context, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _SearchHeader(onClose: onClose),
                    Expanded(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SectionLabel('Destination'),
                            const SizedBox(height: 8),
                            SearchDestinationField(
                              destination: viewModel.destination,
                              onChanged: viewModel.updateDestination,
                              onClear: viewModel.clearDestination,
                            ),
                            const SizedBox(height: 20),
                            const _SectionLabel('When'),
                            const SizedBox(height: 8),
                            SearchCalendar(
                              checkIn: viewModel.checkIn,
                              checkOut: viewModel.checkOut,
                              onDateSelected: viewModel.selectDate,
                            ),
                            const SizedBox(height: 20),
                            const _SectionLabel('Who'),
                            const SizedBox(height: 8),
                            GuestCounterCard(
                              adults: viewModel.adults,
                              children: viewModel.children,
                              onIncrementAdults: viewModel.incrementAdults,
                              onDecrementAdults: viewModel.decrementAdults,
                              onIncrementChildren: viewModel.incrementChildren,
                              onDecrementChildren: viewModel.decrementChildren,
                            ),
                            const SizedBox(height: 20),
                            const _SectionLabel('Property type'),
                            const SizedBox(height: 8),
                            _ChoiceSection(
                              values: SearchViewModel.availableTypes,
                              selectedValue: viewModel.selectedType,
                              onSelected: viewModel.setType,
                              labelBuilder: (value) => value,
                            ),
                            const SizedBox(height: 20),
                            const _SectionLabel('Price per night'),
                            const SizedBox(height: 8),
                            _PriceRangeFilter(viewModel: viewModel),
                            const SizedBox(height: 20),
                            const _SectionLabel('Rating'),
                            const SizedBox(height: 8),
                            _ChoiceSection<double>(
                              values: SearchViewModel.availableRatings,
                              selectedValue: viewModel.minRating,
                              onSelected: viewModel.setMinRating,
                              labelBuilder: (value) => value == 0
                                  ? 'Any'
                                  : '${value.toStringAsFixed(1)}+',
                            ),
                            const SizedBox(height: 20),
                            const _SectionLabel('Amenities'),
                            const SizedBox(height: 8),
                            AmenitySelector(
                              amenities: SearchViewModel.availableAmenities,
                              selectedAmenities: viewModel.selectedAmenities,
                              onToggle: viewModel.toggleAmenity,
                            ),
                          ],
                        ),
                      ),
                    ),
                    _SearchFooter(
                      onSearch: () => onSearch(viewModel.buildQuery()),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _SearchHeader extends StatelessWidget {
  const _SearchHeader({required this.onClose});

  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.gray200)),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          const Text(
            'Search',
            key: Key('search_title'),
            style: TextStyle(
              color: AppColors.slate900,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Positioned(
            left: 4,
            child: IconButton(
              key: const Key('search_close_button'),
              onPressed: onClose,
              tooltip: 'Close search',
              icon: const Icon(Icons.close, size: 24),
              color: AppColors.slate900,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceRangeFilter extends StatelessWidget {
  const _PriceRangeFilter({required this.viewModel});

  final SearchViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.outline),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                '\$${viewModel.minPrice.round()}',
                style: const TextStyle(
                  color: AppColors.slate900,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                '\$${viewModel.maxPrice.round()}',
                style: const TextStyle(
                  color: AppColors.slate900,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          RangeSlider(
            values: RangeValues(viewModel.minPrice, viewModel.maxPrice),
            min: SearchViewModel.minAllowedPrice,
            max: SearchViewModel.maxAllowedPrice,
            divisions: 20,
            labels: RangeLabels(
              '\$${viewModel.minPrice.round()}',
              '\$${viewModel.maxPrice.round()}',
            ),
            onChanged: (values) =>
                viewModel.setPriceRange(values.start, values.end),
          ),
        ],
      ),
    );
  }
}

class _ChoiceSection<T> extends StatelessWidget {
  const _ChoiceSection({
    required this.values,
    required this.selectedValue,
    required this.onSelected,
    required this.labelBuilder,
  });

  final List<T> values;
  final T selectedValue;
  final ValueChanged<T> onSelected;
  final String Function(T value) labelBuilder;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final value in values)
          ChoiceChip(
            label: Text(labelBuilder(value)),
            selected: value == selectedValue,
            onSelected: (_) => onSelected(value),
            selectedColor: AppColors.primaryDark,
            backgroundColor: Colors.white,
            side: BorderSide(
              color: value == selectedValue
                  ? AppColors.primaryDark
                  : AppColors.outline,
            ),
            labelStyle: TextStyle(
              color: value == selectedValue ? Colors.white : AppColors.slate700,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.padded,
          ),
      ],
    );
  }
}

class _SearchFooter extends StatelessWidget {
  const _SearchFooter({required this.onSearch});

  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.gray200)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 48,
        child: FilledButton.icon(
          key: const Key('search_submit_button'),
          onPressed: onSearch,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primaryDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          icon: const Icon(Icons.search_rounded, size: 18),
          label: const Text(
            'Search',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.slate700,
        fontSize: 12,
        height: 1.4,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
