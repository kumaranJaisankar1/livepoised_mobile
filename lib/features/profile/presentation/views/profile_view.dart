import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../core/utils/image_utils.dart';
import '../../../auth/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../../data/models/profile_models.dart';
import 'package:intl/intl.dart';
import 'dart:convert';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingShimmer(context);
        }

        final profile = controller.profileData.value;
        if (profile == null) {
          return const Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(strokeWidth: 2.5),
                SizedBox(width: 12),
                Text("loading profile..."),
              ],
            ),
          );
        }

        final theme = Theme.of(context);
        return DefaultTabController(
          length: 4,
          child: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                _buildSliverAppBar(context, profile),
                SliverToBoxAdapter(
                  child: _buildStatsGrid(context, profile),
                ),
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
                          isScrollable: true,
                          onTap: (index) => controller.loadTabData(index),
                          indicatorSize: TabBarIndicatorSize.tab,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(25),
                            color: theme.colorScheme.primary.withOpacity(0.1),
                          ),
                          labelColor: theme.colorScheme.primary,
                          unselectedLabelColor: Colors.grey,
                          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 13),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          tabs: const [
                            Tab(text: "Overview"),
                            Tab(text: "Recovery Story"),
                            Tab(text: "Contributions"),
                            Tab(text: "Chat History"),
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
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildSelectedTabContent(context, profile),
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLoadingShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final theme = Theme.of(context);
    
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(height: 480, color: Colors.white),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: GridView.count(
                shrinkWrap: true,
                crossAxisCount: 2,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                childAspectRatio: 2.2,
                children: List.generate(4, (index) => Container(decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)))),
              ),
            ),
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(height: 200, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24))),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ProfileResponse profile) {
    final user = profile.userProfile;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SliverAppBar(
      expandedHeight: 480,
      pinned: true,
      stretch: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      elevation: 0,
      actions: [
        IconButton(
          onPressed: () => Get.toNamed('/edit-profile'),
          icon: const Icon(Icons.edit_outlined),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surface.withOpacity(0.2),
          ),
          tooltip: 'Edit Profile',
        ),
        IconButton(
          onPressed: () => Get.toNamed('/settings'),
          icon: const Icon(Icons.settings_outlined),
          style: IconButton.styleFrom(
            backgroundColor: theme.colorScheme.surface.withOpacity(0.2),
          ),
          tooltip: 'Settings',
        ),
        const SizedBox(width: 8),
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
                    theme.colorScheme.primary.withAlpha(200),
                    theme.colorScheme.secondary.withAlpha(150),
                    theme.colorScheme.surface,
                  ],
                  stops: const [0.0, 0.3, 0.6, 1.0],
                ),
              ),
            ),
            // Subtle Pattern Overlay (Optional, using Opacity for now)
            Positioned.fill(
              child: Opacity(
                opacity: 0.05,
                child: Image.asset(
                  'assets/images/logo.png', // Reusing logo as a subtle pattern
                  repeat: ImageRepeat.repeat,
                  scale: 10,
                ),
              ),
            ),
            // Bottom Surface Fade
            Positioned(
              bottom: -1,
              left: 0,
              right: 0,
              child: Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      theme.colorScheme.surface.withOpacity(0),
                      theme.colorScheme.surface,
                    ],
                  ),
                ),
              ),
            ),
            // Content
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Obx(() => Hero(
                  tag: 'profile_avatar_${user.username}',
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Glow/Outer Ring
                      Container(
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
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Material(
                          elevation: 4,
                          shape: const CircleBorder(),
                          child: CircleAvatar(
                            backgroundColor: theme.colorScheme.primary,
                            radius: 20,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                              onPressed: () => controller.pickAndUploadImage(),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
                const SizedBox(height: 16),
                Text(
                  "${user.firstName} ${user.lastName}",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "@${user.username}",
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,fontSize: 12,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [theme.colorScheme.primary, theme.colorScheme.secondary],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: theme.colorScheme.primary.withOpacity(0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        "Active Since ${profile.loginDetails?.createdAt != null ? DateTime.parse(profile.loginDetails!.createdAt!).year : 2024}",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      profile.personalDetails?.injuryType ?? '',
                      style: theme.textTheme.titleSmall?.copyWith(
                        color: theme.colorScheme.secondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (user.caregivers.isNotEmpty)
                  _buildCaregiversSection(context, user.caregivers),
                const SizedBox(height: 16),
                _buildContactChips(context, profile),
                const SizedBox(height: 24),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCaregiversSection(BuildContext context, List<Caregiver> caregivers) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(
          "SUPPORTERS",
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
            color: theme.colorScheme.primary.withOpacity(0.7),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 70,
          child: ListView.builder(
            shrinkWrap: true,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: caregivers.length,
            itemBuilder: (context, index) {
              final cg = caregivers[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Column(
                  children: [
                    Text(
                      "${cg.firstName}(${cg.relationship.toLowerCase()})",
                      style: theme.textTheme.labelSmall?.copyWith(fontSize: 10),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildContactChips(BuildContext context, ProfileResponse profile) {
    final addr = profile.address;
    final chips = [
      "${addr?.city ?? ''}, ${addr?.country ?? ''}",
      "Joined ${DateFormat('MMM yyyy').format(DateTime.now())}", // Placeholder for join date
      profile.userProfile.email,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: chips.map((text) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Chip(
            label: Text(text, style: const TextStyle(fontSize: 11)),
            side: BorderSide.none,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        )).toList(),
      ),
    );
  }

  Widget _buildSelectedTabContent(BuildContext context, ProfileResponse profile) {
    switch (controller.activeTab.value) {
      case 0: return _buildOverviewTab(context, profile);
      case 1: return _buildRecoveryStoryTab(context, profile.personalDetails);
      case 2: return _buildContributionsTab(context);
      case 3: return _buildChatHistoryTab(context);
      default: return const SizedBox.shrink();
    }
  }

  Widget _buildStatsGrid(BuildContext context, ProfileResponse profile) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
        children: [
          _buildStatCard(context, "Active Ally's", controller.connectionsCount.value.toString(), Colors.teal),
          _buildStatCard(context, "Forum Posts", profile.forumPostsCount.toString(), Colors.blue),
          _buildStatCard(context, "Helpful Responses", profile.helpfulResponsesCount.toString(), Colors.green),
          _buildStatCard(context, "Journey", "${profile.personalDetails?.yearsSinceRecovery ?? 0}" , Colors.amber, icon: Icons.person_pin_circle_outlined),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, Color color, {IconData? icon}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return Container(
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative background circle
            Positioned(
              right: -10,
              top: -10,
              child: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.4),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      if (icon != null) 
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(icon, size: 14, color: color),
                        ),
                      if (icon != null) const SizedBox(width: 8),
                      Text(
                        value,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w900,
                          color: isDark ? Colors.white : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label.toUpperCase(),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.hintColor,
                      fontSize: 9,
                      letterSpacing: 0.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewTab(BuildContext context, ProfileResponse profile) {
    final details = profile.personalDetails;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SingleChildScrollView(
      key: const PageStorageKey('overview'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardSection(
            context,
            title: "BIO",
            icon: Icons.person_outline,
            child: Text(
              profile.userProfile.aboutMe ?? "No bio added yet.",
              style: theme.textTheme.bodyLarge?.copyWith(height: 1.6, color: theme.colorScheme.onSurface.withOpacity(0.8)),
            ),
          ),
          const SizedBox(height: 20),
          _buildCardSection(
            context,
            title: "INJURY DETAILS",
            icon: Icons.medical_services_outlined,
            child: Column(
              children: [
                _buildDetailRow(context, "Type", details?.injuryType ?? 'N/A'),
                _buildDetailRow(context, "Duration", "${details?.yearsSinceInjury ?? 0} years since injury"),
                _buildDetailRow(context, "Recovery Stage", details?.stageOfRecovery ?? 'N/A'),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _buildCardSection(
            context,
            title: "RECENT ACHIEVEMENTS",
            icon: Icons.workspace_premium_outlined,
            child: details?.achievements.isEmpty ?? true
                ? const Text("No achievements yet.")
                : Column(
                    children: details!.achievements.map((a) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.amber.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                      ),
                      title: Text(a.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text(a.month),
                    )).toList(),
                  ),
          ),
          const SizedBox(height: 32),
          Center(
            child: TextButton.icon(
              onPressed: () => Get.find<AuthController>().logout(),
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text(
                "Sign Out",
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                backgroundColor: Colors.redAccent.withOpacity(0.05),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCardSection(BuildContext context, {required String title, required IconData icon, required Widget child}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? theme.colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
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
              Icon(icon, size: 18, color: theme.colorScheme.primary),
              const SizedBox(width: 10),
              Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _buildRecoveryStoryTab(BuildContext context, PersonalDetails? details) {
    return SingleChildScrollView(
      key: const PageStorageKey('story'),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCardSection(
            context,
            title: "PERSONAL STORY",
            icon: Icons.history_edu,
            child: Text(details?.personalStory ?? "No story shared yet.", style: const TextStyle(height: 1.6)),
          ),
          const SizedBox(height: 24),
          _buildCardSection(
            context,
            title: "RECOVERY MILESTONES",
            icon: Icons.auto_graph,
            child: (details?.recoveryMilestones.isEmpty ?? true)
                ? const Text("No milestones recorded.")
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: details!.recoveryMilestones.length,
                    itemBuilder: (context, index) {
                      final m = details.recoveryMilestones[index];
                      final isLast = index == details.recoveryMilestones.length - 1;
                      return IntrinsicHeight(
                        child: Row(
                          children: [
                            Column(
                              children: [
                                Container(
                                  width: 14,
                                  height: 14,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Theme.of(context).colorScheme.primary,
                                    border: Border.all(color: Colors.white, width: 2),
                                    boxShadow: [
                                      BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.3), blurRadius: 4),
                                    ],
                                  ),
                                ),
                                if (!isLast)
                                  Expanded(
                                    child: Container(
                                      width: 2,
                                      margin: const EdgeInsets.symmetric(vertical: 4),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(1),
                                        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                                      ),
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
                                      m.date,
                                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      m.title,
                                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildContributionsTab(BuildContext context) {
    final theme = Theme.of(context);
    if (controller.isContributionsLoading.value) {
      return _buildTabLoadingShimmer(context);
    }
    if (controller.forumContributions.isEmpty) {
      return const Center(child: Text("No contributions yet"));
    }
    return ListView.builder(
      key: const PageStorageKey('contributions'),
      padding: const EdgeInsets.all(20),
      itemCount: controller.forumContributions.length,
      itemBuilder: (context, index) {
        final post = controller.forumContributions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            title: Text(post.title, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                "${post.type.capitalizeFirst} • ${post.timeAgo}",
                style: TextStyle(fontSize: 12, color: theme.hintColor),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.thumb_up_rounded, size: 12, color: theme.colorScheme.primary),
                  const SizedBox(width: 4),
                  Text(post.likes.toString(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: theme.colorScheme.primary)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildChatHistoryTab(BuildContext context) {
    final theme = Theme.of(context);
    if (controller.isSessionsLoading.value) {
      return _buildTabLoadingShimmer(context);
    }
    if (controller.chatSessions.isEmpty) {
      return const Center(child: Text("No chat history available"));
    }
    return ListView.builder(
      key: const PageStorageKey('chat'),
      padding: const EdgeInsets.all(20),
      itemCount: controller.chatSessions.length,
      itemBuilder: (context, index) {
        final session = controller.chatSessions[index];
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: theme.dividerColor.withOpacity(0.05)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
              child: Text(
                session.mentee[0].toUpperCase(),
                style: TextStyle(color: theme.colorScheme.primary, fontWeight: FontWeight.bold),
              ),
            ),
            title: Text(session.mentee, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              "${session.topic} • ${session.duration}",
              style: TextStyle(fontSize: 12, color: theme.hintColor),
            ),
            trailing: Text(
              session.lastActive,
              style: TextStyle(fontSize: 10, color: theme.hintColor),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabLoadingShimmer(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Shimmer.fromColors(
      baseColor: isDark ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDark ? Colors.grey[700]! : Colors.grey[100]!,
      child: ListView.builder(
        itemCount: 5,
        itemBuilder: (_, __) => ListTile(
          leading: const CircleAvatar(),
          title: Container(height: 15, color: Colors.white),
          subtitle: Container(height: 10, color: Colors.white, margin: const EdgeInsets.only(top: 5)),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: theme.textTheme.bodyMedium?.copyWith(color: theme.hintColor)),
          Text(value, style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this.widget);

  final PreferredSizeWidget widget;

  @override
  double get minExtent => widget.preferredSize.height;
  @override
  double get maxExtent => widget.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return widget;
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
