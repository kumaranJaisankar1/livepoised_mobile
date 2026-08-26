import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/news_controller.dart';
import '../widgets/news_list_tile.dart';

class NewsListView extends GetView<NewsController> {
  const NewsListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('News & Articles'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: _buildCategoryChips(context),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.articles.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.articles.isEmpty) {
          return _buildEmptyState(context);
        }
        return RefreshIndicator(
          onRefresh: controller.fetchTrendingNews,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.articles.length,
            separatorBuilder: (_, __) => const Divider(height: 1, indent: 16, endIndent: 16),
            itemBuilder: (context, index) => NewsListTile(article: controller.articles[index]),
          ),
        );
      }),
    );
  }

  Widget _buildCategoryChips(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Obx(() {
        final selected = controller.selectedCategory.value;
        return ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          itemCount: NewsController.categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final category = NewsController.categories[index];
            final isSelected = category.value == selected;
            return ChoiceChip(
              label: Text(category.label),
              selected: isSelected,
              onSelected: (_) => controller.selectCategory(category.value),
              labelStyle: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Theme.of(context).colorScheme.onSurface,
              ),
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
              visualDensity: VisualDensity.compact,
              side: BorderSide.none,
            );
          },
        );
      }),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.article_outlined, size: 48, color: theme.colorScheme.onSurface.withOpacity(0.4)),
            const SizedBox(height: 12),
            Text(
              controller.selectedCategory.value == null
                  ? "No news available right now — check back soon."
                  : "No articles found for this category right now.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface.withOpacity(0.6)),
            ),
          ],
        ),
      ),
    );
  }
}
