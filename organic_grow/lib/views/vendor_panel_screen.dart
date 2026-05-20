import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:organic_grow/config/app_color.dart';
import 'package:organic_grow/config/app_typography.dart';
import 'package:organic_grow/core/controllers/vendor_panel_controller.dart';
import 'package:organic_grow/core/services/api_services.dart';

class VendorPanelScreen extends StatelessWidget {
  VendorPanelScreen({super.key}) {
    Get.put(VendorPanelController());
  }

  final VendorPanelController controller = Get.find<VendorPanelController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Store Dashboard', style: AppTypography.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColor.primaryColor,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColor.primaryColor));
        }

        final vendor = controller.vendor.value;
        if (vendor == null) {
          return const Center(child: Text('Vendor profile not found.'));
        }

        final stats = controller.stats;
        final shopImageUrl = vendor.shopImage.isNotEmpty
            ? ApiService.buildImageUrl(vendor.shopImage)
            : '';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Store Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundImage: shopImageUrl.isNotEmpty ? NetworkImage(shopImageUrl) : null,
                      backgroundColor: AppColor.primaryColor.withOpacity(0.1),
                      child: shopImageUrl.isEmpty ? const Icon(Icons.store, size: 30, color: AppColor.primaryColor) : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vendor.shopName,
                            style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.star, color: Colors.amber, size: 16),
                              const SizedBox(width: 4),
                              Text('${vendor.rating} (${vendor.totalReviews} Reviews)', style: AppTypography.caption),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Shop Status Toggle
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: vendor.isOpen ? AppColor.primaryColor.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: vendor.isOpen ? AppColor.primaryColor : Colors.red, width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(vendor.isOpen ? Icons.check_circle : Icons.cancel, 
                             color: vendor.isOpen ? AppColor.primaryColor : Colors.red),
                        const SizedBox(width: 12),
                        Text(
                          vendor.isOpen ? 'Shop is Currently Open' : 'Shop is Closed',
                          style: AppTypography.h4.copyWith(
                            color: vendor.isOpen ? AppColor.primaryColor : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Switch(
                      value: vendor.isOpen,
                      onChanged: (value) => controller.toggleShopStatus(),
                      activeColor: AppColor.primaryColor,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
              Text('Overview', style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Stats Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [
                  _buildStatCard(
                    title: 'Total Earnings',
                    value: '₹${stats['totalEarnings'] ?? 0}',
                    icon: Icons.currency_rupee,
                    color: Colors.green,
                  ),
                  _buildStatCard(
                    title: 'Total Orders',
                    value: '${stats['totalOrders'] ?? 0}',
                    icon: Icons.shopping_bag,
                    color: Colors.blue,
                  ),
                  _buildStatCard(
                    title: 'Active Orders',
                    value: '${stats['activeOrders'] ?? 0}',
                    icon: Icons.local_shipping,
                    color: Colors.orange,
                  ),
                  _buildStatCard(
                    title: 'Total Products',
                    value: '${stats['totalProducts'] ?? 0}',
                    icon: Icons.inventory_2,
                    color: Colors.purple,
                  ),
                ],
              ),

              const SizedBox(height: 24),
              Text('Quick Actions', style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),

              // Action List
              _buildActionTile(
                icon: Icons.inventory,
                title: 'Manage Products',
                subtitle: 'Add, edit or remove products',
                onTap: () {
                  // Get.toNamed('/vendor-products');
                },
              ),
              const SizedBox(height: 8),
              _buildActionTile(
                icon: Icons.receipt_long,
                title: 'Manage Orders',
                subtitle: 'View and process incoming orders',
                onTap: () {
                  // Get.toNamed('/vendor-orders');
                },
              ),
              const SizedBox(height: 8),
              _buildActionTile(
                icon: Icons.storefront,
                title: 'Edit Store Profile',
                subtitle: 'Update address, delivery time, etc.',
                onTap: () {
                  // Get.toNamed('/vendor-edit-profile');
                },
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatCard({required String title, required String value, required IconData icon, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Text(title, style: AppTypography.caption.copyWith(color: color, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: AppTypography.h3.copyWith(fontWeight: FontWeight.bold, color: AppColor.textColor)),
        ],
      ),
    );
  }

  Widget _buildActionTile({required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    final context = Get.context!;
    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      tileColor: Theme.of(context).cardColor,
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColor.primaryColor.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColor.primaryColor),
      ),
      title: Text(title, style: AppTypography.h5.copyWith(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: AppTypography.caption),
      trailing: const Icon(Icons.chevron_right),
    );
  }
}
