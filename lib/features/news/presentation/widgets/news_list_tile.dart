import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../data/models/news_article.dart';

/// Full-width row tile for the dedicated News & Articles list — thumbnail on
/// the side, text filling the rest, matching a typical news-reader layout
/// rather than the carousel-card shape (that lived inline in the social
/// feed and was dropped in favor of this standalone screen).
class NewsListTile extends StatelessWidget {
  final NewsArticle article;

  const NewsListTile({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => Get.toNamed('/news-article', arguments: article),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 96,
                height: 96,
                child: (article.imageUrl == null || article.imageUrl!.isEmpty)
                    ? _ImageFallback(theme: theme)
                    : Image.network(
                        article.imageUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => _ImageFallback(theme: theme),
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(color: theme.colorScheme.surfaceContainerHighest);
                        },
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold, height: 1.25),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.65),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          article.sourceName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Text(
                        '  •  ${timeago.format(article.publishedAt)}',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageFallback extends StatelessWidget {
  final ThemeData theme;
  const _ImageFallback({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: theme.colorScheme.primary.withOpacity(0.12),
      child: Icon(Icons.article_outlined, color: theme.colorScheme.primary, size: 28),
    );
  }
}
