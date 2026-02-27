import 'package:flutter/material.dart';
import 'package:edupulse_ai/core/theme/app_theme.dart';

class MemoryBankScreen extends StatelessWidget {
  const MemoryBankScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Memory Bank'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20),
          onPressed: () {}, // Handled by router usually, or pop
        ),
        actions: [
          const CircleAvatar(
            radius: 16,
            backgroundImage: NetworkImage(
                'https://i.pravatar.cc/150?img=12'), // Placeholder or asset
            child: Icon(Icons.person, size: 20),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            _buildAccuracyCard(),
            const SizedBox(height: 32),
            _buildRecentLogsHeader(),
            const SizedBox(height: 16),
            _buildLogsList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildAccuracyCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B), // Navy Card
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Accuracy over Time',
                  style: TextStyle(color: AppColors.textSecondary)),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'LIVE ANALYSIS',
                  style: TextStyle(
                    color: AppColors.primaryBlue,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                '0.00%',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '0.01%',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.greenAccent.shade400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 150,
            width: double.infinity,
            child: CustomPaint(
              painter: _ChartPainter(),
            ),
          ),
          const SizedBox(height: 16),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('MON',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 10)),
              Text('TUE',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 10)),
              Text('WED',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 10)),
              Text('THU',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 10)),
              Text('FRI',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 10)),
              Text('SAT',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 10)),
              Text('SUN',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(child: _buildFilterChip("All Mistakes", true)),
              const SizedBox(width: 8),
              Expanded(child: _buildFilterChip("Calculation", false)),
              const SizedBox(width: 8),
              Expanded(child: _buildFilterChip("Concept", false)),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryBlue : Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isSelected
              ? AppColors.primaryBlue
              : Colors.white.withValues(alpha: 0.2),
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.textSecondary,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildRecentLogsHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recent Logs',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        TextButton(
            onPressed: () {},
            child: const Text('View History',
                style: TextStyle(color: AppColors.primaryBlue))),
      ],
    );
  }

  Widget _buildLogsList() {
    return Column(
      children: [
        _buildLogCard(
          "Algebraic Sign Flip",
          "Grade 10 Math • 2 hours ago",
          Icons.calculate,
          Colors.redAccent,
        ),
        const SizedBox(height: 16),
        _buildLogCard(
          "Newton's 3rd Law",
          "Physics • Session #42",
          Icons.lightbulb,
          Colors.amber,
        ),
        const SizedBox(height: 16),
        _buildLogCard(
          "Logarithmic Base Error",
          "Additional Mathematics • Yesterday",
          Icons.functions,
          Colors.redAccent,
        ),
        const SizedBox(height: 16),
        _buildLogCard(
          "Mitosis Phase Swap",
          "Biology • 1 day ago",
          Icons.science,
          Colors
              .amber, // Using amber for standard look, though design had microscope icon
        ),
        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildLogCard(
      String title, String subtitle, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
        boxShadow: [
          // Left accent border visual trick
          BoxShadow(
            color: color,
            offset:
                const Offset(-4, 0), // Negative X offset simulating left border
            spreadRadius: 0,
            blurRadius: 0,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B).withValues(alpha: 0.5),
            border: Border(
                left:
                    BorderSide(color: color, width: 4)), // Actual border logic
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color),
            ),
            title: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text(
                subtitle,
                style: const TextStyle(color: AppColors.textSecondary),
              ),
            ),
            trailing:
                const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _ChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.primaryBlue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    final path = Path();
    // Use Bezier curves for smooth wave
    // Mocking points (0 to Width)
    final w = size.width;
    final h = size.height;

    path.moveTo(0, h * 0.7);

    // Wave points
    path.cubicTo(w * 0.1, h * 0.3, w * 0.2, h * 0.9, w * 0.3, h * 0.6);
    path.cubicTo(w * 0.4, h * 0.3, w * 0.5, h * 0.5, w * 0.6, h * 0.8);
    path.cubicTo(w * 0.7, h * 1.0, w * 0.8, h * 0.2, w * 0.9, h * 0.5);
    path.lineTo(w, h * 0.3);

    // Glow Effect
    final shadowPaint = Paint()
      ..color = AppColors.primaryBlue.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawPath(path, shadowPaint);
    canvas.drawPath(path, paint);

    // Gradient Fill below the line
    final fillPath = Path.from(path)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    final gradient = LinearGradient(
      colors: [
        AppColors.primaryBlue.withValues(alpha: 0.2),
        AppColors.primaryBlue.withValues(alpha: 0.0),
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    );

    final fillPaint = Paint()
      ..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h))
      ..style = PaintingStyle.fill;

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
