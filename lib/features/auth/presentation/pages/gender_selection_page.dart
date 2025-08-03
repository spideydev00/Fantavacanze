import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/auth_dialog_box.dart';
import 'package:fantavacanze_official/core/widgets/info_container.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/dashboard/sections/dashboard.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class GenderSelectionPage extends StatefulWidget {
  static const String routeName = '/gender_selection';

  static get route => MaterialPageRoute(
        builder: (context) => const GenderSelectionPage(),
        settings: const RouteSettings(name: routeName),
      );

  const GenderSelectionPage({super.key});

  @override
  State<GenderSelectionPage> createState() => _GenderSelectionPageState();
}

class _GenderSelectionPageState extends State<GenderSelectionPage> {
  String? _selectedGender;
  bool _isLoading = false;

  // Opzioni per il genere
  final Map<String?, String> _genderOptions = {
    'male': 'Uomo',
    'female': 'Donna',
    'undefined': 'Preferisco non dirlo',
  };

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  void _confirmGenderSelection() async {
    if (_selectedGender == null) {
      // Mostra dialog di errore se non è stato selezionato alcun genere
      showDialog(
        context: context,
        builder: (_) => const AuthDialogBox(
          title: "Attenzione!",
          description: "Per favore seleziona il tuo genere per continuare",
          type: DialogType.error,
          isMultiButton: false,
        ),
      );
      return;
    }

    // Mostra loader per 1 secondo fisso
    setState(() {
      _isLoading = true;
    });

    // Attendi 1 secondo
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      // Invia l'evento per aggiornare il genere dell'utente
      context.read<AuthBloc>().add(
            AuthUpdateGender(gender: _selectedGender!),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      // Impedisce la navigazione indietro
      canPop: false,
      child: Scaffold(
        // No appBar per impedire la navigazione indietro
        body: SafeArea(
          child: BlocConsumer<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthFailure) {
                setState(() => _isLoading = false);
                // Mostra snackbar in caso di errore
                showSnackBar(state.message, color: ColorPalette.error);
              } else if (state is AuthSuccess) {
                // Naviga alla dashboard in caso di successo
                Navigator.of(context).pushAndRemoveUntil(
                  DashboardScreen.route,
                  (_) => false,
                );
              }
            },
            builder: (context, state) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom,
                  ),
                  child: IntrinsicHeight(
                    child: Padding(
                      padding: const EdgeInsets.all(ThemeSizes.lg),
                      child: Column(
                        children: [
                          // Titolo
                          Text(
                            'Seleziona il tuo genere',
                            style: context.textTheme.headlineSmall!.copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.textPrimaryColor,
                            ),
                            textAlign: TextAlign.center,
                          ),

                          const SizedBox(height: ThemeSizes.lg),

                          // Info container che spiega perché la selezione è necessaria
                          InfoContainer(
                            title: 'Informazione Importante',
                            message:
                                'Le funzionalità sono influenzate dal genere dell\'utente.',
                            icon: Icons.info_outline,
                            color: ColorPalette.info,
                          ),

                          const SizedBox(height: ThemeSizes.xxl),

                          // Opzioni di genere (maschile e femminile)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              // Opzione Uomo
                              _buildGenderOption(
                                  'male', Icons.male, ColorPalette.info),

                              // Opzione Donna
                              _buildGenderOption('female', Icons.female,
                                  context.secondaryColor),
                            ],
                          ),

                          const SizedBox(height: ThemeSizes.lg),

                          // Opzione "Preferisco non dirlo"
                          _buildGenderOption(
                            'undefined',
                            Icons.do_not_disturb_rounded,
                            ColorPalette.darkGrey,
                          ),

                          SizedBox(height: ThemeSizes.xxl),

                          // Pulsante continua
                          ElevatedButton(
                            onPressed: _isLoading || _selectedGender == null
                                ? null
                                : _confirmGenderSelection,
                            style:
                                context.elevatedButtonThemeData.style!.copyWith(
                              backgroundColor: WidgetStatePropertyAll(
                                _selectedGender == null
                                    ? ColorPalette.buttonDisabled
                                    : context.primaryColor,
                              ),
                            ),
                            child: _isLoading
                                ? Loader(color: context.textPrimaryColor)
                                : const Text('Continua'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildGenderOption(String gender, IconData icon, Color color) {
    final isSelected = _selectedGender == gender;

    return GestureDetector(
      onTap: () => _selectGender(gender),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: Constants.getWidth(context) * 0.4,
        height: Constants.getWidth(context) * 0.4,
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: 0.2)
              : context.secondaryBgColor,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 60,
              color: isSelected ? color : context.textSecondaryColor,
            ),
            const SizedBox(height: ThemeSizes.md),
            Text(
              _genderOptions[gender]!,
              textAlign: TextAlign.center,
              style: context.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: isSelected ? color : context.textPrimaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
