import 'package:flutter/material.dart';
import 'package:organic_grow/config/app_color.dart';
import 'package:organic_grow/config/app_typography.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockOrders = [
      {'id': '#OG-8902', 'date': '12 May 2026', 'items': '6 Items', 'total': '₹42.50', 'status': 'Delivered', 'color': Colors.green},
      {'id': '#OG-8714', 'date': '08 May 2026', 'items': '3 Items', 'total': '₹18.90', 'status': 'Delivered', 'color': Colors.green},
      {'id': '#OG-8620', 'date': '02 May 2026', 'items': '12 Items', 'total': '₹94.30', 'status': 'Delivered', 'color': Colors.green},
      {'id': '#OG-8511', 'date': '24 Apr 2026', 'items': '5 Items', 'total': '₹31.20', 'status': 'Cancelled', 'color': Colors.redAccent},
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Order History', style: AppTypography.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: mockOrders.isEmpty
          ? Center(
              child: Text('No orders yet', style: AppTypography.bodyLarge.copyWith(color: AppColor.textColor.withOpacity(0.5))),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: mockOrders.length,
              itemBuilder: (context, index) {
                final order = mockOrders[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Theme.of(context).dividerColor, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(order['id'] as String, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColor.textColor)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: (order['color'] as Color).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                order['status'] as String,
                                style: AppTypography.caption.copyWith(color: order['color'] as Color, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Divider(color: Theme.of(context).dividerColor, height: 1),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Date', style: AppTypography.caption.copyWith(color: AppColor.textColor.withOpacity(0.4))),
                                const SizedBox(height: 4),
                                Text(order['date'] as String, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColor.textColor)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Quantity', style: AppTypography.caption.copyWith(color: AppColor.textColor.withOpacity(0.4))),
                                const SizedBox(height: 4),
                                Text(order['items'] as String, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w600, color: AppColor.textColor)),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('Total Amount', style: AppTypography.caption.copyWith(color: AppColor.textColor.withOpacity(0.4))),
                                const SizedBox(height: 4),
                                Text(order['total'] as String, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColor.primaryColor)),
                              ],
                            ),
                          ],
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
