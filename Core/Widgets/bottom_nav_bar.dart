import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utilities/App_Colors/App_Colors.dart';
import '../controller/pchat_controller.dart';

class PChatBottomNav extends StatelessWidget {
  PChatBottomNav({super.key});

  final PChatController controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentIndex = controller.selectedIndex.value;

      return Container(
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
            _navItem(
              context: context,
              icon: Icons.notifications,
              label: "Requests",
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
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 26,
                color: isSelected
                    ? AppColors.themeColor
                    : Colors.grey,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? AppColors.themeColor
                      : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
