import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pchat/Feature/Home/widget/post_interaction_sheet.dart';
import 'package:pchat/utilities/App_Strings/app_strings.dart';

import '../../../utilities/App_Colors/App_Colors.dart';
import '../../Animation/reactionAnimation/function/show_floation_reaction.dart';
import '../../PostScreen/controller/post_controller.dart';

final Set<String> _showPostIds = {};

class PostCard extends StatefulWidget {
  final Map<String, dynamic> postData;

  const PostCard({super.key, required this.postData});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard>
    with SingleTickerProviderStateMixin {
  late bool isNewPost;
  late AnimationController _controller;
  late Animation<double> fade;
  late Animation<Offset> slide;
  late Animation<double> scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    fade = Tween(begin: 0.0, end: 1.0).animate(_controller);

    slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    scale = Tween(
      begin: 0.95,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    /// DETECT NEW POST


    final id = widget.postData['postId'];

    isNewPost = !_showPostIds.contains(id);
    _showPostIds.add(id);

    if (isNewPost) {
      _controller.forward();
    } else {
      _controller.value = 1;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  String _formatTime(int timestamp) {
    final diff = DateTime.now().difference(
      DateTime.fromMillisecondsSinceEpoch(timestamp),
    );

    if (diff.inMinutes < 1) return AppStrings.justNow;
    if (diff.inMinutes < 60) return "${diff.inMinutes}${AppStrings.minutesAgo}";
    if (diff.inHours < 24) return "${diff.inHours}${AppStrings.hoursAgo}";
    return "${diff.inDays}${AppStrings.daysAgo}";
  }

  /// ... icon functionality

  void _showPostOptions(
    BuildContext context, {
    required TapDownDetails details,
    required String postId,
    required bool isOwner,
    required String text,
  }) async {

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        details.globalPosition.dx,
        details.globalPosition.dy,
        details.globalPosition.dx,
        details.globalPosition.dy,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      color: Colors.white.withOpacity(0.95),
      elevation: 10,
      items: [
        /// OWNER OPTIONS
        if (isOwner) ...[
          PopupMenuItem(
            value: "edit",
            child: Row(
              children: const [
                Icon(Icons.edit, color: Colors.blue, size: 20),
                SizedBox(width: 10),
                Text(AppStrings.editPost),
              ],
            ),
          ),
          PopupMenuItem(
            value: "delete",
            child: Row(
              children: const [
                Icon(Icons.delete, color: Colors.red, size: 20),
                SizedBox(width: 10),
                Text(AppStrings.deletePost),
              ],
            ),
          ),
        ],

        /// OTHER USERS
        if (!isOwner)
          PopupMenuItem(
            value: "report",
            child: Row(
              children: const [
                Icon(Icons.report_gmailerrorred_outlined, color: Colors.red, size: 20),
                SizedBox(width: 10),
                Text(AppStrings.reportPost),
              ],
            ),
          ),
      ],
    );

    /// HANDLE ACTIONS
    switch (selected) {
      case "edit":
        _showEditPostDialog(postId, text);
        break;

      case "delete":
        _confirmDelete(postId);
        break;

      case "report":
        Get.snackbar("Reported", AppStrings.reportedSuccess);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: slide,
        child: ScaleTransition(scale: scale, child: _buildContent()),
      ),
    );
  }

  Widget _buildContent() {
    final controller = Get.find<PostController>();
    final currentUid = controller.uid;

    final postData = widget.postData;

    /// detect type
    final postId = postData['postId'];

    final isResharePost = postData['originalPostId'] != null;

    final originalData = postData['originalData'] is Map
        ? Map<String, dynamic>.from(postData['originalData'])
        : null;

    final originalUsername =
        originalData?['username']?.toString() ?? '';

    final originalText =
        originalData?['text']?.toString() ?? '';

    final username = postData['username']?.toString() ?? '';
    final text = postData['text']?.toString() ?? '';
    final createdAt = postData['createdAt'] ?? 0;

    final commentsMap = postData['comments'] is Map
        ? Map<String, dynamic>.from(postData['comments'])
        : {};
    final commentCount = commentsMap.length;

    final isLiked = controller.likesMap[postId]
        ?.any((e) => e['uid'] == currentUid) ??
        false;

    final isResharedByMe = controller.hasUserReshared(postId);

    return GestureDetector(
      behavior: HitTestBehavior.translucent,

      onDoubleTapDown: (details) {
        if (!isLiked) {
          showFloatingReaction(
            context: context,
            position: details.globalPosition,
            child: const Icon(Icons.favorite, color: Colors.red, size: 30),
            count: 10,
          );
        }
      },
      onDoubleTap: () {
        controller.toggleLike(postId);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.95),
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: isNewPost ? Colors.blue.withOpacity(0.3) : Colors.black12,
              blurRadius: isNewPost ? 20 : 8,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// RESHARE LABEL
            if (isResharePost)
              const Padding(
                padding: EdgeInsets.only(bottom: 6),
                child: Text(
                  AppStrings.resharedPost,
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            if (postData['editedAt'] != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: const Text(
                  AppStrings.edited,
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),

            /// HEADER
            Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppColors.darkAvatarGradient,
                  ),
                  child: CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.transparent,
                    child: Text(
                      username.isNotEmpty ? username[0].toUpperCase() : "?",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      _formatTime(createdAt),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),

                const Spacer(),
                GestureDetector(
                  onTapDown: (details) {
                    _showPostOptions(
                      context,
                      details: details,
                      postId: postId,
                      isOwner: postData['userId'] == currentUid,
                      text: text,
                    );
                  },
                  child: const Icon(Icons.more_horiz),
                ),
              ],
            ),

            const SizedBox(height: 10),

            /// TEXT
            Text(text, style: const TextStyle(fontSize: 15)),

            const SizedBox(height: 12),

            /// ACTIONS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                /// LIKE
                GestureDetector(
                  onTapDown: (details) {
                    /// floating hearts ONLY when liking (not unliking)
                    if (!isLiked) {
                      showFloatingReaction(
                        context: context,
                        position: details.globalPosition,
                        child: const Icon(Icons.favorite, color: Colors.red),
                      );
                    }
                  },

                  onTap: () {
                    controller.toggleLike(postId);
                  },

                  child: Row(
                    children: [
                      Obx(() {
                        final isLiked = controller.likesMap[postId]
                            ?.any((e) => e['uid'] == currentUid) ??
                            false;

                        return Icon(
                          isLiked ? Icons.favorite : Icons.favorite_border,
                          color: isLiked ? Colors.red : Colors.grey,
                          size: 20,
                        );
                      }),
                      const SizedBox(width: 5),
                      Obx(() {
                        final count = controller.likesMap[postId]?.length ?? 0;
                        return Text(count.toString());
                      }),
                    ],
                  ),
                ),

                /// COMMENT
                GestureDetector(
                  onTap: () {
                    Get.bottomSheet(
                      PostInteractionSheet(
                        postId: postId,
                        initialIndex: 1,
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      const Icon(
                        Icons.comment_outlined,
                        size: 20,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Text(commentCount.toString()),
                    ],
                  ),
                ),

                /// RESHARE
                GestureDetector(
                  onTap: () => controller.toggleReshare(postData),
                  child: Row(
                    children: [
                      Icon(
                        Icons.repeat,
                        color: isResharedByMe ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(width: 5),
                      Obx(() {
                        final count = controller.reshareCountMap[postId] ?? 0;
                        return Text(count.toString());
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showEditPostDialog(String postId, String oldText) {
    final textCtrl = TextEditingController(text: oldText);
    final controller = Get.find<PostController>();

    final RxInt charCount = oldText.length.obs;

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.97),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// HEADER (ICON + TITLE)
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: AppColors.lightAvatarGradient,
                    ),
                    child: Icon(Icons.edit, color: AppColors.themeColor),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    AppStrings.editPost,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// TEXT FIELD CARD
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.themeColor.withOpacity(0.2),
                  ),
                ),
                child: Column(
                  children: [

                    /// INPUT
                    TextField(
                      controller: textCtrl,
                      maxLines: null,
                      autofocus: true,
                      style: const TextStyle(fontSize: 16, height: 1.4),
                      onChanged: (val) => charCount.value = val.length,
                      decoration: InputDecoration(
                        hintText: AppStrings.whatsOnMind,
                        border: InputBorder.none,
                      ),
                    ),

                    /// CHARACTER COUNTER
                    Obx(() => Align(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        "${charCount.value}/500",
                        style: TextStyle(
                          fontSize: 11,
                          color: charCount.value > 480
                              ? Colors.red
                              : Colors.grey,
                        ),
                      ),
                    )),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              /// ACTION BUTTONS
              Row(
                children: [

                  /// CANCEL (subtle)
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.themeColor.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          AppStrings.cancel,
                          style: TextStyle(
                            color: AppColors.themeColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// SAVE
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        final newText = textCtrl.text.trim();
                        if (newText.isEmpty) return;

                        HapticFeedback.lightImpact();

                        await controller.editPost(
                          postId: postId,
                          newText: newText,
                        );

                        Get.back();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: AppColors.darkAvatarGradient,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          AppStrings.save,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(String postId) {
    final controller = Get.find<PostController>();

    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.97),
            borderRadius: BorderRadius.circular(26),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.2),
                blurRadius: 25,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// WARNING ICON
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.1),
                ),
                child: const Icon(
                  Icons.delete_forever,
                  color: Colors.red,
                  size: 30,
                ),
              ),

              const SizedBox(height: 14),

              /// TITLE
              const Text(
                AppStrings.deletePost,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              /// MESSAGE
              Text(
                AppStrings.deleteConfirm,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 20),

              /// ACTIONS
              Row(
                children: [

                  /// CANCEL
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: AppColors.themeColor.withOpacity(0.4),
                          ),
                        ),
                        child: Text(
                          AppStrings.cancel,
                          style: TextStyle(
                            color: AppColors.themeColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(width: 10),

                  /// DELETE BUTTON (DANGER)
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        HapticFeedback.mediumImpact(); // ⚡ strong feedback

                        await controller.deletePost(postId);
                        Get.back();

                        Get.snackbar(
                          AppStrings.success,
                           AppStrings.postDeletedSuccessfully
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFF4B4B), Color(0xFFFF0000)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Text(
                          AppStrings.deletePost,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
