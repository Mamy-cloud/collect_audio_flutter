import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/global/app_styles.dart';
import '../widgets/screens_widgets/login_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _identifiantCtrl = TextEditingController();
  final _codeCtrl        = TextEditingController();
  bool  _isLoading       = false;

  Future<void> _onLogin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    setState(() => _isLoading = false);
    context.go('/list_temoin');
  }

  void _onGuestMode() {
    context.go('/list_temoin');
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content:         Text(msg, style: const TextStyle(color: Colors.white)),
      backgroundColor: AppColors.surface,
      behavior:        SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side:         const BorderSide(color: Colors.white24),
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  const SizedBox(height: 40),

                  const Center(child: LoginTitle()),

                  const SizedBox(height: 20),

                  const LoginHeroImage(assetPath: 'assets/img/logo_essai.png'),

                  const SizedBox(height: 20),

                  Center(
                    child: Text(
                      'Connectez-vous pour continuer',
                      style: AppTextStyles.label.copyWith(fontSize: 14),
                    ),
                  ),

                  const SizedBox(height: 36),

                  IdentifiantField(controller: _identifiantCtrl),

                  const SizedBox(height: 16),

                  CodeAccesField(controller: _codeCtrl),

                  const SizedBox(height: 28),

                  LoginButton(
                    onPressed: _onLogin,
                    isLoading: _isLoading,
                  ),

                  const Spacer(),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 28),
                    child: GuestModeLink(onTap: _onGuestMode),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _identifiantCtrl.dispose();
    _codeCtrl.dispose();
    super.dispose();
  }
}
