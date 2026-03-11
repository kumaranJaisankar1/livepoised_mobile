import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';
import '../controllers/caregiver_controller.dart';
import 'package:intl/intl.dart';
import '../../data/models/profile_models.dart';
import 'dart:convert';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(CaregiverController());
    controller.initEditForm();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: ClipRect(
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface.withOpacity(0.8),
              ),
            ),
          ),
          title: Text(
            "Edit Profile", 
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5)
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ElevatedButton(
                onPressed: () => controller.saveProfile(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: const Text("Save", style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(60),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceVariant.withOpacity(0.5),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TabBar(
                isScrollable: true,
                indicatorSize: TabBarIndicatorSize.tab,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: theme.colorScheme.primary,
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                labelColor: Colors.white,
                unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                dividerColor: Colors.transparent,
                tabs: const [
                  Tab(text: "Personal"),
                  Tab(text: "Contact"),
                  Tab(text: "Health"),
                  Tab(text: "Supporters"),
                  Tab(text: "Mentorship"),
                ],
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            // Premium Background Gradient
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isDark 
                      ? [
                          theme.colorScheme.surface,
                          theme.colorScheme.surface.withBlue(20),
                        ]
                      : [
                          Colors.white,
                          const Color(0xFFF1F5F9), // Very light cool grey
                        ],
                  ),
                ),
              ),
            ),
            // Pattern Overlay
            Positioned.fill(
              child: Opacity(
                opacity: isDark ? 0.02 : 0.03, // Extra subtle
                child: Image.asset(
                  'assets/images/logo.png', 
                  repeat: ImageRepeat.repeat,
                  scale: 16, // Smaller pattern
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 130),
              child: const TabBarView(
                children: [
                  _PersonalTab(),
                  _ContactTab(),
                  _HealthTab(),
                  _SupportersTab(),
                  _MentorshipTab(),
                ],
              ),
            ),
            Obx(() => controller.isSaving.value
                ? Container(
                    color: Colors.black45,
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }
}

class _PersonalTab extends GetView<ProfileController> {
  const _PersonalTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTextField("Username", controller.usernameC, icon: Icons.person_outline, readOnly: true),
          const SizedBox(height: 12),
          _buildTextField("First Name", controller.firstNameC, icon: Icons.badge_outlined),
          const SizedBox(height: 12),
          _buildTextField("Middle Name", controller.middleNameC, icon: Icons.badge_outlined),
          const SizedBox(height: 12),
          _buildTextField("Last Name", controller.lastNameC, icon: Icons.badge_outlined),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTextField("Prefix", controller.prefixC, icon: Icons.text_fields)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField("Suffix", controller.suffixC, icon: Icons.text_fields)),
            ],
          ),
          const SizedBox(height: 12),
          _buildDropdown("Gender", controller.genderC, ["Male", "Female", "Other"], icon: Icons.wc_outlined),
          const SizedBox(height: 20),
          Obx(() => Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              leading: Icon(Icons.calendar_today_outlined, color: theme.colorScheme.primary),
              title: Text("Date of Birth", style: theme.textTheme.labelMedium?.copyWith(color: theme.colorScheme.primary.withOpacity(0.8), fontWeight: FontWeight.bold)),
              subtitle: Text(controller.dobC.value == null
                  ? "Not set"
                  : DateFormat('MMMM dd, yyyy').format(controller.dobC.value!),
                  style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500)),
              trailing: const Icon(Icons.edit_calendar_outlined, size: 20),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: controller.dobC.value ?? DateTime.now(),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(data: theme, child: child!);
                  }
                );
                if (picked != null) controller.dobC.value = picked;
              },
            ),
          )),
        ],
      ),
    );
  }
}

class _ContactTab extends GetView<ProfileController> {
  const _ContactTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTextField("Email", controller.emailC, icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 12),
          _buildTextField("Mobile Number", controller.mobileNumberC, icon: Icons.phone_android_outlined),
          const SizedBox(height: 12),
          _buildTextField("Secondary Phone 1", controller.phone1C, icon: Icons.phone_outlined),
          const SizedBox(height: 12),
          _buildTextField("Secondary Phone 2", controller.phone2C, icon: Icons.phone_outlined),
          const SizedBox(height: 32),
          Row(
            children: [
              Icon(Icons.home_outlined, size: 18, color: Get.theme.colorScheme.primary),
              const SizedBox(width: 8),
              Text("OFFICIAL ADDRESS", style: Get.theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: Get.theme.colorScheme.primary)),
            ],
          ),
          const Divider(height: 24),
          _buildTextField("Address Line 1", controller.addressLine1C, icon: Icons.location_on_outlined),
          const SizedBox(height: 12),
          _buildTextField("Address Line 2", controller.addressLine2C, icon: Icons.location_city_outlined),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildTextField("City", controller.cityC, icon: Icons.map_outlined)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField("State", controller.stateC, icon: Icons.explore_outlined)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField("Country", controller.countryC, icon: Icons.public)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField("Postal Code", controller.postalCodeC, icon: Icons.pin_drop_outlined)),
            ],
          ),
          const SizedBox(height: 120), // Bottom buffer
        ],
      ),
    );
  }
}

