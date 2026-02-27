import 'package:flutter/material.dart';
import 'package:edupulse_ai/core/theme/app_theme.dart';

class GradingScreen extends StatelessWidget {
  const GradingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              size: 18, color: Colors.white),
        ),
        centerTitle: true,
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: const Text(
            'AI GRADING RESULT',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
              color: Colors.white,
            ),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: IconButton(
              icon: const Icon(Icons.share_outlined,
                  size: 20, color: Colors.white),
              onPressed: () {},
            ),
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Ambient backround
          Positioned(
            top: 100,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryBlue.withOpacity(0.15),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryBlue.withOpacity(0.2),
                      blurRadius: 100,
                      spreadRadius: 20,
                    ),
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildScoreCard(),
                  const SizedBox(height: 32),
                  const Text(
                    'KEY INSIGHTS',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildInsightsGrid(),
                  const SizedBox(height: 32),
                  _buildFeedbackCard(),
                  const SizedBox(height: 80), // Padding for bottom FABs
                ],
              ),
            ),
          ),

          // Bottom Actions
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text("Regrade Page"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                      shadowColor: AppColors.primaryBlue.withOpacity(0.4),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                _buildCircleAction(Icons.download),
                const SizedBox(width: 12),
                _buildCircleAction(Icons.more_vert),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCircleAction(IconData icon) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: () {},
        padding: const EdgeInsets.all(16),
      ),
    );
  }

  Widget _buildScoreCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 40),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.6),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: const Column(
        children: [
          Text(
            'GRADE ANALYSIS',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.bold,
              fontSize: 12,
              letterSpacing: 1.2,
            ),
          ),
          SizedBox(height: 8),
          Text(
            '0%',
            style: TextStyle(
                fontSize: 80,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.0,
                shadows: [
                  BoxShadow(
                    color: Colors.white24,
                    blurRadius: 20,
                    spreadRadius: 20,
                  )
                ]),
          ),
          SizedBox(height: 16),
          Text(
            'Overall Accuracy Score',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightsGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _buildInsightChip(
            'Grammar: Strong', Icons.check_circle, AppColors.primaryBlue),
        _buildInsightChip(
            'Logic Issues', Icons.warning_amber, Colors.redAccent),
        _buildInsightChip('Great Hook', Icons.star, Colors.blueAccent),
        _buildInsightChip('MLA Format Error', Icons.description, Colors.amber),
        _buildInsightChip('Deep Analysis', Icons.psychology, Colors.lightBlue),
      ],
    );
  }

  Widget _buildInsightChip(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeedbackCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withOpacity(0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.info, color: AppColors.primaryBlue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'AI Feedback',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "The thesis statement is compelling but lacks supporting evidence in the third paragraph. Pay attention to the transitions between your main arguments for a smoother logical flow.",
            style: TextStyle(
              color: AppColors.textSecondary,
              height: 1.6,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
