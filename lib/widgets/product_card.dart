import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../utils/theme.dart';
import '../utils/constants.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final VoidCallback? onAddToCart;
  final VoidCallback? onEdit;
  final bool showActions;

  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.onAddToCart,
    this.onEdit,
    this.showActions = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(AppConstants.paddingSmall),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppConstants.radiusLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppTheme.backgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppConstants.radiusLarge),
                        topRight: Radius.circular(AppConstants.radiusLarge),
                      ),
                    ),
                    child: Icon(
                      Icons.car_repair,
                      size: 50,
                      color: AppTheme.textLight,
                    ),
                  ),
                  if (product.stockQuantity < 10)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.cancelledColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Low Stock',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const NeverScrollableScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Category
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.category,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: AppTheme.primaryColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                          ),

                          const SizedBox(height: 3),

                          // Product Name
                          Text(
                            product.name,
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          const SizedBox(height: 4),

                          // Price and Stock
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Flexible(
                                child: Text(
                                  AppConstants.formatCurrency(product.price),
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: AppTheme.primaryColor,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 13,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                'Stock: ${product.stockQuantity}',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(
                                      color: AppTheme.textSecondary,
                                      fontSize: 9,
                                    ),
                              ),
                            ],
                          ),

                          // Action Buttons
                          if (showActions) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                if (onEdit != null)
                                  Expanded(
                                    child: OutlinedButton(
                                      onPressed: onEdit,
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: AppTheme.primaryColor,
                                        side: const BorderSide(
                                          color: AppTheme.primaryColor,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        minimumSize: const Size(0, 24),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Edit',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ),
                                if (onEdit != null && onAddToCart != null)
                                  const SizedBox(width: 4),
                                if (onAddToCart != null)
                                  Expanded(
                                    child: ElevatedButton(
                                      onPressed: onAddToCart,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTheme.accentColor,
                                        foregroundColor: AppTheme.textPrimary,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 2,
                                        ),
                                        minimumSize: const Size(0, 24),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        'Add',
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ] else if (onAddToCart != null) ...[
                            const SizedBox(height: 4),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: onAddToCart,
                                icon: const Icon(
                                  Icons.add_shopping_cart,
                                  size: 12,
                                ),
                                label: const Text(
                                  'Add to Cart',
                                  style: TextStyle(fontSize: 10),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.accentColor,
                                  foregroundColor: AppTheme.textPrimary,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  minimumSize: const Size(0, 28),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
