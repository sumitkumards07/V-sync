import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vsync/core/widgets/glass_surface.dart';

class PrivacyPage extends ConsumerWidget {
  const PrivacyPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(FIcons.chevronLeft, color: context.theme.colors.foreground),
                ),
                const SizedBox(width: 12),
                const Text(
                  "Privacy Portal",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _PrivacyHero(),
            const SizedBox(height: 32),
            _PrivacySection(
              icon: FIcons.shieldCheck,
              title: "Everything on Device",
              description:
                  "V-sync is designed with data sovereignty at its core. Your VTOP credentials, academic records, and app preferences never leave your device to any 3rd party server.",
              color: Colors.greenAccent,
            ),
            const SizedBox(height: 24),
            _PrivacySection(
              icon: FIcons.lock,
              title: "Secure Credentials",
              description:
                  "Your registration number and password are stored using system-level encryption (Keychain/Keystore). They are only used to authenticate directly with university servers.",
              color: Colors.blueAccent,
            ),
            const SizedBox(height: 24),
            _PrivacySection(
              icon: FIcons.globe,
              title: "Campus Services",
              description:
                  "Static data like Mess Menus and Travel Buddy posts are fetched from our secure cloud. No personal VTOP data is ever linked or shared with these services.",
              color: Colors.orangeAccent,
            ),
            const SizedBox(height: 24),
            _PrivacySection(
              icon: FIcons.userRoundX,
              title: "Zero Tracking",
              description:
                  "We do not sell your data. We do not use advertising cookies. Minimal anonymous diagnostics may be collected to fix crashes and improve app stability.",
              color: Colors.pinkAccent,
            ),
            const SizedBox(height: 48),
            Center(
              child: Column(
                children: [
                  const Text(
                    "Need more clarity?",
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Contact: sumitkumards07@gmail.com",
                    style: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrivacyHero extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GlassSurface(
      radius: 24,
      blur: 20,
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.theme.colors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(FIcons.shield, size: 48, color: context.theme.colors.primary),
          ),
          const SizedBox(height: 16),
          const Text(
            "Your Data, Your Control",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            "Transparency is not a feature, it's our foundation.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: context.theme.colors.mutedForeground,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacySection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final Color color;

  const _PrivacySection({
    required this.icon,
    required this.title,
    required this.description,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: context.theme.colors.mutedForeground,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
