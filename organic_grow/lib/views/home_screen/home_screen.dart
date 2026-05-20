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
  final RxBool isSearchExpanded = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Cohesive organic background
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
              // 1. Beautiful Gradient Custom Header (No standard AppBar)
              _buildHeader(context),
              
              const SizedBox(height: 20),
              
              // 2. Carousel Slider
              Obx(() => _buildCarouselSlider()),
              
              const SizedBox(height: 24),
              
              // 3. Categories Horizontal Section
              Obx(() => _buildCategoriesSection()),
              
              const SizedBox(height: 24),

              // 4. Nearby Stores Section (Zomato-style vendor cards)
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

  // Premium Header with dynamic personalization & search bar
  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1B5E20), // Jungle Green
            Color(0xFF4CAF50), // Fresh Emerald Green
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Stack(
        children: [
          // Translucent background circles for premium texture
          Positioned(
            top: -40,
            right: -30,
            child: CircleAvatar(
              radius: 90,
              backgroundColor: Colors.white.withOpacity(0.07),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white.withOpacity(0.04),
            ),
          ),
          // Header Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Fresh & Organic 🌿',
                            style: AppTypography.caption.copyWith(
                              color: Colors.white.withOpacity(0.7),
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                           Obx(() {
                            final user = profileController.user.value;
                            final firstName = user.name.isNotEmpty ? user.name.split(' ')[0] : 'Guest';
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hello, $firstName! 👋',
                                  style: AppTypography.h2.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.location_on_rounded,
                                      color: Colors.white,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    SizedBox(
                                      width: 180, // Bound width to ensure text truncates gracefully
                                      child: Text(
                                        user.address.isNotEmpty ? user.address : 'Locating...',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: AppTypography.caption.copyWith(
                                          color: Colors.white.withOpacity(0.9),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                      // Top Action Icons
                      Row(
                        children: [
                          _buildHeaderIconButton(
                            icon: Icons.search_rounded,
                            onTap: () {
                              isSearchExpanded.value =
                                  !isSearchExpanded.value;
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildHeaderIconButton(
                            icon: Icons.favorite_rounded,
                            onTap: () => Get.to(() => const WishlistScreen()),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Obx(() {
                    if (isSearchExpanded.value) {
                      return const SizedBox(height: 18);
                    }
                    return const SizedBox();
                  }),
                  // Integrated Search Bar
                  _buildSearchBar(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderIconButton({required IconData icon, required VoidCallback onTap}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.12),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white, size: 22),
        onPressed: onTap,
        constraints: const BoxConstraints(),
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Obx(() {
      final isExpanded = isSearchExpanded.value;
      return AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: isExpanded ? 52 : 0,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: isExpanded ? 1.0 : 0.0,
          child: isExpanded
              ? Row(
                  children: [
                    const Icon(Icons.search_rounded, color: AppColor.primaryColor, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        decoration: InputDecoration(
                          hintText: 'Search organic fruits, veggies...',
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
                        color: AppColor.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.tune_rounded,
                        color: AppColor.primaryColor,
                        size: 20,
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
        ),
      );
    });
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
      homeController.isLoading.value ? const SpecialOffersWidgetShimmer() : const SpecialOffersWidget();
}
