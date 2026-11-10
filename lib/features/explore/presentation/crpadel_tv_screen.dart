import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/app_theme.dart';

class CrpadelTvScreen extends StatefulWidget {
  const CrpadelTvScreen({super.key});

  @override
  State<CrpadelTvScreen> createState() => _CrpadelTvScreenState();
}

class _CrpadelTvScreenState extends State<CrpadelTvScreen> {
  static final Uri _channelUri = Uri.parse(
    'https://www.youtube.com/@CastelliRomaniPadel',
  );

  late final WebViewController _controller;
  int _progress = 0;
  bool _hasMainFrameError = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (mounted) setState(() => _progress = progress);
          },
          onPageStarted: (_) {
            if (mounted) setState(() => _hasMainFrameError = false);
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame == true && mounted) {
              setState(() => _hasMainFrameError = true);
            }
          },
        ),
      )
      ..loadRequest(_channelUri);
  }

  Future<void> _reload() async {
    setState(() => _hasMainFrameError = false);
    await _controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CRPadel TV'),
        actions: [
          IconButton(
            tooltip: 'Aggiorna video',
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
            color: context.colors.surface,
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rivedi le partite del circolo',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                SizedBox(height: 4),
                Text(
                  'Video e dirette dal canale ufficiale Castelli Romani Padel.',
                  style: TextStyle(fontSize: 13),
                ),
              ],
            ),
          ),
          if (_progress < 100 && !_hasMainFrameError)
            LinearProgressIndicator(value: _progress / 100),
          Expanded(
            child: _hasMainFrameError
                ? _VideoLoadError(onRetry: _reload)
                : WebViewWidget(controller: _controller),
          ),
        ],
      ),
    );
  }
}

class _VideoLoadError extends StatelessWidget {
  const _VideoLoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.ondemand_video_outlined,
              size: 48,
              color: context.colors.textSecondary,
            ),
            const SizedBox(height: 14),
            const Text(
              'Non riesco a caricare CRPadel TV',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              'Controlla la connessione e riprova.',
              textAlign: TextAlign.center,
              style: TextStyle(color: context.colors.textSecondary),
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Riprova'),
            ),
          ],
        ),
      ),
    );
  }
}
