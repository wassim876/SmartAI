import 'package:flutter/material.dart';

class SpeechToTextScreen extends StatelessWidget {
  const SpeechToTextScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Speech to Text')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GestureDetector(
              onTap: () {
                // Implement speech recognition here
              },
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
                child: const Icon(Icons.mic, color: Colors.white, size: 50),
              ),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text('Tap the microphone to start recording', style: TextStyle(fontSize: 16, color: Colors.grey)),
            ),
            const SizedBox(height: 32),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 32),
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
              child: const Text('Transcribed text will appear here...', style: TextStyle(color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }
}