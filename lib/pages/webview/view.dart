import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'model.dart';

// import 'package:webview_flutter_android/webview_flutter_android.dart';

class WebView extends StatefulWidget {
  final String initialUrl;
  final WebViewModel model;
  const new({super.key, required this.initialUrl, required this.model});

  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  final _log = Logger('WebViewState');
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    final params = PlatformWebViewControllerCreationParams();
    final controller = WebViewController.fromPlatformCreationParams(params);
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            widget.model.reset();
          },
          onPageFinished: (String url) {
            _log.fine('onPageFinished: $url');
            widget.model.fetchFeed(url);
          },
          onWebResourceError: (WebResourceError error) {
            _log.fine('onWebResourceError: $error');
          },
          onHttpError: (HttpResponseError error) {
            _log.fine('onHttpError: $error');
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.initialUrl));
    _controller = controller;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.model,
      builder: (context, _) {
        return Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () async {
                if (await _controller.canGoBack()) {
                  await _controller.goBack();
                } else {
                  if (context.mounted) {
                    context.go('/search');
                  }
                }
              },
            ),
            title: const Text('Navigate to the RSS feed page'),
          ),
          body: WebViewWidget(controller: _controller),
          floatingActionButton: widget.model.found
              ? FloatingActionButton.extended(
                  onPressed: () =>
                      context.go('/search', extra: widget.model.feed),
                  label: Text('Choose this feed'),
                )
              : null,
        );
      },
    );
  }
}
