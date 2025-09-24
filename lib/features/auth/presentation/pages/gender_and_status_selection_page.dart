import 'package:fantavacanze_official/core/cubits/app_user/app_user_cubit.dart';
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
import 'package:dropdown_button2/dropdown_button2.dart';

class GenderAndStatusSelectionPage extends StatefulWidget {
  static const String routeName = '/gender_selection';

  static get route => MaterialPageRoute(
        builder: (context) => const GenderAndStatusSelectionPage(),
        settings: const RouteSettings(name: routeName),
      );

  const GenderAndStatusSelectionPage({super.key});

  @override
  State<GenderAndStatusSelectionPage> createState() =>
      _GenderAndStatusSelectionPageState();
}

class _GenderAndStatusSelectionPageState
    extends State<GenderAndStatusSelectionPage> {
  String? _selectedGender;
  String? _selectedSentimentalStatus;
  bool _isLoading = false;

  // Opzioni per il genere
  final Map<String, String> _genderOptions = {
    'male': 'Uomo',
    'female': 'Donna',
    'undefined': 'Preferisco non dirlo',
  };

  // Opzioni per lo stato sentimentale
  final Map<String, String> _sentimentalStatusOptions = {
    'single': 'Single',
    'engaged': 'Fidanzato/a',
    'undefined': 'Preferisco non dirlo',
  };

  @override
  void initState() {
    super.initState();
    // Get current user data to pre-populate dropdowns
    final userState = context.read<AppUserCubit>().state;

    if (userState is AppUserNeedsGenderOrStatus) {
      _selectedGender = userState.user.gender;
      _selectedSentimentalStatus = userState.user.sentimentalStatus;
    }
  }

  void _confirmSelection() async {
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

    if (_selectedSentimentalStatus == null) {
      // Mostra dialog di errore se non è stato selezionato lo stato sentimentale
      showDialog(
        context: context,
        builder: (_) => const AuthDialogBox(
          title: "Attenzione!",
          description:
              "Per favore seleziona il tuo stato sentimentale per continuare",
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

      // Invia l'evento per aggiornare lo stato sentimentale
      context.read<AuthBloc>().add(
            AuthUpdateIsSingleStatus(status: _selectedSentimentalStatus!),
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
                            'Completa il tuo profilo',
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
                                'Le funzionalità sono influenzate dal genere e dallo stato sentimentale dell\'utente.',
                            icon: Icons.info_outline,
                            color: ColorPalette.info,
                          ),

                          const SizedBox(height: ThemeSizes.xxl),

                          // Gender Selection Dropdown
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Seleziona il genere:',
                                style: context.textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: ThemeSizes.sm),
                              _buildGenderDropdown(),
                            ],
                          ),

                          const SizedBox(height: ThemeSizes.xl),

                          // Sentimental Status Selection Dropdown
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Seleziona stato sentimentale:',
                                style: context.textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: context.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: ThemeSizes.sm),
                              _buildSentimentalStatusDropdown(),
                            ],
                          ),

                          const SizedBox(height: ThemeSizes.xxl),

                          // Pulsante continua
                          ElevatedButton(
                            onPressed: _isLoading ||
                                    _selectedGender == null ||
                                    _selectedSentimentalStatus == null
                                ? null
                                : _confirmSelection,
                            style:
                                context.elevatedButtonThemeData.style!.copyWith(
                              backgroundColor: WidgetStatePropertyAll(
                                _selectedGender == null ||
                                        _selectedSentimentalStatus == null
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

  Widget _buildGenderDropdown() {
    return DropdownButton2<String>(
      value: _selectedGender,
      onChanged: (String? newValue) {
        setState(() {
          _selectedGender = newValue;
        });
      },
      items: _genderOptions.entries.map<DropdownMenuItem<String>>((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Row(
            children: [
              Icon(
                entry.key == 'male'
                    ? Icons.male
                    : entry.key == 'female'
                        ? Icons.female
                        : Icons.do_not_disturb_rounded,
                size: 22,
                color: context.textTheme.bodyMedium?.color,
              ),
              const SizedBox(width: ThemeSizes.sm),
              Text(
                entry.value,
                style: context.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      selectedItemBuilder: (context) {
        return _genderOptions.entries.map<Widget>((entry) {
          return Row(
            children: [
              Icon(
                entry.key == 'male'
                    ? Icons.male
                    : entry.key == 'female'
                        ? Icons.female
                        : Icons.do_not_disturb_rounded,
                size: 22,
                color: context.textTheme.bodyMedium?.color,
              ),
              const SizedBox(width: ThemeSizes.sm),
              Expanded(
                child: Text(
                  entry.value,
                  style: context.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }).toList();
      },
      isExpanded: true,
      underline: const SizedBox(),
      hint: Text(
        'Seleziona il tuo genere',
        style: context.textTheme.bodyMedium!.copyWith(
          color: ColorPalette.darkerGrey,
        ),
      ),
      buttonStyleData: ButtonStyleData(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeSizes.md,
          vertical: ThemeSizes.xs,
        ),
        decoration: BoxDecoration(
          color: context.secondaryBgColor,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
          border: Border.all(
            color: ColorPalette.darkGrey,
            width: 0.2,
          ),
        ),
      ),
      iconStyleData: IconStyleData(
        icon: const Icon(Icons.arrow_drop_down),
        iconEnabledColor: context.textTheme.bodyMedium?.color,
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
          color: context.secondaryBgColor,
        ),
        offset: const Offset(0, -5),
      ),
      menuItemStyleData: const MenuItemStyleData(
        height: 40,
        padding: EdgeInsets.only(left: 14, right: 14),
      ),
    );
  }

  Widget _buildSentimentalStatusDropdown() {
    return DropdownButton2<String>(
      value: _selectedSentimentalStatus,
      onChanged: (String? newValue) {
        setState(() {
          _selectedSentimentalStatus = newValue;
        });
      },
      items: _sentimentalStatusOptions.entries
          .map<DropdownMenuItem<String>>((entry) {
        return DropdownMenuItem<String>(
          value: entry.key,
          child: Row(
            children: [
              Icon(
                entry.key == 'single'
                    ? Icons.person
                    : entry.key == 'engaged'
                        ? Icons.favorite
                        : Icons.do_not_disturb_rounded,
                size: 22,
                color: context.textTheme.bodyMedium?.color,
              ),
              const SizedBox(width: ThemeSizes.sm),
              Text(
                entry.value,
                style: context.textTheme.bodyMedium!.copyWith(
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      selectedItemBuilder: (context) {
        return _sentimentalStatusOptions.entries.map<Widget>((entry) {
          return Row(
            children: [
              Icon(
                entry.key == 'single'
                    ? Icons.person
                    : entry.key == 'engaged'
                        ? Icons.favorite
                        : Icons.do_not_disturb_rounded,
                size: 22,
                color: context.textTheme.bodyMedium?.color,
              ),
              const SizedBox(width: ThemeSizes.sm),
              Expanded(
                child: Text(
                  entry.value,
                  style: context.textTheme.bodyMedium!.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );
        }).toList();
      },
      isExpanded: true,
      underline: const SizedBox(),
      hint: Text(
        'Seleziona il tuo stato sentimentale',
        style: context.textTheme.bodyMedium!.copyWith(
          color: ColorPalette.darkerGrey,
        ),
      ),
      buttonStyleData: ButtonStyleData(
        padding: const EdgeInsets.symmetric(
          horizontal: ThemeSizes.md,
          vertical: ThemeSizes.xs,
        ),
        decoration: BoxDecoration(
          color: context.secondaryBgColor,
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
          border: Border.all(
            color: ColorPalette.darkGrey,
            width: 0.2,
          ),
        ),
      ),
      iconStyleData: IconStyleData(
        icon: const Icon(Icons.arrow_drop_down),
        iconEnabledColor: context.textTheme.bodyMedium?.color,
      ),
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
          color: context.secondaryBgColor,
        ),
        offset: const Offset(0, -5),
      ),
      menuItemStyleData: const MenuItemStyleData(
        height: 40,
        padding: EdgeInsets.only(left: 14, right: 14),
      ),
    );
  }
}
