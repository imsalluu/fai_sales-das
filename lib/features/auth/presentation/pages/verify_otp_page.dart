import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/forgot_password_provider.dart';

class VerifyOtpPage extends ConsumerStatefulWidget {
  const VerifyOtpPage({super.key});

  @override
  ConsumerState<VerifyOtpPage> createState() => _VerifyOtpPageState();
}

class _VerifyOtpPageState extends ConsumerState<VerifyOtpPage> {
  final _otpController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(forgotPasswordProvider);

    return Scaffold(
      body: Row(
        children: [
          // Left side: Image/Branding
          Expanded(
            child: Container(
              color: Theme.of(context).primaryColor,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 30, offset: const Offset(0, 10)),
                        ],
                      ),
                      child: Image.asset('assets/images/fai_logo.png', width: 120, height: 120, fit: BoxFit.contain),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      "FAI Dashboard",
                      style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Verify OTP",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Right side: Verify OTP Form
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                   IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      context.go('/forgot-password');
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Enter OTP",
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text("We've sent an OTP to \${state.email}. Please enter it below."),
                  const SizedBox(height: 32),
                  TextField(
                    controller: _otpController,
                    decoration: const InputDecoration(
                      labelText: "OTP",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.message),
                    ),
                    onChanged: (value) {
                      ref.read(forgotPasswordProvider.notifier).setOtp(value);
                    },
                  ),
                  const SizedBox(height: 24),
                  if (state.error != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: Text(state.error!, style: const TextStyle(color: Colors.red)),
                    ),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () async {
                              final success = await ref.read(forgotPasswordProvider.notifier).verifyOtp();
                              if (success && mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(state.successMessage ?? 'OTP Verified')),
                                );
                                context.go('/reset-password');
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: state.isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("Verify", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }
}
