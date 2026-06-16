import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/feature_card.dart';
import '../../widgets/usage_tracker.dart';
import '../../widgets/upgrade_banner.dart';
import 'chat_screen.dart';
import 'translate_screen.dart';
import 'speech_to_text_screen.dart';
import 'profile_screen.dart';

class UserDashboard extends StatelessWidget {
  const UserDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().currentUser;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Icon(Icons.smart_toy, color: Colors.purple),
            const SizedBox(width: 8),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SmartAI', style: TextStyle(fontSize: 16)),
                Text('Your AI Assistant',
                    style: TextStyle(fontSize: 10, color: Colors.grey)),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
          CircleAvatar(
            backgroundImage:
                user?.avatarUrl != null ? NetworkImage(user!.avatarUrl!) : null,
            child: user?.avatarUrl == null
                ? Text(user?.name[0].toUpperCase() ?? 'U')
                : null,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hello, ${user?.name ?? "User"}! 👋',
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text('Welcome back! What would you like to do today?',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Colors.grey)),
            const SizedBox(height: 24),
            if (!(user?.isPremium ?? false))
              UsageTracker(
                messagesUsed: user?.dailyMessagesUsed ?? 0,
                messagesLimit: user?.dailyMessagesLimit ?? 50,
                onUpgradeTap: () => _showUpgradeDialog(context),
              ),
            const SizedBox(height: 24),
            Text('Features',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
              children: [
                FeatureCard(
                    title: 'AI Chat',
                    subtitle: 'Talk with AI assistant',
                    icon: Icons.chat_bubble_outline,
                    color: Colors.purple,
                    onTap: () => Navigator.push(context,
                        MaterialPageRoute(builder: (_) => const ChatScreen()))),
                FeatureCard(
                    title: 'Translate',
                    subtitle: 'Translate text instantly',
                    icon: Icons.translate_outlined,
                    color: Colors.green,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const TranslateScreen()))),
                FeatureCard(
                    title: 'Speech to Text',
                    subtitle: 'Convert speech to text',
                    icon: Icons.mic_outlined,
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const SpeechToTextScreen()))),
                FeatureCard(
                    title: 'Image Analysis',
                    subtitle: 'Analyze images with AI',
                    icon: Icons.image_outlined,
                    color: Colors.orange,
                    isLocked: !(user?.isPremium ?? false),
                    onTap: () => _showUpgradeDialog(context)),
                FeatureCard(
                    title: 'Text to Speech',
                    subtitle: 'Convert text to voice',
                    icon: Icons.record_voice_over_outlined,
                    color: Colors.pink,
                    isLocked: !(user?.isPremium ?? false),
                    onTap: () => _showUpgradeDialog(context)),
                FeatureCard(
                    title: 'Documents',
                    subtitle: 'Analyze your documents',
                    icon: Icons.description_outlined,
                    color: Colors.teal,
                    isLocked: !(user?.isPremium ?? false),
                    onTap: () => _showUpgradeDialog(context)),
              ],
            ),
            const SizedBox(height: 24),
            if (!(user?.isPremium ?? false))
              UpgradeBanner(onUpgradeTap: () => _showUpgradeDialog(context)),
            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.purple,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        onTap: (index) {
          if (index == 2)
            Navigator.push(context,
                MaterialPageRoute(builder: (_) => const ProfileScreen()));
        },
      ),
    );
  }

  void _showUpgradeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(Icons.workspace_premium, color: Colors.amber[700]),
          const SizedBox(width: 8),
          const Text('Upgrade to Premium')
        ]),
        content: const Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Unlock all features:'),
              SizedBox(height: 12),
              Text('✓ Unlimited AI messages'),
              Text('✓ Image & document analysis'),
              Text('✓ Priority support'),
            ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Maybe Later')),
          ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
              child: const Text('Upgrade Now')),
        ],
      ),
    );
  }
}
