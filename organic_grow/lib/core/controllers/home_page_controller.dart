import 'package:get/get.dart';
import 'package:organic_grow/core/models/category_model.dart';
import 'package:organic_grow/core/models/product_model.dart';
import 'package:organic_grow/core/models/vendor_model.dart';
import 'package:organic_grow/core/services/api_services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:organic_grow/core/controllers/connectivity_controller.dart';

class HomeController extends GetxController {
  var categories = <Category>[].obs;
  var featuredProducts = <Product>[].obs;
  var vendors = <Vendor>[].obs;
  var banners = <String>[].obs;
  var currentCarouselIndex = 0.obs;
  var isLoading = true.obs;
  var isRefreshing = false.obs;
  
  final RefreshController refreshController = RefreshController();

  final ConnectivityController connectivityController = Get.find<ConnectivityController>();

  @override
  void onInit() {
    super.onInit();
    fetchHomeData();
  }

  Future<void> fetchHomeData() async {
    try {
      await connectivityController.checkConnection();
      if (!connectivityController.isConnected) {
        refreshController.refreshFailed();
        isLoading.value = false;
        isRefreshing.value = false;
        Get.snackbar("No Internet", "Please check your connection and try again",
            snackPosition: SnackPosition.BOTTOM);
        return;
      }

      isLoading.value = true;

      final categoriesData = await ApiService.fetchCategories();
      final productsData = await ApiService.fetchFeaturedProducts();
      final vendorsData = await ApiService.fetchVendors();
      final bannersData = await ApiService.fetchBanners();

      categories.assignAll(categoriesData);
      featuredProducts.assignAll(productsData);
      vendors.assignAll(vendorsData);
      banners.assignAll(bannersData);

      isLoading.value = false;
      isRefreshing.value = false;
      refreshController.refreshCompleted();
    } catch (e) {
      isLoading.value = false;
      isRefreshing.value = false;
      refreshController.refreshFailed();
      Get.snackbar('Error', 'Failed to load data: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> refreshData() async {
    isRefreshing.value = true;
    await fetchHomeData();
  }

  void updateCarouselIndex(int index) {
    currentCarouselIndex.value = index;
  }

  @override
  void onClose() {
    refreshController.dispose();
    super.onClose();
  }
}
