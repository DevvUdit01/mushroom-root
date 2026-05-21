import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:organic_grow/core/controllers/cart_controller.dart';
import 'package:organic_grow/core/services/api_services.dart';

class CheckoutController extends GetxController {
  var selectedPaymentMethod = 'cod'.obs;
  var isPlacingOrder = false.obs;

  final CartController cartController = Get.find();

  void setPaymentMethod(String method) {
    selectedPaymentMethod.value = method;
  }

  Future<void> placeOrder() async {
    if (cartController.cartItems.isEmpty) {
      Get.snackbar('Error', 'Cart is empty!');
      return;
    }

    try {
      isPlacingOrder.value = true;
      final response = await ApiService.placeOrder(selectedPaymentMethod.value);

      if (response['success'] == true) {
        cartController.clearCart();
        Get.offNamed('/order-success');
      }
    } catch (e) {
      Get.snackbar(
        'Order Failed',
        e.toString(),
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    } finally {
      isPlacingOrder.value = false;
    }
  }
}
