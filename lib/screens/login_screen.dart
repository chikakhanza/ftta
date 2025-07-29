import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/api_service.dart';
import 'main_screen.dart';
import 'register_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final FocusNode emailFocusNode = FocusNode();
  final FocusNode passwordFocusNode = FocusNode();
  
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _emailValid = true;
  bool _passwordValid = true;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _rotationController;
  late AnimationController _formController;
  
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _formAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    
    // Add listeners for form validation
    emailController.addListener(_validateEmail);
    passwordController.addListener(_validatePassword);
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    
    _formController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.elasticOut,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(_rotationController);

    _formAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _formController,
      curve: Curves.easeInOut,
    ));
  }

  void _startAnimations() async {
    _rotationController.repeat();
    
    await Future.delayed(const Duration(milliseconds: 300));
    _fadeController.forward();
    
    await Future.delayed(const Duration(milliseconds: 200));
    _scaleController.forward();
    
    await Future.delayed(const Duration(milliseconds: 400));
    _slideController.forward();
    
    await Future.delayed(const Duration(milliseconds: 600));
    _formController.forward();
  }

  void _validateEmail() {
    final email = emailController.text;
    setState(() {
      _emailValid = email.isEmpty || RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
    });
  }

  void _validatePassword() {
    setState(() {
      _passwordValid = passwordController.text.length >= 6 || passwordController.text.isEmpty;
    });
  }

  void _login() async {
    HapticFeedback.lightImpact();
    
    final email = emailController.text.trim();
    final password = passwordController.text;
    
    if (email.isEmpty || password.isEmpty) {
      _showSnackBar('Email dan password harus diisi', isError: true);
      return;
    }
    
    if (!_emailValid || !_passwordValid) {
      _showSnackBar('Pastikan email dan password valid', isError: true);
      return;
    }
    
    setState(() => _isLoading = true);
    
    try {
      final loginResult = await ApiService.login(email, password);
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      
      if (loginResult.containsKey('user') && loginResult['user'] != null) {
        await prefs.setInt('user_id', loginResult['user']['id']);
      } else if (loginResult.containsKey('id')) {
        await prefs.setInt('user_id', loginResult['id']);
      } else {
        await prefs.setInt('user_id', 1);
      }
      
      HapticFeedback.heavyImpact();
      _showSnackBar('Login berhasil! Selamat datang', isError: false);
      
      await Future.delayed(const Duration(milliseconds: 500));
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const MainScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    } catch (e) {
      HapticFeedback.heavyImpact();
      _showSnackBar('Login gagal: ${e.toString()}', isError: true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade400 : Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    _rotationController.dispose();
    _formController.dispose();
    emailController.dispose();
    passwordController.dispose();
    emailFocusNode.dispose();
    passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6D1B47),
              Color(0xFF9B4064),
              Color(0xFFB76A8A),
              Color(0xFF8B1E5B),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Animated background particles
            ...List.generate(15, (index) => Positioned(
              left: (index * 50.0) % MediaQuery.of(context).size.width,
              top: (index * 60.0) % MediaQuery.of(context).size.height,
              child: AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      30 * _rotationAnimation.value * (index % 2 == 0 ? 1 : -1),
                      25 * _rotationAnimation.value * (index % 3 == 0 ? 1 : -1),
                    ),
                    child: Container(
                      width: 6 + (index % 4) * 2,
                      height: 6 + (index % 4) * 2,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05 + (index % 5) * 0.05),
                        shape: BoxShape.circle,
                      ),
                    ),
                  );
                },
              ),
            )),
            
            // Main content
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated logo
                      AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.3),
                                      blurRadius: 25,
                                      offset: const Offset(0, 15),
                                    ),
                                    BoxShadow(
                                      color: Colors.white.withOpacity(0.1),
                                      blurRadius: 15,
                                      offset: const Offset(0, -5),
                                    ),
                                  ],
                                ),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/hm2.jpg',
                                    width: 120,
                                    height: 120,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Welcome text with animation
                      SlideTransition(
                        position: _slideAnimation,
                        child: FadeTransition(
                          opacity: _fadeAnimation,
                          child: Column(
                            children: [
                              const Text(
                                'Selamat Datang Kembali',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  fontFamily: 'Serif',
                                  shadows: [
                                    Shadow(
                                      offset: Offset(2, 2),
                                      blurRadius: 8,
                                      color: Colors.black26,
                                    ),
                                  ],
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Masuk untuk melanjutkan booking homestay',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 16,
                                  fontFamily: 'Serif',
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Login form with animation
                      AnimatedBuilder(
                        animation: _formAnimation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, 50 * (1 - _formAnimation.value)),
                            child: Opacity(
                              opacity: _formAnimation.value,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.95),
                                  borderRadius: BorderRadius.circular(28),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.1),
                                      blurRadius: 25,
                                      offset: const Offset(0, 15),
                                    ),
                                  ],
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(32),
                                  child: Column(
                                    children: [
                                      // Email field with animation
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: !_emailValid 
                                                ? Colors.red.shade300
                                                : emailFocusNode.hasFocus 
                                                    ? const Color(0xFF9B4064)
                                                    : Colors.grey.shade300,
                                            width: emailFocusNode.hasFocus ? 2 : 1,
                                          ),
                                          boxShadow: emailFocusNode.hasFocus ? [
                                            BoxShadow(
                                              color: const Color(0xFF9B4064).withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ] : null,
                                        ),
                                        child: TextField(
                                          controller: emailController,
                                          focusNode: emailFocusNode,
                                          keyboardType: TextInputType.emailAddress,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.email_outlined,
                                              color: emailFocusNode.hasFocus 
                                                  ? const Color(0xFF9B4064)
                                                  : Colors.grey.shade600,
                                            ),
                                            labelText: 'Email',
                                            labelStyle: TextStyle(
                                              color: emailFocusNode.hasFocus 
                                                  ? const Color(0xFF9B4064)
                                                  : Colors.grey.shade600,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 16,
                                            ),
                                            errorText: !_emailValid ? 'Email tidak valid' : null,
                                          ),
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 20),
                                      
                                      // Password field with animation
                                      AnimatedContainer(
                                        duration: const Duration(milliseconds: 300),
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(16),
                                          border: Border.all(
                                            color: !_passwordValid 
                                                ? Colors.red.shade300
                                                : passwordFocusNode.hasFocus 
                                                    ? const Color(0xFF9B4064)
                                                    : Colors.grey.shade300,
                                            width: passwordFocusNode.hasFocus ? 2 : 1,
                                          ),
                                          boxShadow: passwordFocusNode.hasFocus ? [
                                            BoxShadow(
                                              color: const Color(0xFF9B4064).withOpacity(0.1),
                                              blurRadius: 8,
                                              offset: const Offset(0, 4),
                                            ),
                                          ] : null,
                                        ),
                                        child: TextField(
                                          controller: passwordController,
                                          focusNode: passwordFocusNode,
                                          obscureText: _obscurePassword,
                                          decoration: InputDecoration(
                                            prefixIcon: Icon(
                                              Icons.lock_outline,
                                              color: passwordFocusNode.hasFocus 
                                                  ? const Color(0xFF9B4064)
                                                  : Colors.grey.shade600,
                                            ),
                                            labelText: 'Password',
                                            labelStyle: TextStyle(
                                              color: passwordFocusNode.hasFocus 
                                                  ? const Color(0xFF9B4064)
                                                  : Colors.grey.shade600,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 16,
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _obscurePassword 
                                                    ? Icons.visibility_off_outlined 
                                                    : Icons.visibility_outlined,
                                                color: passwordFocusNode.hasFocus 
                                                    ? const Color(0xFF9B4064)
                                                    : Colors.grey.shade600,
                                              ),
                                              onPressed: () {
                                                HapticFeedback.lightImpact();
                                                setState(() => _obscurePassword = !_obscurePassword);
                                              },
                                            ),
                                            errorText: !_passwordValid ? 'Password minimal 6 karakter' : null,
                                          ),
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 32),
                                      
                                      // Login button with animation
                                      SizedBox(
                                        width: double.infinity,
                                        height: 54,
                                        child: AnimatedContainer(
                                          duration: const Duration(milliseconds: 200),
                                          child: ElevatedButton(
                                            onPressed: _isLoading ? null : _login,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(0xFF9B4064),
                                              foregroundColor: Colors.white,
                                              elevation: _isLoading ? 0 : 8,
                                              shadowColor: const Color(0xFF9B4064).withOpacity(0.4),
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(16),
                                              ),
                                              textStyle: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                            child: _isLoading
                                                ? Row(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      SizedBox(
                                                        width: 20,
                                                        height: 20,
                                                        child: CircularProgressIndicator(
                                                          strokeWidth: 2,
                                                          valueColor: AlwaysStoppedAnimation<Color>(
                                                            Colors.white,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(width: 12),
                                                      const Text('Memproses...'),
                                                    ],
                                                  )
                                                : const Text('Masuk'),
                                          ),
                                        ),
                                      ),
                                      
                                      const SizedBox(height: 24),
                                      
                                      // Register link with animation
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            'Belum punya akun? ',
                                            style: TextStyle(
                                              color: Colors.grey.shade600,
                                              fontSize: 14,
                                            ),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              HapticFeedback.lightImpact();
                                              Navigator.push(
                                                context,
                                                PageRouteBuilder(
                                                  pageBuilder: (context, animation, secondaryAnimation) => 
                                                      const RegisterScreen(),
                                                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                                    return SlideTransition(
                                                      position: Tween<Offset>(
                                                        begin: const Offset(1.0, 0.0),
                                                        end: Offset.zero,
                                                      ).animate(animation),
                                                      child: child,
                                                    );
                                                  },
                                                ),
                                              );
                                            },
                                            child: const Text(
                                              'Daftar Sekarang',
                                              style: TextStyle(
                                                color: Color(0xFF9B4064),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
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
