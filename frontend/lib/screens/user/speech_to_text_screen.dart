import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class SpeechToTextScreen extends StatefulWidget {
  const SpeechToTextScreen({super.key});
  @override
  State<SpeechToTextScreen> createState() => _SpeechToTextScreenState();
}

class _SpeechToTextScreenState extends State<SpeechToTextScreen> with SingleTickerProviderStateMixin {
  bool _isRecording = false;
  String _transcription = '';
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;

  static const _primary = Color(0xFF8B5CF6);
  static const _primaryLight = Color(0xFFEDE9FE);
  static const _bg = Color(0xFFF5F6FA);

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.15).animate(CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut));
    _pulseController.stop();
  }

  @override
  void dispose() { _pulseController.dispose(); super.dispose(); }

  void _toggleRecording() {
    setState(() => _isRecording = !_isRecording);
    if (_isRecording) {
      _pulseController.repeat(reverse: true);
      // Simulate transcript after 3s
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted && _isRecording) {
          setState(() { _transcription = 'This is a simulated transcription. Connect your speech recognition API here.'; _isRecording = false; });
          _pulseController.stop();
        }
      });
    } else {
      _pulseController.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1A1A2E)), onPressed: () => Navigator.pop(context)),
        title: Text('Speech to Text', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(children: [
          const SizedBox(height: 20),

          // Mic button
          Center(child: AnimatedBuilder(
            animation: _pulseAnim,
            builder: (_, __) => Transform.scale(
              scale: _isRecording ? _pulseAnim.value : 1.0,
              child: GestureDetector(
                onTap: _toggleRecording,
                child: Container(
                  width: 110, height: 110,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _isRecording ? const Color(0xFFEF4444) : _primary,
                    boxShadow: [BoxShadow(color: (_isRecording ? const Color(0xFFEF4444) : _primary).withValues(alpha: 0.35), blurRadius: 24, spreadRadius: 4)],
                  ),
                  child: Icon(_isRecording ? Icons.stop_rounded : Icons.mic_rounded, color: Colors.white, size: 48),
                ),
              ),
            ),
          )),
          const SizedBox(height: 20),

          Text(
            _isRecording ? 'Listening…' : (_transcription.isEmpty ? 'Tap to start recording' : 'Recording complete'),
            style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E)),
          ),
          const SizedBox(height: 6),
          Text(
            _isRecording ? 'Speak clearly into your microphone' : 'Tap the mic to begin',
            style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[500]),
          ),

          const SizedBox(height: 32),

          // Transcription box
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 140),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _transcription.isNotEmpty ? _primary.withValues(alpha: 0.4) : const Color(0xFFE5E7EB)),
            ),
            child: _transcription.isEmpty
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.record_voice_over_rounded, size: 36, color: Colors.grey[200]),
                    const SizedBox(height: 8),
                    Text('Transcription will appear here', style: GoogleFonts.poppins(fontSize: 13, color: Colors.grey[400])),
                  ]))
                : Text(_transcription, style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF1A1A2E), height: 1.6)),
          ),

          if (_transcription.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: OutlinedButton.icon(
                onPressed: () { Clipboard.setData(ClipboardData(text: _transcription)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!'), behavior: SnackBarBehavior.floating)); },
                icon: const Icon(Icons.copy_rounded, size: 16), label: Text('Copy', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                style: OutlinedButton.styleFrom(foregroundColor: _primary, side: const BorderSide(color: Color(0xFFE5E7EB)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              )),
              const SizedBox(width: 10),
              Expanded(child: OutlinedButton.icon(
                onPressed: () => setState(() => _transcription = ''),
                icon: const Icon(Icons.refresh_rounded, size: 16), label: Text('Clear', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
                style: OutlinedButton.styleFrom(foregroundColor: Colors.grey[600], side: const BorderSide(color: Color(0xFFE5E7EB)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              )),
            ]),
          ],

          const SizedBox(height: 32),

          // Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: _primaryLight, borderRadius: BorderRadius.circular(14)),
            child: Column(children: [
              Row(children: [const Icon(Icons.tips_and_updates_rounded, color: _primary, size: 18), const SizedBox(width: 8), Text('Tips for better results', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: _primary))]),
              const SizedBox(height: 10),
              _tip('Speak clearly at a normal pace'),
              _tip('Minimize background noise'),
              _tip('Hold the phone 15–30 cm from your mouth'),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _tip(String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(children: [
      Container(width: 5, height: 5, decoration: const BoxDecoration(color: _primary, shape: BoxShape.circle)),
      const SizedBox(width: 10),
      Text(text, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF4C1D95))),
    ]),
  );
}