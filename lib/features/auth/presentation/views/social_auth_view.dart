import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:livepoised_mobile/features/auth/auth_controller.dart';
import 'package:livepoised_mobile/features/auth/auth_service.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SocialAuthView extends StatefulWidget {
  const SocialAuthView({super.key});

  @override
  State<SocialAuthView> createState() => _SocialAuthViewState();
}

class _SocialAuthViewState extends State<SocialAuthView> {
  late final WebViewController _controller;
  final AuthService _authService = AuthService();
  final AuthController _authController = Get.find<AuthController>();
  bool _isLoading = true;
  late final String _provider;

  @override
  void initState() {
    super.initState();
    _provider = Get.arguments?['provider'] ?? 'google';
    _initializeWebView();
  }

  Future<void> _initializeWebView() async {
    final url = _authService.getSocialLoginUrl(_provider);
    
    // Clear cookies for a fresh social login session
    await WebViewCookieManager().clearCookies();
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
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
            print('Social Auth Nav: ${request.url}');
            
            final uri = Uri.parse(request.url);
            if (uri.scheme == 'com.livepoised.app') {
              final code = uri.queryParameters['code'];
              if (code != null) {
                // Successful authorization, return code to controller
                Get.back();
                _authController.handleSocialAuthCallback(code);
                return NavigationDecision.prevent;
              } else if (uri.queryParameters.containsKey('error')) {
                Get.back();
                Get.snackbar('Error', 'Social login failed: ${uri.queryParameters['error_description'] ?? 'Unknown error'}');
                return NavigationDecision.prevent;
              }
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(url));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign in with ${_provider.capitalizeFirst}'),
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
