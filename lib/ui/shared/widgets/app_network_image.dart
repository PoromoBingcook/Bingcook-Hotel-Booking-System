import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    required this.imageUrl,
    required this.fallback,
    required this.sourceWidth,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
  });

  final String? imageUrl;
  final Widget fallback;
  final int sourceWidth;
  final double? width;
  final double? height;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty || sourceWidth <= 0) {
      return fallback;
    }

    final optimizedUrl = _optimizedImageUrl(url, sourceWidth);
    return CachedNetworkImage(
      imageUrl: optimizedUrl,
      width: width,
      height: height,
      fit: fit,
      memCacheWidth: sourceWidth,
      maxWidthDiskCache: sourceWidth,
      fadeInDuration: const Duration(milliseconds: 180),
      placeholder: (context, _) =>
          _ImageLoadingPlaceholder(width: width, height: height),
      errorWidget: (context, _, _) => fallback,
    );
  }

  static String _optimizedImageUrl(String value, int width) {
    final uri = Uri.tryParse(value);
    if (uri == null || uri.host.toLowerCase() != 'images.unsplash.com') {
      return value;
    }

    final query = Map<String, String>.of(uri.queryParameters)
      ..['auto'] = 'format'
      ..['fit'] = 'crop'
      ..['w'] = width.toString()
      ..['q'] = '75';
    return uri.replace(queryParameters: query).toString();
  }
}

class _ImageLoadingPlaceholder extends StatelessWidget {
  const _ImageLoadingPlaceholder({this.width, this.height});

  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: const ColoredBox(
        color: Color(0xFFE9EDF2),
        child: Center(
          child: SizedBox.square(
            dimension: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      ),
    );
  }
}
