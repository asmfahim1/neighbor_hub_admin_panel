import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/common_widgets/common_button.dart';
import '../../../../core/common_widgets/common_text_field.dart';
import '../../../../core/localization/app_strings.dart';
import '../../../../core/utils/app_validators.dart';
import '../../../../core/utils/dimensions.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import 'social_sign_in_buttons.dart';

/// The admin sign-up form: building name/address, then either a
/// Google/Apple button or the manual account fields (display name, email,
/// password, confirm password). See `auth_plan.md`'s UI Design Plan.
///
/// Uses **two sibling `Form`s** (`_buildingFormKey` + `_accountFormKey`)
/// instead of one: Google/Apple sign-up only needs the building fields, and
/// Flutter's nested-`Form` semantics register a `FormField` with the
/// *nearest* enclosing `Form` — there's no way for one outer `Form` to
/// selectively validate a subset of its own fields, so two independent
/// sibling forms is the only way to let the social buttons validate just
/// the building group while "Create account" validates both.
///
/// The **only** `StatefulWidget` in the sign-up flow — owns the
/// `TextEditingController`s and the password-obscure toggle, same
/// justification as `SignInForm`.
class SignUpForm extends StatefulWidget {
  const SignUpForm({super.key});

  @override
  State<SignUpForm> createState() => _SignUpFormState();
}

class _SignUpFormState extends State<SignUpForm> {
  final _buildingFormKey = GlobalKey<FormState>();
  final _accountFormKey = GlobalKey<FormState>();
  final _buildingNameController = TextEditingController();
  final _buildingAddressController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _buildingNameController.dispose();
    _buildingAddressController.dispose();
    _displayNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    final buildingValid = _buildingFormKey.currentState!.validate();
    final accountValid = _accountFormKey.currentState!.validate();
    if (!buildingValid || !accountValid) return;
    context.read<AuthBloc>().add(
          SignUpAsAdminRequested(
            buildingName: _buildingNameController.text.trim(),
            buildingAddress: _buildingAddressController.text.trim(),
            displayName: _displayNameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  void _submitWithGoogle() {
    if (!_buildingFormKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          SignUpWithGoogleRequested(
            buildingName: _buildingNameController.text.trim(),
            buildingAddress: _buildingAddressController.text.trim(),
          ),
        );
  }

  void _submitWithApple() {
    if (!_buildingFormKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          SignUpWithAppleRequested(
            buildingName: _buildingNameController.text.trim(),
            buildingAddress: _buildingAddressController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Form(
          key: _buildingFormKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CommonTextField(
                controller: _buildingNameController,
                labelText: context.tr('auth_building_name_label'),
                hintText: context.tr('auth_building_name_hint'),
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.apartment_outlined),
                validator: AppValidators.required(context.tr('auth_building_name_label')),
              ),
              SizedBox(height: Dimensions.height(16)),
              CommonTextField(
                controller: _buildingAddressController,
                labelText: context.tr('auth_building_address_label'),
                hintText: context.tr('auth_building_address_hint'),
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(Icons.location_on_outlined),
                validator: AppValidators.required(context.tr('auth_building_address_label')),
              ),
            ],
          ),
        ),
        SizedBox(height: Dimensions.height(20)),
        BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (previous, current) => previous.status != current.status,
          builder: (context, state) {
            final isSubmitting = state.status == AuthStatus.authenticating;
            return SocialSignInButtons(
              isEnabled: !isSubmitting,
              onGooglePressed: _submitWithGoogle,
              onApplePressed: _submitWithApple,
            );
          },
        ),
        SizedBox(height: Dimensions.height(20)),
        Row(
          children: [
            const Expanded(child: Divider()),
            Padding(
              padding: Dimensions.paddingSymmetric(horizontal: 12),
              child: Text(
                context.tr('auth_or_continue_with_email'),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: Dimensions.font(12)),
              ),
            ),
            const Expanded(child: Divider()),
          ],
        ),
        SizedBox(height: Dimensions.height(20)),
        Form(
          key: _accountFormKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CommonTextField(
                controller: _displayNameController,
                labelText: context.tr('auth_display_name_label'),
                hintText: context.tr('auth_display_name_hint'),
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.person_outline),
                validator: AppValidators.required(context.tr('auth_display_name_label')),
              ),
              SizedBox(height: Dimensions.height(16)),
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
                textInputAction: TextInputAction.next,
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (value) => AppValidators.password(value, minLength: 6),
              ),
              SizedBox(height: Dimensions.height(16)),
              CommonTextField(
                controller: _confirmPasswordController,
                labelText: context.tr('auth_confirm_password_label'),
                hintText: context.tr('auth_password_hint'),
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                prefixIcon: const Icon(Icons.lock_outline),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return AppValidators.password(value, minLength: 6);
                  }
                  if (value != _passwordController.text) {
                    return context.tr('auth_passwords_do_not_match');
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        SizedBox(height: Dimensions.height(24)),
        BlocBuilder<AuthBloc, AuthState>(
          buildWhen: (previous, current) => previous.status != current.status,
          builder: (context, state) {
            final isSubmitting = state.status == AuthStatus.authenticating;
            return CommonButton(
              label: context.tr('auth_sign_up_button'),
              onPressed: _submit,
              isLoading: isSubmitting,
              isEnabled: !isSubmitting,
              height: Dimensions.height(50),
              backgroundColor: Theme.of(context).colorScheme.primary,
            );
          },
        ),
      ],
    );
  }
}
