import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pchat/Feature/Home/controller/userController/all_users_controller.dart';

import '../../../../utilities/App_Colors/App_Colors.dart';
import '../../../../utilities/App_Images/App_Images.dart';
import '../../../utilities/App_Strings/app_strings.dart';
import '../controller/post_controller.dart';
import '../service/text_recognition_sevice.dart';
import 'live_text_scanner.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {

  final TextEditingController textController = TextEditingController();
  final AllUsersController userController = Get.find();


  final RxBool isTyping = false.obs;
  final RxInt textLength = 0.obs;

  final ImagePicker _picker = ImagePicker();
  final TextRecognitionService _ocrService = TextRecognitionService();

  @override
  void initState() {
    super.initState();

    textController.addListener(() {
      final text = textController.text.trim();
      isTyping.value = text.isNotEmpty;
      textLength.value = text.length;
    });
  }

  @override
  void dispose() {
    textController.dispose();
    _ocrService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      body: Stack(
        children: [

          /// BACKGROUND
          Positioned.fill(
            child: Image.asset(
              AppImages.backgroundImage,
              fit: BoxFit.cover,
            ),
          ),

          SafeArea(
            child: Column(
              children: [

                /// APP BAR
                _appBar(),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        _userRow(),

                        const SizedBox(height: 20),

                        /// POST CARD
                        _postCard(),

                        const SizedBox(height: 20),

                        /// POST BUTTON
                        _postButton(),
                      ],
                    ),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  /// APP BAR
  Widget _appBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      child: Row(
        children: [

          IconButton(
            icon: Icon(Icons.arrow_back_ios_new,
                color: AppColors.themeColor),
            onPressed: () => Get.back(),
          ),

          const SizedBox(width: 45),

          /// LOGO
          Container(
            height: 45,
            width: 45,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Transform.scale(
              scale: 1.5,
              child: Image.asset(AppImages.logo),
            ),
          ),

          const SizedBox(width: 8),

          const Text(
            AppStrings.addPost,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// USER
  Widget _userRow() {
    return Obx(() {
      final username = userController.currentUserUsername.value;

      final firstLetter =
      username.isNotEmpty ? username[0].toUpperCase() : AppStrings
          .defaultAvatar;

      return Row(
        children: [

          /// AVATAR
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.darkAvatarGradient,
            ),
            child: CircleAvatar(
              radius: 26,
              backgroundColor: Colors.transparent,
              child: Text(
                firstLetter,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          /// USERNAME
          Text(
            username.isNotEmpty ? username : AppStrings.loading,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          )
        ],
      );
    });
  }

  /// POST CARD
  Widget _postCard() {
    return Expanded(
      child: Stack(
        children: [

          /// CARD
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: AppColors.lightAvatarGradient,
              borderRadius: BorderRadius.circular(25),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 15,
                  offset: Offset(0, 6),
                )
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                /// INPUT
                Expanded(
                  child: TextField(
                    controller: textController,
                    maxLines: null,
                    style: const TextStyle(
                      fontSize: 18,
                      height: 1.4,
                    ),
                    decoration: const InputDecoration(
                      hintText: AppStrings.whatsOnMind,
                      border: InputBorder.none,
                    ),
                  ),
                ),

                /// COUNT
                Obx(() =>
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        "${textLength.value}/500",
                        style: const TextStyle(fontSize: 12),
                      ),
                    ))
              ],
            ),
          ),

          /// FLOATING OCR BUTTON
          Positioned(
            bottom: 10,
            right: 10,
            child: GestureDetector(
                onTap: _showImagePickerOptions,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppColors.themeColor,
                      shape: BoxShape.circle,
                      boxShadow: const[
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                        )
                      ]
                  ),
                  child: const Icon(Icons.filter_center_focus,
                      color: Colors.white, size: 22),
                )
            ),
          )
        ],
      ),
    );
  }

  /// POST BUTTON
  Widget _postButton() {
    final PostController postController = Get.find();

    return Obx(() =>
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: (isTyping.value && !postController.isPosting.value)
                ? () async {
              HapticFeedback.mediumImpact();

              await postController.createPost(textController.text);

              textController.clear();

              Get.back();
            }
                : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.themeColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
            child: postController.isPosting.value
                ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Text(
              AppStrings.post,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ));
  }

  void _showImagePickerOptions() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Wrap(
          children: [

            /// LIVE SCAN
            ListTile(
              leading: const Icon(Icons.document_scanner),
              title: const Text("Scan Live"),
              onTap: () async {
                Get.back();

                final result = await Get.to(() => const LiveTextScanner());

                if (result != null && result is String) {
                  textController.text = result;
                }
              },
            ),

            /// GALLERY
            ListTile(
              leading: const Icon(Icons.photo),
              title: const Text("Gallery"),
              onTap: () {
                Get.back();
                _pickImage(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);

    if (pickedFile == null) return;

    final file = File(pickedFile.path);

    Get.dialog(
      const Center(child: CircularProgressIndicator()),
      barrierDismissible: false,
    );

    try {
      final extractedText = await _ocrService.extractText(file);
      textController.text = extractedText;
    } catch (e) {
      Get.snackbar("Error", "Failed to extract text");
    } finally {
      Get.back();
    }
  }
}