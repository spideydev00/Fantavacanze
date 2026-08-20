import 'package:cached_network_image/cached_network_image.dart';
import 'package:fantavacanze_official/core/cubits/drop/drop_cubit.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/drop/domain/entities/drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class DropPosterPage extends StatelessWidget {
  const DropPosterPage({super.key, required this.drop});

  final Drop drop;

  Future<void> _openStore(BuildContext context) async {
    final cubit = context.read<DropCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.tryParse(drop.ctaUrl);

    if (uri == null) {
      _showOpenError(messenger);
      return;
    }

    try {
      final opened = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!opened) {
        _showOpenError(messenger);
        return;
      }
    } catch (_) {
      _showOpenError(messenger);
      return;
    }

    await cubit.dismiss();
  }

  void _showOpenError(ScaffoldMessengerState messenger) {
    messenger.showSnackBar(
      const SnackBar(
        content: Text('Non riesco ad aprire il link, riprova più tardi.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: CachedNetworkImage(
                imageUrl: drop.imageUrl,
                fit: BoxFit.contain,
                width: double.infinity,
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (imageContext, url, error) {
                  WidgetsBinding.instance.addPostFrameCallback((duration) {
                    if (imageContext.mounted) {
                      imageContext.read<DropCubit>().imageFailed();
                    }
                  });
                  return const SizedBox.shrink();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                ThemeSizes.lg,
                ThemeSizes.md,
                ThemeSizes.lg,
                ThemeSizes.lg,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => _openStore(context),
                      child: Text(drop.ctaLabel),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.read<DropCubit>().dismiss(),
                    child: const Text('Chiudi'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
