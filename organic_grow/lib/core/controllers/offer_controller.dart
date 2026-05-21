import 'package:get/get.dart';
import 'package:organic_grow/core/models/offer_model.dart';
import 'package:organic_grow/core/services/api_services.dart';

class OfferController extends GetxController {
  var isLoading = false.obs;
  var currentOffer = Rxn<Offer>();

  @override
  void onInit() {
    super.onInit();
    fetchOffer();
  }

  Future<void> fetchOffer() async {
    try {
      isLoading.value = true;
      final response = await ApiService.fetchSpecialOffer();
      if (response['success'] == true && response['offer'] != null) {
        currentOffer.value = Offer.fromJson(response['offer']);
      }
    } catch (e) {
      print("Failed to fetch offer: $e");
    } finally {
      isLoading.value = false;
    }
  }
}