class _HealthTab extends GetView<ProfileController> {
  const _HealthTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField("About Me", controller.aboutMeC, icon: Icons.person_pin_outlined, maxLines: 3),
          const SizedBox(height: 12),
          _buildTextField("Injury Type", controller.injuryTypeC, icon: Icons.medical_information_outlined),
          const SizedBox(height: 12),
          _buildTextField("Injury Details", controller.injuryDetailsC, icon: Icons.description_outlined, maxLines: 3),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildNumberField("Years Since Injury", controller.yearsSinceInjuryC, icon: Icons.calendar_today_outlined)),
              const SizedBox(width: 16),
              Expanded(child: _buildNumberField("Years Since Recovery", controller.yearsSinceRecoveryC, icon: Icons.auto_graph_outlined)),
            ],
          ),
          const SizedBox(height: 12),
          _buildTextField("Personal Story", controller.personalStoryC, icon: Icons.history_edu_outlined, maxLines: 4),
          const SizedBox(height: 12),
          _buildTextField("Condition Details", controller.conditionDetailsC, icon: Icons.list_alt_outlined, maxLines: 3),
          const SizedBox(height: 12),
          _buildTextField("Stage of Recovery", controller.stageOfRecoveryC, icon: Icons.speed_outlined),
          const SizedBox(height: 24),
          
          _buildDynamicList(
            context,
            title: "Recovery Milestones",
            items: controller.recoveryMilestonesC,
            onAdd: () => _showMilestoneDialog(context),
            onRemove: (index) => controller.recoveryMilestonesC.removeAt(index),
            itemBuilder: (m) => Text("${m.title} (${m.date}) - ${m.type}"),
          ),
          const SizedBox(height: 24),
          
          _buildDynamicList(
            context,
            title: "Achievements",
            items: controller.achievementsC,
            onAdd: () => _showAchievementDialog(context),
            onRemove: (index) => controller.achievementsC.removeAt(index),
            itemBuilder: (a) => Text("${a.title} (${a.month})"),
          ),
          
          const SizedBox(height: 120), // Prevent hiding by navbar
        ],
      ),
    );
  }

  Widget _buildDynamicList<T>(
    BuildContext context, {
    required String title,
    required RxList<T> items,
    required VoidCallback onAdd,
    required Function(int) onRemove,
    required Widget Function(T) itemBuilder,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            IconButton(
              onPressed: onAdd,
              icon: Icon(Icons.add_circle_outline, color: theme.colorScheme.primary),
            ),
          ],
        ),
        Obx(() => items.isEmpty
            ? const Text("No items added yet.", style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey))
            : ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      title: DefaultTextStyle(
                        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600) ?? const TextStyle(),
                        child: itemBuilder(items[index]),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red, size: 20),
                        onPressed: () => onRemove(index),
                      ),
                    ),
                  );
                },
              )),
      ],
    );
  }

  void _showMilestoneDialog(BuildContext context) {
    final titleC = TextEditingController();
    final dateC = TextEditingController();
    final typeC = "milestone".obs;

    Get.dialog(
      AlertDialog(
        title: const Text("Add Milestone"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleC, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: dateC, decoration: const InputDecoration(labelText: "Date (YYYY-MM)")),
            Obx(() => DropdownButton<String>(
                  value: typeC.value,
                  isExpanded: true,
                  items: ["milestone", "celebration", "achievement"].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
                  onChanged: (val) => typeC.value = val!,
                )),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (titleC.text.isNotEmpty && dateC.text.isNotEmpty) {
                controller.recoveryMilestonesC.add(RecoveryMilestone(
                  id: 0,
                  title: titleC.text,
                  type: typeC.value,
                  date: dateC.text,
                ));
                Get.back();
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  void _showAchievementDialog(BuildContext context) {
    final titleC = TextEditingController();
    final monthC = TextEditingController();

    Get.dialog(
      AlertDialog(
        title: const Text("Add Achievement"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleC, decoration: const InputDecoration(labelText: "Title")),
            TextField(controller: monthC, decoration: const InputDecoration(labelText: "Month (YYYY-MM)")),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              if (titleC.text.isNotEmpty && monthC.text.isNotEmpty) {
                controller.achievementsC.add(Achievement(
                  id: 0,
                  title: titleC.text,
                  month: monthC.text,
                ));
                Get.back();
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }
}

class _SupportersTab extends GetView<CaregiverController> {
  const _SupportersTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Section
            const Text("Find Allies", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              onChanged: (val) => controller.searchQuery.value = val,
              style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
              decoration: InputDecoration(
                hintText: "Search by username...",
                hintStyle: TextStyle(color: theme.hintColor),
                suffixIcon: Obx(() => controller.isSearching.value 
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : Icon(Icons.search, color: theme.colorScheme.primary)),
                filled: true,
                fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.25),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              ),
            ),
            
            // Removing the redundant isSearching indicator here as it's now in the suffixIcon

            if (controller.searchResults.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text("Search Results", style: TextStyle(fontWeight: FontWeight.bold)),
              ...controller.searchResults.map((user) => _buildUserCard(context, user)).toList(),
            ],

            const SizedBox(height: 24),
            
            // Pending Requests
            if (controller.pendingRequests.isNotEmpty) ...[
              const Text("Pending Requests", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
              const SizedBox(height: 12),
              ...controller.pendingRequests.map((req) => _buildPendingRequestCard(context, req)).toList(),
              const SizedBox(height: 24),
            ],

            // Current Allies
            const Text("Your Allies", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            if (controller.allies.isEmpty)
              const Text("No allies connected yet. Use the search above to find and link with supporters.")
            else
              ...controller.allies.map((ally) => _buildAllyCard(context, ally)).toList(),
            
            const SizedBox(height: 120), // Spacer for nav bar
          ],
        ),
      );
    });
  }

  Widget _buildUserCard(BuildContext context, LinkedUserDTO user) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          backgroundImage: user.profileImage != null && user.profileImage!.isNotEmpty
              ? MemoryImage(base64Decode(user.profileImage!.split(',').last))
              : null,
          child: user.profileImage == null || user.profileImage!.isEmpty
              ? Text(user.firstName.isNotEmpty ? user.firstName[0].toUpperCase() : "?")
              : null,
        ),
        title: Text("${user.firstName} ${user.lastName}", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("@${user.username}\n${user.country ?? ''}"),
        trailing: ElevatedButton(
          onPressed: () => _showRequestDialog(context, user),
          style: ElevatedButton.styleFrom(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            visualDensity: VisualDensity.compact,
          ),
          child: const Text("Request"),
        ),
      ),
    );
  }

  Widget _buildPendingRequestCard(BuildContext context, PendingCaregiverRequest req) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(top: 8),
      color: Colors.transparent,
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.orange.withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.orange.withOpacity(0.2)),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            backgroundImage: req.profileImage != null && req.profileImage!.isNotEmpty
                ? MemoryImage(base64Decode(req.profileImage!.split(',').last))
                : null,
            child: req.profileImage == null || req.profileImage!.isEmpty
                ? Text(req.firstName.isNotEmpty ? req.firstName[0].toUpperCase() : "?")
                : null,
          ),
          title: Text("${req.firstName} ${req.lastName}", style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text("Relationship: ${req.relationship}"),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.check_circle, color: Colors.green),
                onPressed: () => controller.respondToReq(req.linkId, true),
              ),
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: () => controller.respondToReq(req.linkId, false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAllyCard(BuildContext context, Caregiver ally) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
          backgroundImage: ally.profileImage != null && ally.profileImage!.isNotEmpty
              ? MemoryImage(base64Decode(ally.profileImage!.split(',').last))
              : null,
          child: ally.profileImage == null || ally.profileImage!.isEmpty
              ? Text(ally.firstName.isNotEmpty ? ally.firstName[0].toUpperCase() : "?")
              : null,
        ),
        title: Text("${ally.firstName} ${ally.lastName}", style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text("Relationship: ${ally.relationship}"),
        trailing: const Icon(Icons.verified, color: Colors.teal),
      ),
    );
  }

  void _showRequestDialog(BuildContext context, LinkedUserDTO user) {
    String selectedRelationship = "SPOUSE";
    final List<String> relationships = ["SPOUSE", "PARENT", "SIBLING", "FRIEND", "CAREGIVER", "PROFESSIONAL", "OTHER"];

    Get.dialog(
      AlertDialog(
        title: Text("Request Connection with ${user.firstName}"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select your relationship:"),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: selectedRelationship,
              items: relationships.map((r) => DropdownMenuItem(value: r, child: Text(r))).toList(),
              onChanged: (val) {
                if (val != null) selectedRelationship = val;
              },
              decoration: const InputDecoration(border: OutlineInputBorder()),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              controller.sendRequest(user.username, selectedRelationship);
              Get.back();
            },
            child: const Text("Send Request"),
          ),
        ],
      ),
    );
  }
}

