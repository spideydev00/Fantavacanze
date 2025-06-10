import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/age_verification_form.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/core/pages/empty_branded_page.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/auth_dialog_box.dart';
import 'package:fantavacanze_official/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fantavacanze_official/features/auth/presentation/pages/standard_login.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/auth_field.dart';
import 'package:fantavacanze_official/features/auth/presentation/widgets/cloudflare_turnstile_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';

class SignUpPage extends StatefulWidget {
  static const String routeName = '/signup';

  static get route => MaterialPageRoute(
        builder: (context) => const SignUpPage(),
        settings: const RouteSettings(name: routeName),
      );
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  String _turnstile = "";
  bool _isAdult = false;
  bool _isTermsAccepted = false;
  String? _selectedGender;

  bool get _nameValid => _nameCtrl.text.trim().isNotEmpty;
  bool get _emailValid {
    final e = _emailCtrl.text.trim();
    return e.isNotEmpty && RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(e);
  }

  bool get _passValid => _passCtrl.text.length >= 6;
  bool get _genderValid => _selectedGender != null;

  bool get _formReady =>
      _nameValid &&
      _emailValid &&
      _passValid &&
      _turnstile.isNotEmpty &&
      _isAdult &&
      _isTermsAccepted &&
      _genderValid;

  final List<String> genders = ["Uomo", "Donna"];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  void _rebuild() => setState(() {});

  /// Traduce il valore del dropdown nel formato richiesto dal backend.
  String _getGenderText(String gender) {
    if (gender == "Uomo") {
      return 'male';
    } else if (gender == "Donna") {
      return 'female';
    }
    // Fallback di sicurezza, anche se non dovrebbe mai accadere
    // con la logica attuale del dropdown.
    return 'male';
  }

  IconData _getGenderIcon(String gender) {
    switch (gender) {
      case "Uomo":
        return Icons.male;
      case "Donna":
        return Icons.female;
      default:
        return Icons.person;
    }
  }

