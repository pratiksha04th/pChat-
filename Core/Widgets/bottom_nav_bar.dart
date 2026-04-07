import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../Feature/PostScreen/view/create_post_screen.dart';
import '../../utilities/App_Colors/App_Colors.dart';
import '../controller/pchat_controller.dart';

class PChatBottomNav extends StatelessWidget {
  PChatBottomNav({super.key});

  final PChatController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentIndex = controller.selectedIndex.value;

      return Stack(
        alignment: Alignment.bottomCenter,
        children: [

          /// NAV BAR
          Container(
            margin: const EdgeInsets.all(14),
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.95),
              borderRadius: BorderRadius.circular(30),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 12,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                  context: context,
                  icon: Icons.home,
                  label: "Home",
                  index: 0,
                  currentIndex: currentIndex,
                ),
                _navItem(
                  context: context,
                  icon: Icons.group,
                  label: "Friends",
                  index: 1,
                  currentIndex: currentIndex,
                ),

                /// SPACE FOR CENTER BUTTON
                const SizedBox(width: 50),

                _navItem(
                  context: context,
                  icon: Icons.search,
                  label: "Search",
                  index: 2,
                  currentIndex: currentIndex,
                ),
                _navItem(
                  context: context,
                  icon: Icons.person,
                  label: "Profile",
                  index: 3,
                  currentIndex: currentIndex,
                ),
              ],
            ),
          ),

          /// FLOATING + BUTTON
          Positioned(
            bottom: 20,
            child: GestureDetector(
              onTap: () => Get.to(() => CreatePostScreen()),
              child: Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.themeColor,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.themeColor.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _navItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required int index,
    required int currentIndex,
  }) {
    final bool isSelected = index == currentIndex;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () => controller.changeTab(index),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            transform: Matrix4.translationValues(
              0,
              isSelected ? -4 : 0,
              0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedScale(
                  scale: isSelected ? 1.2 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  child: Icon(
                    icon,
                    size: 26,
                    color: isSelected
                        ? AppColors.themeColor
                        : Colors.grey,
                  ),
                ),
                const SizedBox(height: 4),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isSelected
                        ? AppColors.themeColor
                        : Colors.grey,
                  ),
                  child: Text(label),
                ),

                AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(top: 4),
                  height: 4,
                  width: isSelected ? 20 : 0,
                  decoration: BoxDecoration(
                    color: AppColors.themeColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
