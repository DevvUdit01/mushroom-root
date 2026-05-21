import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:organic_grow/config/app_color.dart';
import 'package:organic_grow/config/app_typography.dart';
import 'package:organic_grow/core/controllers/order_controller.dart';
import 'package:organic_grow/core/models/order_model.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderController orderController = Get.isRegistered<OrderController>()
        ? Get.find<OrderController>()
        : Get.put(OrderController());

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Order History',
            style: AppTypography.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => orderController.fetchOrders(),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Obx(() {
        if (orderController.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColor.primaryColor),
          );
        }

        if (orderController.errorMessage.value.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline_rounded, size: 64, color: Colors.redAccent),
                const SizedBox(height: 16),
                Text(orderController.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: AppTypography.bodyMedium.copyWith(color: AppColor.textColor.withOpacity(0.6))),
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  onPressed: () => orderController.fetchOrders(),
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColor.primaryColor, foregroundColor: Colors.white),
                ),
              ],
            ),
          );
        }

        if (orderController.orders.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_long_rounded, size: 80,
                    color: AppColor.primaryColor.withOpacity(0.3)),
                const SizedBox(height: 16),
                Text('No orders yet!',
                    style: AppTypography.h3.copyWith(color: AppColor.textColor.withOpacity(0.4))),
                const SizedBox(height: 8),
                Text('Your order history will appear here.',
                    style: AppTypography.bodyMedium.copyWith(color: AppColor.textColor.withOpacity(0.4))),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: AppColor.primaryColor,
          onRefresh: () => orderController.fetchOrders(),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            itemCount: orderController.orders.length,
            itemBuilder: (context, index) {
              return _OrderCard(order: orderController.orders[index]);
            },
          ),
        );
      }),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final AppOrder order;
  const _OrderCard({required this.order});

  Color _statusColor(String status) {
    switch (status) {
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.redAccent;
      case 'out_for_delivery':
        return Colors.blue;
      case 'packed':
        return Colors.orange;
      case 'accepted':
        return Colors.teal;
      default:
        return Colors.amber;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      case 'packed':
        return 'Packed';
      case 'accepted':
        return 'Accepted';
      default:
        return 'Pending';
    }
  }

  String _formatDate(DateTime dt) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${dt.day} ${months[dt.month]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(order.orderStatus);
    final label = _statusLabel(order.orderStatus);
    final shortId = '#${order.id.length > 8 ? order.id.substring(order.id.length - 8).toUpperCase() : order.id.toUpperCase()}';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Header row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(shortId,
                        style: AppTypography.bodyLarge
                            .copyWith(fontWeight: FontWeight.bold, color: AppColor.textColor)),
                    const SizedBox(height: 2),
                    Text(order.vendorName,
                        style: AppTypography.caption.copyWith(
                            color: AppColor.primaryColor, fontWeight: FontWeight.w600)),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(label,
                      style: AppTypography.caption
                          .copyWith(color: color, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(color: Theme.of(context).dividerColor, height: 1),
            const SizedBox(height: 14),

            // Items preview
            if (order.items.isNotEmpty) ...[
              ...order.items.take(2).map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.circle, size: 6, color: AppColor.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${item.productName} x${item.quantity}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.caption.copyWith(
                              color: AppColor.textColor.withOpacity(0.7),
                            ),
                          ),
                        ),
                        Text(
                          '₹${(item.price * item.quantity).toStringAsFixed(0)}',
                          style: AppTypography.caption
                              .copyWith(color: AppColor.textColor, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  )),
              if (order.items.length > 2)
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    '+ ${order.items.length - 2} more items',
                    style: AppTypography.caption
                        .copyWith(color: AppColor.primaryColor, fontWeight: FontWeight.w500),
                  ),
                ),
              const SizedBox(height: 8),
              Divider(color: Theme.of(context).dividerColor, height: 1),
              const SizedBox(height: 12),
            ],

            // Bottom summary row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date',
                        style: AppTypography.caption
                            .copyWith(color: AppColor.textColor.withOpacity(0.4))),
                    const SizedBox(height: 4),
                    Text(_formatDate(order.createdAt),
                        style: AppTypography.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600, color: AppColor.textColor)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('Items',
                        style: AppTypography.caption
                            .copyWith(color: AppColor.textColor.withOpacity(0.4))),
                    const SizedBox(height: 4),
                    Text('${order.totalItemCount} Items',
                        style: AppTypography.bodyMedium
                            .copyWith(fontWeight: FontWeight.w600, color: AppColor.textColor)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('Total',
                        style: AppTypography.caption
                            .copyWith(color: AppColor.textColor.withOpacity(0.4))),
                    const SizedBox(height: 4),
                    Text('₹${order.totalAmount.toStringAsFixed(0)}',
                        style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold, color: AppColor.primaryColor)),
                  ],
                ),
              ],
            ),

            // Payment badge
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.paymentStatus == 'paid'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.paymentMethod == 'cod' ? 'Cash on Delivery' : 'Online Payment',
                    style: AppTypography.caption.copyWith(
                      color: order.paymentStatus == 'paid' ? Colors.green : Colors.amber[800],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: order.paymentStatus == 'paid'
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    order.paymentStatus == 'paid' ? 'Paid ✓' : 'Payment Pending',
                    style: AppTypography.caption.copyWith(
                      color: order.paymentStatus == 'paid' ? Colors.green : Colors.orange[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
