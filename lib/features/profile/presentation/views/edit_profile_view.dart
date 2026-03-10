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

    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Edit Profile", style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            TextButton(
              onPressed: () => controller.saveProfile(),
              child: const Text("Save", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: "Personal"),
              Tab(text: "Contact"),
              Tab(text: "Health & Recovery"),
              Tab(text: "Supporters"),
              Tab(text: "Mentorship"),
            ],
          ),
        ),
        body: Stack(
          children: [
            const TabBarView(
              children: [
                _PersonalTab(),
                _ContactTab(),
                _HealthTab(),
                _SupportersTab(),
                _MentorshipTab(),
              ],
            ),
            Obx(() => controller.isSaving.value
                ? Container(
                    color: Colors.black26,
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
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildTextField("Username", controller.usernameC, readOnly: true),
          const SizedBox(height: 16),
          _buildTextField("First Name", controller.firstNameC),
          const SizedBox(height: 16),
          _buildTextField("Middle Name", controller.middleNameC),
          const SizedBox(height: 16),
          _buildTextField("Last Name", controller.lastNameC),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField("Prefix", controller.prefixC)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField("Suffix", controller.suffixC)),
            ],
          ),
          const SizedBox(height: 16),
          _buildDropdown("Gender", controller.genderC, ["Male", "Female", "Other"]),
          const SizedBox(height: 16),
          Obx(() => ListTile(
                title: const Text("Date of Birth"),
                subtitle: Text(controller.dobC.value == null
                    ? "Not set"
                    : DateFormat('yyyy-MM-dd').format(controller.dobC.value!)),
                trailing: const Icon(Icons.calendar_today),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: controller.dobC.value ?? DateTime.now(),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) controller.dobC.value = picked;
                },
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
          _buildTextField("Email", controller.emailC, keyboardType: TextInputType.emailAddress),
          const SizedBox(height: 16),
          _buildTextField("Mobile Number", controller.mobileNumberC),
          const SizedBox(height: 16),
          _buildTextField("Secondary Phone 1", controller.phone1C),
          const SizedBox(height: 16),
          _buildTextField("Secondary Phone 2", controller.phone2C),
          const SizedBox(height: 24),
          const Text("Address", style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          _buildTextField("Address Line 1", controller.addressLine1C),
          const SizedBox(height: 16),
          _buildTextField("Address Line 2", controller.addressLine2C),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField("City", controller.cityC)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField("State", controller.stateC)),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField("Country", controller.countryC)),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField("Postal Code", controller.postalCodeC)),
            ],
          ),
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
          _buildTextField("About Me", controller.aboutMeC, maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField("Injury Type", controller.injuryTypeC),
          const SizedBox(height: 16),
          _buildTextField("Injury Details", controller.injuryDetailsC, maxLines: 3),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildNumberField("Years Since Injury", controller.yearsSinceInjuryC)),
              const SizedBox(width: 16),
              Expanded(child: _buildNumberField("Years Since Recovery", controller.yearsSinceRecoveryC)),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField("Personal Story", controller.personalStoryC, maxLines: 4),
          const SizedBox(height: 16),
          _buildTextField("Condition Details", controller.conditionDetailsC, maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField("Stage of Recovery", controller.stageOfRecoveryC),
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
          
          const SizedBox(height: 80), // Prevent hiding by navbar
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
                itemCount: items.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: itemBuilder(items[index]),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.red),
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
              decoration: InputDecoration(
                hintText: "Search by username...",
                suffixIcon: Obx(() => controller.isSearching.value 
                  ? const Padding(
                      padding: EdgeInsets.all(12.0),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                  : const Icon(Icons.search)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
            
            const SizedBox(height: 80), // Spacer for nav bar
          ],
        ),
      );
    });
  }

  Widget _buildUserCard(BuildContext context, LinkedUserDTO user) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(top: 8),
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
        title: Text("${user.firstName} ${user.lastName}"),
        subtitle: Text("@${user.username}\n${user.country ?? ''}"),
        trailing: ElevatedButton(
          onPressed: () => _showRequestDialog(context, user),
          child: const Text("Request"),
        ),
      ),
    );
  }

  Widget _buildPendingRequestCard(BuildContext context, PendingCaregiverRequest req) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(top: 8),
      color: Colors.orange.withOpacity(0.05),
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
        title: Text("${req.firstName} ${req.lastName}"),
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
    );
  }

  Widget _buildAllyCard(BuildContext context, Caregiver ally) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(top: 8),
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
        title: Text("${ally.firstName} ${ally.lastName}"),
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
          Obx(() => SwitchListTile(
            title: const Text("Willing to Offer Support"),
            value: controller.offerSupportC.value,
            onChanged: (val) => controller.offerSupportC.value = val,
          )),
          const SizedBox(height: 16),
          _buildTextField("Mentorship Goals", controller.mentorshipGoalsC, maxLines: 3),
          const SizedBox(height: 16),
          _buildTextField("Fitness Level", controller.fitnessLevelC),
          const SizedBox(height: 16),
          _buildNumberField("Availability (Hours per week)", controller.availabilityHoursC),
        ],
      ),
    );
  }
}

// Helper methods
Widget _buildTextField(String label, RxString controller, {int maxLines = 1, bool readOnly = false, TextInputType? keyboardType}) {
  return Obx(() => TextFormField(
    initialValue: controller.value,
    readOnly: readOnly,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: readOnly,
      fillColor: readOnly ? Colors.grey.withOpacity(0.1) : null,
    ),
    maxLines: maxLines,
    onChanged: (val) => controller.value = val,
  ));
}

Widget _buildNumberField(String label, RxInt controller) {
  return Obx(() => TextFormField(
    initialValue: controller.value.toString(),
    decoration: InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
    keyboardType: TextInputType.number,
    onChanged: (val) => controller.value = int.tryParse(val) ?? 0,
  ));
}

Widget _buildDropdown(String label, RxString controller, List<String> options) {
  return Obx(() {
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
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items: options.map((o) => DropdownMenuItem(value: o, child: Text(o))).toList(),
      onChanged: (val) {
        if (val != null) controller.value = val;
      },
    );
  });
}
