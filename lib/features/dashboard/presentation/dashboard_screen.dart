import 'package:edupulse_ai/features/dashboard/presentation/login_page.dart';
import 'package:edupulse_ai/features/dashboard/presentation/physics.dart';
import 'package:flutter/material.dart';
import 'package:edupulse_ai/core/theme/app_theme.dart';
import 'dart:math' as math;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _showAll = false;

  final List<Map<String, dynamic>> _subjects = [
    {
      'title': 'Mathematics',
      'subtitle': 'Algebra & Geometry',
      'icon': 'Σ',
      'color': AppColors.primaryBlue,
      'image': 'assets/mathematics.png',
    },
    {
      'title': 'Add. Mathematics',
      'subtitle': 'Calculus & Vectors',
      'icon': '∫',
      'color': AppColors.accentPurple,
      'image': 'assets/addmaths.png',
    },
    {
      'title': 'Physics',
      'subtitle': 'Forces & Motion',
      'icon': '⚡',
      'color': Colors.amber,
      'image': 'assets/physics.png',
    },
    {
      'title': 'Chemistry',
      'subtitle': 'Organic Compounds',
      'icon': '⚗',
      'color': AppColors.accentCyan,
      'image': 'assets/chemistry.png',
    },
    {
      'title': 'Biology',
      'subtitle': 'Cell Structure',
      'icon': '🧬',
      'color': Colors.greenAccent
    },
    {
      'title': 'Science',
      'subtitle': 'General Concepts',
      'icon': '🔬',
      'color': Colors.deepOrangeAccent
    },
    {
      'title': 'Sejarah',
      'subtitle': 'Malaysian History',
      'icon': '📜',
      'color': Colors.brown
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // We use a Stack to layer the background image behind the content
      body: Stack(
        children: [
          // 1. The Global Background Image
          Positioned.fill(
            child: Image.asset(
              'assets/main.png', // Replace with actual background file
              fit: BoxFit.cover,
            ),
          ),

          // 2. Optional: Dark overlay to keep your UI readable
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.4),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context),
                  const SizedBox(height: 32),
                  _buildDailyPulseCard(context),
                  const SizedBox(height: 32),
                  _buildSubjectsHeader(context),
                  const SizedBox(height: 16),
                  _buildSubjectsGrid(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Powered By Firebase',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 2.0,
                    fontSize: 10,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'EasLearn',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    fontSize: 26,
                  ),
            ),
          ],
        ),
        Row(
          children: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.notifications_outlined),
              style: IconButton.styleFrom(
                backgroundColor: AppColors.cardSurface.withOpacity(0.5),
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.all(12),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ));
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.primaryBlue, width: 2),
                ),
                child: const CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.cardSurface,
                  child: Icon(Icons.person, color: AppColors.textPrimary),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDailyPulseCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.backgroundNavy.withOpacity(0.8),
            AppColors.backgroundDark.withOpacity(0.9),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: Colors.white.withOpacity(0.08),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          SizedBox(
            height: 200,
            width: 200,
            child: CustomPaint(
              painter: _CircularProgressPainter(percentage: 0.001),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '0%',
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: -1.0,
                      ),
                    ),
                    Text(
                      'COMPLETED',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Daily Pulse',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            "Start learning!",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 24),
          // Progress Bars
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSegment(true),
              _buildSegment(true),
              _buildSegment(true),
              _buildSegment(false),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSegment(bool filled) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 4,
      width: 40,
      decoration: BoxDecoration(
        color: filled ? AppColors.primaryBlue : Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }

  Widget _buildSubjectsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Current Subjects',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        GestureDetector(
          onTap: () {
            setState(() {
              _showAll = !_showAll;
            });
          },
          child: Text(
            _showAll ? 'Show Less' : 'View All',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectsGrid(BuildContext context) {
    final displayedSubjects = _showAll ? _subjects : _subjects.take(4).toList();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 0.85,
      children: displayedSubjects.map((subject) {
        return _buildSubjectCard(
          subject['title'] as String,
          subject['subtitle'] as String,
          subject['icon'] as String,
          subject['color'] as Color,
          subject['image'] as String?,
        );
      }).toList(),
    );
  }

  Widget _buildSubjectCard(
    String title,
    String subtitle,
    String iconSymbol,
    Color accentColor,
    String? imagePath,
  ) {
    return GestureDetector(
      onTap: () {
        if (title == 'Physics') {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => const PhysicsChaptersScreen()),
          );
        } else {
          // Handle other subjects or show a snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("$title content coming soon!")),
          );
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1E293B).withOpacity(0.4),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.white.withOpacity(0.05),
          ),
          image: imagePath != null
              ? DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover, // ensure that textbook fit the whole box
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(
                        0.5), // add this mask, otherwise you can't read the text
                    BlendMode.darken,
                  ),
                )
              : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 48,
              width: 48,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: Text(
                  iconSymbol,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: accentColor,
                  ),
                ),
              ),
            ),
            const Spacer(),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                height: 1.2,
                shadows: [
                  Shadow(blurRadius: 4, color: Colors.black)
                ], // add shadow, make the text clearer
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8), // make it brighter
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: 0.6,
                backgroundColor: Colors.white
                    .withOpacity(0.2), // make the background bar darker
                color: accentColor,
                minHeight: 4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircularProgressPainter extends CustomPainter {
  final double percentage;

  _CircularProgressPainter({required this.percentage});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width / 2, size.height / 2);
    final strokeWidth = 12.0;

    // Background Circle
    final bgPaint = Paint()
      ..color = const Color(0xFF0F172A)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius - strokeWidth / 2, bgPaint);

    // Background Glow
    final shadowPaint = Paint()
      ..color = AppColors.primaryBlue.withOpacity(0.1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth + 10
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
      -math.pi / 2,
      2 * math.pi * percentage,
      false,
      shadowPaint,
    );

    // Foreground Gradient Arc
    final gradient = LinearGradient(
      colors: [
        AppColors.primaryBlue,
        AppColors.accentCyan,
      ],
      begin: Alignment.topCenter,
      end: Alignment.bottomRight,
    );

    final rect =
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2);
    final fgPaint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      rect,
      -math.pi / 2, // Start at top
      2 * math.pi * percentage,
      false,
      fgPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
