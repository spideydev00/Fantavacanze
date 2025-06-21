import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/extensions/context_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/date_formatter.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_bloc.dart';
import 'package:fantavacanze_official/features/league/presentation/bloc/league_bloc/league_event.dart';
import 'package:fantavacanze_official/features/league/presentation/pages/navigation/admin/widgets/admin_section_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LeagueInfoSection extends StatefulWidget {
  final League league;

  const LeagueInfoSection({super.key, required this.league});

  @override
  State<LeagueInfoSection> createState() => _LeagueInfoSectionState();
}

class _LeagueInfoSectionState extends State<LeagueInfoSection> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isEditingName = false;
  bool _isEditingDescription = false;
  bool _inviteCodeCopied = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.league.name;
    _descriptionController.text = widget.league.description ?? '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AdminSectionCard(
      title: 'Informazioni Lega',
      icon: Icons.info_outline,
      child: _buildInfoDisplay(),
    );
  }

  Widget _buildInfoDisplay() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(ThemeSizes.md),
          child: Text(
            'Informazioni di base sulla tua lega. Puoi modificare nome e descrizione cliccando sui rispettivi campi.',
            style: context.textTheme.bodyMedium!.copyWith(
              color: context.textSecondaryColor.withValues(alpha: 0.8),
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.all(ThemeSizes.md),
          decoration: BoxDecoration(
            color: context.bgColor,
            borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.02),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildNameItem(),
              Divider(
                  color: context.borderColor.withValues(alpha: 0.1), height: 1),
              _buildDescriptionItem(),
              Divider(
                  color: context.borderColor.withValues(alpha: 0.1), height: 1),
              _buildInfoItem(
                icon: widget.league.isTeamBased ? Icons.groups : Icons.person,
                title: 'Tipo',
                value: widget.league.isTeamBased ? 'A squadre' : 'Individuale',
              ),
              Divider(
                  color: context.borderColor.withValues(alpha: 0.1), height: 1),
              _buildInfoItem(
                icon: Icons.key,
                title: 'Codice invito',
                value: widget.league.inviteCode,
                onCopyPressed: () => _copyToClipboard(widget.league.inviteCode),
                isCopied: _inviteCodeCopied,
              ),
              Divider(
                  color: context.borderColor.withValues(alpha: 0.1), height: 1),
              _buildInfoItem(
                icon: Icons.calendar_today,
                title: 'Data creazione',
                value:
                    DateFormatter.formatRelativeTime(widget.league.createdAt),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNameItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeSizes.md,
        vertical: ThemeSizes.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.primaryColor.withValues(alpha: 0.7),
                  context.primaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
            ),
            child: const Icon(
              Icons.title,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: ThemeSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nome',
                  style: context.textTheme.labelMedium!.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                if (_isEditingName)
                  Column(
                    children: [
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                ThemeSizes.borderRadiusMd),
                          ),
                        ),
                        style: context.textTheme.bodyLarge!.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                        autofocus: true,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: Icon(
                              Icons.check,
                              color: ColorPalette.success,
                            ),
                            label: const Text(
                              'Salva',
                              style: TextStyle(
                                color: ColorPalette.success,
                              ),
                            ),
                            onPressed: _saveName,
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.close,
                                color: ColorPalette.error),
                            label: const Text('Annulla'),
                            onPressed: () => setState(() {
                              _isEditingName = false;
                              _nameController.text = widget.league.name;
                            }),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  GestureDetector(
                    onTap: () => setState(() {
                      _isEditingName = true;
                    }),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: context.secondaryBgColor,
                        borderRadius:
                            BorderRadius.circular(ThemeSizes.borderRadiusMd),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.league.name,
                              style: context.textTheme.bodyLarge!.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: context.primaryColor.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionItem() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeSizes.md,
        vertical: ThemeSizes.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.primaryColor.withValues(alpha: 0.7),
                  context.primaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
            ),
            child: const Icon(
              Icons.description,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: ThemeSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Descrizione',
                  style: context.textTheme.labelMedium!.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                if (_isEditingDescription)
                  Column(
                    children: [
                      TextField(
                        controller: _descriptionController,
                        decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(
                                ThemeSizes.borderRadiusMd),
                          ),
                        ),
                        style: context.textTheme.bodyMedium,
                        maxLines: 3,
                        autofocus: true,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            icon: const Icon(
                              Icons.check,
                              color: ColorPalette.success,
                            ),
                            label: Text(
                              'Salva',
                              style: TextStyle(
                                color: ColorPalette.success,
                              ),
                            ),
                            onPressed: _saveDescription,
                          ),
                          TextButton.icon(
                            icon: const Icon(Icons.close),
                            label: const Text('Annulla'),
                            onPressed: () => setState(() {
                              _isEditingDescription = false;
                              _descriptionController.text =
                                  widget.league.description ?? '';
                            }),
                          ),
                        ],
                      ),
                    ],
                  )
                else
                  GestureDetector(
                    onTap: () => setState(() {
                      _isEditingDescription = true;
                    }),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: context.secondaryBgColor,
                        borderRadius:
                            BorderRadius.circular(ThemeSizes.borderRadiusMd),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.league.description ??
                                  'Nessuna descrizione',
                              style: widget.league.description == null
                                  ? context.textTheme.bodyMedium!.copyWith(
                                      fontStyle: FontStyle.italic,
                                      color: context.textSecondaryColor,
                                    )
                                  : context.textTheme.bodyMedium,
                            ),
                          ),
                          Icon(
                            Icons.edit_outlined,
                            size: 18,
                            color: context.primaryColor.withValues(alpha: 0.7),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onCopyPressed,
    bool isCopied = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: ThemeSizes.md,
        vertical: ThemeSizes.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  context.primaryColor.withValues(alpha: 0.7),
                  context.primaryColor,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(ThemeSizes.borderRadiusMd),
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: ThemeSizes.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: context.textTheme.labelMedium!.copyWith(
                    color: context.textSecondaryColor,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: context.secondaryBgColor,
                          borderRadius:
                              BorderRadius.circular(ThemeSizes.borderRadiusMd),
                        ),
                        child: Text(
                          value,
                          style: context.textTheme.bodyMedium,
                        ),
                      ),
                    ),
                    if (onCopyPressed != null)
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(left: 8),
                        decoration: BoxDecoration(
                          color: isCopied
                              ? Colors.green.withValues(alpha: 0.1)
                              : context.textPrimaryColor.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(ThemeSizes.borderRadiusMd),
                        ),
                        child: IconButton(
                          icon: Icon(
                            isCopied ? Icons.check : Icons.content_copy,
                            size: 18,
                            color: isCopied
                                ? Colors.green
                                : context.textPrimaryColor,
                          ),
                          onPressed: onCopyPressed,
                          tooltip:
                              isCopied ? 'Copiato!' : 'Copia negli appunti',
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    setState(() {
      _inviteCodeCopied = true;
    });

    // Reset the copied state after a delay
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _inviteCodeCopied = false;
        });
      }
    });
  }

  void _saveName() {
    final newName = _nameController.text.trim();
    if (newName.isNotEmpty && newName != widget.league.name) {
      _updateLeagueInfo(name: newName);
    }
    setState(() {
      _isEditingName = false;
    });
  }

  void _saveDescription() {
    final newDescription = _descriptionController.text.trim();
    if (newDescription != (widget.league.description ?? '')) {
      _updateLeagueInfo(
          description: newDescription.isNotEmpty ? newDescription : null);
    }
    setState(() {
      _isEditingDescription = false;
    });
  }

  void _updateLeagueInfo({String? name, String? description}) {
    context.read<LeagueBloc>().add(
          UpdateLeagueInfoEvent(
            league: widget.league,
            name: name,
            description: description,
          ),
        );
  }
}
