import 'package:flutter/material.dart';
import 'package:lapinia_mobile/l10n/app_localizations.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;

    final formKey = useMemoized(GlobalKey<FormState>.new);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isSignUp = useState(false);

    final authState = ref.watch(authControllerProvider);

    ref.listen<AsyncValue<User?>>(authControllerProvider, (prev, next) {
      next.whenOrNull(
        error: (err, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err.toString()), backgroundColor: AppColors.danger),
          );
        },
        data: (user) {
          if (user != null) {
            context.go('/dashboard');
          }
        },
      );
    });

    Future<void> submit() async {
      if (!formKey.currentState!.validate()) return;
      final email = emailController.text.trim();
      final password = passwordController.text;

      if (isSignUp.value) {
        try {
          final response = await ref
              .read(authControllerProvider.notifier)
              .signUp(email: email, password: password);
          if (response.session == null) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(l10n.signUpCheckEmail(email))),
            );
          }
        } catch (_) {}
        return;
      }

      await ref
          .read(authControllerProvider.notifier)
          .signIn(email: email, password: password);
    }

    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + bottomInset),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Form(
                    key: formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 24),
                        Text(
                          l10n.loginTitle,
                          style: AppTypography.headline1,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          isSignUp.value
                              ? l10n.loginSubtitleSignUp
                              : l10n.loginSubtitleSignIn,
                          style: AppTypography.body1.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          l10n.emailLabel,
                          style: AppTypography.label,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: l10n.emailHint,
                            prefixIcon: const Icon(Icons.email),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.validationEmailRequired;
                            }
                            final v = value.trim();
                            if (!v.contains('@') || !v.contains('.')) {
                              return l10n.validationEmailInvalid;
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Text(
                          l10n.passwordLabel,
                          style: AppTypography.label,
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: l10n.passwordHint,
                            prefixIcon: const Icon(Icons.lock),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return l10n.validationPasswordRequired;
                            }
                            if (value.length < 6) {
                              return l10n.validationPasswordTooShort;
                            }
                            return null;
                          },
                        ),
                        const Spacer(),
                        ElevatedButton(
                          onPressed: isLoading ? null : submit,
                          child: isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  isSignUp.value
                                      ? l10n.signUp
                                      : l10n.signIn,
                                ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: isLoading
                              ? null
                              : () => isSignUp.value = !isSignUp.value,
                          child: Text(
                            isSignUp.value
                                ? l10n.loginToggleToSignIn
                                : l10n.loginToggleToSignUp,
                            style: AppTypography.body2.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
