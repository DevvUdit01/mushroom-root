import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:organic_grow/config/app_color.dart';
import 'package:organic_grow/config/app_typography.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wishlistItems = [
      {'name': 'Organic Avocado', 'price': '₹4.99 / kg', 'image': 'assets/images/avocado.png', 'rating': '4.9'},
      {'name': 'Fresh Strawberry', 'price': '₹6.49 / box', 'image': 'assets/images/strawberry.png', 'rating': '4.8'},
      {'name': 'Green Spinach', 'price': '₹2.20 / bunch', 'image': 'assets/images/spinach.png', 'rating': '4.7'},
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('My Wishlist', style: AppTypography.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: wishlistItems.isEmpty
          ? Center(child: Text('Wishlist is empty', style: AppTypography.bodyLarge.copyWith(color: AppColor.textColor.withOpacity(0.5))))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: wishlistItems.length,
              itemBuilder: (context, index) {
                final item = wishlistItems[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Theme.of(context).dividerColor, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: AppColor.primaryColor.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.eco_rounded, color: AppColor.primaryColor, size: 36),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item['name']!, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColor.textColor)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.star_rounded, color: Colors.amber, size: 16),
                                  const SizedBox(width: 4),
                                  Text(item['rating']!, style: AppTypography.caption.copyWith(color: AppColor.textColor.withOpacity(0.5))),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(item['price']!, style: AppTypography.bodyMedium.copyWith(color: AppColor.primaryColor, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.favorite_rounded, color: Colors.pink),
                          onPressed: () {
                            Get.snackbar(
                              'Removed',
                              '${item['name']} removed from wishlist.',
                              backgroundColor: Colors.pink.withOpacity(0.1),
                              colorText: Colors.pink,
                              borderRadius: 16,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
