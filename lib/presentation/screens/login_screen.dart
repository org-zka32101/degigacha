import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../riverpod/auth_notifier.dart';
import '../riverpod/providers.dart';

/// ログイン画面
///
/// ユーザーの認証を行うスクリーン。
/// - Google Sign-In
/// - Apple Sign-In (iOS)
/// - メールアドレス/パスワード認証
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isSigningUp = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _navigateToHome() {
    context.go('/');
  }

  Future<void> _signInWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar('メールアドレスとパスワードを入力してください');
      return;
    }

    await ref.read(authNotifierProvider.notifier).signInWithEmail(
          email: email,
          password: password,
        );

    if (mounted) {
      final authState = ref.read(authNotifierProvider);
      if (authState.isAuthenticated) {
        _navigateToHome();
      } else if (authState.errorMessage != null) {
        _showErrorSnackBar(authState.errorMessage!);
      }
    }
  }

  Future<void> _signUpWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showErrorSnackBar('メールアドレスとパスワードを入力してください');
      return;
    }

    if (password.length < 6) {
      _showErrorSnackBar('パスワードは6文字以上で設定してください');
      return;
    }

    await ref.read(authNotifierProvider.notifier).signUpWithEmail(
          email: email,
          password: password,
        );

    if (mounted) {
      final authState = ref.read(authNotifierProvider);
      if (authState.isAuthenticated) {
        _navigateToHome();
      } else if (authState.errorMessage != null) {
        _showErrorSnackBar(authState.errorMessage!);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    await ref.read(authNotifierProvider.notifier).signInWithGoogle();

    if (mounted) {
      final authState = ref.read(authNotifierProvider);
      if (authState.isAuthenticated) {
        _navigateToHome();
      } else if (authState.errorMessage != null) {
        _showErrorSnackBar(authState.errorMessage!);
      }
    }
  }

  Future<void> _signInWithApple() async {
    await ref.read(authNotifierProvider.notifier).signInWithApple();

    if (mounted) {
      final authState = ref.read(authNotifierProvider);
      if (authState.isAuthenticated) {
        _navigateToHome();
      } else if (authState.errorMessage != null) {
        _showErrorSnackBar(authState.errorMessage!);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);
    final isLoading = authState.isLoading;
    return Scaffold(
      appBar: AppBar(
        title: const Text('デジタルガチャ帳へログイン'),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Icon / Logo
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Icon(
                        Icons.collections_bookmark,
                        size: 60,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'デジタルガチャ帳',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'ガチャの戦利品を撮るだけで自動認識・図鑑化',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 48),

                    // Google Sign-In Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _signInWithGoogle,
                        icon: const Icon(Icons.login),
                        label: const Text('Googleでログイン'),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Apple Sign-In Button (iOS only)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _signInWithApple,
                        icon: const Icon(Icons.login),
                        label: const Text('Appleでログイン'),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Divider(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                    const SizedBox(height: 24),

                    // Email/Password login form
                    TextField(
                      controller: _emailController,
                      enabled: !isLoading,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'メールアドレス',
                        prefixIcon: const Icon(Icons.email),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _passwordController,
                      enabled: !isLoading,
                      obscureText: true,
                      decoration: InputDecoration(
                        hintText: 'パスワード',
                        prefixIcon: const Icon(Icons.lock),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Sign In Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton(
                        onPressed:
                            isLoading ? null : _signInWithEmail,
                        child: const Text('ログイン'),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Sign Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton(
                        onPressed:
                            isLoading ? null : _signUpWithEmail,
                        child: const Text('新しいアカウントを作成'),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Forgot Password Link
                    TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              // TODO: Navigate to password reset
                            },
                      child: const Text('パスワードを忘れた方へ'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
