import 'package:flutter/material.dart';
import 'login_screen.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  final AuthServiceApi auth;

  const SplashScreen({super.key, required this.auth});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _arrowController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _arrowAnimation;
  bool _isSwiping = false;
  double _swipeProgress = 0.0;
  double _rotationAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _arrowController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _arrowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _arrowController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();

    // Start arrow animation after main animation
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _arrowController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _arrowController.dispose();
    super.dispose();
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginScreen(auth: widget.auth)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onPanStart: (details) {
          setState(() {
            _isSwiping = true;
            _swipeProgress = 0.0;
            _rotationAngle = 0.0;
          });
        },
        onPanUpdate: (details) {
          if (_isSwiping) {
            setState(() {
              // Calculate swipe progress based on finger movement
              _swipeProgress = (-details.delta.dy / 200).clamp(0.0, 1.0);
              _rotationAngle +=
                  details.delta.dy * 0.01; // Rotate based on movement
            });
          }
        },
        onPanEnd: (details) {
          if (_isSwiping) {
            // If swiped enough, navigate to login
            if (_swipeProgress > 0.3) {
              _navigateToLogin();
            } else {
              // Reset if not swiped enough
              setState(() {
                _isSwiping = false;
                _swipeProgress = 0.0;
                _rotationAngle = 0.0;
              });
            }
          }
        },
        child: Transform.translate(
          offset: Offset(
              0, -_swipeProgress * MediaQuery.of(context).size.height * 0.3),
          child: SafeArea(
            child: Column(
              children: [
                const Spacer(),

                // SPORTLINK Title
                Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: const Text(
                        'SPORTLINK',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Chain Links Icon
                Center(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Transform.rotate(
                        angle: _rotationAngle,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: const BoxDecoration(
                            color: Color(0xFF2C2C2C),
                            shape: BoxShape.circle,
                          ),
                          child: Image.asset(
                            'assets/chainlink.png',
                            width: 60,
                            height: 60,
                            color: Colors.white,
                            colorBlendMode: BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Animated up arrow and text
                Center(
                  child: Column(
                    children: [
                      // Animated up arrow
                      AnimatedBuilder(
                        animation: _arrowAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, -10 * _arrowAnimation.value),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: const BoxDecoration(
                                color: Color(0xFF2C2C2C),
                                shape: BoxShape.circle,
                              ),
                              child: CustomPaint(
                                size: const Size(24, 24),
                                painter: ArrowUpPainter(),
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 10),

                      // Swipe up text
                      FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: const Text(
                            'Swipe up to get started',
                            style: TextStyle(
                              fontSize: 16,
                              color: Color(0xFF666666),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ArrowUpPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = Path();

    // Draw up arrow
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final arrowSize = size.width * 0.3;

    // Arrow head pointing up
    path.moveTo(centerX, centerY - arrowSize);
    path.lineTo(centerX - arrowSize, centerY);
    path.moveTo(centerX, centerY - arrowSize);
    path.lineTo(centerX + arrowSize, centerY);

    // Arrow shaft
    path.moveTo(centerX, centerY - arrowSize);
    path.lineTo(centerX, centerY + arrowSize);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
