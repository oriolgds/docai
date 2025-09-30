import 'package:flutter/material.dart';
import 'dart:math' as math;

class ProfileStatsWidget extends StatefulWidget {
  const ProfileStatsWidget({super.key});

  @override
  State<ProfileStatsWidget> createState() => _ProfileStatsWidgetState();
}

class _ProfileStatsWidgetState extends State<ProfileStatsWidget>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _progressController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.easeOutCubic),
    );

    _pulseController.repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 500), () {
      _progressController.forward();
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Tu actividad',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D3436),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00B894),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 8),
              const Text(
                'En línea',
                style: TextStyle(
                  fontSize: 12,
                  color: Color(0xFF00B894),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          
          // Stats grid
          Row(
            children: [
              Expanded(
                child: _buildAnimatedStatCard(
                  '152',
                  'Consultas totales',
                  Icons.chat_bubble_outline,
                  const Color(0xFF6C5CE7),
                  0.0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnimatedStatCard(
                  '2.3k',
                  'Minutos de chat',
                  Icons.access_time,
                  const Color(0xFF00B894),
                  0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildAnimatedStatCard(
                  '96%',
                  'Satisfacción',
                  Icons.thumb_up_alt_outlined,
                  const Color(0xFFE17055),
                  0.4,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildAnimatedStatCard(
                  '12',
                  'Esta semana',
                  Icons.trending_up,
                  const Color(0xFFE84393),
                  0.6,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Weekly progress
          _buildWeeklyProgress(),
        ],
      ),
    );
  }

  Widget _buildAnimatedStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
    double delay,
  ) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        final progress = math.max(
          0.0,
          math.min(1.0, (_progressAnimation.value - delay) / (1.0 - delay)),
        );
        
        return Transform.scale(
          scale: 0.8 + (0.2 * progress),
          child: Opacity(
            opacity: progress,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: color.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(icon, color: color, size: 20),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '+5%',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFF6C757D).withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWeeklyProgress() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Actividad semanal',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2D3436),
              ),
            ),
            Text(
              '87% completado',
              style: TextStyle(
                fontSize: 12,
                color: const Color(0xFF00B894),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        AnimatedBuilder(
          animation: _progressAnimation,
          builder: (context, child) {
            return Column(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F2F6),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: 0.87 * _progressAnimation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00B894), Color(0xFF00A085)],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(7, (index) {
                    final days = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
                    final isActive = index < 6; // Solo 6 días activos
                    final opacity = math.max(
                      0.0,
                      math.min(1.0, (_progressAnimation.value - index * 0.1) / 0.7),
                    );
                    
                    return Opacity(
                      opacity: opacity,
                      child: Column(
                        children: [
                          Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: isActive 
                                  ? const Color(0xFF00B894)
                                  : const Color(0xFFF1F2F6),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                days[index],
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isActive 
                                      ? Colors.white
                                      : const Color(0xFF6C757D),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 4,
                            height: isActive ? 12 : 4,
                            decoration: BoxDecoration(
                              color: isActive 
                                  ? const Color(0xFF00B894)
                                  : const Color(0xFFF1F2F6),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}