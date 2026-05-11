import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/utils/image_utils.dart';
import '../controllers/user_profile_controller.dart';
import '../../data/models/profile_models.dart';
import 'package:intl/intl.dart';

class UserProfileView extends StatelessWidget {
  const UserProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Extract username from arguments or parameters
    final String username = Get.parameters['username'] ?? Get.arguments ?? '';
    
    // Initialize controller for this specific user
    final controller = Get.put(UserProfileController(username: username), tag: username);

    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingShimmer(context);
        }

        final profile = controller.profileData.value;
        if (profile == null) {
          return _buildErrorState(context, controller);
        }

        final theme = Theme.of(context);
        return DefaultTabController(
          length: 2,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildSliverAppBar(context, controller, profile),
                SliverPersistentHeader(
                  pinned: true,
                  delegate: _SliverAppBarDelegate(
                    PreferredSize(
                      preferredSize: const Size.fromHeight(60),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surface,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: TabBar(
                          onTap: (index) => controller.changeTab(index),
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: theme.colorScheme.primary.withOpacity(0.1),
                          ),
                          labelColor: theme.colorScheme.primary,
                          unselectedLabelColor: Colors.grey,
                          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 14),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          tabs: const [
                            Tab(text: "Overview"),
                            Tab(text: "Journey"),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ];
            },
            body: SafeArea(
              top: false,
              bottom: false,
              child: TabBarView(
                children: [
                  _buildOverviewTab(context, profile),
                  _buildJourneyTab(context, profile.personalDetails),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, UserProfileController controller, ProfileResponse profile) {
    final user = profile.userProfile;
    final theme = Theme.of(context);
    
    return SliverAppBar(
      expandedHeight: 450,
      pinned: true,
      stretch: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 20),
        onPressed: () => Get.back(),
        style: IconButton.styleFrom(
          backgroundColor: Colors.black.withOpacity(0.2),
          foregroundColor: Colors.white,
        ),
      ),
      actions: [
        if (controller.username != controller.currentUsername)
          IconButton(
            onPressed: () {
              // Logic to start chat or share profile
            },
            icon: const Icon(Icons.chat_bubble_outline),
            style: IconButton.styleFrom(
              backgroundColor: Colors.black.withOpacity(0.2),
              foregroundColor: Colors.white,
            ),
          ),
        const SizedBox(width: 16),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
        ],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Premium Gradient Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    theme.colorScheme.primary,
                    theme.colorScheme.secondary.withOpacity(0.8),
                    theme.colorScheme.surface,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
            ),
            // Content
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Hero(
                  tag: 'profile_avatar_${user.username}',
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.5),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: 70,
                      backgroundColor: theme.colorScheme.surface,
                      child: CircleAvatar(
                        radius: 66,
                        backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                        backgroundImage: ImageUtils.getImageProvider(controller.userImage.value),
                        child: controller.userImage.value.isEmpty
                            ? Text(
                                "${user.firstName[0]}${user.lastName[0]}".toUpperCase(),
                                style: theme.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : null,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "${user.firstName} ${user.lastName}",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  "@${user.username}",
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildStatMini(context, "Posts", profile.forumPostsCount.toString()),
                    const SizedBox(width: 24),
                    _buildStatMini(context, "Helpful", profile.helpfulResponsesCount.toString()),
                  ],
                ),
                const SizedBox(height: 24),
                if (controller.username != controller.currentUsername)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Add Ally Logic
                      },
                      icon: const Icon(Icons.person_add_outlined),
                      label: const Text("Add Ally"),
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 8,
                        shadowColor: theme.colorScheme.primary.withOpacity(0.4),
                      ),
                    ),
                  ),
                const SizedBox(height: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatMini(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Text(
          label.toUpperCase(),
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurface.withOpacity(0.5),
            letterSpacing: 1.0,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildOverviewTab(BuildContext context, ProfileResponse profile) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            context,
            title: "About",
            icon: Icons.person_outline,
            content: profile.userProfile.aboutMe ?? "No bio available.",
          ),
          const SizedBox(height: 16),
          _buildInfoCard(
            context,
            title: "Injury Details",
            icon: Icons.medical_services_outlined,
            child: Column(
              children: [
                _buildDetailRow(context, "Type", profile.personalDetails?.injuryType ?? "N/A"),
                _buildDetailRow(context, "Years", "${profile.personalDetails?.yearsSinceInjury ?? 0} Years"),
                _buildDetailRow(context, "Stage", profile.personalDetails?.stageOfRecovery ?? "N/A"),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (profile.userProfile.caregivers.isNotEmpty)
            _buildInfoCard(
              context,
              title: "Support Network",
              icon: Icons.group_outlined,
              child: SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: profile.userProfile.caregivers.length,
                  itemBuilder: (context, index) {
                    final cg = profile.userProfile.caregivers[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        children: [
                          CircleAvatar(
                            radius: 25,
                            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                            backgroundImage: cg.profileImage != null ? ImageUtils.getImageProvider(cg.profileImage!) : null,
                            child: cg.profileImage == null ? Icon(Icons.person, color: theme.colorScheme.primary) : null,
                          ),
                          const SizedBox(height: 4),
                          Text(cg.firstName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                          Text(cg.relationship, style: TextStyle(fontSize: 10, color: theme.hintColor)),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildJourneyTab(BuildContext context, PersonalDetails? details) {
    if (details == null) return const Center(child: Text("No journey data available"));
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoCard(
            context,
            title: "Personal Story",
            icon: Icons.history_edu_outlined,
            content: details.personalStory ?? "No story shared yet.",
          ),
          const SizedBox(height: 24),
          Text(
            "RECOVERY MILESTONES",
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          const SizedBox(height: 16),
          if (details.recoveryMilestones.isEmpty)
            const Text("No milestones recorded.")
          else
            ...details.recoveryMilestones.map((m) => _buildTimelineTile(context, m)),
        ],
      ),
    );
  }

  Widget _buildTimelineTile(BuildContext context, RecoveryMilestone milestone) {
    final theme = Theme.of(context);
    return IntrinsicHeight(
      child: Row(
        children: [
          Column(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.primary,
                  border: Border.all(color: Colors.white, width: 2),
                ),
              ),
              Expanded(
                child: Container(
                  width: 2,
                  color: theme.colorScheme.primary.withOpacity(0.2),
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    milestone.date,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.secondary,
                    ),
                  ),
                  Text(
                    milestone.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, {required String title, required IconData icon, String? content, Widget? child}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: theme.colorScheme.primary),
              const SizedBox(width: 12),
              Text(
                title.toUpperCase(),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (content != null)
            Text(
              content,
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.6),
            ),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Theme.of(context).hintColor)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, UserProfileController controller) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.grey),
          const SizedBox(height: 16),
          const Text("Couldn't load profile"),
          ElevatedButton(
            onPressed: () => controller.fetchUserProfile(),
            child: const Text("Retry"),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 450, color: Colors.white),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: List.generate(3, (index) => Container(
                  height: 150,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._preferredSize);
  final PreferredSize _preferredSize;

  @override
  double get minExtent => _preferredSize.preferredSize.height;
  @override
  double get maxExtent => _preferredSize.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return _preferredSize;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}
