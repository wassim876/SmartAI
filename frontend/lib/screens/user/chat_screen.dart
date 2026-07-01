import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/admin_notification_service.dart';
import '../../services/supabase_data_service.dart';
import '../../services/ai_service.dart';
import '../../theme/dark_mode_helpers.dart';

class ChatScreen extends StatefulWidget {
  final String initialPrompt;
  const ChatScreen({super.key, this.initialPrompt = ''});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, dynamic>> _messages = [];
  final List<_Attachment> _pendingAttachments = [];
  final Set<int> _bookmarkedIndices = {};
  bool _isTyping = false;
  bool _isRecording = false;
  bool _isStreaming = false;
  final ImagePicker _picker = ImagePicker();
  final AiService _ai = AiService();
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _speechAvailable = false;
  // Continuous dictation: the recognizer ends on a pause or when it hits a
  // platform time limit. While the user is still recording we commit the text
  // so far and restart, so it doesn't cut off mid-sentence.
  bool _wantListening = false;
  String _sttBase = '';

  String? _currentSessionId;
  List<_ChatSession> _sessions = [];
  bool _isLoadingSessions = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _primary = Color(0xFF5B4FE8);

  @override
  void initState() {
    super.initState();
    _loadSessions();
    _initSpeech();
    if (widget.initialPrompt.isNotEmpty) {
      _controller.text = widget.initialPrompt;
    }
  }

