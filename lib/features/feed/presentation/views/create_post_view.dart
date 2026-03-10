import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/create_post_controller.dart';

class CreatePostView extends GetView<CreatePostController> {
  const CreatePostView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEditMode.value ? 'Edit Post' : 'Create Forum Post'),
        actions: [
          Obx(() => TextButton(
            onPressed: controller.isSubmitting.value ? null : () => controller.submitPost(),
            child: controller.isSubmitting.value
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text(
                    'Post',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
          )),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Community Selection
              _buildLabel('Select Community', theme),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: theme.dividerColor),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: controller.selectedCommunity.value?.id?.toString(),
                    isExpanded: true,
                    hint: const Text('Choose a community'),
                    onChanged: (val) {
                      final comm = controller.communities.firstWhere((c) => c.id.toString() == val);
                      controller.selectedCommunity.value = comm;
                    },
                    items: controller.communities.map((c) {
                      return DropdownMenuItem<String>(
                        value: c.id.toString(),
                        child: Text(c.name),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Title
              _buildLabel('Title', theme),
              TextField(
                controller: controller.titleController,
                decoration: InputDecoration(
                  hintText: 'Give your post a clear title',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 12),

              // Content
              _buildLabel('Content', theme),
              TextField(
                controller: controller.contentController,
                maxLines: 8,
                decoration: InputDecoration(
                  hintText: 'Share your thoughts, story, or question...',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 20),

              // Visibility
              _buildLabel('Visibility', theme),
              Row(
                children: [
                  _VisibilityOption(
                    label: 'Public',
                    icon: Icons.public,
                    value: 'public',
                    selectedValue: controller.visibility.value,
                    onTap: () => controller.visibility.value = 'public',
                  ),
                  const SizedBox(width: 12),
                  _VisibilityOption(
                    label: 'Private',
                    icon: Icons.lock_outline,
                    value: 'private',
                    selectedValue: controller.visibility.value,
                    onTap: () => controller.visibility.value = 'private',
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tags
              _buildLabel('Tags', theme),
              _TagInput(
                onSubmitted: (tag) => controller.addTag(tag),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: controller.tags.map((tag) {
                  return Chip(
                    label: Text(tag),
                    onDeleted: () => controller.removeTag(tag),
                    backgroundColor: theme.colorScheme.primaryContainer.withOpacity(0.3),
                    side: BorderSide.none,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildLabel(String text, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        text,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.primary,
        ),
      ),
    );
  }
}

class _VisibilityOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final String selectedValue;
  final VoidCallback onTap;

  const _VisibilityOption({
    required this.label,
    required this.icon,
    required this.value,
    required this.selectedValue,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSelected = value == selectedValue;
    final theme = Theme.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : Colors.transparent,
          border: Border.all(
            color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: isSelected ? theme.colorScheme.primary : Colors.grey),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? theme.colorScheme.primary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TagInput extends StatefulWidget {
  final Function(String) onSubmitted;

  const _TagInput({required this.onSubmitted});

  @override
  State<_TagInput> createState() => _TagInputState();
}

class _TagInputState extends State<_TagInput> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: 'Add a tag and press enter',
        suffixIcon: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            widget.onSubmitted(controller.text);
            controller.clear();
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      onSubmitted: (value) {
        widget.onSubmitted(value);
        controller.clear();
      },
    );
  }
}
