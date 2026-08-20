import 'package:cached_network_image/cached_network_image.dart';
import 'package:fantavacanze_official/core/cubits/drop/drop_cubit.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/features/drop/domain/entities/drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:url_launcher/url_launcher.dart';

typedef DropImagesPreloader = Future<bool> Function(
  BuildContext context,
  List<String> imageUrls,
);

Future<bool> _preloadDropImages(
  BuildContext context,
  List<String> imageUrls,
) async {
  var failed = false;
  await Future.wait(
    imageUrls.map(
      (url) => precacheImage(
        CachedNetworkImageProvider(url),
        context,
        onError: (_, __) => failed = true,
      ),
    ),
  );
  return !failed;
}

class DropPosterPage extends StatefulWidget {
  const DropPosterPage({
    super.key,
    required this.drop,
    this.imagePreloader = _preloadDropImages,
  });

  final Drop drop;
  final DropImagesPreloader imagePreloader;

  @override
  State<DropPosterPage> createState() => _DropPosterPageState();
}

class _DropPosterPageState extends State<DropPosterPage> {
  final _pageController = PageController();
  var _preloadStarted = false;
  var _imagesReady = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_preloadStarted) return;

    _preloadStarted = true;
    _preloadImages();
  }

  Future<void> _preloadImages() async {
    final succeeded =
        await widget.imagePreloader(context, widget.drop.imageUrls);
    if (!mounted) return;

    if (!succeeded) {
      context.read<DropCubit>().imageFailed();
      return;
    }

    setState(() => _imagesReady = true);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _openStore(BuildContext context) async {
    final cubit = context.read<DropCubit>();
    final messenger = ScaffoldMessenger.of(context);
    final uri = Uri.tryParse(widget.drop.ctaUrl);

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
              child: _imagesReady
                  ? PageView.builder(
                      controller: _pageController,
                      itemCount: widget.drop.imageUrls.length,
                      itemBuilder: (context, index) {
                        return Semantics(
                          image: true,
                          label: '${widget.drop.imageDescriptions[index]}. '
                              'Prodotto ${index + 1} '
                              'di ${widget.drop.imageUrls.length}',
                          child: CachedNetworkImage(
                            key: ValueKey('drop-image-$index'),
                            imageUrl: widget.drop.imageUrls[index],
                            fit: BoxFit.contain,
                            width: double.infinity,
                            errorWidget: (imageContext, url, error) {
                              WidgetsBinding.instance
                                  .addPostFrameCallback((duration) {
                                if (imageContext.mounted) {
                                  imageContext.read<DropCubit>().imageFailed();
                                }
                              });
                              return const SizedBox.shrink();
                            },
                          ),
                        );
                      },
                    )
                  : const Center(child: CircularProgressIndicator()),
            ),
            if (_imagesReady) ...[
              Padding(
                padding: const EdgeInsets.only(top: ThemeSizes.sm),
                child: SmoothPageIndicator(
                  controller: _pageController,
                  count: widget.drop.imageUrls.length,
                  effect: ExpandingDotsEffect(
                    activeDotColor: ColorPalette.white,
                    dotColor: ColorPalette.white.withValues(alpha: 0.45),
                    dotHeight: ThemeSizes.sm,
                    dotWidth: ThemeSizes.sm,
                    spacing: ThemeSizes.sm,
                  ),
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
                        child: Text(widget.drop.ctaLabel),
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
          ],
        ),
      ),
    );
  }
}
