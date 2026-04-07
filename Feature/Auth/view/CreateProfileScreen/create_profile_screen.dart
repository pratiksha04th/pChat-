import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../utilities/App_Colors/App_Colors.dart';
import '../../../../utilities/App_Images/App_Images.dart';
import '../../../../Core/Widgets/Text_field/input_decoration.dart';
import '../../../../utilities/App_Strings/app_strings.dart';
import '../../controller/auth_controlller.dart';

class CreateProfileScreen extends StatelessWidget {

  final String username;

  CreateProfileScreen({super.key, required this.username});

  final AuthController controller = Get.find<AuthController>();

  final formKey = GlobalKey<FormState>();

  String get avatarLetter {
    if (username.isEmpty) return "U";
    return username[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: Colors.transparent,

      body: GestureDetector(

        /// dismiss keyboard
        onTap: () => FocusScope.of(context).unfocus(),

        child: Stack(
          children: [

            /// BACKGROUND
            Positioned.fill(
              child: Image.asset(
                AppImages.backgroundImage,
                fit: BoxFit.cover,
              ),
            ),

            /// MAIN CONTAINER
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {

                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),

                      child: Form(
                        key: formKey,

                        child: Column(
                          children: [

                            const SizedBox(height: 40),

                            /// AVATAR
                            CircleAvatar(
                              radius: 45,
                              backgroundColor: AppColors.themeColor,
                              child: Text(
                                avatarLetter,
                                style: const TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),

                            const SizedBox(height: 20),

                            const Text(
                              AppStrings.completeProfile,
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 5),

                            const Text(
                              AppStrings.completeProfileSubtitle,
                              style: TextStyle(color: Colors.grey),
                            ),

                            const SizedBox(height: 30),

                            /// CARD
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),

                              child: Container(
                                padding: const EdgeInsets.all(20),

                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25),
                                ),

                                child: Column(
                                  children: [

                                    /// FIRST NAME
                                    TextFormField(
                                      controller: controller.firstNameController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return AppStrings.firstNameRequired;
                                        }
                                        return null;
                                      },
                                      decoration: AppInputDecoration.build(
                                        hint: AppStrings.hintFirstName,
                                        label: AppStrings.firstName,
                                        icon: Icons.person_outline,
                                      ),
                                    ),

                                    const SizedBox(height: 15),

                                    /// LAST NAME
                                    TextFormField(
                                      controller: controller.lastNameController,
                                      validator: (value) {
                                        if (value == null || value.isEmpty) {
                                          return AppStrings.lastNameRequired;
                                        }
                                        return null;
                                      },
                                      decoration: AppInputDecoration.build(
                                        hint: AppStrings.hintLastName,
                                        label: AppStrings.lastName,
                                        icon: Icons.person_outline,
                                      ),
                                    ),

                                    const SizedBox(height: 15),

                                    /// DOB
                                    TextFormField(
                                      controller: controller.dobController,
                                      readOnly: true,
                                      onTap: () => controller.pickDOB(context),
                                      decoration: AppInputDecoration.build(
                                        hint: AppStrings.selectDate,
                                        label: AppStrings.dateOfBirth,
                                        icon: Icons.calendar_today,
                                      ),
                                    ),

                                    const SizedBox(height: 15),

                                    /// GENDER
                                    Obx(() => DropdownButtonFormField<String>(

                                      value: controller.gender.value.isEmpty
                                          ? null
                                          : controller.gender.value,

                                      validator: (value) =>
                                      value == null
                                          ? AppStrings.genderRequired
                                          : null,

                                      items: const [

                                        DropdownMenuItem(
                                          value: AppStrings.male,
                                          child: Text(AppStrings.male),
                                        ),

                                        DropdownMenuItem(
                                          value: AppStrings.female,
                                          child: Text(AppStrings.female),
                                        ),

                                        DropdownMenuItem(
                                          value: AppStrings.other,
                                          child: Text(AppStrings.other),
                                        ),

                                      ],

                                      onChanged: (value) {
                                        controller.gender.value = value!;
                                      },

                                      decoration: AppInputDecoration.build(
                                        hint: AppStrings.selectGender,
                                        label: "",
                                        icon: Icons.people_outline,
                                      ),
                                    )),

                                    const SizedBox(height: 25),

                                    /// SAVE BUTTON
                                    SizedBox(
                                      width: double.infinity,
                                      height: 55,

                                      child: ElevatedButton(

                                        onPressed: controller.isLoading.value
                                            ? null
                                            : () {
                                          controller.saveProfile(
                                              formKey);
                                        },

                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                          AppColors.themeColor,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(18),
                                          ),
                                        ),

                                        child: Obx(() => controller.isLoading.value
                                            ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                            : const Text(
                                          AppStrings.save,
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    )),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 40),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}