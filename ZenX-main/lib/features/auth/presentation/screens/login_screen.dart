import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';
import '../../../../core/config/app_config.dart';
import '../../../../core/network/graphql_client.dart';
import '../../../../core/network/graphql_queries.dart';
import '../../../../core/network/security.dart';

/// Login screen backed by the real GraphQL gateway.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final client = ref.read(graphqlProvider);
      final result = await client.mutate(
        MutationOptions(
          document: gql(GraphQLQueries.login),
          variables: {
            'email': _emailController.text.trim(),
            'password': _passwordController.text,
          },
          fetchPolicy: FetchPolicy.noCache,
        ),
      );

      if (result.hasException) {
        throw result.exception!;
      }

      final payload = result.data?['login'] as Map<String, dynamic>?;
      if (payload == null) {
        throw StateError('No login payload returned');
      }

      final accessToken = payload['accessToken'] as String? ?? '';
      final refreshToken = payload['refreshToken'] as String? ?? '';
      final expiresAtRaw = payload['expiresAt'] as String? ?? '';

      if (accessToken.isEmpty || refreshToken.isEmpty || expiresAtRaw.isEmpty) {
        throw StateError('Incomplete auth payload');
      }

      await SecurityManager.saveAccessToken(
        accessToken,
        DateTime.parse(expiresAtRaw),
      );
      await SecurityManager.saveRefreshToken(refreshToken);

      if (!mounted) return;
      context.go('/home');
    } catch (error) {
      if (!mounted) return;
      
      String errorMessage = 'Login failed. Please check your credentials.';
      final errorStr = error.toString().toLowerCase();
      
      if (errorStr.contains('timeout') || errorStr.contains('deadline')) {
        errorMessage = 'Connection timed out. Ensure the server IP is correct.';
      } else if (errorStr.contains('connection refused') || errorStr.contains('socketexception')) {
        errorMessage = 'Could not reach server. Check if it\'s running on the target IP.';
      } else if (errorStr.contains('unauthorized') || 
                 errorStr.contains('invalid') ||
                 errorStr.contains('credentials')) {
        errorMessage = 'Invalid email or password. Please try again.';
      } else if (errorStr.contains('network') || 
                 errorStr.contains('connection')) {
        errorMessage = 'Network error. Please check your connection.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            errorMessage,
            style: const TextStyle(color: HevyColors.textPrimary),
          ),
          backgroundColor: HevyColors.error,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'CONFIG',
            textColor: Colors.white,
            onPressed: () => _showServerConfigDialog(context),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  void _showServerConfigDialog(BuildContext context) {
    final controller = TextEditingController(text: AppConfig.apiBaseUrl);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Server Configuration'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Enter the API URL for your environment.\nUse your computer\'s LAN IP for physical devices.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              decoration: const InputDecoration(
                labelText: 'API URL',
                hintText: 'http://192.168.1.10:4000/graphql',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Reset to default
              AppConfig.setCustomUrl(null);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reset to default configuration. Please restart the app.')),
              );
            },
            child: const Text('Reset Default'),
          ),
          ElevatedButton(
            onPressed: () {
              AppConfig.setCustomUrl(controller.text.trim());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Configuration saved. Please RESTART the app to apply.'),
                  duration: Duration(seconds: 4),
                ),
              );
            },
            child: const Text('Save & Restart'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: HevyColors.background,
      appBar: AppBar(
        backgroundColor: HevyColors.background,
        elevation: 0,
        title: const Text(
          'Welcome to ZenX',
          style: TextStyle(
            fontSize: DesignTokens.titleLarge,
            fontWeight: FontWeight.w600,
            color: HevyColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(DesignTokens.paddingScreen),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: DesignTokens.spacingXXL),
                const SizedBox(height: DesignTokens.spacingXXL),
                GestureDetector(
                  onLongPress: () => _showServerConfigDialog(context),
                  child: Text(
                    'ZenX',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingXS),
                Text(
                  'Your Fitness Journey Starts Here',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: DesignTokens.spacingXXXL),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    prefixIcon: const Icon(Icons.email_outlined),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Email is required';
                    }
                    if (!value.contains('@')) {
                      return 'Enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: DesignTokens.spacingM),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    prefixIcon: const Icon(Icons.lock_outlined),
                    suffixIcon: IconButton(
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(DesignTokens.radiusM),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Password is required';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/auth/forgot-password'),
                    child: const Text('Forgot Password?'),
                  ),
                ),
                const SizedBox(height: DesignTokens.spacingL),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: DesignTokens.paddingButtonVertical,
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: _isSubmitting
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Login'),
                ),
                const SizedBox(height: DesignTokens.spacingM),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Don't have an account? ",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                    TextButton(
                      onPressed: () => context.push('/auth/register'),
                      child: const Text('Sign Up'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
