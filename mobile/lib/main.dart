import 'package:flutter/material.dart';
import 'services/api_service.dart';
import 'services/share_intent_service.dart';
import 'screens/home_screen.dart';
import 'screens/analysis_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TrustLensApp());
}

class TrustLensApp extends StatelessWidget {
  const TrustLensApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrustLens',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const _AppShell(),
    );
  }
}

class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  final _api = ApiService();
  late final ShareIntentService _shareService;
  bool _backendConnected = false;

  // Holds content that arrived before the first frame (cold-start share).
  SharedContent? _pendingContent;

  @override
  void initState() {
    super.initState();
    _checkBackend();
    _shareService = ShareIntentService(
      onContentReceived: _onSharedContent,
    );
    _shareService.init();
    // After the first frame the Navigator is ready — flush any queued content.
    _afterFirstFrame();
  }

  Future<void> _checkBackend() async {
    final ok = await _api.isHealthy();
    if (mounted) setState(() => _backendConnected = ok);
  }

  void _onSharedContent(SharedContent content) {
    if (!content.hasContent || !mounted) return;

    // Check whether the Navigator is already active.
    final nav = Navigator.maybeOf(context);
    if (nav != null) {
      // Warm start: navigate straight away.
      nav.push(MaterialPageRoute(
        builder: (_) => AnalysisScreen(sharedContent: content),
      ));
    } else {
      // Cold start: Navigator not ready yet — queue and let _afterFirstFrame handle it.
      setState(() => _pendingContent = content);
    }
  }

  /// Called once after the first frame so the Navigator exists and any
  /// content that arrived during initState can be forwarded to AnalysisScreen.
  void _afterFirstFrame() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final content = _pendingContent;
      if (content != null) {
        setState(() => _pendingContent = null);
        Navigator.of(context).push(MaterialPageRoute(
          builder: (_) => AnalysisScreen(sharedContent: content),
        ));
      }
    });
  }

  @override
  void dispose() {
    _shareService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return HomeScreen(
      isBackendConnected: _backendConnected,
      onRetryConnection: _checkBackend,
    );
  }
}
