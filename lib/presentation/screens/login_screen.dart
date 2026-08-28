import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// ログイン画面
///
/// ユーザーの認証を行うスクリーン。
/// - Google Sign-In
/// - Apple Sign-In (iOS)
/// - メールアドレス/パスワード認証
class LoginScreen extends ConsumerWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('デジタルガチャ帳へログイン'),
        centerTitle: true,
      ),
      body: Center(
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
                  color: Theme.of(context).colorScheme.primaryContainer,
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
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              Text(
                'ガチャの戦利品を撮るだけで自動認識・図鑑化',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),

              // TODO: Implement Google Sign-In button
              ElevatedButton.icon(
                onPressed: () {
                  // Sign in with Google
                },
                icon: const Icon(Icons.login),
                label: const Text('Googleでログイン'),
              ),
              const SizedBox(height: 12),

              // TODO: Implement Apple Sign-In button (iOS only)
              ElevatedButton.icon(
                onPressed: () {
                  // Sign in with Apple
                },
                icon: const Icon(Icons.login),
                label: const Text('Appleでログイン'),
              ),
              const SizedBox(height: 24),
              Divider(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              const SizedBox(height: 24),

              // TODO: Implement Email/Password login form
              TextField(
                decoration: InputDecoration(
                  hintText: 'メールアドレス',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'パスワード',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Sign in with email
                  },
                  child: const Text('ログイン'),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  // Navigate to sign up
                },
                child: const Text('アカウントを作成'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
