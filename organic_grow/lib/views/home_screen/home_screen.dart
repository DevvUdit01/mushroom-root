import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:organic_grow/config/app_color.dart';
import 'package:organic_grow/config/app_typography.dart';
import 'package:organic_grow/core/controllers/home_page_controller.dart';
import 'package:organic_grow/core/controllers/profile_controller.dart';
import 'package:organic_grow/views/home_screen/widget/carousel_slider_widget.dart';
import 'package:organic_grow/views/home_screen/widget/categories_section_widget.dart';
import 'package:organic_grow/views/home_screen/widget/featured_product_widget.dart';
import 'package:organic_grow/views/home_screen/widget/special_offer.dart';
import 'package:organic_grow/views/home_screen/widget/vendor_section_widget.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:organic_grow/views/sub_pages/wishlist_screen.dart';

class HomeScreen extends GetView<HomeController> {
  HomeScreen({super.key});

  final HomeController homeController = Get.put(HomeController());
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SmartRefresher(
        controller: homeController.refreshController, 
        onRefresh: homeController.refreshData,        
        enablePullDown: true,
        enablePullUp: false,
        header: const WaterDropHeader(waterDropColor: AppColor.primaryColor),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Zomato-Style Premium Location & Search Header
              _buildHeader(context),
              
              const SizedBox(height: 16),
              
              // 2. Carousel Slider
              Obx(() => _buildCarouselSlider()),
              
              const SizedBox(height: 24),
              
              // 3. Double-Row Categories Grid ("What's on your mind?")
              Obx(() => _buildCategoriesSection()),
              
              const SizedBox(height: 24),

              // 4. Nearby Stores Section (Zomato-style vendor cards with filter row)
              Obx(() => _buildVendorSection()),
              
              const SizedBox(height: 24),
              
              // 5. Special Offers Section
              Obx(() => _buildSpecialOffersSection()),
              
              const SizedBox(height: 24),
              
              // 6. Featured Products Section
              Obx(() => _buildFeaturedProductsSection()),
              
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Zomato style neutral header with red location pin, dynamic location text & profile image
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Location + Profile Action
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        // Tapping location manually requests GPS updates
                        profileController.fetchAndSaveCurrentLocation();
                      },
                      child: Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Colors.redAccent,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Deliver to',
                                      style: AppTypography.caption.copyWith(
                                        color: Colors.grey[500],
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Icon(
                                      Icons.keyboard_arrow_down_rounded,
                                      color: Colors.grey[600],
                                      size: 16,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Obx(() {
                                  final user = profileController.user.value;
                                  return Text(
                                    user.address.isNotEmpty ? user.address : 'Locating...',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColor.textColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Heart / Wishlist icon
                  GestureDetector(
                    onTap: () => Get.to(() => const WishlistScreen()),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_rounded,
                        color: Colors.redAccent,
                        size: 20,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Profile Photo
                  Obx(() {
                    final user = profileController.user.value;
                    final hasProfileImage = user.image.isNotEmpty && !user.image.contains('assets/');
                    return Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColor.primaryColor.withOpacity(0.2),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.grey[200],
                        backgroundImage: hasProfileImage
                            ? NetworkImage(user.image)
                            : const AssetImage('assets/user_profile.jpg') as ImageProvider,
                      ),
                    );
                  }),
                ],
              ),
              const SizedBox(height: 18),
              
              // Always visible sticky-style Search Bar
              _buildSearchBar(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[200]!,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.search_rounded, color: Colors.grey, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              readOnly: true,
              onTap: () {
                Get.toNamed('/search');
              },
              decoration: InputDecoration(
                hintText: "Search 'organic fruits', 'fresh veggies'...",
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500,
                ),
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: AppColor.primaryColor.withOpacity(0.08),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.tune_rounded,
              color: AppColor.primaryColor,
              size: 18,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCarouselSlider() =>
      homeController.isLoading.value ? const CarouselSliderWidgetShimmer() : CarouselSliderWidget();

  Widget _buildCategoriesSection() =>
      homeController.isLoading.value ? const CategoriesSectionWidgetShimmer() : CategoriesSectionWidget();

  Widget _buildVendorSection() =>
      homeController.isLoading.value ? const VendorSectionWidgetShimmer() : VendorSectionWidget();

  Widget _buildFeaturedProductsSection() =>
      homeController.isLoading.value ? const FeaturedProductWidgetShimmer() : FeaturedProductWidget();

  Widget _buildSpecialOffersSection() =>
      homeController.isLoading.value ? const SpecialOffersWidgetShimmer() : SpecialOffersWidget();
}
