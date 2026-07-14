import 'package:bingcook/ui/core/theme/app_colors.dart';
import 'package:bingcook/ui/features/property_details/view_models/property_details_view_model.dart';
import 'package:flutter/material.dart';

class PropertyReviewSheet extends StatefulWidget {
  const PropertyReviewSheet({
    required this.viewModel,
    required this.propertyId,
    required this.onSaved,
    super.key,
  });

  final PropertyDetailsViewModel viewModel;
  final String propertyId;
  final Future<void> Function() onSaved;

  @override
  State<PropertyReviewSheet> createState() => _PropertyReviewSheetState();
}

class _PropertyReviewSheetState extends State<PropertyReviewSheet> {
  late final TextEditingController _commentController;
  late final bool _isEditing;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.viewModel.myReview != null;
    _commentController = TextEditingController(
      text: widget.viewModel.myReview?.comment ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: ListenableBuilder(
        listenable: widget.viewModel,
        builder: (context, _) {
          final viewModel = widget.viewModel;
          return SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              24,
              12,
              24,
              MediaQuery.viewInsetsOf(context).bottom + 24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.gray400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _isEditing ? 'Edit your review' : 'Write a review',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontFamily: 'Manrope',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'How would you rate this property?',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (var rating = 1; rating <= 5; rating++)
                      SizedBox.square(
                        dimension: 48,
                        child: IconButton(
                          key: Key('review_star_$rating'),
                          onPressed: viewModel.isSubmittingReview
                              ? null
                              : () => viewModel.selectRating(rating),
                          tooltip: 'Rate $rating stars',
                          icon: Icon(
                            rating <= viewModel.selectedRating
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            color: const Color(0xFFFBBC04),
                            size: 34,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 18),
                TextField(
                  key: const Key('review_comment_field'),
                  controller: _commentController,
                  enabled: !viewModel.isSubmittingReview,
                  minLines: 4,
                  maxLines: 6,
                  maxLength: 1000,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    labelText: 'Comment (optional)',
                    hintText: 'Share your experience',
                    alignLabelWithHint: true,
                  ),
                ),
                if (viewModel.errorMessage != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    viewModel.errorMessage!,
                    key: const Key('review_sheet_error'),
                    style: const TextStyle(
                      color: AppColors.error,
                      fontSize: 13,
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                FilledButton(
                  key: const Key('review_submit_button'),
                  onPressed: viewModel.isSubmittingReview ? null : _submit,
                  child: viewModel.isSubmittingReview
                      ? const SizedBox.square(
                          dimension: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isEditing ? 'Update review' : 'Submit review'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _submit() async {
    final saved = await widget.viewModel.submitReview(
      propertyId: widget.propertyId,
      comment: _commentController.text,
    );
    if (!saved) return;
    await widget.onSaved();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }
}