  /// Metodo helper per costruire la UI per un elemento del dropdown
  Widget _buildGenderItem(String gender) {
    final Color iconColor;
    final IconData icon = _getGenderIcon(gender);

    if (gender == "Uomo") {
      iconColor = Colors.blue.shade400;
    } else if (gender == "Donna") {
      iconColor = Colors.pink.shade300;
    } else {
      iconColor = ColorPalette.darkGrey;
    }

    return Row(
      children: [
        Icon(
          icon,
          size: 22,
          color: iconColor,
        ),
        const SizedBox(width: ThemeSizes.sm),
        Flexible(
          child: Text(
            gender,
            style: TextStyle(
              color: ColorPalette.darkerGrey,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return EmptyBrandedPage(
      logoImagePath: "assets/images/logo.png",
      bgImagePath: "assets/images/bg.png",
      isBackNavigationActive: true,
      mainColumnAlignment: MainAxisAlignment.start,
      widgets: [
        Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.disabled,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: ThemeSizes.lg),
            child: Column(
              children: [
                // Nome e Genere
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nome field
                    Expanded(
                      flex: 7,
                      child: AuthField(
                        controller: _nameCtrl,
                        hintText: "Nome",
                        icon: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: ThemeSizes.sm,
                            horizontal: ThemeSizes.md,
                          ),
                          child: SvgPicture.asset(
                            "assets/images/icons/auth_field_icons/user-icon.svg",
                            width: 35,
                          ),
                        ),
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        onChanged: (_) => _rebuild(),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return "Inserisci il tuo nome";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Gender selector
                    Expanded(
                      flex: 6,
                      child: DropdownButton2<String>(
                        isExpanded: true,
                        value: _selectedGender,
                        hint: Text(
                          "Sesso",
                          style: TextStyle(
                            color: ColorPalette.darkerGrey,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        selectedItemBuilder: (context) {
                          return genders.map((gender) {
                            return _buildGenderItem(gender);
                          }).toList();
                        },
                        items: genders.map((String gender) {
                          return DropdownMenuItem<String>(
                            value: gender,
                            child: _buildGenderItem(gender),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedGender = newValue;
                          });
                        },
                        underline: const SizedBox(),
                        buttonStyleData: ButtonStyleData(
                          height: 64,
                          padding: const EdgeInsets.symmetric(horizontal: 12.0),
                          decoration: BoxDecoration(
                            color: ColorPalette.white,
                            borderRadius: BorderRadius.circular(
                                ThemeSizes.borderRadiusMd),
                            border: Border.all(
                              color: context.borderColor.withValues(alpha: 0.3),
                              width: 1,
                            ),
                          ),
                        ),
                        iconStyleData: const IconStyleData(
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: ColorPalette.darkGrey,
                          ),
                          iconSize: 24,
                        ),
                        dropdownStyleData: DropdownStyleData(
                          decoration: BoxDecoration(
                            color: ColorPalette.white,
                            borderRadius: BorderRadius.circular(
                                ThemeSizes.borderRadiusMd),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Email
                AuthField(
                  controller: _emailCtrl,
                  hintText: "E-mail",
                  keyboardType: TextInputType.emailAddress,
                  icon: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: ThemeSizes.sm,
                      horizontal: ThemeSizes.md,
                    ),
                    child: SvgPicture.asset(
                      "assets/images/icons/auth_field_icons/add-email-icon.svg",
                      width: 35,
                    ),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (_) => _rebuild(),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return "Inserisci l'email";
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v.trim())) {
                      return "Email non valida";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),

                // Password
                AuthField(
                  controller: _passCtrl,
                  hintText: "Password",
                  isPassword: true,
                  icon: Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: ThemeSizes.sm,
                      horizontal: ThemeSizes.md,
                    ),
                    child: SvgPicture.asset(
                      "assets/images/icons/auth_field_icons/lock-icon.svg",
                      width: 35,
                    ),
                  ),
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  onChanged: (_) => _rebuild(),
                  validator: (v) {
                    if (v == null || v.isEmpty) {
                      return "Inserisci la password";
                    }
                    if (v.length < 6) {
                      return "Almeno 6 caratteri";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: ThemeSizes.lg),

                // Turnstile
                CloudflareTurnstileWidget(
                  onTokenReceived: (token) {
                    setState(() => _turnstile = token);
                  },
                ),
                const SizedBox(height: 15),

                // Age & Terms
                AgeVerificationForm(
                  initialIsAdult: _isAdult,
                  initialIsTermsAccepted: _isTermsAccepted,
                  onValueChanged: (adult, terms) {
                    setState(() {
                      _isAdult = adult;
                      _isTermsAccepted = terms;
                    });
                  },
                ),
                const SizedBox(height: 15),

                // Submit button
                BlocConsumer<AuthBloc, AuthState>(
                  listener: (context, state) {
                    if (state is AuthFailure) {
                      showDialog(
                        context: context,
                        builder: (_) => AuthDialogBox(
                          title: "Errore!",
                          description: state.message,
                          type: DialogType.error,
                          isMultiButton: false,
                        ),
                      );
                    }
                    if (state is AuthSignUpSuccess) {
                      Navigator.of(context).pushAndRemoveUntil(
                        StandardLoginPage.route,
                        (_) => false,
                      );
                      showDialog(
                        context: context,
                        builder: (_) => AuthDialogBox(
                          title: "Ottimo!",
                          description:
                              "Attiva l'account cliccando sul link inviato per e-mail",
                          buttonText: "Ok",
                          type: DialogType.success,
                          isMultiButton: false,
                        ),
                      );
                    }
                  },
                  builder: (context, state) {
                    if (state is AuthLoading) {
                      return Center(
                        child: Loader(
                          color: ColorPalette.primary(ThemeMode.dark),
                        ),
                      );
                    }

                    final buttonColor = _formReady
                        ? ColorPalette.primary(ThemeMode.dark)
                        : Color.lerp(
                            ColorPalette.primary(ThemeMode.dark),
                            Colors.black,
                            0.3,
                          )!;

                    return ElevatedButton.icon(
                      onPressed: () {
                        if (!_genderValid) {
                          showDialog(
                            context: context,
                            builder: (_) => AuthDialogBox(
                              title: "Attenzione!",
                              description: "Per favore seleziona il tuo genere",
                              type: DialogType.error,
                              isMultiButton: false,
                            ),
                          );
                          return;
                        }

                        if (_formReady) {
                          if (_formKey.currentState!.validate()) {
                            context.read<AuthBloc>().add(
                                  AuthEmailSignUp(
                                    name: _nameCtrl.text.trim(),
                                    email: _emailCtrl.text.trim(),
                                    password: _passCtrl.text,
                                    hCaptcha: _turnstile,
                                    isAdult: _isAdult,
                                    isTermsAccepted: _isTermsAccepted,
                                    gender: _getGenderText(_selectedGender!),
                                  ),
                                );
                          }
                        }
                      },
                      style: context.elevatedButtonThemeData.style!.copyWith(
                        backgroundColor: WidgetStatePropertyAll(buttonColor),
                        foregroundColor: WidgetStatePropertyAll(_formReady
                            ? ColorPalette.textPrimary(ThemeMode.dark)
                            : ColorPalette.textPrimary(ThemeMode.dark)
                                .withValues(alpha: 0.7)),
                      ),
                      icon: SvgPicture.asset(
                        "assets/images/icons/auth_icons/sign-up-icon.svg",
                        width: 25,
                        colorFilter: _formReady
                            ? null
                            : ColorFilter.mode(
                                ColorPalette.textPrimary(ThemeMode.dark)
                                    .withValues(alpha: 0.7),
                                BlendMode.srcIn,
                              ),
                      ),
                      label: const Text("Registrati Ora!"),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
