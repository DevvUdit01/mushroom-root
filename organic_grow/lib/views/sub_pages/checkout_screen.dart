import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:organic_grow/config/app_color.dart';
import 'package:organic_grow/config/app_typography.dart';
import 'package:organic_grow/core/controllers/checkout_controller.dart';
import 'package:organic_grow/core/controllers/cart_controller.dart';
import 'package:organic_grow/core/controllers/profile_controller.dart';

class CheckoutScreen extends StatelessWidget {
  CheckoutScreen({super.key});

  final CheckoutController checkoutController = Get.put(CheckoutController());
  final CartController cartController = Get.find();
  final ProfileController profileController = Get.find();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'Checkout',
          style: AppTypography.h3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Delivery Address
            Text(
              'Delivery Address',
              style: AppTypography.h4.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColor.textColor,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on_rounded, color: Colors.redAccent, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Obx(() {
                      final address = profileController.user.value.address;
                      return Text(
                        address.isNotEmpty ? address : 'No address set. Please update profile.',
                        style: AppTypography.bodyMedium.copyWith(color: AppColor.textColor),
                      );
                    }),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Order Summary
            Text(
              'Order Summary',
              style: AppTypography.h4.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColor.textColor,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Obx(() {
                final subtotal = cartController.totalAmount.value;
                final tax = subtotal * 0.05;
                final delivery = 30.0;
                final grandTotal = subtotal + tax + delivery;

                return Column(
                  children: [
                    _buildSummaryRow('Subtotal', '₹${subtotal.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Tax (5%)', '₹${tax.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Delivery Charge', '₹${delivery.toStringAsFixed(2)}'),
                    const Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total',
                          style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '₹${grandTotal.toStringAsFixed(2)}',
                          style: AppTypography.h3.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColor.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
            ),

            const SizedBox(height: 24),

            // Payment Method
            Text(
              'Payment Method',
              style: AppTypography.h4.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColor.textColor,
              ),
            ),
            const SizedBox(height: 12),
            Obx(() => Column(
              children: [
                _buildPaymentOption(
                  'cod',
                  'Cash on Delivery',
                  Icons.money_rounded,
                  Colors.green,
                ),
                const SizedBox(height: 12),
                _buildPaymentOption(
                  'online',
                  'Pay Online (Cards/UPI)',
                  Icons.credit_card_rounded,
                  Colors.blue,
                ),
              ],
            )),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Obx(() {
            return ElevatedButton(
              onPressed: checkoutController.isPlacingOrder.value
                  ? null
                  : () => checkoutController.placeOrder(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.btnColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: checkoutController.isPlacingOrder.value
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      'Place Order',
                      style: AppTypography.buttonLarge.copyWith(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            );
          }),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTypography.bodyMedium.copyWith(color: AppColor.textColor.withOpacity(0.7)),
        ),
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColor.textColor,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentOption(String value, String title, IconData icon, Color color) {
    final isSelected = checkoutController.selectedPaymentMethod.value == value;
    final context = Get.context!;
    
    return InkWell(
      onTap: () => checkoutController.setPaymentMethod(value),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? color : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle_rounded, color: color),
          ],
        ),
      ),
    );
  }
}
