import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pchat/utilities/App_Images/App_Images.dart';

class HumeAppBar extends StatelessWidget implements PreferredSizeWidget {
  const HumeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,

      // Back button
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Get.back();
        },
      ),

      // Logo + Title
      title: Row(
        children: [
          SizedBox(
            width: 35,
            height: 35,
            child: Image.asset(
              AppImages.Ailogo,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Hume',
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 22,
              letterSpacing: 1,
            ),
          ),
        ],
      ),

      centerTitle: false,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}