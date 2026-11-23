import 'package:flutter/material.dart';

class BukuCover extends StatelessWidget {
  final String source;
  final String fallbackAsset;
  final BoxFit fit;

  const BukuCover({
    super.key,
    required this.source,
    required this.fallbackAsset,
    this.fit = BoxFit.cover,
  });

  @override
  Widget build(BuildContext context) {
    final isNetworkImage =
        source.startsWith('https://') || source.startsWith('http://');
    if (!isNetworkImage) {
      return Image.asset(
        source.isEmpty ? fallbackAsset : source,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      );
    }

    return Image.network(
      source,
      fit: fit,
      errorBuilder: (_, __, ___) => Image.asset(
        fallbackAsset,
        fit: fit,
        errorBuilder: (_, __, ___) => _placeholder(),
      ),
    );
  }

  Widget _placeholder() => const ColoredBox(
        color: Color(0xFFEAF3F8),
        child: Center(
          child: Icon(Icons.menu_book_rounded, color: Color(0xFF456B86)),
        ),
      );
}
