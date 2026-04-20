import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:vsync/core/widgets/coming_soon_placeholder.dart';

class CourseMaterialPage extends StatelessWidget {
  const CourseMaterialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          FHeader.nested(
            title: const Text("Course Materials"),
            prefixes: [FHeaderAction.back(onPress: () => Navigator.pop(context))],
          ),
          const Expanded(
            child: ComingSoonPlaceholder(
              title: "Course Materials",
              subtitle: "Module-wise academic content and study materials will be available here soon.",
              icon: FIcons.library,
            ),
          ),
        ],
      ),
    );
  }
}
