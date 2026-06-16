import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';

class TranslateScreen extends StatefulWidget {
  const TranslateScreen({super.key});
  @override
  State<TranslateScreen> createState() => _TranslateScreenState();
}

class _TranslateScreenState extends State<TranslateScreen> {
  final TextEditingController _inputController = TextEditingController();
  String _fromLang = 'English';
  String _toLang = 'French';
  String _result = '';
  bool _isTranslating = false;

  static const _primary = Color(0xFF10B981);
  static const _primaryLight = Color(0xFFD1FAE5);
  static const _bg = Color(0xFFF5F6FA);

  final List<String> _languages = ['English', 'French', 'Arabic', 'Spanish', 'German', 'Italian', 'Chinese', 'Japanese', 'Portuguese', 'Russian'];

  Future<void> _translate() async {
    if (_inputController.text.trim().isEmpty) return;
    setState(() { _isTranslating = true; _result = ''; });
    await Future.delayed(const Duration(seconds: 1));
    setState(() { _result = '(Simulated translation) Connect your translation API here.'; _isTranslating = false; });
  }

  void _swap() => setState(() { final tmp = _fromLang; _fromLang = _toLang; _toLang = tmp; });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1A1A2E)), onPressed: () => Navigator.pop(context)),
        title: Text('Translate', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Language selector row
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
            child: Row(children: [
              Expanded(child: _langDropdown(_fromLang, (v) => setState(() => _fromLang = v!))),
              GestureDetector(
                onTap: _swap,
                child: Container(
                  width: 36, height: 36,
                  decoration: BoxDecoration(color: _primaryLight, borderRadius: BorderRadius.circular(10)),
                  child: const Icon(Icons.swap_horiz_rounded, color: _primary, size: 20),
                ),
              ),
              Expanded(child: _langDropdown(_toLang, (v) => setState(() => _toLang = v!))),
            ]),
          ),
          const SizedBox(height: 14),

          // Input
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
            child: Column(children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: TextField(
                  controller: _inputController,
                  maxLines: 5,
                  style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF1A1A2E)),
                  decoration: InputDecoration.collapsed(hintText: 'Enter text to translate…', hintStyle: GoogleFonts.poppins(color: Colors.grey[400], fontSize: 14)),
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE5E7EB)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('${_inputController.text.length} chars', style: GoogleFonts.poppins(fontSize: 11, color: Colors.grey[400])),
                  IconButton(icon: Icon(Icons.clear_rounded, size: 18, color: Colors.grey[400]), onPressed: () { _inputController.clear(); setState(() {}); }, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
                ]),
              ),
            ]),
          ),
          const SizedBox(height: 14),

          // Translate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isTranslating ? null : _translate,
              icon: _isTranslating ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.translate_rounded, size: 18),
              label: Text(_isTranslating ? 'Translating…' : 'Translate Now', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primary, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0,
              ),
            ),
          ),

          // Result
          if (_result.isNotEmpty) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Translation', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: const Color(0xFF1A1A2E))),
                  GestureDetector(
                    onTap: () { Clipboard.setData(ClipboardData(text: _result)); ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Copied!'), behavior: SnackBarBehavior.floating)); },
                    child: const Icon(Icons.copy_rounded, size: 18, color: Color(0xFF6B7280)),
                  ),
                ]),
                const SizedBox(height: 10),
                Text(_result, style: GoogleFonts.poppins(fontSize: 14, color: const Color(0xFF1A1A2E), height: 1.6)),
              ]),
            ),
          ],

          const SizedBox(height: 24),

          // Tips
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: _primaryLight, borderRadius: BorderRadius.circular(14)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.info_outline_rounded, color: _primary, size: 20),
              const SizedBox(width: 10),
              Expanded(child: Text('Supports 100+ languages. For best results, use clear and complete sentences.', style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF065F46), height: 1.5))),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _langDropdown(String value, void Function(String?) onChanged) {
    return DropdownButton<String>(
      value: value, onChanged: onChanged, isExpanded: true, underline: const SizedBox(),
      style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF1A1A2E)),
      items: _languages.map((l) => DropdownMenuItem(value: l, child: Text(l, style: GoogleFonts.poppins(fontSize: 13)))).toList(),
    );
  }
}