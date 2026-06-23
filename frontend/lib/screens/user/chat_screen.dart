import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../providers/auth_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../services/admin_notification_service.dart';
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

  String? _currentSessionId;
  List<_ChatSession> _sessions = [];
  bool _isLoadingSessions = true;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  static const _primary = Color(0xFF5B4FE8);

  @override
  void initState() {
    super.initState();
    _loadSessions();
    if (widget.initialPrompt.isNotEmpty) {
      _controller.text = widget.initialPrompt;
    }
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
      final snap = await FirebaseFirestore.instance
          .collection('chat_sessions')
          .where('userId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .limit(100)
          .get();
      final sessions = snap.docs.map((doc) {
        final data = doc.data();
        final messages =
            List<Map<String, dynamic>>.from(data['messages'] ?? []);
        final firstUserMsg = messages
            .where((m) => m['role'] == 'user')
            .map((m) => m['text'] ?? '')
            .firstWhere((t) => t.isNotEmpty, orElse: () => 'New Chat');
        final createdAt =
            (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
        return _ChatSession(
          id: doc.id,
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
      final doc = await FirebaseFirestore.instance
          .collection('chat_sessions')
          .doc(session.id)
          .get();
      if (!doc.exists) return;
      final data = doc.data()!;
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
      await FirebaseFirestore.instance
          .collection('chat_sessions')
          .doc(session.id)
          .delete();
      setState(() => _sessions.removeWhere((s) => s.id == session.id));
      if (_currentSessionId == session.id) _startNewChat();
    } catch (_) {}
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
      final XFile? img = await _picker.pickImage(
          source: source, maxWidth: 1800, maxHeight: 1800, imageQuality: 85);
      if (img != null) {
        setState(() => _pendingAttachments.add(_Attachment(
            type: _AttachmentType.image, path: img.path, name: img.name)));
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
        setState(() => _pendingAttachments.add(
            _Attachment(type: type, path: file.path ?? '', name: file.name)));
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
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('TTS: Connect a TTS API to enable voice output'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2)));
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty && _pendingAttachments.isEmpty) return;
    _controller.clear();
    final attachments = List<_Attachment>.from(_pendingAttachments);
    setState(() {
      _pendingAttachments.clear();
      _messages.add({'role': 'user', 'text': text, 'attachments': attachments});
      _isTyping = true;
    });
    _scrollToBottom();
    try {
      await context.read<AuthProvider>().incrementDailyMessages();
    } catch (_) {}
    try {
      final user = context.read<AuthProvider>().currentUser;
      await AdminNotificationService.onNewChat(user?.displayName ?? 'Unknown');
    } catch (_) {}

    String fullReply;
    final hasImages = attachments.any((a) => a.type == _AttachmentType.image);
    final hasDocs = attachments.any((a) => a.type == _AttachmentType.document);
    if (hasImages) {
      fullReply =
          'I can see the image you shared. Here\'s my analysis: This appears to be an interesting image. In production, this would use AI vision API to analyze the content in detail including objects, scene description, colors, and any text found.';
    } else if (hasDocs) {
      fullReply =
          'I\'ve received your document. In production, I would read and summarize its contents for you. Here are the key points that would be extracted from the document.';
    } else {
      fullReply =
          'This is a simulated AI response. In production, this would be connected to an actual AI API that generates intelligent responses to your questions and prompts.';
    }

    setState(() {
      _messages.add({'role': 'ai', 'text': ''});
      _isTyping = false;
      _isStreaming = true;
    });

    final aiIndex = _messages.length - 1;
    for (int i = 0; i < fullReply.length; i++) {
      if (!mounted || !_isStreaming) break;
      await Future.delayed(const Duration(milliseconds: 18));
      if (!mounted) return;
      setState(() {
        _messages[aiIndex]['text'] = fullReply.substring(0, i + 1);
      });
      if (i % 10 == 0) _scrollToBottom();
    }
    if (mounted) {
      setState(() => _isStreaming = false);
      _scrollToBottom();
    }
    await _saveChatToFirestore();
  }

  Future<void> _saveChatToFirestore() async {
    try {
      final user = context.read<AuthProvider>().currentUser;
      if (user == null) return;
      final sessionData = {
        'userId': user.uid,
        'messages': _messages
            .map((m) => {'role': m['role'], 'text': m['text']})
            .toList(),
        'createdAt': FieldValue.serverTimestamp(),
      };
      if (_currentSessionId != null) {
        await FirebaseFirestore.instance
            .collection('chat_sessions')
            .doc(_currentSessionId)
            .update(sessionData);
      } else {
        final doc = await FirebaseFirestore.instance
            .collection('chat_sessions')
            .add(sessionData);
        _currentSessionId = doc.id;
      }
      await _loadSessions();
    } catch (_) {}
  }

  void _toggleRecording() {
    setState(() => _isRecording = !_isRecording);
    if (_isRecording) {
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isRecording) {
          setState(() {
            _isRecording = false;
            _controller.text =
                'This is a simulated transcription. Connect your speech recognition API here.';
          });
        }
      });
    }
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
              Icon(Icons.chevron_right_rounded, size: 16, color: D.t2(context)),
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
              Image.file(File(a.path),
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
                                        child: Image.file(File(a.path),
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
  final String path;
  final String name;
  const _Attachment(
      {required this.type, required this.path, required this.name});
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
