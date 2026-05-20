import 'package:flutter/material.dart';
import 'package:organic_grow/config/app_color.dart';
import 'package:organic_grow/config/app_typography.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mockNotifications = [
      {'title': 'Order Delivered!', 'body': 'Your order #OG-8902 has been successfully delivered to your doorstep.', 'time': '2 hrs ago', 'icon': Icons.local_shipping_rounded, 'color': Colors.green},
      {'title': 'Huge Discount!', 'body': 'Get 30% discount on all leafy vegetables this morning. Order now!', 'time': '5 hrs ago', 'icon': Icons.local_offer_rounded, 'color': Colors.amber},
      {'title': 'Points Credited', 'body': 'Congratulations! 50 reward points have been credited to your account.', 'time': '1 day ago', 'icon': Icons.star_rounded, 'color': Colors.blue},
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Notifications', style: AppTypography.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: mockNotifications.isEmpty
          ? Center(child: Text('No notifications', style: AppTypography.bodyLarge.copyWith(color: AppColor.textColor.withOpacity(0.5))))
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              itemCount: mockNotifications.length,
              itemBuilder: (context, index) {
                final notif = mockNotifications[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Theme.of(context).dividerColor, width: 1),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: (notif['color'] as Color).withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(notif['icon'] as IconData, color: notif['color'] as Color, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(notif['title'] as String, style: AppTypography.bodyLarge.copyWith(fontWeight: FontWeight.bold, color: AppColor.textColor)),
                                  Text(notif['time'] as String, style: AppTypography.caption.copyWith(color: AppColor.textColor.withOpacity(0.4))),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Text(notif['body'] as String, style: AppTypography.bodyMedium.copyWith(color: AppColor.textColor.withOpacity(0.6))),
                            ],
                          ),
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
