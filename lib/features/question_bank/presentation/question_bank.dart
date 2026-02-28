import 'package:flutter/material.dart';
import 'physics_quiz_page.dart';

class QuestionBankPage extends StatelessWidget {
  const QuestionBankPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar:
          true, // Crucial for the background to go behind the AppBar
      backgroundColor: const Color(0xFF0F1522), // Solid dark base color
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon:
              const Icon(Icons.arrow_back_ios, color: Colors.white70, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Question Bank',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF4A8CFF),
              child: const Icon(Icons.person, size: 20, color: Colors.white),
            ),
          ),
        ],
      ),
      // Restored the Stack to layer the starry background behind the content
      body: Stack(
        children: [
          // Background starry sky effect
          Positioned.fill(
            child: Opacity(
              opacity: 1.0, // Adjusted for a subtle, elegant look
              child: Image.asset(
                'assets/background2.png', //local asset path
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const SizedBox.shrink(),
              ),
            ),
          ),

          // Main Content perfectly centered
          SafeArea(
            child: SizedBox(
              width: double
                  .infinity, // Forces the column to take full screen width
              child: Column(
                crossAxisAlignment: CrossAxisAlignment
                    .center, // Centers everything horizontally
                children: [
                  // Top Subjects & Topics Section
                  Container(
                    constraints: const BoxConstraints(
                        maxWidth: 800), // Keeps it neatly sized on wide screens
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF222938).withOpacity(0.8),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          'Subjects List',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 16),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          physics: const BouncingScrollPhysics(),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildTabButton('All', true),
                              _buildTabButton('Math', false),
                              _buildTabButton('Add.Math', false),
                              _buildTabButton('Physics', false),
                              _buildTabButton('Chemistry', false),
                              _buildTabButton('Biology', false),
                              _buildTabButton('Science', false),
                              _buildTabButton('Sejarah', false),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Cards Section
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: SizedBox(
                        width: double
                            .infinity, // Ensures the Wrap utilizes full width for centering
                        child: Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          alignment: WrapAlignment
                              .center, // Centers the cards perfectly
                          children: [
                            _buildSubjectCard(
                              title: 'Mathematics',
                              grade: 'Grade 9-10',
                              questionsCount: '100 Questions',
                              accentColor: const Color(0xFFE57373), // Soft Red
                              smallIcon: Icons.calculate,
                              largeIcons: [
                                Icons.calculate_outlined,
                                Icons.menu_book
                              ],
                              progress: 0.1,
                            ),
                            _buildSubjectCard(
                              title: 'Physics',
                              grade: 'Grade 11-12',
                              questionsCount: '15 Questions', // Updated count
                              accentColor: const Color(0xFFFFCA28),
                              smallIcon: Icons.lightbulb,
                              largeIcons: [
                                Icons.lightbulb_outline,
                                Icons.science_outlined
                              ],
                              progress: 0.1,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) =>
                                          const PhysicsQuizPage()),
                                );
                              },
                            ),
                            _buildSubjectCard(
                              title: 'Biology',
                              grade: 'Grade 11-12',
                              questionsCount: '100 Questions',
                              accentColor:
                                  const Color(0xFF81C784), // Soft Green
                              smallIcon: Icons.biotech,
                              largeIcons: [
                                Icons.biotech_outlined,
                                Icons.coronavirus_outlined
                              ],
                              progress: 0.1,
                            ),
                            _buildSubjectCard(
                              title: 'Chemistry',
                              grade: 'Grade 12',
                              questionsCount: '160 Questions',
                              accentColor:
                                  const Color(0xFFFFB74D), // Soft Orange
                              smallIcon: Icons.science,
                              largeIcons: [
                                Icons.science_outlined,
                                Icons.bubble_chart_outlined
                              ],
                              progress: 0.1,
                            ),
                            _buildSubjectCard(
                              title: 'Sejarah',
                              grade: 'Grade 10-12',
                              questionsCount: '200 Questions',
                              accentColor: const Color(0xFF4DD0E1), // Soft Teal
                              smallIcon: Icons.public,
                              largeIcons: [
                                Icons.public_outlined,
                                Icons.history_edu_outlined
                              ],
                              progress: 0.1,
                            ),
                            const SizedBox(
                                height: 100,
                                width: double.infinity), // Padding for FAB
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating Action Button
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          color: const Color(0xFF4A8CFF),
          borderRadius: BorderRadius.circular(16), // Softer rounded square look
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4A8CFF).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () {},
            child: const Icon(Icons.add, color: Colors.white, size: 28),
          ),
        ),
      ),
    );
  }

  // Filter tab button component
  Widget _buildTabButton(String label, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4A8CFF) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? const Color(0xFF4A8CFF) : Colors.white24,
          width: 1,
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: isActive ? Colors.white : Colors.white70,
          fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          fontSize: 14,
        ),
      ),
    );
  }

  // Subject card component
  Widget _buildSubjectCard({
    required String title,
    required String grade,
    required String questionsCount,
    required Color accentColor,
    required IconData smallIcon,
    required List<IconData> largeIcons,
    required double progress,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width:
            380, // Fixed width ensures they wrap beautifully on wider screens
        height: 120, // Fixed height for consistency
        decoration: BoxDecoration(
          // Blended dark background tinted softly by the accent color
          color: Color.lerp(const Color(0xFF1E2536), accentColor, 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: accentColor.withOpacity(0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: accentColor.withOpacity(0.05),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            // Left accent glow edge
            Container(
              width: 8,
              decoration: BoxDecoration(
                color: accentColor.withOpacity(0.8),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(15),
                  bottomLeft: Radius.circular(15),
                ),
              ),
            ),
            const SizedBox(width: 16),

            // Icon and Text Column
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(smallIcon, color: accentColor, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.only(left: 48.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          grade,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          questionsCount,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Right side icons and progress
            Padding(
              padding: const EdgeInsets.only(right: 12.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: largeIcons.map((icon) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Icon(icon,
                            color: accentColor.withOpacity(0.8), size: 32),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    width: 70,
                    height: 6,
                    decoration: BoxDecoration(
                      color: accentColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        decoration: BoxDecoration(
                          color: accentColor,
                          borderRadius: BorderRadius.circular(3),
                          boxShadow: [
                            BoxShadow(
                              color: accentColor.withOpacity(0.5),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Chevron icon
            Icon(Icons.chevron_right_rounded,
                color: Colors.white.withOpacity(0.3)),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}
