import 'package:fantavacanze_official/core/common/widgets/loader.dart';
import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/post_otp_verification.dart';
import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter_verification_code/flutter_verification_code.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  bool _isResendAgain = false;
  bool _isVerified = false;
  bool _isLoading = false;

  String _code = '';

  late Timer timer;
  int _start = 60;

  void resend() {
    setState(() {
      _isResendAgain = true;
    });

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
  }

  //could be replaced with bloc later
  void verify() {
    setState(() {
      _isLoading = true;
    });

    const oneSec = Duration(seconds: 1);
    timer = Timer.periodic(
      oneSec,
      (timer) {
        setState(() {
          _isLoading = false;
          _isVerified = true;
        });
        Future.delayed(const Duration(milliseconds: 1000), () {
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
                PostOtpVerification.route, (route) => false);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(),
      backgroundColor: Colors.white,
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
                "images/otp-verification-icon.png",
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
                      color: ColorPalette.darkGrey,
                    ),
                  ),
                  Text(
                    "+39 349 233 5705",
                    textAlign: TextAlign.center,
                    style: context.textTheme.bodyLarge!.copyWith(
                      color: ColorPalette.darkGrey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              VerificationCode(
                cursorColor: ColorPalette.black,
                length: 6,
                textStyle: context.textTheme.headlineSmall!,
                keyboardType: const TextInputType.numberWithOptions(
                  signed: true,
                ),
                fullBorder: true,
                underlineWidth: 2.5,
                //when clicked
                underlineColor: ColorPalette.primary,
                //when unclicked
                underlineUnfocusedColor: ColorPalette.grey,
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
                      color: ColorPalette.darkGrey,
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
              ElevatedButton(
                onPressed: _code.length < 4
                    ? () => {}
                    : () {
                        verify();
                      },
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: Loader(color: ColorPalette.white),
                      )
                    : _isVerified
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 30,
                          )
                        : const Text(
                            "Verifica",
                            style: TextStyle(color: ColorPalette.white),
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
