import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:forui/forui.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:vsync/core/providers/theme_provider.dart';
import 'package:vsync/core/theme/app_theme.dart';
import 'package:vsync/features/attendance/presentation/widgets/attendance_colors.dart';

class AttendanceCalculator extends HookConsumerWidget {
  final int currentAttended;
  final int currentTotal;

  const AttendanceCalculator({
    super.key,
    required this.currentAttended,
    required this.currentTotal,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    (int, int) getDefaultFuturePlan(int attended, int total) {
      if (total <= 0) return (0, 0);
      final currentPct = (attended / total) * 100;
      if (currentPct >= 75) {
        final maxSkip = ((4 * attended - 3 * total) / 3).floor();
        return (0, maxSkip > 0 ? maxSkip : 0);
      }
      final needAttend = 3 * total - 4 * attended;
      return (needAttend > 0 ? needAttend : 0, 0);
    }

    final initialPlan = useMemoized(
      () => getDefaultFuturePlan(currentAttended, currentTotal),
      [currentAttended, currentTotal],
    );
    final attended = useState(currentAttended);
    final total = useState(currentTotal);
    final editCurrent = useState(false);
    final futureAttend = useState(initialPlan.$1);
    final futureSkip = useState(initialPlan.$2);

    useEffect(() {
      final defaultPlan = getDefaultFuturePlan(attended.value, total.value);
      futureAttend.value = defaultPlan.$1;
      futureSkip.value = defaultPlan.$2;
      return null;
    }, [attended.value, total.value]);

    double getCurrentPercentage() {
      if (total.value == 0) return 0.0;
      return (attended.value / total.value) * 100;
    }

    double getPredictedPercentage() {
      final newTotal = total.value + futureAttend.value + futureSkip.value;
      final newAttended = attended.value + futureAttend.value;
      if (newTotal == 0) return 0.0;
      return (newAttended / newTotal) * 100;
    }

    Color getPercentageColor(double percentage) {
      if (percentage >= 75) return AttendanceColors.presentText;
      return AttendanceColors.absentText;
    }

    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFF0B0E14),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Compact Header: Current State
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF151922),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.white.withOpacity(0.05)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Current Session",
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withOpacity(0.4),
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              "${attended.value}/${total.value}",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFFE2E8F0),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                "classes",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white.withOpacity(0.3),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _buildPercentageBadge(getCurrentPercentage()),
                  const SizedBox(width: 8),
                  // New Edit Button
                  FTappable(
                    onPress: () => editCurrent.value = !editCurrent.value,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: editCurrent.value
                            ? kUniversityBlue.withOpacity(0.1)
                            : Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        editCurrent.value ? Icons.check_rounded : Icons.edit_rounded,
                        size: 18,
                        color: editCurrent.value
                            ? kUniversityBlue
                            : Colors.white.withOpacity(0.5),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            if (editCurrent.value) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildStepperCard(
                      label: "Adjust Attended",
                      value: attended.value,
                      onIncrement: () {
                        attended.value++;
                        total.value++;
                      },
                      onDecrement: () {
                        if (attended.value > 0) {
                          attended.value--;
                          total.value--;
                        }
                      },
                      color: const Color(0xFF34D399),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildStepperCard(
                      label: "Adjust Total",
                      value: total.value,
                      onIncrement: () => total.value++,
                      onDecrement: () {
                        if (total.value > attended.value) total.value--;
                      },
                      color: const Color(0xFF60A5FA),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: 24),

            // Simulation Section
            Text(
              "Future Prediction",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Simulate how many classes you can skip or must attend.",
              style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.4)),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildFutureCard(
                    label: "Will Attend",
                    value: futureAttend.value,
                    onIncrement: () => futureAttend.value++,
                    onDecrement: () {
                      if (futureAttend.value > 0) futureAttend.value--;
                    },
                    color: const Color(0xFF34D399),
                    icon: Icons.add_task_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildFutureCard(
                    label: "Will Skip",
                    value: futureSkip.value,
                    onIncrement: () => futureSkip.value++,
                    onDecrement: () {
                      if (futureSkip.value > 0) futureSkip.value--;
                    },
                    color: const Color(0xFFFB7185),
                    icon: Icons.block_flipped,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Prediction Result
            _buildPredictionResult(getCurrentPercentage(), getPredictedPercentage()),

            const SizedBox(height: 32),

            // Goal Seeker (Reverse Mode)
            _buildGoalSeeker(attended.value, total.value),
            
            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _buildPercentageBadge(double pct) {
    final color = pct >= 75 ? const Color(0xFF34D399) : const Color(0xFFFB7185);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(100),
      ),
      child: Text(
        "${pct.toStringAsFixed(1)}%",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: color,
        ),
      ),
    );
  }

  Widget _buildPredictionResult(double current, double predicted) {
    final color = predicted >= 75 ? const Color(0xFF34D399) : const Color(0xFFFB7185);
    final delta = predicted - current;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF151922),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        children: [
          Text(
            "PREDICTED PERCENTAGE",
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: Colors.white.withOpacity(0.3),
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "${predicted.toStringAsFixed(1)}%",
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: -1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                delta >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                "${delta.abs().toStringAsFixed(1)}%",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                delta >= 0 ? "increase" : "drop",
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: Colors.white.withOpacity(0.05)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8, height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Text(
                predicted >= 75 ? "Status: Safe" : "Status: Warning - Below 75%",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: predicted >= 75 ? color : color.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGoalSeeker(int p, int t) {
    final target = useState(75.0);
    
    String getAdvice() {
      final currentPct = t == 0 ? 0.0 : (p / t) * 100;
      if (currentPct >= target.value) {
        // Can miss classes
        final canMiss = ((p / (target.value / 100)) - t).floor();
        if (canMiss <= 0) return "You are right on the edge. Don't skip!";
        return "You can skip the next $canMiss class${canMiss == 1 ? '' : 'es'} while staying above ${target.value.toInt()}%";
      } else {
        // Must attend classes
        final need = (((target.value / 100) * t - p) / (1 - (target.value / 100))).ceil();
        if (need <= 0) return "Just attend the next class to reach your goal.";
        return "You need to attend the next $need classes without skipping to reach ${target.value.toInt()}%";
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Goal Seeker",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: kUniversityBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Target: ${target.value.toInt()}%",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: kUniversityBlue,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [75.0, 80.0, 85.0, 90.0].map((val) {
            final isSelected = target.value == val;
            return FTappable(
              onPress: () => target.value = val,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? kUniversityBlue : const Color(0xFF151922),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? kUniversityBlue
                        : Colors.white.withOpacity(0.05),
                  ),
                ),
                child: Text(
                  "${val.toInt()}%",
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : Colors.white.withOpacity(0.5),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kUniversityBlue.withOpacity(0.05),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: kUniversityBlue.withOpacity(0.1)),
          ),
          child: Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: kUniversityBlue, size: 24),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  getAdvice(),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFFE2E8F0),
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStepperCard({
    required String label,
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF151922),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Text(label, style: TextStyle(fontSize: 10, color: Colors.white.withOpacity(0.4), fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRoundBtn(icon: Icons.remove, color: color, onTap: onDecrement),
              Text("$value", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white)),
              _buildRoundBtn(icon: Icons.add, color: color, onTap: onIncrement),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFutureCard({
    required String label,
    required int value,
    required VoidCallback onIncrement,
    required VoidCallback onDecrement,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF151922),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: color),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white.withOpacity(0.4))),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildRoundBtn(icon: Icons.remove, color: color, onTap: onDecrement),
              Text("$value", style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.white)),
              _buildRoundBtn(icon: Icons.add, color: color, onTap: onIncrement),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRoundBtn({required IconData icon, required Color color, required VoidCallback onTap}) {
    return FTappable(
      onPress: onTap,
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 16, color: color),
      ),
    );
  }
}
