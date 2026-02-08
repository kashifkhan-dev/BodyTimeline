import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:io';
import '../../../core/theme/color_palette.dart';
import '../../../core/theme/theme_provider.dart';
import 'package:provider/provider.dart';

/// Shows a WebView in a modal bottom sheet
void showWebViewSheet(BuildContext context, {required String url, required String title}) {
  final colors = context.read<ThemeProvider>().colors(context);

  if (Platform.isIOS) {
    showCupertinoModalPopup(
      context: context,
      builder: (context) => _WebViewBottomSheet(url: url, title: title, colors: colors),
    );
  } else {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      enableDrag: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _WebViewBottomSheet(url: url, title: title, colors: colors),
    );
  }
}

class _WebViewBottomSheet extends StatefulWidget {
  final String url;
  final String title;
  final AppColors colors;

  const _WebViewBottomSheet({required this.url, required this.title, required this.colors});

  @override
  State<_WebViewBottomSheet> createState() => _WebViewBottomSheetState();
}

class _WebViewBottomSheetState extends State<_WebViewBottomSheet> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            // Allow navigation within Google Docs domain, block everything else
            final uri = Uri.parse(request.url);
            if (uri.host.contains('google.com') || uri.host.contains('docs.google.com')) {
              return NavigationDecision.navigate;
            }
            // Block external navigation
            return NavigationDecision.prevent;
          },
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
                _hasError = false;
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
          onWebResourceError: (WebResourceError error) {
            if (mounted) {
              setState(() {
                _isLoading = false;
                _hasError = true;
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.url));
  }

  void _retry() {
    _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.8,
      decoration: BoxDecoration(
        color: widget.colors.background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Drag handle and header - draggable area
          GestureDetector(
            onVerticalDragUpdate: (details) {
              // Dismiss on downward drag from header area
              if (details.primaryDelta! > 10) {
                Navigator.of(context).pop();
              }
            },
            child: Column(
              children: [
                // Drag handle
                Container(
                  margin: const EdgeInsets.only(top: 12, bottom: 8),
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: widget.colors.textMuted.withAlpha(100),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Header
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(bottom: BorderSide(color: widget.colors.border, width: 0.5)),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.title,
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: widget.colors.textPrimary),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: widget.colors.surface,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Platform.isIOS ? CupertinoIcons.xmark : Icons.close,
                            size: 20,
                            color: widget.colors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // WebView content - scrollable
          Expanded(
            child: Stack(
              children: [
                if (!_hasError)
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(bottom: Radius.circular(20)),
                    child: WebViewWidget(controller: _controller),
                  ),
                if (_isLoading)
                  Center(
                    child: Platform.isIOS
                        ? const CupertinoActivityIndicator()
                        : CircularProgressIndicator(color: widget.colors.primary),
                  ),
                if (_hasError)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Platform.isIOS ? CupertinoIcons.exclamationmark_triangle : Icons.error_outline,
                          size: 48,
                          color: widget.colors.textMuted,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load document',
                          style: TextStyle(color: widget.colors.textPrimary, fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        if (Platform.isIOS)
                          CupertinoButton(onPressed: _retry, child: const Text('Retry'))
                        else
                          ElevatedButton(
                            onPressed: _retry,
                            style: ElevatedButton.styleFrom(backgroundColor: widget.colors.primary),
                            child: const Text('Retry'),
                          ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
