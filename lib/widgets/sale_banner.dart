import 'package:flutter/material.dart';
import 'package:imat/model/imat/product.dart';

class SaleBanner extends StatelessWidget {
  const SaleBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 10,
      right: -20,
      child: Transform.rotate(
        angle: 0.785398, // 45 degrees in radians
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            'REA',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }
}

class SalePriceDisplay extends StatelessWidget {
  final Product product;
  final TextStyle? priceStyle;
  final bool showUnit;

  const SalePriceDisplay({
    super.key,
    required this.product,
    this.priceStyle,
    this.showUnit = true,
  });

  @override
  Widget build(BuildContext context) {
    final originalPrice = product.originalPrice;
    
    if (originalPrice == null) {
      // No sale, show normal price
      return Text(
        showUnit ? product.priceString : product.price.toStringAsFixed(2).replaceAll('.', ','),
        style: priceStyle,
      );
    }

    // Product is on sale
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Original price (struck through, no unit)
        Text(
          originalPrice.toStringAsFixed(2).replaceAll('.', ','),
          style: (priceStyle ?? TextStyle()).copyWith(
            decoration: TextDecoration.lineThrough,
            color: Colors.grey[600],
            fontSize: (priceStyle?.fontSize ?? 14) * 0.9,
          ),
        ),
        // Current sale price (red, with unit if showUnit is true)
        Text(
          showUnit ? product.priceString : product.price.toStringAsFixed(2).replaceAll('.', ','),
          style: (priceStyle ?? TextStyle()).copyWith(
            color: Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
} 