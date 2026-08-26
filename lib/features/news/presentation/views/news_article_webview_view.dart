import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../data/models/news_article.dart';

/// In-app article reader — keeps the user inside Live Poised instead of
/// bouncing them out to an external browser tab (which, on a health-focused
/// app, tends to feel like leaving the app entirely and makes it easy to
/// lose the thread and not come back). Some publisher sites set headers
/// that block embedding, so this always offers "Open in Browser" as an
/// explicit, one-tap fallback rather than only surfacing it after a failure.
class NewsArticleWebViewView extends StatefulWidget {
  const NewsArticleWebViewView({super.key});

  @override
  State<NewsArticleWebViewView> createState() => _NewsArticleWebViewViewState();
}

class _NewsArticleWebViewViewState extends State<NewsArticleWebViewView> {
  late final NewsArticle _article;
  late final WebViewController _controller;
  double _loadProgress = 0;
  bool _failedToLoad = false;

  @override
  void initState() {
    super.initState();
    _article = Get.arguments as NewsArticle;
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _loadProgress = progress / 100);
          },
          onPageFinished: (_) {
            if (mounted) setState(() => _loadProgress = 1);
          },
          onWebResourceError: (error) {
            // Only treat a failure on the article's own main frame as fatal —
            // publisher pages routinely have unrelated ad/tracker sub-resource
            // errors that shouldn't block the whole reader.
            if (mounted && error.isForMainFrame != false) {
              setState(() => _failedToLoad = true);
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(_article.url));
  }

  Future<void> _openExternally() async {
    final uri = Uri.parse(_article.url);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _article.sourceName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_browser),
            tooltip: 'Open in Browser',
            onPressed: _openExternally,
          ),
        ],
        bottom: _loadProgress < 1 && !_failedToLoad
            ? PreferredSize(
                preferredSize: const Size.fromHeight(2),
                child: LinearProgressIndicator(value: _loadProgress),
              )
            : null,
      ),
      body: _failedToLoad ? _buildLoadFailure(context) : WebViewWidget(controller: _controller),
    );
  }

  Widget _buildLoadFailure(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.wifi_off_rounded, size: 48, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
            const SizedBox(height: 16),
            const Text(
              "This article couldn't be loaded in-app.",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              _article.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _openExternally,
              icon: const Icon(Icons.open_in_browser),
              label: const Text('Open in Browser'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _failedToLoad = false;
                  _loadProgress = 0;
                });
                _controller.reload();
              },
              child: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }
}
