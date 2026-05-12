import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../store/auth_provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // ── Logo entrance ──────────────────────────────────────────────
  late AnimationController _entryCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textSlide;
  late Animation<double> _textOpacity;

  // ── Continuous glow pulse ───────────────────────────────────────
  late AnimationController _glowCtrl;
  late Animation<double> _glowScale;

  // ── Rotating orbit ring ─────────────────────────────────────────
  late AnimationController _orbitCtrl;

  // ── Shimmer loading bar ─────────────────────────────────────────
  late AnimationController _shimmerCtrl;
  late Animation<double> _shimmerAnim;

  // ── Background orbs ─────────────────────────────────────────────
  late AnimationController _orbCtrl;
  late Animation<double> _orbAnim;

  @override
  void initState() {
    super.initState();

    // 1. Entry animation (logo + text)
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _logoOpacity = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.0, 0.55, curve: Curves.easeOut),
    );

    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.7, curve: Curves.elasticOut),
      ),
    );

    _textOpacity = CurvedAnimation(
      parent: _entryCtrl,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    );

    _textSlide = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
      ),
    );

    // 2. Glow pulse
    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _glowScale = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut),
    );

    // 3. Orbit ring rotation
    _orbitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    // 4. Shimmer loading bar
    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _shimmerAnim = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerCtrl, curve: Curves.easeInOut),
    );

    // 5. Background orbs
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat(reverse: true);

    _orbAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) _entryCtrl.forward();
    });

    _checkNavigation();
  }

  void _checkNavigation() async {
    await Future.delayed(const Duration(milliseconds: 3200));
    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    while (authProvider.isLoading) {
      await Future.delayed(const Duration(milliseconds: 100));
    }
    if (!mounted) return;

    if (authProvider.isAuthenticated) {
      if (authProvider.role == 'admin') {
        Navigator.of(context).pushReplacementNamed('/admin_home');
      } else if (authProvider.role == 'doctor') {
        Navigator.of(context).pushReplacementNamed('/doctor_home');
      } else {
        Navigator.of(context).pushReplacementNamed('/main_container');
      }
    } else {
      Navigator.of(context).pushReplacementNamed('/main_container');
    }
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    _glowCtrl.dispose();
    _orbitCtrl.dispose();
    _shimmerCtrl.dispose();
    _orbCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.45, 1.0],
            colors: [
              Color(0xFF020B1E),
              Color(0xFF0A1A3A),
              Color(0xFF041020),
            ],
          ),
        ),
        child: Stack(
          children: [
            // ── Grid pattern ──────────────────────────────────────
            Positioned.fill(
              child: CustomPaint(painter: _GridPainter()),
            ),

            // ── Background orb – top-left ─────────────────────────
            AnimatedBuilder(
              animation: _orbAnim,
              builder: (context, child) => Positioned(
                top: -80 + (_orbAnim.value * 20),
                left: -80,
                child: _OrbWidget(
                  size: 340,
                  color: const Color(0xFF00B4FF).withValues(alpha: 0.10),
                ),
              ),
            ),

            // ── Background orb – bottom-right ─────────────────────
            AnimatedBuilder(
              animation: _orbAnim,
              builder: (context, child) => Positioned(
                bottom: -60 - (_orbAnim.value * 20),
                right: -80,
                child: _OrbWidget(
                  size: 280,
                  color: const Color(0xFF00E6B4).withValues(alpha: 0.07),
                ),
              ),
            ),

            // ── Main content ──────────────────────────────────────
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ── Logo section ──────────────────────────────
                  AnimatedBuilder(
                    animation: Listenable.merge(
                        [_logoScale, _logoOpacity, _glowScale, _orbitCtrl]),
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value.clamp(0.0, 1.0),
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: SizedBox(
                            width: 200,
                            height: 200,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Outer glow halo
                                Transform.scale(
                                  scale: _glowScale.value,
                                  child: Container(
                                    width: 190,
                                    height: 190,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      gradient: RadialGradient(
                                        colors: [
                                          const Color(0xFF00B4FF)
                                              .withValues(alpha: 0.18),
                                          const Color(0xFF00E6B4)
                                              .withValues(alpha: 0.08),
                                          Colors.transparent,
                                        ],
                                        stops: const [0.0, 0.5, 1.0],
                                      ),
                                    ),
                                  ),
                                ),

                                // Rotating orbit ring
                                Transform.rotate(
                                  angle: _orbitCtrl.value * 2 * math.pi,
                                  child: CustomPaint(
                                    painter: _OrbitRingPainter(),
                                    size: const Size(175, 175),
                                  ),
                                ),

                                // White circular card behind logo
                                Container(
                                  width: 148,
                                  height: 148,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(0xFF00B4FF)
                                            .withValues(alpha: 0.35),
                                        blurRadius: 32,
                                        spreadRadius: 4,
                                      ),
                                      BoxShadow(
                                        color: const Color(0xFF00E6B4)
                                            .withValues(alpha: 0.20),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),

                                // Actual logo image
                                ClipOval(
                                  child: Image.asset(
                                    'assets/images/logo.png',
                                    width: 138,
                                    height: 138,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 36),

                  // ── Text section ──────────────────────────────
                  AnimatedBuilder(
                    animation: Listenable.merge([_textOpacity, _textSlide]),
                    builder: (context, child) {
                      return Opacity(
                        opacity: _textOpacity.value.clamp(0.0, 1.0),
                        child: Transform.translate(
                          offset: Offset(0, _textSlide.value),
                          child: Column(
                            children: [
                              // App name with gradient
                              ShaderMask(
                                shaderCallback: (bounds) =>
                                    const LinearGradient(
                                  colors: [
                                    Color(0xFF00C8FF),
                                    Color(0xFF00F0C8),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ).createShader(bounds),
                                child: const Text(
                                  'كلينك وان',
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 30,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 1.0,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 6),

                              // Subtitle
                              Text(
                                'مجمع عيادات',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.45),
                                  fontSize: 15,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: 0.8,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 56),

                  // ── Shimmer loading bar ───────────────────────
                  AnimatedBuilder(
                    animation: _shimmerAnim,
                    builder: (context, child) {
                      return SizedBox(
                        width: size.width * 0.55,
                        child: Column(
                          children: [
                            Text(
                              'جاري التحميل...',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.30),
                                fontSize: 12,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: Colors.white.withValues(alpha: 0.08),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(2),
                                child: CustomPaint(
                                  painter: _ShimmerBarPainter(
                                    progress: _shimmerAnim.value,
                                  ),
                                  child: const SizedBox.expand(),
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // ── Version tag – bottom ──────────────────────────────
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: AnimatedBuilder(
                animation: _textOpacity,
                builder: (context, child) => Opacity(
                  opacity: (_textOpacity.value * 0.5).clamp(0.0, 1.0),
                  child: const Text(
                    'v1.0.0',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white38,
                      fontSize: 11,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper widgets & painters
// ─────────────────────────────────────────────────────────────────────────────

class _OrbWidget extends StatelessWidget {
  const _OrbWidget({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [color, Colors.transparent],
          stops: const [0.0, 0.72],
        ),
      ),
    );
  }
}

class _OrbitRingPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final paint = Paint()
      ..color = const Color(0xFF00B4FF).withValues(alpha: 0.50)
      ..strokeWidth = 1.8
      ..style = PaintingStyle.stroke;

    const dashCount = 24;
    const gap = math.pi / (dashCount * 2);
    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i * 2 * math.pi / dashCount);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        math.pi / dashCount - gap,
        false,
        paint,
      );
    }

    // Bright dot on ring
    const dotAngle = 0.0;
    final dotX = center.dx + radius * math.cos(dotAngle);
    final dotY = center.dy + radius * math.sin(dotAngle);
    canvas.drawCircle(
      Offset(dotX, dotY),
      4,
      Paint()..color = const Color(0xFF00E6B4),
    );
    canvas.drawCircle(
      Offset(dotX, dotY),
      6,
      Paint()
        ..color = const Color(0xFF00E6B4).withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}

class _ShimmerBarPainter extends CustomPainter {
  final double progress;
  const _ShimmerBarPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = Colors.white.withValues(alpha: 0.06),
    );

    final shimmerX = progress * size.width;
    final grad = LinearGradient(
      colors: [
        Colors.transparent,
        const Color(0xFF00C8FF).withValues(alpha: 0.8),
        const Color(0xFF00F0C8).withValues(alpha: 0.9),
        const Color(0xFF00C8FF).withValues(alpha: 0.8),
        Colors.transparent,
      ],
      stops: const [0.0, 0.3, 0.5, 0.7, 1.0],
    );

    final rect = Rect.fromLTWH(shimmerX - 80, 0, 160, size.height);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = grad.createShader(rect),
    );
  }

  @override
  bool shouldRepaint(covariant _ShimmerBarPainter old) =>
      old.progress != progress;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 1.0;

    const spacing = 36.0;
    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => false;
}
