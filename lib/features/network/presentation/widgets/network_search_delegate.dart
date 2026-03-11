import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/network_controller.dart';
import 'package:livepoised_mobile/core/utils/image_utils.dart';
import '../../data/models/network_models.dart';

class NetworkSearchDelegate extends SearchDelegate<String> {
  final NetworkController controller = Get.find<NetworkController>();

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          controller.searchQuery.value = '';
          controller.matchmakingResults.clear();
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildBody(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isNotEmpty) {
      controller.searchQuery.value = query;
    }
    return _buildBody(context);
  }

  Widget _buildBody(BuildContext context) {
    return Column(
      children: [
        _buildFilterBar(context),
        Expanded(child: _buildSearchResults(context)),
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(bottom: BorderSide(color: theme.dividerColor, width: 0.5)),
      ),
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          Obx(() => FilterChip(
            label: Text(controller.selectedLiveExperienceTags.isEmpty ? 'Lived Experience' : '${controller.selectedLiveExperienceTags.length} Experience'),
            selected: controller.selectedLiveExperienceTags.isNotEmpty,
            onSelected: (val) => _showExperienceMegaFilter(context),
          )),
          const SizedBox(width: 8),
          Obx(() => FilterChip(
            label: Text(controller.selectedCountry.value.isEmpty ? 'Location' : controller.selectedCountry.value),
            selected: controller.selectedCountry.value.isNotEmpty,
            onSelected: (val) => _showLocationPicker(context),
          )),
          const SizedBox(width: 8),
          Obx(() => FilterChip(
            label: Text(controller.selectedLanguages.isEmpty ? 'Language' : '${controller.selectedLanguages.length} Lang'),
            selected: controller.selectedLanguages.isNotEmpty,
            onSelected: (val) => _showLanguagePicker(context),
          )),
          const SizedBox(width: 8),
          Obx(() => FilterChip(
            label: Text(controller.minExperienceYears.value == 0 ? 'Years' : '${controller.minExperienceYears.value}+ Yrs'),
            selected: controller.minExperienceYears.value > 0,
            onSelected: (val) => _showYearsPicker(context),
          )),
          const SizedBox(width: 16),
          // Clear All Filters Option
          Obx(() {
            final hasFilters = controller.selectedLiveExperienceTags.isNotEmpty ||
                controller.selectedCountry.value.isNotEmpty ||
                controller.selectedLanguages.isNotEmpty ||
                controller.minExperienceYears.value > 0 ||
                controller.offerSupport.value;
            
            if (!hasFilters) return const SizedBox.shrink();
            
            return Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: TextButton.icon(
                onPressed: () {
                  controller.selectedLiveExperienceTags.clear();
                  controller.selectedCountry.value = '';
                  controller.selectedLanguages.clear();
                  controller.minExperienceYears.value = 0;
                  controller.offerSupport.value = false;
                  controller.executeMatchmakingSearch(query);
                },
                icon: Icon(Icons.close, size: 16, color: theme.colorScheme.error),
                label: Text(
                  'Clear',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: TextButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context) {
    final theme = Theme.of(context);
    
    return Obx(() {
      if (controller.isSearching.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final aiMatches = controller.matchmakingResults;
      final error = controller.matchmakingError.value;

      if (error.isNotEmpty) {
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.info_outline, size: 48, color: theme.colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  error,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.error),
                ),
              ],
            ),
          ),
        );
      }

      if (aiMatches.isEmpty) {
        return Center(
          child: Text(
            query.isEmpty && aiMatches.isEmpty
                ? 'Search for Ally to add...' 
                : 'No results found for "$query"',
            style: theme.textTheme.bodyLarge,
          ),
        );
      }

      return ListView(
        padding: const EdgeInsets.all(16),
        children: aiMatches.map((match) => _buildAllyMatchCard(context, match, theme)).toList(),
      );
    });
  }

  Widget _buildAllyMatchCard(BuildContext context, AllyMatch match, ThemeData theme) {
    final imageProvider = ImageUtils.getImageProvider(match.profileImageUrl);
    final confidenceColor = _getConfidenceColor(match.matchConfidence);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CircleAvatar(
                backgroundColor: theme.colorScheme.primaryContainer,
                foregroundImage: imageProvider,
                child: Text(match.fullName[0].toUpperCase()),
              ),
              title: Row(
                children: [
                  Expanded(child: Text(match.fullName, style: const TextStyle(fontWeight: FontWeight.bold))),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: confidenceColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: confidenceColor),
                    ),
                    child: Text(
                      '${match.matchConfidence}% Match',
                      style: TextStyle(color: confidenceColor, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              subtitle: Text('@${match.username}'),
              trailing: _buildActionButton(match),
            ),
            if (match.aboutMe != null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  match.aboutMe!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            if (match.liveExperienceTags != null && match.liveExperienceTags!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Wrap(
                  spacing: 4,
                  runSpacing: 0,
                  children: match.liveExperienceTags!.take(3).map((tag) => Chip(
                    label: Text(tag, style: const TextStyle(fontSize: 10)),
                    padding: EdgeInsets.zero,
                    visualDensity: VisualDensity.compact,
                  )).toList(),
                ),
              ),
          ],
        ),
      ),
    );
  }


  Widget _buildActionButton(AllyMatch match) {
    if (match.connectionStatus == 'ACCEPTED') {
      return const OutlinedButton(onPressed: null, child: Text('Connected'));
    }
    if (match.connectionStatus == 'PENDING') {
      return const OutlinedButton(onPressed: null, child: Text('Pending'));
    }
    return ElevatedButton(
      onPressed: () => controller.sendAllyRequest(match.username),
      child: const Text('Connect'),
    );
  }

  Color _getConfidenceColor(int score) {
    if (score >= 80) return Colors.green;
    if (score >= 50) return Colors.teal;
    return Colors.grey;
  }

  // --- Filter Pickers ---

  void _showLocationPicker(BuildContext context) {
    final List<String> countries = ["United Kingdom", "USA", "Canada", "Australia", "India", "Other"];
    _showSimpleListPicker(context, "Select Country", countries, (val) {
      if (val != null) controller.selectedCountry.value = val == "Other" ? "" : val;
      controller.executeMatchmakingSearch(query);
    });
  }

  void _showLanguagePicker(BuildContext context) {
    final List<String> languages = ["English", "Spanish", "French", "German", "Hindi", "Mandarin"];
    _showMultiSelectPicker(context, "Select Languages", languages, controller.selectedLanguages);
  }

  void _showYearsPicker(BuildContext context) {
    final List<int> years = [0, 1, 2, 3, 5, 10];
    _showSimpleListPicker(context, "Min Experience (Years)", years.map((y) => y == 0 ? "Any" : "$y+ years").toList(), (val) {
      if (val != null) {
        final year = int.tryParse(val.split('+')[0]) ?? 0;
        controller.minExperienceYears.value = year;
        controller.executeMatchmakingSearch(query);
      }
    });
  }

  void _showExperienceMegaFilter(BuildContext context) {
    final theme = Theme.of(context);
    final categories = {
      "Neurological & Cognitive": ["Stroke recovery", "Brain fog", "Memory challenges", "Seizures"],
      "Chronic & Long-Term": ["Chronic pain", "Autoimmune", "Long COVID", "Digestive disorders"],
      "Mobility & Physical": ["Injury recovery", "Paralysis", "Amputation", "Rehabilitation"],
      "Mental & Emotional": ["Anxiety", "Depression", "PTSD", "Burnout", "Identity shifts"],
      "Serious Illness": ["Cancer journey", "Post-treatment", "Rare conditions"],
      "Grief & Loss": ["Loss of a loved one", "Loss of identity", "Caregiver grief"],
      "Growth & Momentum": ["Resilience", "Motivation", "Mindset rebuilding", "Accountability"],
    };

    Get.bottomSheet(
      Theme(
        data: theme,
        child: Container(
          height: Get.height * 0.55,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Lived Experience Filters", style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      controller.selectedLiveExperienceTags.clear();
                      controller.offerSupport.value = false;
                      controller.executeMatchmakingSearch(query);
                      Get.back();
                    },
                    child: const Text("Clear"),
                  ),
                ],
              ),
              const Divider(),
              Obx(() => SwitchListTile(
                    title: const Text("Offer Support", style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: const Text("Show allies who are specifically offering support"),
                    value: controller.offerSupport.value,
                    activeColor: theme.colorScheme.primary,
                    onChanged: (val) {
                      controller.offerSupport.value = val;
                      controller.executeMatchmakingSearch(query);
                    },
                  )),
              const Divider(),
              Expanded(
                child: ListView(
                  children: categories.entries.map((entry) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Text(
                            entry.key,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        Wrap(
                          spacing: 8,
                          children: entry.value.map((tag) {
                            return Obx(() => FilterChip(
                                  label: Text(tag),
                                  selected: controller.selectedLiveExperienceTags.contains(tag),
                                  onSelected: (selected) {
                                    if (selected) {
                                      controller.selectedLiveExperienceTags.add(tag);
                                    } else {
                                      controller.selectedLiveExperienceTags.remove(tag);
                                    }
                                    controller.executeMatchmakingSearch(query);
                                  },
                                ));
                          }).toList(),
                        ),
                        const SizedBox(height: 16),
                      ],
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: () => Get.back(), child: const Text("Apply Filters")),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void _showSimpleListPicker(BuildContext context, String title, List<String> items, Function(String?) onSelected) {
    final theme = Theme.of(context);
    Get.bottomSheet(
      Theme(
        data: theme,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const Divider(),
              ...items.map((item) => ListTile(
                    title: Text(item, style: theme.textTheme.bodyLarge),
                    onTap: () {
                      onSelected(item);
                      Get.back();
                    },
                  )),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

  void _showMultiSelectPicker(BuildContext context, String title, List<String> items, RxList<String> selectedItems) {
    final theme = Theme.of(context);
    Get.bottomSheet(
      Theme(
        data: theme,
        child: Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.only(topLeft: Radius.circular(20), topRight: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title, style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const Divider(),
              Flexible(
                child: ListView(
                  shrinkWrap: true,
                  children: items.map((item) => Obx(() => CheckboxListTile(
                        title: Text(item, style: theme.textTheme.bodyLarge),
                        value: selectedItems.contains(item),
                        activeColor: theme.colorScheme.primary,
                        onChanged: (val) {
                          if (val == true) {
                            selectedItems.add(item);
                          } else {
                            selectedItems.remove(item);
                          }
                          controller.executeMatchmakingSearch(query);
                        },
                      ))).toList(),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(onPressed: () => Get.back(), child: const Text("Done")),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }

}