  Future<void> _initSpeech() async {
    try {
      _speechAvailable = await _speech.initialize(
        onStatus: _onSpeechStatus,
        onError: (_) {
          // Stop cleanly on error rather than looping restarts.
          if (mounted) {
            setState(() {
              _wantListening = false;
              _isRecording = false;
            });
          }
        },
      );
    } catch (_) {
      _speechAvailable = false;
    }
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _wantListening = false;
    _speech.stop();
    _tts.stop();
    super.dispose();
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(message), behavior: SnackBarBehavior.floating));
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(_scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _loadSessions() async {
    setState(() => _isLoadingSessions = true);
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) return;
      final rows = await SupabaseDataService().getChatSessions(limit: 100);
      final sessions = rows.map((row) {
        final messages =
            List<Map<String, dynamic>>.from(row['messages'] ?? []);
        final firstUserMsg = messages
            .where((m) => m['role'] == 'user')
            .map((m) => m['text'] ?? '')
            .firstWhere((t) => t.isNotEmpty, orElse: () => 'New Chat');
        final createdAt =
            DateTime.tryParse(row['created_at']?.toString() ?? '') ??
                DateTime.now();
        return _ChatSession(
          id: row['id'].toString(),
          title: firstUserMsg.length > 50
              ? '${firstUserMsg.substring(0, 50)}...'
              : firstUserMsg,
          createdAt: createdAt,
          messageCount: messages.length,
        );
      }).toList();
      if (mounted) {
        setState(() {
          _sessions = sessions;
          _isLoadingSessions = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoadingSessions = false);
    }
  }

  Future<void> _loadSession(_ChatSession session) async {
    Navigator.pop(context);
    try {
      final data = await SupabaseDataService().getChatSession(session.id);
      if (data == null) return;
      final messages = List<Map<String, dynamic>>.from(data['messages'] ?? []);
      if (mounted) {
        setState(() {
          _currentSessionId = session.id;
          _messages.clear();
          _bookmarkedIndices.clear();
          _messages.addAll(messages);
        });
        _scrollToBottom();
      }
    } catch (_) {}
  }

  void _startNewChat() {
    setState(() {
      _currentSessionId = null;
      _messages.clear();
      _pendingAttachments.clear();
      _bookmarkedIndices.clear();
      _controller.clear();
    });
  }

  void _deleteSession(_ChatSession session) async {
    try {
      await SupabaseDataService().deleteChatSession(session.id);
      if (!mounted) return;
      setState(() => _sessions.removeWhere((s) => s.id == session.id));
      if (_currentSessionId == session.id) _startNewChat();
      _showSnack(AppLocalizations.of(context).translate('chatDeleted'));
    } catch (e) {
      if (mounted) _showSnack('Error: $e');
    }
  }

  void _showAttachMenu() {
    final loc = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: D.card(context),
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(loc.translate('attach'),
                style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: D.t1(context))),
            const SizedBox(height: 8),
            _attachOption(Icons.photo_library_rounded, const Color(0xFF3B82F6),
                loc.translate('image'), loc.translate('uploadFromGallery'), () {
              Navigator.pop(context);
              _pickImage(ImageSource.gallery);
            }),
            _attachOption(Icons.camera_alt_rounded, const Color(0xFF8B5CF6),
                loc.translate('camera'), loc.translate('takeAPhoto'), () {
              Navigator.pop(context);
              _pickImage(ImageSource.camera);
            }),
            _attachOption(Icons.description_rounded, const Color(0xFF10B981),
                loc.translate('document'), loc.translate('pdfWordExcel'), () {
              Navigator.pop(context);
              _pickDocument();
            }),
            _attachOption(Icons.audio_file_rounded, const Color(0xFFF59E0B),
                loc.translate('audio'), loc.translate('mp3Wav'), () {
              Navigator.pop(context);
              _pickDocument();
            }),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  Widget _attachOption(IconData icon, Color color, String title,
      String subtitle, VoidCallback onTap) {
    return ListTile(
      leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color)),
      title: Text(title,
          style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500, color: D.t1(context))),
      subtitle: Text(subtitle,
          style: GoogleFonts.poppins(fontSize: 12, color: D.t2(context))),
      onTap: onTap,
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (source == ImageSource.gallery) {
        // file_picker works on desktop (macOS) where image_picker's gallery
        // source is unsupported; returns a readable file path on native.
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          withData: true, // load bytes: on web there is no file path
        );
        if (result != null && result.files.isNotEmpty) {
          final file = result.files.first;
          // `file.path` throws on web — only read it on native platforms.
          final path = kIsWeb ? '' : (file.path ?? '');
          if (file.bytes != null || path.isNotEmpty) {
            setState(() => _pendingAttachments.add(_Attachment(
                type: _AttachmentType.image,
                path: path,
                name: file.name,
                bytes: file.bytes)));
          }
        }
      } else {
        // Camera capture (mobile only) still uses image_picker.
        final XFile? img = await _picker.pickImage(
            source: source, maxWidth: 1800, maxHeight: 1800, imageQuality: 85);
        if (img != null) {
          setState(() => _pendingAttachments.add(_Attachment(
              type: _AttachmentType.image, path: img.path, name: img.name)));
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: $e'), behavior: SnackBarBehavior.floating));
      }
    }
  }

  Future<void> _pickDocument() async {
    try {
      final result = await FilePicker.platform.pickFiles(
          allowMultiple: false,
          type: FileType.custom,
          withData: true, // load bytes so we can read the document content
          allowedExtensions: [
            'pdf',
            'doc',
            'docx',
            'xls',
            'xlsx',
            'ppt',
            'pptx',
            'txt',
            'csv',
            'mp3',
            'wav',
            'm4a'
          ]);
      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;
        final ext = file.extension?.toLowerCase() ?? '';
        final type = (ext == 'mp3' || ext == 'wav' || ext == 'm4a')
            ? _AttachmentType.audio
            : _AttachmentType.document;
        // `file.path` throws on web — only read it on native platforms.
        final path = kIsWeb ? '' : (file.path ?? '');
        setState(() => _pendingAttachments.add(_Attachment(
            type: type, path: path, name: file.name, bytes: file.bytes)));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Error: $e'), behavior: SnackBarBehavior.floating));
      }
    }
  }

  void _removeAttachment(int index) =>
      setState(() => _pendingAttachments.removeAt(index));

  /// Extracts readable text from a document attachment so the (text-only) chat
  /// model can "read" it. Supports PDF (via Syncfusion) and plain text/CSV.
  /// Returns null for formats we can't parse client-side (doc/xls/ppt).
  Future<String?> _extractDocText(_Attachment a) async {
    final bytes =
        a.bytes ?? (a.path.isNotEmpty ? await File(a.path).readAsBytes() : null);
    if (bytes == null) return null;
    final ext = a.name.contains('.') ? a.name.split('.').last.toLowerCase() : '';
    try {
      if (ext == 'pdf') {
        final document = PdfDocument(inputBytes: bytes);
        final text = PdfTextExtractor(document).extractText();
        document.dispose();
        return text.trim();
      }
      if (ext == 'txt' || ext == 'csv') {
        return utf8.decode(bytes, allowMalformed: true).trim();
      }
    } catch (_) {
      // Unreadable/parse error → treat as no extractable text.
    }
    return null;
  }

  void _toggleBookmark(int msgIndex) {
    final loc = AppLocalizations.of(context);
    setState(() {
      if (_bookmarkedIndices.contains(msgIndex)) {
        _bookmarkedIndices.remove(msgIndex);
      } else {
        _bookmarkedIndices.add(msgIndex);
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(_bookmarkedIndices.contains(msgIndex)
              ? loc.translate('bookmarked')
              : loc.translate('bookmarkRemoved')),
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating),
    );
  }

  Future<void> _exportChat() async {
    final buffer = StringBuffer();
    buffer.writeln('SmartAI Chat Export');
    buffer.writeln('Date: ${DateTime.now().toString().split('.')[0]}');
    buffer.writeln('─' * 40);
    buffer.writeln();
    for (final msg in _messages) {
      final role = msg['role'] == 'user' ? 'You' : 'AI';
      final text = msg['text'] ?? '';
      final List<_Attachment> attachments = msg['attachments'] ?? [];
      buffer.writeln('$role:');
      if (attachments.isNotEmpty) {
        for (final a in attachments) {
          buffer.writeln('  [Attached: ${a.name}]');
        }
      }
      if (text.isNotEmpty) buffer.writeln(text);
      buffer.writeln();
    }
    await Clipboard.setData(ClipboardData(text: buffer.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(AppLocalizations.of(context).translate('chatCopied')),
          behavior: SnackBarBehavior.floating));
    }
  }

  Future<void> _speakText(String text) async {
    if (text.trim().isEmpty) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {
      _showSnack('Voice output is not available on this device.');
    }
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _pendingAttachments.isEmpty) return;
    _controller.clear();
    final attachments = List<_Attachment>.from(_pendingAttachments);
    // Capture context-dependent objects before any await
    final authProvider = context.read<AuthProvider>();
    final user = authProvider.currentUser;

    // Client-side pre-check for fast feedback; nim-chat enforces authoritatively.
    if (user != null && user.hasReachedDailyLimit) {
      _showSnack('You have reached your daily message limit.');
      return;
    }

    setState(() {
      _pendingAttachments.clear();
      _messages.add({'role': 'user', 'text': text, 'attachments': attachments});
      _isTyping = true;
      _isStreaming = true; // gates the send button while awaiting
    });
    _scrollToBottom();
    try {
      await AdminNotificationService.onNewChat(user?.displayName ?? 'Unknown');
    } catch (_) {}

    // OpenAI-style history (text only) for the chat model.
    final apiMessages = <Map<String, String>>[];
    for (final m in _messages) {
      final t = (m['text'] ?? '').toString();
      if (t.isEmpty) continue;
      apiMessages.add({
        'role': m['role'] == 'ai' ? 'assistant' : 'user',
        'content': t,
      });
    }

    // Encode the first attached image as a data URI → routes to the vision model.
    String? imageDataUrl;
    final images =
        attachments.where((a) => a.type == _AttachmentType.image).toList();
    if (images.isNotEmpty) {
      try {
        final img = images.first;
        // Prefer in-memory bytes (always present on web); fall back to the
        // file path on native.
        final bytes = img.bytes ??
            (img.path.isNotEmpty ? await File(img.path).readAsBytes() : null);
        if (bytes != null) {
          final ext =
              img.name.contains('.') ? img.name.split('.').last.toLowerCase() : 'jpg';
          final mime = ext == 'png' ? 'image/png' : 'image/jpeg';
          imageDataUrl = 'data:$mime;base64,${base64Encode(bytes)}';
        }
      } catch (_) {}
    }

    // Extract readable text from attached documents (PDF / txt / csv) so the
    // text-only chat model can actually read them.
    final docParts = <String>[];
    for (final d in attachments
        .where((a) => a.type == _AttachmentType.document)) {
      final text = await _extractDocText(d);
      if (text != null && text.isNotEmpty) {
        // Cap per-document so the prompt stays within the model's context.
        const maxChars = 24000;
        final clipped = text.length > maxChars
            ? '${text.substring(0, maxChars)}\n…[truncated]'
            : text;
        docParts.add('----- "${d.name}" -----\n$clipped');
      }
    }
    final docContext = docParts.join('\n\n');

    // Ensure at least one turn (e.g. attachment sent with no text).
    if (apiMessages.isEmpty) {
      apiMessages.add({
        'role': 'user',
        'content': imageDataUrl != null
            ? 'Describe this image.'
            : docContext.isNotEmpty
                ? 'Please read the attached document and summarize it.'
                : 'Please summarize the attached file.',
      });
    }

    // Attach the extracted document text to the final user turn as context.
    if (docContext.isNotEmpty) {
      for (int i = apiMessages.length - 1; i >= 0; i--) {
        if (apiMessages[i]['role'] == 'user') {
          apiMessages[i]['content'] =
              '${apiMessages[i]['content']}\n\n[Attached document content]\n$docContext';
          break;
        }
      }
    }

    String reply;
    try {
      reply = await _ai.chat(messages: apiMessages, imageDataUrl: imageDataUrl);
    } on AiQuotaException catch (e) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _isStreaming = false;
        _messages.add({'role': 'ai', 'text': '⚠️ ${e.message}'});
      });
      await authProvider.refreshCurrentUser();
      return;
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _isStreaming = false;
        _messages.add({
          'role': 'ai',
          'text': 'Sorry — I couldn\'t get a response. Please try again.'
        });
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      _isTyping = false;
      _isStreaming = false;
      _messages.add({'role': 'ai', 'text': reply});
    });
    _scrollToBottom();

    // nim-chat incremented usage server-side; refresh the local counter.
    await authProvider.refreshCurrentUser();
    await _saveChatToFirestore();
  }

  Future<void> _saveChatToFirestore() async {
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) return;
      final messages = _messages
          .map((m) => <String, dynamic>{'role': m['role'], 'text': m['text']})
          .toList();
      final title = messages
          .where((m) => m['role'] == 'user')
          .map((m) => (m['text'] ?? '').toString())
          .firstWhere((t) => t.isNotEmpty, orElse: () => 'New Chat');
      final id = await SupabaseDataService().saveChatSession(
        id: _currentSessionId,
        title: title,
        messages: messages,
      );
      _currentSessionId = id;
      await _loadSessions();
    } catch (_) {}
  }

  Future<void> _toggleRecording() async {
    // Continuous on-device dictation; recognized words stream into the input.
    if (_wantListening || _speech.isListening) {
      _wantListening = false;
      await _speech.stop();
      if (mounted) setState(() => _isRecording = false);
      return;
    }
    if (!_speechAvailable) {
      _speechAvailable = await _speech.initialize(onStatus: _onSpeechStatus);
      if (!_speechAvailable) {
        _showSnack('Speech recognition is not available on this device.');
        return;
      }
    }
    // Preserve anything already typed; speech is appended after it.
    _sttBase = _controller.text.trim();
    _wantListening = true;
    await _startListening();
  }

  /// Starts (or resumes) a listen session. The recognizer naturally ends on a
  /// pause or at a platform time limit; [_onSpeechStatus] restarts it while
  /// [_wantListening] is true so long utterances aren't cut off.
  Future<void> _startListening() async {
    if (!_wantListening || !mounted || _speech.isListening) return;
    try {
      await _speech.listen(
        onResult: (result) {
          if (!mounted) return;
          final words = result.recognizedWords;
          final combined = _sttBase.isEmpty
              ? words
              : (words.isEmpty ? _sttBase : '$_sttBase $words');
          setState(() {
            _controller.text = combined;
            _controller.selection =
                TextSelection.collapsed(offset: _controller.text.length);
          });
        },
        listenOptions: SpeechListenOptions(
          listenMode: ListenMode.dictation,
          partialResults: true,
          cancelOnError: false,
          listenFor: const Duration(minutes: 5),
          pauseFor: const Duration(seconds: 8),
        ),
      );
      if (mounted) setState(() => _isRecording = true);
    } catch (_) {
      if (mounted) {
        setState(() {
          _wantListening = false;
          _isRecording = false;
        });
      }
    }
  }

  /// Handles recognizer lifecycle. When a session ends but the user still wants
  /// to dictate, the recognized text is committed and a new session starts.
  void _onSpeechStatus(String status) {
    if (!mounted) return;
    if ((status == 'done' || status == 'notListening') && _wantListening) {
      _sttBase = _controller.text.trim();
      // Brief delay so the previous session fully tears down before restart.
      Future.delayed(const Duration(milliseconds: 50), _startListening);
      return;
    }
    setState(() => _isRecording = _wantListening || _speech.isListening);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: D.bg(context),
      drawer: _buildHistoryDrawer(),
      appBar: AppBar(
        backgroundColor: D.appBar(context),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu_rounded, color: D.t1(context), size: 24),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Row(children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset('assets/images/smartai.png',
                width: 38, height: 38, fit: BoxFit.cover),
          ),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(loc.translate('aiChatTitle'),
                style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: D.t1(context))),
            Row(children: [
              Container(
                  width: 7,
                  height: 7,
                  decoration: const BoxDecoration(
                      color: Color(0xFF22C55E), shape: BoxShape.circle)),
              const SizedBox(width: 4),
              Text(loc.translate('online'),
                  style:
                      GoogleFonts.poppins(fontSize: 11, color: D.t2(context))),
            ]),
          ]),
        ]),
        actions: [
          IconButton(
              icon: Icon(Icons.add_comment_rounded,
                  color: D.t2(context), size: 22),
              onPressed: _startNewChat,
              tooltip: loc.translate('newChat')),
          IconButton(
              icon:
                  Icon(Icons.ios_share_rounded, color: D.t2(context), size: 22),
              onPressed: _messages.isEmpty ? null : _exportChat,
              tooltip: loc.translate('exportChat')),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: _messages.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  controller: _scrollController,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: _messages.length + (_isTyping ? 1 : 0),
                  itemBuilder: (context, i) {
                    if (_isTyping && i == _messages.length) {
                      return _buildTypingIndicator();
                    }
                    return _buildMessage(_messages[i], i);
                  },
                ),
        ),
        _buildInputBar(),
      ]),
    );
  }

  Widget _buildHistoryDrawer() {
    final loc = AppLocalizations.of(context);
    return Drawer(
      backgroundColor: D.card(context),
      width: 280,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _startNewChat,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: D.bd(context)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(children: [
                      Icon(Icons.edit_square, color: D.t1(context), size: 18),
                      const SizedBox(width: 10),
                      Text(loc.translate('newChat'),
                          style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: D.t1(context))),
                    ]),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(loc.translate('chatHistory'),
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: D.t2(context),
                      letterSpacing: 0.5)),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _isLoadingSessions
                  ? Center(
                      child: CircularProgressIndicator(
                          color: _primary, strokeWidth: 2))
                  : _sessions.isEmpty
                      ? Center(
                          child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.chat_bubble_outline_rounded,
                                    size: 40, color: D.t2(context)),
                                const SizedBox(height: 12),
                                Text(loc.translate('noConversations'),
                                    style: GoogleFonts.poppins(
                                        fontSize: 13, color: D.t2(context))),
                              ]),
                        )
                      : _buildSessionList(),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: D.bg(context),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: D.bd(context)),
                    ),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.home_rounded,
                              color: D.t1(context), size: 18),
                          const SizedBox(width: 8),
                          Text(loc.translate('backToHome'),
                              style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: D.t1(context))),
                        ]),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionList() {
    final grouped = <String, List<_ChatSession>>{};
    for (final s in _sessions) {
      final label = _dateLabel(s.createdAt);
      grouped.putIfAbsent(label, () => []).add(s);
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      itemCount: grouped.length,
      itemBuilder: (_, sectionIndex) {
        final label = grouped.keys.elementAt(sectionIndex);
        final sessions = grouped[label]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
              child: Text(label,
                  style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: D.t2(context))),
            ),
            ...sessions.map((s) => _buildSessionTile(s)),
          ],
        );
      },
    );
  }

  Widget _buildSessionTile(_ChatSession session) {
    final isActive = _currentSessionId == session.id;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Material(
        color: isActive ? _primary.withValues(alpha: 0.12) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _loadSession(session),
          onLongPress: () => _showDeleteDialog(session),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Row(children: [
              Icon(Icons.chat_bubble_outline_rounded,
                  size: 16, color: isActive ? _primary : D.t2(context)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(session.title,
                    style: GoogleFonts.poppins(
                        fontSize: 13,
                        color: isActive ? _primary : D.t1(context),
                        fontWeight:
                            isActive ? FontWeight.w500 : FontWeight.w400),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              const SizedBox(width: 4),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: IconButton(
                  icon: Icon(Icons.delete_outline_rounded,
                      size: 18, color: D.t2(context)),
                  tooltip: AppLocalizations.of(context).translate('deleteChat'),
                  splashRadius: 18,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 32, minHeight: 32),
                  onPressed: () => _showDeleteDialog(session),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  void _showDeleteDialog(_ChatSession session) {
    final loc = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: D.card(context),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(loc.translate('deleteChat'),
            style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600, color: D.t1(context))),
        content: Text(loc.translate('deleteChatConfirm'),
            style: GoogleFonts.poppins(fontSize: 14, color: D.t2(context))),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(loc.translate('cancel'),
                  style: GoogleFonts.poppins(color: D.t2(context)))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteSession(session);
            },
            child: Text(loc.translate('delete'),
                style: GoogleFonts.poppins(
                    color: Colors.red, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  String _dateLabel(DateTime date) {
    final loc = AppLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final diff = today.difference(dateOnly).inDays;
    if (diff == 0) return loc.translate('today');
    if (diff == 1) return loc.translate('yesterday');
    if (diff < 7) return loc.translate('previous7Days');
    if (diff < 30) return loc.translate('previous30Days');
    return '${date.month}/${date.year}';
  }

  Widget _buildEmptyState() {
    final loc = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                  color: _primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(22)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Image.asset('assets/images/bot.png',
                    width: 80, height: 80, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 16),
            Text(loc.translate('startConversation'),
                style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: D.t1(context))),
            const SizedBox(height: 6),
            Text(loc.translate('askMeAnything'),
                style: GoogleFonts.poppins(fontSize: 13, color: D.t2(context)),
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            Wrap(
                spacing: 8,
                runSpacing: 8,
                alignment: WrapAlignment.center,
                children: [
                  _SuggestionChip(
                      icon: Icons.auto_awesome_rounded,
                      color: const Color(0xFF6366F1),
                      label: loc.translate('explainConcept'),
                      onTap: () {
                        _controller.text =
                            'Explain quantum computing in simple terms';
                        _sendMessage();
                      }),
                  _SuggestionChip(
                      icon: Icons.image_search_rounded,
                      color: const Color(0xFF3B82F6),
                      label: loc.translate('analyzeImage'),
                      onTap: () => _showAttachMenu()),
                  _SuggestionChip(
                      icon: Icons.mic_rounded,
                      color: const Color(0xFF8B5CF6),
                      label: loc.translate('voiceInput'),
                      onTap: () => _toggleRecording()),
                  _SuggestionChip(
                      icon: Icons.description_rounded,
                      color: const Color(0xFF06B6D4),
                      label: loc.translate('summarizeDocument'),
                      onTap: () => _showAttachMenu()),
                  _SuggestionChip(
                      icon: Icons.code_rounded,
                      color: const Color(0xFF10B981),
                      label: loc.translate('writeCode'),
                      onTap: () {
                        _controller.text =
                            'Write a Python function to sort a list';
                        _sendMessage();
                      }),
                  _SuggestionChip(
                      icon: Icons.translate_rounded,
                      color: const Color(0xFFF59E0B),
                      label: loc.translate('translateText'),
                      onTap: () {
                        _controller.text =
                            'Translate "Hello, how are you?" to French';
                        _sendMessage();
                      }),
                ]),
          ])),
    );
  }

  Widget _buildMessage(Map<String, dynamic> msg, int index) {
    final isUser = msg['role'] == 'user';
    final text = msg['text'] ?? '';
    final List<_Attachment> attachments = msg['attachments'] ?? [];
    final isBookmarked = _bookmarkedIndices.contains(index);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset('assets/images/smartai.png',
                  width: 38, height: 38, fit: BoxFit.cover),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
                crossAxisAlignment:
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: isUser ? _primary : D.card(context),
                      borderRadius: BorderRadius.only(
                        topLeft: const Radius.circular(16),
                        topRight: const Radius.circular(16),
                        bottomLeft: Radius.circular(isUser ? 16 : 4),
                        bottomRight: Radius.circular(isUser ? 4 : 16),
                      ),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 6,
                            offset: const Offset(0, 2))
                      ],
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (attachments.isNotEmpty) ...[
                            ...attachments
                                .map((a) => _buildAttachmentPreview(a, isUser)),
                            if (text.isNotEmpty) const SizedBox(height: 6),
                          ],
                          if (text.isNotEmpty)
                            Text(text,
                                style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color:
                                        isUser ? Colors.white : D.t1(context),
                                    height: 1.5)),
                        ]),
                  ),
                  if (!isUser && text.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                                onTap: () => _toggleBookmark(index),
                                child: Icon(
                                    isBookmarked
                                        ? Icons.bookmark_rounded
                                        : Icons.bookmark_border_rounded,
                                    size: 16,
                                    color: isBookmarked
                                        ? _primary
                                        : D.t2(context)))),
                        const SizedBox(width: 12),
                        MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () {
                                Clipboard.setData(ClipboardData(text: text));
                                ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                        content: Text(AppLocalizations.of(context).translate('copied')),
                                        duration: Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating));
                              },
                              child: Icon(Icons.copy_rounded,
                                  size: 16, color: D.t2(context)),
                            )),
                        const SizedBox(width: 12),
                        MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                                onTap: () => _speakText(text),
                                child: Icon(Icons.volume_up_rounded,
                                    size: 16, color: D.t2(context)))),
                      ]),
                    ),
                ]),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }

  Widget _buildAttachmentPreview(_Attachment a, bool isUser) {
    final textColor = isUser ? Colors.white70 : D.t2(context);
    final bgColor =
        isUser ? Colors.white.withValues(alpha: 0.15) : D.bg(context);
    switch (a.type) {
      case _AttachmentType.image:
        return Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Stack(children: [
              a.bytes != null
                  ? Image.memory(a.bytes!,
                      width: 200, height: 140, fit: BoxFit.cover)
                  : Image.file(File(a.path),
                      width: 200, height: 140, fit: BoxFit.cover),
              Positioned(
                  top: 4,
                  right: 4,
                  child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(4)),
                      child: const Icon(Icons.image_rounded,
                          color: Colors.white, size: 12))),
            ]),
          ),
        );
      case _AttachmentType.document:
        return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Icon(Icons.description_rounded,
                  color: Color(0xFF10B981), size: 20),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(a.name,
                      style:
                          GoogleFonts.poppins(fontSize: 12, color: textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis))
            ]));
      case _AttachmentType.audio:
        return Container(
            margin: const EdgeInsets.only(bottom: 6),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
                color: bgColor, borderRadius: BorderRadius.circular(8)),
            child: Row(children: [
              const Icon(Icons.audio_file_rounded,
                  color: Color(0xFFF59E0B), size: 20),
              const SizedBox(width: 8),
              Expanded(
                  child: Text(a.name,
                      style:
                          GoogleFonts.poppins(fontSize: 12, color: textColor),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis))
            ]));
    }
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.asset('assets/images/smartai.png',
              width: 34, height: 34, fit: BoxFit.cover),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
              color: D.card(context), borderRadius: BorderRadius.circular(16)),
          child: Row(children: [
            _dot(0),
            const SizedBox(width: 4),
            _dot(200),
            const SizedBox(width: 4),
            _dot(400)
          ]),
        ),
      ]),
    );
  }

  Widget _dot(int delay) => TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: Duration(milliseconds: 600 + delay),
        builder: (_, v, __) => Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(
                color: Colors.grey[400]!.withValues(alpha: 0.4 + 0.6 * v),
                shape: BoxShape.circle)),
      );

  Widget _buildInputBar() {
    final loc = AppLocalizations.of(context);
    return Container(
      padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 10,
          bottom: MediaQuery.of(context).padding.bottom + 10),
      decoration: BoxDecoration(
          color: D.card(context),
          border: Border(top: BorderSide(color: D.bd(context)))),
      child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_pendingAttachments.isNotEmpty)
              Container(
                height: 72,
                margin: const EdgeInsets.only(bottom: 10),
                child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _pendingAttachments.length,
                    itemBuilder: (_, i) {
                      final a = _pendingAttachments[i];
                      return Container(
                          width: 72,
                          margin: const EdgeInsets.only(right: 8),
                          child: Stack(clipBehavior: Clip.none, children: [
                            Positioned.fill(
                                child: a.type == _AttachmentType.image
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: a.bytes != null
                                            ? Image.memory(a.bytes!,
                                                fit: BoxFit.cover)
                                            : Image.file(File(a.path),
                                                fit: BoxFit.cover))
                                    : Container(
                                        decoration: BoxDecoration(
                                            color: a.type ==
                                                    _AttachmentType.document
                                                ? const Color(0xFFECFDF5)
                                                : const Color(0xFFFEF3C7),
                                            borderRadius:
                                                BorderRadius.circular(10)),
                                        child: Icon(
                                            a.type == _AttachmentType.document
                                                ? Icons.description_rounded
                                                : Icons.audio_file_rounded,
                                            color: a.type ==
                                                    _AttachmentType.document
                                                ? const Color(0xFF10B981)
                                                : const Color(0xFFF59E0B),
                                            size: 28))),
                            Positioned(
                                top: -4,
                                right: -4,
                                child: MouseRegion(
                                    cursor: SystemMouseCursors.click,
                                    child: GestureDetector(
                                        onTap: () => _removeAttachment(i),
                                        child: Container(
                                            width: 20,
                                            height: 20,
                                            decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle),
                                            child: const Icon(
                                                Icons.close_rounded,
                                                color: Colors.white,
                                                size: 12))))),
                            if (a.type != _AttachmentType.image)
                              Positioned(
                                  bottom: 4,
                                  left: 4,
                                  right: 4,
                                  child: Text(a.name,
                                      style: GoogleFonts.poppins(
                                          fontSize: 8, color: D.t2(context)),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis)),
                          ]));
                    }),
              ),
            Row(children: [
              MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                      onTap: _showAttachMenu,
                      child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              color: D.bg(context),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: D.bd(context))),
                          child: Icon(Icons.add_rounded,
                              color: D.t2(context), size: 22)))),
              const SizedBox(width: 8),
              Expanded(
                  child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _sendMessage(),
                      style: GoogleFonts.poppins(
                          fontSize: 14, color: D.t1(context)),
                      decoration: InputDecoration(
                          hintText: _isRecording
                              ? loc.translate('listening')
                              : loc.translate('typeMessage'),
                          hintStyle: GoogleFonts.poppins(
                              color: D.t2(context), fontSize: 14),
                          filled: true,
                          fillColor: D.bg(context),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: const BorderSide(
                                  color: _primary, width: 1.5))))),
              const SizedBox(width: 8),
              MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                      onTap: _toggleRecording,
                      child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              color: _isRecording
                                  ? const Color(0xFFEF4444)
                                  : D.bg(context),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                  color: _isRecording
                                      ? const Color(0xFFEF4444)
                                      : D.bd(context))),
                          child: Icon(
                              _isRecording
                                  ? Icons.stop_rounded
                                  : Icons.mic_rounded,
                              color:
                                  _isRecording ? Colors.white : D.t2(context),
                              size: 20)))),
              const SizedBox(width: 8),
              MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                      onTap: _isStreaming ? null : _sendMessage,
                      child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                              color: _primary,
                              borderRadius: BorderRadius.circular(14)),
                          child: const Icon(Icons.send_rounded,
                              color: Colors.white, size: 20)))),
            ]),
          ]),
    );
  }
}

enum _AttachmentType { image, document, audio }

class _Attachment {
  final _AttachmentType type;
  final String path; // native file path; '' on web (use [bytes] there)
  final String name;
  final Uint8List? bytes; // in-memory data; always populated on web
  const _Attachment(
      {required this.type,
      required this.path,
      required this.name,
      this.bytes});
}

class _ChatSession {
  final String id;
  final String title;
  final DateTime createdAt;
  final int messageCount;
  const _ChatSession(
      {required this.id,
      required this.title,
      required this.createdAt,
      required this.messageCount});
}

class _SuggestionChip extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;
  const _SuggestionChip(
      {required this.icon,
      required this.color,
      required this.label,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
              color: D.card(context),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                    color: color.withValues(alpha: 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2))
              ]),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(width: 6),
            Text(label,
                style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: D.t1(context))),
          ]),
        ),
      ),
    );
  }
}
