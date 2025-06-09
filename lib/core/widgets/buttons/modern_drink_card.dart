import 'package:fantavacanze_official/core/constants/constants.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/premium_access_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';

/// Una card moderna e animata per selezionare opzioni di gioco.
class ModernDrinkCard extends StatelessWidget {
  /// Se la card è attualmente selezionata.
  final bool isSelected;

  /// Il testo principale da visualizzare sulla card.
  final String label;

  /// Il percorso dell'asset per l'icona SVG.
  final String svgIconPath;

  /// La funzione di callback chiamata al tocco.
  final VoidCallback onTap;

  /// Una descrizione opzionale da mostrare sotto l'etichetta.
  final String? description;

  /// Il gradiente da usare quando la card è selezionata.
  final Gradient? selectedGradient;

  /// Il colore di sfondo quando la card non è selezionata.
  final Color? unselectedColor;

  /// Indica se il gioco è premium (richiede accesso premium).
  final bool isPremium;

  /// Indica se una versione di prova è disponibile.
  final bool isTrialAvailable;

  /// Funzione chiamata quando l'utente richiede la prova gratuita.
  final VoidCallback? onTrialRequested;

  /// Funzione chiamata quando si richiede l'accesso premium.
  final VoidCallback? onPremiumRequested;

  /// Se mostrare un'icona informativa.
  final bool showInfoIcon;

  /// Callback per quando l'icona informativa viene premuta.
  final VoidCallback? onInfoIconTapped;

  const ModernDrinkCard({
    super.key,
    required this.isSelected,
    required this.label,
    required this.svgIconPath,
    required this.onTap,
    this.description,
    this.selectedGradient,
    this.unselectedColor,
    this.isPremium = false,
    this.isTrialAvailable = false,
    this.onTrialRequested,
    this.onPremiumRequested,
    this.showInfoIcon = false,
    this.onInfoIconTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Colori e stili di default
    const selectedGradient = LinearGradient(
      colors: [Color(0xFF69EACB), Color(0xFF8860D0)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // Gradient for regular unselected state
    final unselectedGradient = LinearGradient(
      colors: [
        Color(0xFF69EACB).withValues(alpha: 0.2),
        Color(0xFF8860D0).withValues(alpha: 0.2),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // Even darker gradient for premium-locked cards
    final premiumLockedGradient = LinearGradient(
      colors: [
        Color(0xFF69EACB).withValues(alpha: 0.15),
        Color(0xFF8860D0).withValues(alpha: 0.15),
      ],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // Premium ribbon gradient based on ColorPalette.premiumGradient
    final premiumRibbonGradient = LinearGradient(
      colors: ColorPalette.premiumGradient,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    // Handle tap with premium logic
    void handleTap() {
      if (isPremium && !isTrialAvailable) {
        // Show premium access dialog
        showDialog(
          context: context,
          builder: (ctx) => PremiumAccessDialog(
            premiumOnly: true,
            title: 'Accesso Premium Richiesto',
            description:
                'Sblocca "$label" e tutte le altre funzionalità premium!',
            onPremiumBtnTapped: onPremiumRequested,
          ),
        );
      } else {
        // Normal tap behavior
        onTap();
      }
    }

    return Stack(
      children: [
        // The card itself
        GestureDetector(
          onTap: handleTap,
          child: AnimatedContainer(
            width: isSelected
                ? Constants.getWidth(context) * 0.45
                : Constants.getWidth(context) * 0.4,
            height: isSelected ? 240 : 230,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18.0),
              gradient: isSelected
                  ? selectedGradient
                  : (isPremium ? premiumLockedGradient : unselectedGradient),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color:
                            selectedGradient.colors[0].withValues(alpha: 0.7),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      )
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      )
                    ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Contenitore per l'icona
                AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.white.withValues(alpha: 0.25)
                        : Colors.white.withValues(
                            alpha: 0.15,
                          ),
                    shape: BoxShape.circle,
                  ),
                  child: Opacity(
                    opacity: (isSelected) ? 1.0 : 0.7,
                    child: SvgPicture.asset(
                      svgIconPath,
                      width: 46,
                      height: 46,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                // Etichetta
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.passeroOne(
                    fontWeight: FontWeight.bold,
                    fontSize: 22,
                    color: isSelected
                        ? Colors.white
                        : Colors.white.withValues(
                            alpha: 0.7,
                          ),
                  ),
                ),
                // Descrizione opzionale
                if (description != null) ...[
                  const SizedBox(height: 6),
                  Expanded(
                    child: Text(
                      description!,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 3,
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: isSelected
                            ? Colors.white.withValues(alpha: 0.8)
                            : Colors.white.withValues(
                                alpha: 0.7,
                              ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Premium label overlay
        if (isPremium)
          Positioned(
            top: 10,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                gradient: premiumRibbonGradient,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  bottomLeft: Radius.circular(4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                "PREMIUM",
                style: GoogleFonts.montserrat(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),

        // Info Icon
        if (showInfoIcon)
          Positioned(
            top: 8,
            left: 8,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onInfoIconTapped,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white.withOpacity(0.8),
                    size: 20,
                  ),
                ),
              ),
            ),
          ),

        // Free trial button
        if (isPremium && isTrialAvailable)
          Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: GestureDetector(
              onTap: onTrialRequested,
              child: Opacity(
                opacity: isSelected ? 1.0 : 0.8,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade600, Colors.green.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    "Prova Gratis",
                    textAlign: TextAlign.center,
                    style: context.textTheme.labelMedium!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
