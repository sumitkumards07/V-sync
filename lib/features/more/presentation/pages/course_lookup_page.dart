import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:vsync/core/widgets/coming_soon_placeholder.dart';

class CourseLookupPage extends StatelessWidget {
  const CourseLookupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          FHeader.nested(
            title: const Text("Course Hub"),
            prefixes: [FHeaderAction.back(onPress: () => Navigator.pop(context))],
          ),
          const Expanded(
            child: ComingSoonPlaceholder(
              title: "Course Hub",
              subtitle: "Access university-wide records, faculty details, and academic resources soon.",
              icon: FIcons.graduationCap,
            ),
          ),
        ],
      ),
    );
  }
}
