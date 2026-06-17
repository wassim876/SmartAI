import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class ImageAnalysisScreen extends StatefulWidget {
  const ImageAnalysisScreen({super.key});
  @override
  State<ImageAnalysisScreen> createState() => _ImageAnalysisScreenState();
}

class _ImageAnalysisScreenState extends State<ImageAnalysisScreen> {
  File? _selectedImage;
  bool _isAnalyzing = false;
  String? _result;
  final ImagePicker _picker = ImagePicker();

  static const _primary = Color(0xFF3B82F6);
  static const _primaryLight = Color(0xFFEFF6FF);
  static const _bg = Color(0xFFF5F6FA);

  Future<void> _pickImage(ImageSource source) async {
    try {
      final XFile? img = await _picker.pickImage(source: source, maxWidth: 1800, maxHeight: 1800, imageQuality: 85);
      if (img != null) setState(() { _selectedImage = File(img.path); _result = null; });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), behavior: SnackBarBehavior.floating));
    }
  }

  Future<void> _analyze() async {
    if (_selectedImage == null) return;
    setState(() { _isAnalyzing = true; });
    try { await context.read<AuthProvider>().incrementDailyMessages(); } catch (_) {}
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    setState(() {
      _isAnalyzing = false;
      _result = 'This is a simulated analysis result. In production, this would contain the AI\'s detailed analysis of your image including detected objects, scene description, colors, and any text found.';
    });
  }

  void _showSourcePicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => SafeArea(child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 36, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
          const SizedBox(height: 16),
          ListTile(
            leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: _primaryLight, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.camera_alt_rounded, color: _primary)),
            title: Text('Take a Photo', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            onTap: () { Navigator.pop(context); _pickImage(ImageSource.camera); },
          ),
          ListTile(
            leading: Container(width: 40, height: 40, decoration: BoxDecoration(color: _primaryLight, borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.photo_library_rounded, color: _primary)),
            title: Text('Choose from Gallery', style: GoogleFonts.poppins(fontWeight: FontWeight.w500)),
            onTap: () { Navigator.pop(context); _pickImage(ImageSource.gallery); },
          ),
        ]),
      )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white, elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Color(0xFF1A1A2E)), onPressed: () => Navigator.pop(context)),
        title: Text('Image Analysis', style: GoogleFonts.poppins(fontSize: 17, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
        actions: [
          if (_selectedImage != null)
            IconButton(icon: Icon(Icons.delete_outline_rounded, color: Colors.grey[600]), onPressed: () => setState(() { _selectedImage = null; _result = null; })),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          // Image area
          GestureDetector(
            onTap: _showSourcePicker,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 240,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _selectedImage != null ? _primary.withValues(alpha: 0.4) : const Color(0xFFE5E7EB), width: _selectedImage != null ? 1.5 : 1),
              ),
              child: _selectedImage == null
                  ? Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(width: 64, height: 64, decoration: BoxDecoration(color: _primaryLight, borderRadius: BorderRadius.circular(18)),
                          child: const Icon(Icons.add_photo_alternate_rounded, color: _primary, size: 32)),
                      const SizedBox(height: 14),
                      Text('Tap to upload an image', style: GoogleFonts.poppins(fontSize: 15, fontWeight: FontWeight.w600, color: const Color(0xFF1A1A2E))),
                      const SizedBox(height: 4),
                      Text('Supports JPG, PNG', style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[400])),
                    ])
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(17),
                      child: Stack(fit: StackFit.expand, children: [
                        Image.file(_selectedImage!, fit: BoxFit.cover),
                        Positioned(bottom: 12, right: 12,
                          child: GestureDetector(
                            onTap: _showSourcePicker,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                              decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(20)),
                              child: Row(children: [const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 14), const SizedBox(width: 5), Text('Change', style: GoogleFonts.poppins(color: Colors.white, fontSize: 12))]),
                            ),
                          )),
                      ]),
                    ),
            ),
          ),
          const SizedBox(height: 14),

          // Analyze button
          if (_selectedImage != null && _result == null)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isAnalyzing ? null : _analyze,
                icon: _isAnalyzing
                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Icon(Icons.auto_awesome_rounded, size: 18),
                label: Text(_isAnalyzing ? 'Analyzing…' : 'Analyze Image', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primary, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0,
                ),
              ),
            ),

          // Result
          if (_result != null) ...[
            const SizedBox(height: 14),
            Container(
              width: double.infinity, padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(width: 32, height: 32, decoration: BoxDecoration(color: const Color(0xFFD1FAE5), borderRadius: BorderRadius.circular(8)),
                      child: const Icon(Icons.check_rounded, color: Color(0xFF10B981), size: 18)),
                  const SizedBox(width: 10),
                  Text('Analysis Complete', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 14, color: const Color(0xFF1A1A2E))),
                ]),
                const SizedBox(height: 12),
                Text(_result!, style: GoogleFonts.poppins(fontSize: 13, color: const Color(0xFF374151), height: 1.6)),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => setState(() { _selectedImage = null; _result = null; }),
                  child: Text('Analyze another image →', style: GoogleFonts.poppins(fontSize: 13, fontWeight: FontWeight.w600, color: _primary)),
                ),
              ]),
            ),
          ],

          const SizedBox(height: 20),

          // Capabilities
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: _primaryLight, borderRadius: BorderRadius.circular(14)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('What I can analyze', style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 13, color: _primary)),
              const SizedBox(height: 12),
              Row(children: [
                Expanded(child: Column(children: [_cap(Icons.visibility_rounded, 'Objects & Scenes'), _cap(Icons.text_fields_rounded, 'Text (OCR)')])),
                Expanded(child: Column(children: [_cap(Icons.face_rounded, 'Faces & Emotions'), _cap(Icons.palette_rounded, 'Colors')])),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _cap(IconData icon, String label) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(children: [
      Icon(icon, size: 16, color: _primary),
      const SizedBox(width: 8),
      Text(label, style: GoogleFonts.poppins(fontSize: 12, color: const Color(0xFF1E40AF))),
    ]),
  );
}