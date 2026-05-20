import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:organic_grow/config/app_color.dart';
import 'package:organic_grow/config/app_typography.dart';
import 'package:organic_grow/core/controllers/profile_controller.dart';

class EditProfileScreen extends StatelessWidget {
  EditProfileScreen({super.key});

  final ProfileController profileController = Get.find<ProfileController>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final user = profileController.user.value;
    nameController.text = user.name;
    emailController.text = user.email;
    phoneController.text = user.phone;
    addressController.text = user.address;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('Edit Profile', style: AppTypography.h3.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppColor.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    shape: BoxShape.circle,
                    boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 4))],
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: AppColor.secondaryColor.withOpacity(0.1),
                    child: ClipOval(
                      child: Image.asset(
                        user.image,
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.person_rounded, size: 65, color: AppColor.primaryColor),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColor.primaryColor,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
                  ),
                  child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildTextField(context, controller: nameController, label: 'Full Name', icon: Icons.person_outline_rounded),
            const SizedBox(height: 16),
            _buildTextField(context, controller: emailController, label: 'Email Address', icon: Icons.mail_outline_rounded, keyboardType: TextInputType.emailAddress),
            const SizedBox(height: 16),
            _buildTextField(context, controller: phoneController, label: 'Phone Number', icon: Icons.phone_iphone_rounded, keyboardType: TextInputType.phone),
            const SizedBox(height: 16),
            _buildTextField(context, controller: addressController, label: 'Home Address', icon: Icons.home_work_outlined, maxLines: 3),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  profileController.updateProfile(
                    nameController.text,
                    emailController.text,
                    phoneController.text,
                    addressController.text,
                  );
                  Get.back();
                  Get.snackbar(
                    'Success',
                    'Profile details updated successfully!',
                    backgroundColor: AppColor.primaryColor,
                    colorText: Colors.white,
                    borderRadius: 16,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.btnColor,
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: Text('Save Changes', style: AppTypography.buttonLarge.copyWith(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Theme.of(context).dividerColor, width: 1),
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(color: AppColor.textColor, fontWeight: FontWeight.w600),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: AppColor.textColor.withOpacity(0.5)),
          prefixIcon: Icon(icon, color: AppColor.primaryColor),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }
}
