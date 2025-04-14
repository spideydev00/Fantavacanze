import 'package:flutter/material.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule.dart';

class RuleDialog extends StatefulWidget {
  final String title;
  final String buttonText;
  final Map<String, dynamic>? initialRule;
  final Function(String, RuleType, int) onSave;

  const RuleDialog({
    super.key,
    required this.title,
    required this.buttonText,
    this.initialRule,
    required this.onSave,
  });

  @override
  State<RuleDialog> createState() => _RuleDialogState();
}

class _RuleDialogState extends State<RuleDialog> {
  late TextEditingController nameController;
  late TextEditingController pointsController;
  late RuleType selectedType;

  @override
  void initState() {
    super.initState();
    final rule = widget.initialRule;
    nameController = TextEditingController(text: rule?['name'] ?? '');
    pointsController =
        TextEditingController(text: rule?['points']?.toString() ?? '');
    selectedType = rule?['type'] == 'bonus' ? RuleType.bonus : RuleType.malus;
  }

  @override
  void dispose() {
    nameController.dispose();
    pointsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bonusColor = Colors.green.withValues(alpha: 0.8);
    final malusColor = Colors.red.withValues(alpha: 0.8);

    // Get available screen height minus keyboard height
    final viewInsets = MediaQuery.of(context).viewInsets;
    final screenHeight = MediaQuery.of(context).size.height;
    final availableHeight = screenHeight - viewInsets.bottom - 80;

    return Stack(
      children: [
        // Full screen blocking barrier to prevent content from showing through
        Positioned.fill(
          child: Container(color: Colors.black.withValues(alpha: 0.5)),
        ),
        Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
          ),
          elevation: 5,
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.only(
            left: ThemeSizes.md,
            right: ThemeSizes.md,
            // Adjust top inset when keyboard is visible
            top: viewInsets.bottom > 0 ? ThemeSizes.md : ThemeSizes.lg,
            bottom: ThemeSizes.lg,
          ),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: double.infinity,
            // Constrain height to available space when keyboard is visible
            constraints: BoxConstraints(
              maxHeight: availableHeight,
            ),
            decoration: BoxDecoration(
              color: context.bgColor,
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusLg),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  spreadRadius: 1,
                  blurRadius: 10,
                )
              ],
            ),
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(ThemeSizes.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.only(
                        top: ThemeSizes.sm,
                        bottom: ThemeSizes.md,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.title,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => Navigator.pop(context),
                            padding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        ],
                      ),
                    ),

                    // Rule Type Selector
                    Text(
                      'Tipo di Regola',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: ThemeSizes.sm),
                    Row(
                      children: [
                        // Bonus option
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedType = RuleType.bonus;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: ThemeSizes.md,
                                horizontal: ThemeSizes.sm,
                              ),
                              decoration: BoxDecoration(
                                color: selectedType == RuleType.bonus
                                    ? bonusColor.withValues(alpha: 0.1)
                                    : context.secondaryBgColor
                                        .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(
                                    ThemeSizes.borderRadiusLg),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.add_circle,
                                    color: bonusColor,
                                    size: 32,
                                  ),
                                  const SizedBox(height: ThemeSizes.xs),
                                  Text(
                                    'Bonus',
                                    style: TextStyle(
                                      color: selectedType == RuleType.bonus
                                          ? bonusColor
                                          : context.textSecondaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: ThemeSizes.sm),
                        // Malus option
                        Expanded(
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedType = RuleType.malus;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: ThemeSizes.md,
                                horizontal: ThemeSizes.sm,
                              ),
                              decoration: BoxDecoration(
                                color: selectedType == RuleType.malus
                                    ? malusColor.withValues(alpha: 0.1)
                                    : context.secondaryBgColor
                                        .withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(
                                  ThemeSizes.borderRadiusLg,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    Icons.remove_circle,
                                    color: malusColor,
                                    size: 32,
                                  ),
                                  const SizedBox(height: ThemeSizes.xs),
                                  Text(
                                    'Malus',
                                    style: TextStyle(
                                      color: selectedType == RuleType.malus
                                          ? malusColor
                                          : context.textSecondaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Rule Name
                    const SizedBox(height: ThemeSizes.lg),
                    Text(
                      'Nome Regola',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: ThemeSizes.sm),
                    Container(
                      decoration: BoxDecoration(
                        color: context.secondaryBgColor,
                        borderRadius: BorderRadius.circular(
                          ThemeSizes.borderRadiusLg,
                        ),
                      ),
                      child: TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          hintText: 'es. Goal Segnato',
                          prefixIcon: Icon(
                            Icons.text_fields,
                            color: selectedType == RuleType.bonus
                                ? bonusColor
                                : malusColor,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              ThemeSizes.borderRadiusLg,
                            ),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: context.secondaryBgColor,
                        ),
                      ),
                    ),

                    // Points
                    const SizedBox(height: ThemeSizes.lg),
                    Text(
                      'Punti',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                    const SizedBox(height: ThemeSizes.sm),
                    Container(
                      decoration: BoxDecoration(
                        color: context.secondaryBgColor,
                        borderRadius: BorderRadius.circular(
                          ThemeSizes.borderRadiusLg,
                        ),
                      ),
                      child: TextField(
                        controller: pointsController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'es. 10',
                          prefixIcon: Icon(
                            Icons.star,
                            color: selectedType == RuleType.bonus
                                ? bonusColor
                                : malusColor,
                          ),
                          suffixText: 'pt',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                              ThemeSizes.borderRadiusLg,
                            ),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: context.secondaryBgColor,
                        ),
                      ),
                    ),

                    // Actions
                    const SizedBox(height: ThemeSizes.xl),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(
                            'Annulla',
                            style: TextStyle(
                              color: context.textSecondaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: ThemeSizes.md),
                        // Custom ElevatedButton to avoid theme constraints
                        Material(
                          color: selectedType == RuleType.bonus
                              ? bonusColor
                              : malusColor,
                          borderRadius:
                              BorderRadius.circular(ThemeSizes.borderRadiusLg),
                          elevation: 2,
                          child: InkWell(
                            onTap: () {
                              final name = nameController.text.trim();
                              final pointsText = pointsController.text.trim();

                              if (name.isNotEmpty && pointsText.isNotEmpty) {
                                final points = int.tryParse(pointsText) ?? 0;
                                widget.onSave(name, selectedType, points);
                                Navigator.pop(context);
                              }
                            },
                            borderRadius: BorderRadius.circular(
                                ThemeSizes.borderRadiusLg),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: ThemeSizes.lg,
                                vertical: ThemeSizes.md,
                              ),
                              child: Text(
                                widget.buttonText,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
