import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/auth_dialog_box.dart';
import 'package:fantavacanze_official/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/reset_password_page.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/cloudflare_turnstile_widget.dart';
import 'package:fantavacanze_official/initial_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_verification_code/flutter_verification_code.dart';

class OtpPage extends StatefulWidget {
  final String email;
  final bool isPasswordReset;

  const OtpPage({
    super.key,
    required this.email,
    this.isPasswordReset = false,
  });

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  bool _isResendAgain = false;
  bool isVerified = false;
  String _code = '';
  String _captchaToken = '';
  late Timer timer;
  int _start = 60;

  void resend() {
    if (_isResendAgain) return;

    // Invece di inviare direttamente l'evento, mostriamo il dialogo di conferma con captcha
    _showCaptchaConfirmationDialog();
  }

  // Nuovo metodo per mostrare il dialogo di conferma con captcha
  void _showCaptchaConfirmationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return ConfirmationDialog(
              title: 'Conferma di essere umano',
              message:
                  'Per ricevere un nuovo codice OTP, completa la verifica captcha qui sotto:',
              confirmText: 'Invia nuovo codice',
              cancelText: 'Annulla',
              icon: Icons.security,
              iconColor: ColorPalette.warning,
              isPrimaryAction: true,
              onConfirm: () {
                if (_captchaToken.isEmpty) {
                  showDialog(
                    context: context,
                    builder: (_) => AuthDialogBox(
                      title: "Verifica richiesta",
                      description: "Completa il captcha prima di continuare",
                      type: DialogType.error,
                      isMultiButton: false,
                    ),
                  );
                  return;
                }

                // Imposta il timer di cooldown
                setState(() {
                  _isResendAgain = true;
                  _start = 60;
                });

                // Invia l'evento con il token captcha
                context.read<AuthBloc>().add(
                      AuthSendOtpEmail(
                        email: widget.email,
                        hCaptcha: _captchaToken,
                      ),
                    );

                // Avvia il timer
                const oneSec = Duration(seconds: 1);
                timer = Timer.periodic(oneSec, (timer) {
                  setState(() {
                    if (_start == 0) {
                      _start = 60;
                      _isResendAgain = false;
                      timer.cancel();
                    } else {
                      _start--;
                    }
                  });
                });
              },
              additionalContent: Padding(
                padding: const EdgeInsets.symmetric(vertical: ThemeSizes.md),
                child: CloudflareTurnstileWidget(
                  onTokenReceived: (token) {
                    _captchaToken = token;
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(),
      backgroundColor: context.secondaryBgColor,
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
          height: Constants.getHeight(context),
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/otp-verification-icon.png",
                height: Constants.getHeight(context) * 0.3,
              ),
              const SizedBox(height: 30),
              Text(
                "Verifica",
                style: context.textTheme.headlineMedium,
              ),
              const SizedBox(height: 30),
              Column(
                children: [
                  Text(
                    "Inserisci il codice di verifica inviato a",
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyLarge!.copyWith(
                      color: ColorPalette.darkGrey.withValues(alpha: 0.8),
                    ),
                  ),
                  Text(
                    widget.email,
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyLarge!.copyWith(
                      color: ColorPalette.darkGrey.withValues(alpha: 0.9),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              VerificationCode(
                cursorColor: ColorPalette.lightGrey,
                length: 6,
                textStyle: context.textTheme.headlineSmall!,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                ),
                fullBorder: true,
                underlineWidth: 2.5,
                //when clicked
                underlineColor: context.primaryColor,
                //when unclicked
                underlineUnfocusedColor: ColorPalette.darkerGrey,
                onCompleted: (value) {
                  setState(() {
                    _code = value;
                  });
                  FocusScope.of(context).unfocus();
                },
                onEditing: (value) {},
              ),
              const SizedBox(height: 20),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Non hai ricevuto il codice?",
                    style: context.textTheme.bodyMedium!.copyWith(
                      color: ColorPalette.darkerGrey.withValues(alpha: 0.8),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_isResendAgain) return;
                      resend();
                    },
                    child: Text(
                      _isResendAgain
                          ? "Riprova tra ${_start.toString()}"
                          : "Invia di nuovo",
                    ),
                  )
                ],
              ),
              const SizedBox(height: 50),
              BlocConsumer<AuthBloc, AuthState>(
                listener: (context, state) {
                  if (state is AuthOtpVerified) {
                    if (widget.isPasswordReset) {
                      // Navigate to reset password page
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ResetPasswordPage(
                            email: widget.email,
                            token: _code,
                          ),
                        ),
                      );
                    } else {
                      // For other OTP verifications
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(builder: (_) => const InitialPage()),
                        (route) => false,
                      );
                    }
                  } else if (state is AuthFailure &&
                      state.operation == "verify_otp") {
                    showDialog(
                      context: context,
                      builder: (_) => AuthDialogBox(
                        title: "Errore di verifica",
                        description: state.message,
                        type: DialogType.error,
                        isMultiButton: false,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  final isLoading = state is AuthLoading;

                  return ElevatedButton(
                    onPressed: _code.length < 6 || isLoading
                        ? null
                        : () {
                            context.read<AuthBloc>().add(
                                  AuthVerifyOtp(
                                    email: widget.email,
                                    otp: _code,
                                    isPasswordReset: widget.isPasswordReset,
                                  ),
                                );
                          },
                    child: isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: Loader(color: ColorPalette.white),
                          )
                        : isVerified
                            ? const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 30,
                              )
                            : const Text(
                                "Verifica",
                                style: TextStyle(color: ColorPalette.white),
                              ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (_isResendAgain) {
      timer.cancel();
    }
    super.dispose();
  }
}
