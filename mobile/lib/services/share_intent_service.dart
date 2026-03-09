import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:share_handler/share_handler.dart';

/// Listens for incoming shared content using the share_handler plugin.
/// Works on both iOS (via ShareExtension + App Group) and Android (via Intent).
class ShareIntentService {
  StreamSubscription<SharedMedia>? _mediaSub;

  /// Callback invoked whenever shared content arrives.
  final void Function(SharedContent content) onContentReceived;

  ShareIntentService({required this.onContentReceived});

  /// Start listening for incoming share intents.
  void init() {
    final handler = ShareHandler.instance;

    // Handle initial share (cold start: app launched from share sheet).
    handler.getInitialSharedMedia().then((media) {
      debugPrint('[ShareIntentService] getInitialSharedMedia: $media');
      if (media != null) _handleMedia(media);
    }).catchError((e) {
      debugPrint('[ShareIntentService] getInitialSharedMedia error: $e');
    });

    // Handle shares while the app is already running (warm start).
    _mediaSub = handler.sharedMediaStream.listen(
      (media) {
        debugPrint('[ShareIntentService] sharedMediaStream: $media');
        _handleMedia(media);
      },
      onError: (e) {
        debugPrint('[ShareIntentService] sharedMediaStream error: $e');
      },
    );
  }

  void _handleMedia(SharedMedia media) {
    debugPrint('[ShareIntentService] _handleMedia content="${media.content}" '
        'attachments=${media.attachments?.length}');

    final text = media.content?.trim();
    final attachments = media.attachments ?? [];

    // Pick the first image/video attachment if any.
    SharedAttachment? imageAttachment;
    SharedAttachment? anyAttachment;
    for (final a in attachments) {
      if (a == null) continue;
      anyAttachment ??= a;
      if (a.type == SharedAttachmentType.image ||
          a.type == SharedAttachmentType.video) {
        imageAttachment = a;
        break;
      }
    }
    final filePath = (imageAttachment ?? anyAttachment)?.path;

    // Determine if the text field is a URL.
    final isUrl = text != null &&
        (text.startsWith('http://') || text.startsWith('https://'));

    final content = SharedContent(
      text: isUrl ? null : (text?.isNotEmpty == true ? text : null),
      imageUrl: isUrl ? text : null,
      imagePath: filePath,
    );

    debugPrint('[ShareIntentService] SharedContent: $content');

    if (content.hasContent) {
      onContentReceived(content);
    } else {
      debugPrint('[ShareIntentService] No content to forward.');
    }
  }

  void dispose() {
    _mediaSub?.cancel();
  }
}

/// Normalized shared content from any platform.
class SharedContent {
  final String? text;
  final String? imageUrl;
  final String? imagePath; // Local file path for shared images

  SharedContent({this.text, this.imageUrl, this.imagePath});

  bool get hasContent =>
      (text != null && text!.isNotEmpty) ||
      (imageUrl != null && imageUrl!.isNotEmpty) ||
      (imagePath != null && imagePath!.isNotEmpty);

  @override
  String toString() =>
      'SharedContent(text: $text, imageUrl: $imageUrl, imagePath: $imagePath)';
}
