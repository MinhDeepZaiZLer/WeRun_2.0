// lib/presentation/screens/auth/sign_up_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'bloc/auth_bloc.dart';

class SignUpScreen extends StatefulWidget {
  final VoidCallback? onBackClicked;
  final VoidCallback? onSignUpSuccess;

  const SignUpScreen({
    Key? key,
    this.onBackClicked,
    this.onSignUpSuccess,
  }) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _dobController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;
  bool _passwordMismatch = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is Authenticated) {
          // Navigate on success
          if (widget.onSignUpSuccess != null) {
            widget.onSignUpSuccess!();
          } else {
            context.go('/home'); // Default navigation
          }
        }
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          toolbarHeight: 80,
          leading: IconButton(
            onPressed: () {
              if (widget.onBackClicked != null) {
                widget.onBackClicked!();
              } else {
                context.go('/login');
              }
            },
            icon: Icon(Icons.arrow_back, color: colorScheme.primary),
            style: IconButton.styleFrom(
              side: BorderSide(color: colorScheme.primary, width: 2),
              shape: const CircleBorder(),
            ),
          ),
          title: Text(
            'Create an account',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: colorScheme.onBackground,
            ),
          ),
          titleSpacing: 0,
        ),
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 16),
                      _buildField(
                        _fullNameController,
                        'Full Name',
                        Icons.person,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        _emailController,
                        'Email',
                        Icons.email,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        _phoneController,
                        'Phone Number',
                        Icons.phone,
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: _showDatePicker,
                        child: AbsorbPointer(
                          child: _buildField(
                            _dobController,
                            'Date of Birth',
                            Icons.date_range,
                            readOnly: true,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        _passwordController,
                        'Password',
                        Icons.lock,
                        isPassword: true,
                        isVisible: _isPasswordVisible,
                        onVisibilityToggle: () {
                          setState(() => _isPasswordVisible = !_isPasswordVisible);
                        },
                      ),
                      const SizedBox(height: 16),
                      _buildField(
                        _confirmPasswordController,
                        'Confirm Password',
                        Icons.lock,
                        isPassword: true,
                        isVisible: _isConfirmVisible,
                        onVisibilityToggle: () {
                          setState(() => _isConfirmVisible = !_isConfirmVisible);
                        },
                        onChanged: (v) {
                          setState(() {
                            _passwordMismatch = v != _passwordController.text && v.isNotEmpty;
                          });
                        },
                        errorText: _passwordMismatch ? 'Passwords do not match' : null,
                      ),
                      const SizedBox(height: 32),
                      ElevatedButton(
                        onPressed: _canSignUp() && !isLoading ? _handleSignUp : null,
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: isLoading
                            ? SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: colorScheme.onPrimary,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Join Us',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                      ),
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          context.go('/login');
                        },
                        child: Text(
                          'Already have an account? Log in',
                          style: TextStyle(color: colorScheme.primary),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const _SocialLoginSection(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
                if (isLoading)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: Center(
                      child: CircularProgressIndicator(
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  bool _canSignUp() {
    return _fullNameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        !_passwordMismatch;
  }

  void _handleSignUp() {
    context.read<AuthBloc>().add(
          RegisterRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
            name: _fullNameController.text.trim(),
            // phone: _phoneController.text.trim(),
            // dateOfBirth: _dobController.text.trim(),
          ),
        );
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobController.text =
          '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildField(
    TextEditingController controller,
    String label,
    IconData icon, {
    bool isPassword = false,
    bool isVisible = false,
    VoidCallback? onVisibilityToggle,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
    String? errorText,
    Function(String)? onChanged,
  }) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      obscureText: isPassword && !isVisible,
      keyboardType: keyboardType,
      readOnly: readOnly,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        errorText: errorText,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  isVisible ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: onVisibilityToggle,
              )
            : null,
      ).applyDefaults(theme.inputDecorationTheme),
    );
  }
}

class _SocialLoginSection extends StatelessWidget {
  const _SocialLoginSection();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialButton(Icons.g_mobiledata, 'Google'),
        const SizedBox(width: 16),
        _socialButton(Icons.facebook, 'Facebook'),
      ],
    );
  }

  Widget _socialButton(IconData icon, String label) {
    return OutlinedButton.icon(
      onPressed: () {},
      icon: Icon(icon, color: Colors.grey),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}