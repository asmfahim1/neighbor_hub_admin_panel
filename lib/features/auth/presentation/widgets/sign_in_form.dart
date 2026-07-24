import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:neighbor_hub_admin_panel/core/common_widgets/common_button.dart';
import 'package:neighbor_hub_admin_panel/core/common_widgets/common_text_field.dart';
import 'package:neighbor_hub_admin_panel/core/localization/app_strings.dart';
import 'package:neighbor_hub_admin_panel/core/route_handler/app_routes.dart';
import 'package:neighbor_hub_admin_panel/core/utils/app_validators.dart';
import 'package:neighbor_hub_admin_panel/core/utils/dimensions.dart';
import 'package:neighbor_hub_admin_panel/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:neighbor_hub_admin_panel/features/auth/presentation/bloc/auth_event.dart';
import 'package:neighbor_hub_admin_panel/features/auth/presentation/bloc/auth_state.dart';
import 'package:neighbor_hub_admin_panel/features/auth/presentation/widgets/social_sign_in_buttons.dart';
import 'package:neighbor_hub_admin_panel/features/dashboard/presentation/bloc/dashboard_bloc.dart';
import 'package:neighbor_hub_admin_panel/features/dashboard/presentation/bloc/dashboard_event.dart';

/// The sign-in form: email/password fields, submit, forgot-password, and
/// the social sign-in buttons. Reused as-is by both the mobile and web
/// layouts (`auth_plan.md`'s UI Design Plan).
///
/// The **only** `StatefulWidget` in this feature's UI — it owns two
/// `TextEditingController`s and the password-obscure toggle, which a
/// `State` must own for disposal/lifecycle reasons. All business state
/// (loading, errors) comes from `AuthBloc`, not local state.
class SignInForm extends StatefulWidget {
  const SignInForm({super.key});

  @override
  State<SignInForm> createState() => _SignInFormState();
}

class _SignInFormState extends State<SignInForm> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    /*if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          SignInWithEmailRequested(_emailController.text.trim(), _passwordController.text),
        );*/

    context.read<DashboardBloc>().add(const DashboardPreviewStarted());
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.dashboard,
      (route) => false,
      arguments: true,
    );
  }

  Future<void> _showForgotPasswordDialog() async {
    final emailController = TextEditingController(text: _emailController.text.trim());
    final formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(dialogContext.tr('auth_reset_dialog_title')),
          content: Form(
            key: formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(dialogContext.tr('auth_reset_dialog_message')),
                SizedBox(height: Dimensions.height(16)),
                CommonTextField(
                  controller: emailController,
                  labelText: dialogContext.tr('email'),
                  hintText: dialogContext.tr('auth_email_hint'),
                  keyboardType: TextInputType.emailAddress,
                  validator: AppValidators.email,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: Text(dialogContext.tr('auth_reset_dialog_cancel')),
            ),
            TextButton(
              onPressed: () {
                if (!formKey.currentState!.validate()) return;
                context
                    .read<AuthBloc>()
                    .add(PasswordResetRequested(emailController.text.trim()));
                Navigator.of(dialogContext).pop();
              },
              child: Text(dialogContext.tr('auth_reset_dialog_send')),
            ),
          ],
        );
      },
    );
    emailController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          CommonTextField(
            controller: _emailController,
            labelText: context.tr('email'),
            hintText: context.tr('auth_email_hint'),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            prefixIcon: const Icon(Icons.mail_outline),
            validator: AppValidators.email,
          ),
          SizedBox(height: Dimensions.height(16)),
          CommonTextField(
            controller: _passwordController,
            labelText: context.tr('password'),
            hintText: context.tr('auth_password_hint'),
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (value) => AppValidators.password(value, minLength: 6),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: _showForgotPasswordDialog,
              child: Text(context.tr('auth_forgot_password')),
            ),
          ),
          SizedBox(height: Dimensions.height(8)),
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (previous, current) => previous.status != current.status,
            builder: (context, state) {
              final isSubmitting = state.status == AuthStatus.authenticating;
              return CommonButton(
                label: context.tr('auth_sign_in_button'),
                onPressed: _submit,
                isLoading: isSubmitting,
                isEnabled: !isSubmitting,
                height: Dimensions.height(50),
                backgroundColor: Theme.of(context).colorScheme.primary,
              );
            },
          ),
          SizedBox(height: Dimensions.height(24)),
          Row(
            children: [
              const Expanded(child: Divider()),
              Flexible(
                child: Padding(
                  padding: Dimensions.paddingSymmetric(horizontal: 12),
                  child: Text(
                    context.tr('auth_or_continue_with'),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: Dimensions.font(12)),
                  ),
                ),
              ),
              const Expanded(child: Divider()),
            ],
          ),
          SizedBox(height: Dimensions.height(24)),
          BlocBuilder<AuthBloc, AuthState>(
            buildWhen: (previous, current) => previous.status != current.status,
            builder: (context, state) {
              final isSubmitting = state.status == AuthStatus.authenticating;
              return SocialSignInButtons(
                isEnabled: !isSubmitting,
                onGooglePressed: () => context.read<AuthBloc>().add(const SignInWithGoogleRequested()),
                onApplePressed: () => context.read<AuthBloc>().add(const SignInWithAppleRequested()),
              );
            },
          ),
        ],
      ),
    );
  }
}
