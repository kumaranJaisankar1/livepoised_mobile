import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livepoised_mobile/features/auth/auth_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RegistrationView extends StatefulWidget {
  const RegistrationView({super.key});

  @override
  State<RegistrationView> createState() => _RegistrationViewState();
}

class _RegistrationViewState extends State<RegistrationView> {
  late final WebViewController _controller;
  final AuthService _authService = AuthService();
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    
    // Initialize controller synchronously
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('WebView loading: $url');
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            print('Navigation Request: ${request.url}');
            
            final uri = Uri.parse(request.url);
            if (uri.scheme == 'com.livepoised.app') {
              print('Detected Callback Scheme! Closing WebView.');
              
              Get.back();
              
              // Only show success if it looks like a successful registration
              if (request.url.contains('code=')) {
                Get.snackbar(
                  'Success',
                  'Registration completed! You can now sign in.',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
                );
              }
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );

    _loadRegistration();
  }

  Future<void> _loadRegistration() async {
    final url = _authService.getRegistrationUrl();
    
    // Clear cookies to ensure fresh registration/login session
    await WebViewCookieManager().clearCookies();
    
    await _controller.loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Get.back(),
        ),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
