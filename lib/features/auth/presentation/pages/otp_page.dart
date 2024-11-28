import 'dart:async';

import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/format_duration.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/otp_field.dart';
import 'package:flutter/material.dart';

class OtpPage extends StatefulWidget {
  const OtpPage({super.key});

  @override
  State<OtpPage> createState() => _OtpPageState();
}

class _OtpPageState extends State<OtpPage> {
  Timer? resendCodeTimer;
  Duration duration = const Duration(seconds: 90);
  bool isTimerRunning = false;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  //Variabile che salva il codice OTP
  String otpCode = '';

  @override
  initState() {
    super.initState();
    startTimer();
  }

  @override
  void dispose() {
    resendCodeTimer?.cancel();
    super.dispose();
  }

  void startTimer() {
    setState(
      () {
        isTimerRunning = true;
        duration = const Duration(
            seconds: 90); // Resetta la durata ogni volta che il timer inizia
      },
    );

    resendCodeTimer?.cancel(); // Cancella l'eventuale timer precedente

    resendCodeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (duration.inSeconds > 0) {
        setState(() {
          duration -= const Duration(seconds: 1); // Decrementa il tempo
        });
      } else {
        timer.cancel();
        setState(() {
          isTimerRunning = false; // Ferma il timer
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorPalette.ternary,
      appBar: AppBar(
        toolbarHeight: 100,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeSizes.lg,
          vertical: ThemeSizes.md,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Codice di verifica",
              style: context.textTheme.headlineMedium,
            ),
            const SizedBox(height: 10),
            Text(
              "Abbiamo inviato un codice di verifica a",
              style: context.textTheme.bodyMedium!.copyWith(
                color: ColorPalette.darkerGrey,
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _formKey,
              child: getOtpFieldsRow(otpCode),
            ),
            const SizedBox(height: 30),
            Center(
              child: isTimerRunning
                  ? RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Richiedi nuovo codice tra  ",
                            style: context.textTheme.bodyMedium,
                          ),
                          TextSpan(
                            text: formatDuration(
                                duration), // Mostra il tempo formattato
                            style: context.textTheme.bodyMedium!.copyWith(
                              color: ColorPalette.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        ],
                      ),
                    )
                  : Column(
                      children: [
                        Text(
                          "Puoi ora richiedere un nuovo codice.",
                          style: context.textTheme.bodySmall!.copyWith(
                            color: ColorPalette.darkerGrey,
                          ),
                        ),
                        TextButton(
                            onPressed: () {
                              // Resetta il timer e avvialo nuovamente
                              startTimer();
                              otpCode = '';
                              _formKey.currentState?.reset();

                              //Invia nuovo codice da Supabase
                            },
                            child: const Text("Invia di nuovo")),
                      ],
                    ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.all(38.0),
              child: Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    //authentication

                    //go to onboarding page
                  },
                  label: const Text("Conferma"),
                  icon: const Icon(Icons.check_rounded),
                  style: context.elevatedButtonThemeData.style!.copyWith(
                    fixedSize: WidgetStatePropertyAll(
                      Size.fromWidth(Constants.getWidth(context) * 0.5),
                    ),
                    textStyle: WidgetStatePropertyAll(
                      context.textTheme.bodyLarge,
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

// FUNZIONE HELPER PER MAGGIORE LEGGIBILITA'
Widget getOtpFieldsRow(String otpCode) {
  int i;
  const int length = 6;

  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      for (i = 0; i < length; i++)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5.0),
            child: OtpField(
              //Qui salviamo sequenzialmente i numeri del codice OTP
              onSaved: (newValue) => {otpCode += newValue!},
            ),
          ),
        ),
    ],
  );
}
