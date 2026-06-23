import 'package:flutter/material.dart';

class D {
  static bool isDark(BuildContext c) => Theme.of(c).brightness == Brightness.dark;

  static Color bg(BuildContext c) => isDark(c) ? const Color(0xFF0B0B0F) : const Color(0xFFF4F6FB);
  static Color card(BuildContext c) => isDark(c) ? const Color(0xFF1E1E2E) : Colors.white;
  static Color t1(BuildContext c) => isDark(c) ? const Color(0xFFF0F0F5) : const Color(0xFF12112A);
  static Color t2(BuildContext c) => isDark(c) ? const Color(0xFF9B9BA7) : const Color(0xFF7B7A8E);
  static Color t3(BuildContext c) => isDark(c) ? const Color(0xFF6B6B80) : const Color(0xFF9E9E9E);
  static Color bd(BuildContext c) => isDark(c) ? const Color(0xFF2A2A3E) : const Color(0xFFEAEAF4);
  static Color appBar(BuildContext c) => isDark(c) ? const Color(0xFF161622) : Colors.white;
  static Color inputFill(BuildContext c) => isDark(c) ? const Color(0xFF1C1C2D) : const Color(0xFFF5F6FA);
  static Color hover(BuildContext c) => isDark(c) ? const Color(0xFF252540) : const Color(0xFFF0F1F8);
  static Color divider(BuildContext c) => isDark(c) ? const Color(0xFF2A2A3E) : const Color(0xFFE8E8F0);
  static Color shimmer(BuildContext c) => isDark(c) ? const Color(0xFF252540) : const Color(0xFFF0F1F8);
}
