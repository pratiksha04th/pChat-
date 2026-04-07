import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pchat/utilities/App_Colors/App_Colors.dart';
import '../../../utilities/App_Strings/app_strings.dart';
import '../../PostScreen/controller/post_controller.dart';

class PostInteractionSheet extends StatefulWidget {
  final String postId;
  final int initialIndex;

  const PostInteractionSheet({
    super.key,
    required this.postId,
    this.initialIndex = 0,
  });

  @override
  State<PostInteractionSheet> createState() => _PostInteractionSheetState();
}

class _PostInteractionSheetState extends State<PostInteractionSheet>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController commentCtrl = TextEditingController();
  final PostController controller = Get.find<PostController>();

  @override
  void initState() {
    super.initState();

    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialIndex,
    );

    _loadData(_tabController.index);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    commentCtrl.dispose();
    super.dispose();
  }

  void _loadData(int index) {
    if (index == 0) {
      controller.listenLikes(widget.postId);
    } else if (index == 1) {
      controller.fetchComments(widget.postId);
    } else if (index == 2) {
      controller.listenReshares(widget.postId);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        height: Get.height * 0.78,
        padding: const EdgeInsets.all(14),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          children: [
            /// DRAG HANDLE
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(10),
              ),
            ),

            /// TAB BAR
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.6),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicator: BoxDecoration(
                    color: AppColors.themeColor,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  indicatorAnimation: TabIndicatorAnimation.elastic,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.black54,
                  labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                  tabs: const [
                    Tab(text: AppStrings.likes),
                    Tab(text: AppStrings.comments),
                    Tab(text: AppStrings.reshares),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// CONTENT
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildLikes(), _buildComments(), _buildReshares()],
              ),
            ),

            ///ONLY SHOW ON COMMENTS TAB
            if (_tabController.index == 1) _buildCommentInput(),
          ],
        ),
      ),
    );
  }

  /// LIKES
  Widget _buildLikes() {
    return Obx(() {
      final isLoading = controller.loadingMap[widget.postId] ?? false;
      final list = controller.likesMap[widget.postId] ?? [];

      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// GRADIENT ICON
              ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: [
                      AppColors.themeColor,
                      AppColors.themeColor.withOpacity(0.4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcIn,
                child: const Icon(
                  Icons.favorite_border,
                  size: 50,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                AppStrings.noLikes,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.themeColor,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context, index) {
          return _buildUserTile(list[index]);
        },
      );
    });
  }

  /// RESHARES
  Widget _buildReshares() {
    return Obx(() {
      final list = controller.reshareUsersMap[widget.postId] ?? [];


      if (list.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// GRADIENT ICON
              ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: [
                      AppColors.themeColor,
                      AppColors.themeColor.withOpacity(0.4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcIn,
                child: const Icon(
                  Icons.repeat,
                  size: 50,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                AppStrings.noReshares,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.themeColor,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: list.length,
        itemBuilder: (context,index){
          return _buildUserTile(list[index]);
        },
      );
    });
  }

  /// COMMENTS
  Widget _buildComments() {
    return Obx(() {
      final isLoading = controller.loadingMap[widget.postId] ?? false;
      final comments = controller.commentsMap[widget.postId] ?? [];

      if (isLoading) {
        return const Center(child: CircularProgressIndicator());
      }

      if (comments.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// GRADIENT ICON
              ShaderMask(
                shaderCallback: (bounds) {
                  return LinearGradient(
                    colors: [
                      AppColors.themeColor,
                      AppColors.themeColor.withOpacity(0.4),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ).createShader(bounds);
                },
                blendMode: BlendMode.srcIn,
                child: const Icon(
                  Icons.chat_bubble_outline,
                  size: 50,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 14),

              Text(
                AppStrings.noComments,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.themeColor,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(top: 6),
        itemCount: comments.length,
        itemBuilder: (context, index) {
          return _buildUserTile(comments[index], isComment: true);
        },
      );
    });
  }

  /// COMMON TILE
  Widget _buildUserTile(Map data, {bool isComment = false}) {
    final username = data['username'] ?? '';
    final text = data['text'] ?? '';

    final commentUserId = data['uid'];
    final currentUid = controller.uid;

    Map<String, dynamic>? post;

    try {
      post = controller.myFeed.firstWhere((e) => e['postId'] == widget.postId);
    } catch (e) {
      post = null;
    }
    final postOwnerId = post?['userId'];
    final canDelete =
        isComment &&
        (currentUid == commentUserId ||
            (postOwnerId != null && currentUid == postOwnerId));

    final canEdit = isComment && currentUid == commentUserId;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppColors.lightAvatarGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppColors.lightAvatarGradient,
              border: Border.all(color: AppColors.themeColor, width: 1),
            ),
            child: CircleAvatar(
              radius: 22,
              backgroundColor: Colors.transparent,
              child: Text(
                username.isNotEmpty ? username[0].toUpperCase() : "?",
                style: TextStyle(
                  color: AppColors.themeColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (data['text'] != null)
                  Text(
                    data['text'],
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                    ),
                  ),
                Text(
                  username,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),

                /// edit label
                if (canEdit)
                  GestureDetector(
                    onTap: () {
                      _showEditDialog(
                        context,
                        initialText: text,
                        onSave: (newText) async {
                          await controller.editComment(
                            postId: widget.postId,
                            commentId: data['commentId'],
                            newText: newText,
                          );
                          await controller.fetchComments(widget.postId);
                        },
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text(
                        AppStrings.edit,
                        style: TextStyle(color: Colors.blue, fontSize: 12),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          /// delete icon
          if (canDelete)
            Builder(
              builder: (context) {
                return IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeletePopupMenu(
                      context,
                      postId: widget.postId,
                      commentId: data['commentId'],
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  /// confirmation to delete comment
  void _showDeletePopupMenu(
      BuildContext context, {
        required String postId,
        required String commentId,
      }) async {

    final RenderBox overlay =
    Overlay.of(context).context.findRenderObject() as RenderBox;

    final result = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        overlay.size.width, // right side
        overlay.size.height / 2,
        0,
        0,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      items: [

        /// TITLE (NON-CLICKABLE)
        const PopupMenuItem(
          enabled: false,
          child: Text(
            AppStrings.deleteComment,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        /// DELETE
        const PopupMenuItem(
          value: AppStrings.delete,
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red, size: 18),
              SizedBox(width: 10),
              Text(AppStrings.delete, style: TextStyle(color: Colors.red)),
            ],
          ),
        ),

        /// CANCEL
        const PopupMenuItem(
          value: "cancel",
          child: Row(
            children: [
              Icon(Icons.close, size: 18),
              SizedBox(width: 10),
              Text("Cancel"),
            ],
          ),
        ),
      ],
    );

    /// HANDLE RESULT
    if (result == "delete") {
      await controller.deleteComment(
        postId: postId,
        commentId: commentId,
      );

      await controller.fetchComments(postId);
    }
  }
  /// COMMENT INPUT
  Widget _buildCommentInput() {
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.themeColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: commentCtrl,
              maxLines: null,
              style: const TextStyle(fontSize: 16, height: 1.4),
              decoration: const InputDecoration(
                hintText: AppStrings.writeComment,
                border: InputBorder.none,
              ),
            ),
          ),

          IconButton(
            icon: ShaderMask(
              blendMode: BlendMode.srcIn,
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Colors.blue.withOpacity(0.9),
                  Colors.blue.withOpacity(0.2),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ).createShader(bounds),
              child: Icon(Icons.send, size: 30),
            ),

            onPressed: () async {
              final text = commentCtrl.text.trim();
              if (text.isEmpty) return;

              await controller.addComment(postId: widget.postId, text: text);
              await controller.fetchComments(widget.postId);

              commentCtrl.clear();
            },
          ),
        ],
      ),
    );
  }

  void _showEditDialog(
    BuildContext context, {
    required String initialText,
    required Function(String) onSave,
  }) {
    final textCtrl = TextEditingController(text: initialText);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppStrings.editComment),
        content: TextField(controller: textCtrl),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () {
              onSave(textCtrl.text.trim());
              Get.back();
            },
            child: const Text(AppStrings.save),
          ),
        ],
      ),
    );
  }
}