class _MentorshipTab extends GetView<ProfileController> {
  const _MentorshipTab();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Obx(() => Container(
            padding: const EdgeInsets.symmetric(vertical: 4),
            decoration: BoxDecoration(
              color: Get.theme.colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: SwitchListTile(
              title: const Text("Willing to Offer Support", style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text("Allow others to reach out to you for guidance"),
              activeColor: Get.theme.colorScheme.primary,
              value: controller.offerSupportC.value,
              onChanged: (val) => controller.offerSupportC.value = val,
            ),
          )),
          const SizedBox(height: 16),
          _buildTextField("Mentorship Goals", controller.mentorshipGoalsC, icon: Icons.flag_outlined, maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField("Fitness Level", controller.fitnessLevelC, icon: Icons.fitness_center_outlined),
          const SizedBox(height: 16),
          _buildNumberField("Availability (Hours per week)", controller.availabilityHoursC, icon: Icons.schedule_outlined),
        ],
      ),
    );
  }
}

  Widget _buildTextField(String label, RxString controller, {int maxLines = 1, bool readOnly = false, TextInputType? keyboardType, IconData? icon}) {
    return Obx(() {
      final theme = Get.theme;
      return TextFormField(
        initialValue: controller.value,
        readOnly: readOnly,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: theme.colorScheme.primary.withOpacity(0.8), fontWeight: FontWeight.w600),
          prefixIcon: icon != null ? Icon(icon, color: theme.colorScheme.primary.withOpacity(0.7), size: 22) : null,
          filled: true,
          fillColor: readOnly 
              ? theme.colorScheme.surfaceVariant.withOpacity(0.15) 
              : theme.colorScheme.surfaceVariant.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        onChanged: (val) => controller.value = val,
      );
    });
  }

  Widget _buildNumberField(String label, RxInt controller, {IconData? icon}) {
    return Obx(() {
      final theme = Get.theme;
      return TextFormField(
        initialValue: controller.value.toString(),
        keyboardType: TextInputType.number,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: theme.colorScheme.primary.withOpacity(0.8), fontWeight: FontWeight.w600),
          prefixIcon: icon != null ? Icon(icon, color: theme.colorScheme.primary.withOpacity(0.7), size: 22) : null,
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        onChanged: (val) => controller.value = int.tryParse(val) ?? 0,
      );
    });
  }

  Widget _buildDropdown(String label, RxString controller, List<String> options, {IconData? icon}) {
    return Obx(() {
      final theme = Get.theme;
      // Normalize: find the exact option that matches the controller value (case-insensitive)
      String? effectiveValue;
      if (controller.value.isNotEmpty) {
        effectiveValue = options.firstWhere(
          (o) => o.toLowerCase() == controller.value.toLowerCase(),
          orElse: () => "",
        );
        if (effectiveValue.isEmpty) effectiveValue = null;
      }

      return DropdownButtonFormField<String>(
        value: effectiveValue,
        style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: theme.colorScheme.primary.withOpacity(0.8), fontWeight: FontWeight.w600),
          prefixIcon: icon != null ? Icon(icon, color: theme.colorScheme.primary.withOpacity(0.7), size: 22) : null,
          filled: true,
          fillColor: theme.colorScheme.surfaceVariant.withOpacity(0.3),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: theme.colorScheme.primary, width: 1.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        ),
        items: options.map((o) => DropdownMenuItem(
          value: o, 
          child: Text(o, style: TextStyle(color: theme.colorScheme.onSurface, fontWeight: FontWeight.w500)),
        )).toList(),
        onChanged: (val) {
          if (val != null) controller.value = val;
        },
      );
    });
  }
