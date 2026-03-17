import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'auth_provider.dart';

final forgotPasswordProvider = StateNotifierProvider<ForgotPasswordNotifier, ForgotPasswordState>((ref) {
  final apiService = ref.read(apiServiceProvider);
  return ForgotPasswordNotifier(apiService);
});

class ForgotPasswordState {
  final bool isLoading;
  final String? error;
  final String? successMessage;
  final String email;
  final String otp;

  ForgotPasswordState({
    this.isLoading = false,
    this.error,
    this.successMessage,
    this.email = '',
    this.otp = '',
  });

  ForgotPasswordState copyWith({
    bool? isLoading,
    String? error,
    String? successMessage,
    String? email,
    String? otp,
  }) {
    return ForgotPasswordState(
      isLoading: isLoading ?? this.isLoading,
      error: error, // Important: Don't default to this.error so we can clear errors by passing null
      successMessage: successMessage,
      email: email ?? this.email,
      otp: otp ?? this.otp,
    );
  }
}

class ForgotPasswordNotifier extends StateNotifier<ForgotPasswordState> {
  final _apiService;

  ForgotPasswordNotifier(this._apiService) : super(ForgotPasswordState());

  void setEmail(String email) {
    state = state.copyWith(email: email, error: null);
  }

  void setOtp(String otp) {
    state = state.copyWith(otp: otp, error: null);
  }

  Future<bool> sendForgotPasswordEmail() async {
    if (state.email.isEmpty) {
      state = state.copyWith(error: "Email cannot be empty");
      return false;
    }

    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final response = await _apiService.forgotPassword(state.email);
      if (response.isSuccess) {
        state = state.copyWith(
            isLoading: false, 
            successMessage: response.responseData['message'] ?? "OTP sent to your email.");
        return true;
      } else {
        state = state.copyWith(
            isLoading: false, 
            error: response.errorMassage ?? "Failed to send OTP.");
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "An unexpected error occurred.");
      return false;
    }
  }

  Future<bool> verifyOtp() async {
    if (state.email.isEmpty || state.otp.isEmpty) {
      state = state.copyWith(error: "Email and OTP cannot be empty");
      return false;
    }

    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final response = await _apiService.verifyOtp(state.email, state.otp);
      if (response.isSuccess) {
        state = state.copyWith(
            isLoading: false, 
            successMessage: response.responseData['message'] ?? "OTP verified successfully.");
        return true;
      } else {
        state = state.copyWith(
            isLoading: false, 
            error: response.errorMassage ?? "Invalid OTP.");
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "An unexpected error occurred.");
      return false;
    }
  }

  Future<bool> resetPassword(String newPassword) async {
    if (state.email.isEmpty || state.otp.isEmpty || newPassword.isEmpty) {
      state = state.copyWith(error: "Fields cannot be empty");
      return false;
    }

    state = state.copyWith(isLoading: true, error: null, successMessage: null);
    try {
      final response = await _apiService.resetPassword(state.email, state.otp, newPassword);
      if (response.isSuccess) {
        state = state.copyWith(
            isLoading: false, 
            successMessage: response.responseData['message'] ?? "Password reset successful.");
        return true;
      } else {
        state = state.copyWith(
            isLoading: false, 
            error: response.errorMassage ?? "Failed to reset password.");
        return false;
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: "An unexpected error occurred.");
      return false;
    }
  }

  void clearState() {
    state = ForgotPasswordState();
  }
}
