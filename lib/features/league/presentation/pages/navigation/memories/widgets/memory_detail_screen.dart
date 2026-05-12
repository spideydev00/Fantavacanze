import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:fantavacanze_official/core/cubits/app_league/app_league_cubit.dart';
import 'package:fantavacanze_official/core/extensions/colors_extension.dart';
import 'package:fantavacanze_official/core/theme/colors.dart';
import 'package:fantavacanze_official/core/theme/sizes.dart';
import 'package:fantavacanze_official/core/utils/in-game/find_event_from_memory.dart';
import 'package:fantavacanze_official/core/utils/media/image_branding_util.dart';
import 'package:fantavacanze_official/core/utils/show-snackbar-or-paywall/show_snackbar.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/confirmation_dialog.dart';
import 'package:fantavacanze_official/core/widgets/dialogs/processing_dialog.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:fantavacanze_official/core/widgets/media/video_player.dart';
import 'package:fantavacanze_official/core/widgets/profile_image_avatar.dart';
import 'package:fantavacanze_official/features/league/domain/entities/league/league.dart';
import 'package:fantavacanze_official/features/league/domain/entities/memory.dart';
import 'package:fantavacanze_official/features/league/domain/entities/rule/rule.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gallery_saver_plus/gallery_saver.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class MemoryDetailScreen extends StatefulWidget {
  final Memory memory;
  final VoidCallback? onDelete;
  final bool isCurrentUserAuthor;
  final League? league;

  const MemoryDetailScreen({
    super.key,
    required this.memory,
    this.onDelete,
    this.isCurrentUserAuthor = false,
    this.league,
  });

  @override
  State<MemoryDetailScreen> createState() => _MemoryDetailScreenState();
}

class _MemoryDetailScreenState extends State<MemoryDetailScreen> {
  bool _isProcessing = false;

  Future<void> _runWithDialog({
    required IconData icon,
    required ProcessingState initialState,
    required Future<void> Function(
      ValueNotifier<ProcessingState> notifier,
      CancelToken token,
    ) work,
    required String? successMessage,
    Color successColor = ColorPalette.success,
  }) async {
    final notifier = ValueNotifier<ProcessingState>(initialState);
    final cancelToken = CancelToken();
    var cancelled = false;
    NavigatorState? dialogNavigator;

    if (mounted) {
      setState(() {
        _isProcessing = true;
      });
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        dialogNavigator = Navigator.of(ctx);
        return ProcessingDialog(
          state: notifier,
          leadingIcon: icon,
          onCancel: () {
            cancelled = true;
            cancelToken.cancel();
            dialogNavigator?.pop();
          },
        );
      },
    );

    try {
      await work(notifier, cancelToken);
      if (!cancelled && successMessage != null) {
        showSnackBar(successMessage, color: successColor);
      }
    } on DioException catch (e) {
      if (!CancelToken.isCancel(e)) {
        showSnackBar(
          'Errore durante l\'operazione',
          color: ColorPalette.error,
        );
      }
    } catch (_) {
      if (!cancelled) {
        showSnackBar(
          'Errore durante l\'operazione',
          color: ColorPalette.error,
        );
      }
    } finally {
      final navigator = dialogNavigator;
      if (!cancelled && navigator != null && navigator.canPop()) {
        navigator.pop();
      }
      notifier.dispose();
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  Future<void> _handleShare() async {
    if (_isProcessing) return;

    if (widget.memory.isVideo) {
      await _runWithDialog(
        icon: Icons.ios_share_rounded,
        initialState: const ProcessingState(
          'Download del video...',
          progress: 0,
        ),
        work: (notifier, token) async {
          final tempDir = await getTemporaryDirectory();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final extension = _extensionFromUrl(widget.memory.mediaUrl);
          final videoFile =
              File('${tempDir.path}/memory_share_$timestamp.$extension');
          var handedToShare = false;

          try {
            await Dio().download(
              widget.memory.mediaUrl,
              videoFile.path,
              cancelToken: token,
              onReceiveProgress: (received, total) {
                if (total > 0) {
                  notifier.value = ProcessingState(
                    'Download del video...',
                    progress: received / total,
                  );
                }
              },
            );

            if (token.isCancelled) return;

            handedToShare = true;
            await ImageBrandingUtil.shareFiles(
              [videoFile],
              text: 'Guarda questo momento da Fantavacanze! 🏖️'
                  'Scarica l\'app e gioca con i tuoi amici.',
            );
          } finally {
            if (!handedToShare) {
              try {
                if (await videoFile.exists()) {
                  await videoFile.delete();
                }
              } catch (_) {}
            }
          }
        },
        successMessage: null,
      );
      return;
    }

    await _runWithDialog(
      icon: Icons.ios_share_rounded,
      initialState: const ProcessingState(
        "Download dell'immagine...",
        progress: 0,
      ),
      work: (notifier, token) async {
        final brandedFile = await ImageBrandingUtil.brandImageFromUrl(
          widget.memory.mediaUrl,
          cancelToken: token,
          onDownloadProgress: (progress) => notifier.value = ProcessingState(
            "Download dell'immagine...",
            progress: progress,
          ),
          onBrandingStart: () => notifier.value = const ProcessingState(
            'Generazione del file per la condivisione...',
          ),
        );

        if (token.isCancelled) {
          try {
            if (await brandedFile.exists()) {
              await brandedFile.delete();
            }
          } catch (_) {}
          return;
        }

        await ImageBrandingUtil.shareFiles(
          [brandedFile],
          text: 'Guarda il mio ricordo da Fantavacanze! 🏖️',
        );
      },
      successMessage: null,
    );
  }

  Future<void> _handleDownload() async {
    if (_isProcessing) return;

    if (widget.memory.isVideo) {
      await _runWithDialog(
        icon: Icons.download_rounded,
        initialState: const ProcessingState(
          'Download del video...',
          progress: 0,
        ),
        work: (notifier, token) async {
          final tempDir = await getTemporaryDirectory();
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final extension = _extensionFromUrl(widget.memory.mediaUrl);
          final tempPath =
              '${tempDir.path}/fantavacanze_video_$timestamp.$extension';
          final tempFile = File(tempPath);

          try {
            await Dio().download(
              widget.memory.mediaUrl,
              tempPath,
              cancelToken: token,
              onReceiveProgress: (received, total) {
                if (total > 0) {
                  notifier.value = ProcessingState(
                    'Download del video...',
                    progress: received / total,
                  );
                }
              },
            );

            if (token.isCancelled) return;

            notifier.value =
                const ProcessingState('Salvataggio in galleria...');
            final saved = await GallerySaver.saveVideo(tempPath);
            if (saved != true) throw Exception('save failed');
          } finally {
            try {
              if (await tempFile.exists()) {
                await tempFile.delete();
              }
            } catch (_) {}
          }
        },
        successMessage: 'Video salvato nella galleria!',
      );
      return;
    }

    await _runWithDialog(
      icon: Icons.download_rounded,
      initialState: const ProcessingState(
        "Download dell'immagine...",
        progress: 0,
      ),
      work: (notifier, token) async {
        final saved = await ImageBrandingUtil.saveBrandedImageToGallery(
          widget.memory.mediaUrl,
          cancelToken: token,
          onDownloadProgress: (progress) => notifier.value = ProcessingState(
            "Download dell'immagine...",
            progress: progress,
          ),
          onBrandingStart: () => notifier.value = const ProcessingState(
            'Generazione immagine brandizzata...',
          ),
          onSavingStart: () => notifier.value = const ProcessingState(
            'Salvataggio in galleria...',
          ),
        );

        if (!saved) throw Exception('save failed');
      },
      successMessage: 'Immagine salvata nella galleria!',
    );
  }

  String _extensionFromUrl(String url) {
    final uri = Uri.tryParse(url);
    final fileName = uri?.pathSegments.isNotEmpty == true
        ? uri!.pathSegments.last
        : url.split('/').last.split('?').first;
    final dotIndex = fileName.lastIndexOf('.');

    if (dotIndex == -1 || dotIndex == fileName.length - 1) {
      return 'mp4';
    }

    final extension = fileName.substring(dotIndex + 1).toLowerCase();
    return RegExp(r'^[a-z0-9]{2,5}$').hasMatch(extension) ? extension : 'mp4';
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('d MMMM yyyy, HH:mm');
    final formattedDate = dateFormat.format(widget.memory.createdAt);

    final relatedEvent = widget.league != null
        ? FindEventFromMemory.findRelatedEvent(widget.memory, widget.league!)
        : null;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.all(ThemeSizes.sm),
          child: BackButton(
            color: Colors.white,
            style: ButtonStyle(
              padding: WidgetStatePropertyAll(
                EdgeInsets.all(ThemeSizes.sm),
              ),
              iconSize: WidgetStatePropertyAll(23),
            ),
          ),
        ),
        actions: [
          if (widget.memory.isVideo)
            Padding(
              padding: const EdgeInsets.only(right: ThemeSizes.sm),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: ColorPalette.info.withValues(alpha: .8),
                  borderRadius:
                      BorderRadius.circular(ThemeSizes.borderRadiusMd),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.videocam_rounded, size: 12, color: Colors.white),
                    SizedBox(width: 4),
                    Text(
                      'VIDEO',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          IconButton(
            icon: const Icon(Icons.ios_share_rounded, size: 25),
            color: Colors.white,
            onPressed: _isProcessing ? null : _handleShare,
            tooltip: 'Condividi',
          ),
          IconButton(
            icon: const Icon(Icons.download_rounded, size: 25),
            color: Colors.white,
            onPressed: _isProcessing ? null : _handleDownload,
            tooltip:
                widget.memory.isVideo ? 'Scarica video' : 'Scarica immagine',
          ),
          if (widget.isCurrentUserAuthor && widget.onDelete != null)
            Padding(
              padding: const EdgeInsets.all(ThemeSizes.xs),
              child: IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 25),
                color: Colors.white,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => ConfirmationDialog.deleteMemory(
                      onDelete: () {
                        Navigator.pop(ctx);
                        widget.onDelete!();
                      },
                    ),
                  );
                },
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // ------------------- MEDIA -------------------
          Expanded(
            flex: 3,
            child: Center(
              child: Hero(
                tag: 'memory_image_${widget.memory.id}',

                // 👉 sostituisce il player in volo con un placeholder statico
                flightShuttleBuilder: (flightContext, animation, direction,
                    fromContext, toContext) {
                  if (widget.memory.isVideo) {
                    return _buildVideoThumbnailForHero(context);
                  }
                  return CachedNetworkImage(
                    imageUrl: widget.memory.mediaUrl,
                    fit: BoxFit.cover,
                  );
                },

                child: widget.memory.isVideo
                    ? _buildVideoPlayer(context)
                    : _buildImageViewer(context),
              ),
            ),
          ),

          // ------------------- DETTAGLI -------------------
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(ThemeSizes.lg),
              decoration: BoxDecoration(
                color: context.bgColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(ThemeSizes.borderRadiusXlg),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: .2),
                    blurRadius: 20,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ---------- AUTHOR ----------
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: .1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: _buildAuthorAvatar(),
                        ),
                        const SizedBox(width: ThemeSizes.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.memory.participantName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: context.textPrimaryColor,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Icon(Icons.access_time_rounded,
                                      size: 14,
                                      color: context.textSecondaryColor),
                                  const SizedBox(width: 4),
                                  Text(
                                    formattedDate,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: context.textSecondaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    // ---------- DIVIDER ----------
                    Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: ThemeSizes.md),
                      child: Divider(
                        color: context.borderColor.withValues(alpha: .3),
                        height: 1,
                      ),
                    ),

                    // ---------- EVENT ----------
                    if (widget.memory.eventName != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: ThemeSizes.md),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: ThemeSizes.md,
                              vertical: ThemeSizes.sm),
                          decoration: BoxDecoration(
                            color: _getEventColor(relatedEvent?.type)
                                .withValues(alpha: .1),
                            borderRadius: BorderRadius.circular(
                                ThemeSizes.borderRadiusLg),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _getEventIcon(relatedEvent?.type),
                                size: 16,
                                color: _getEventColor(relatedEvent?.type),
                              ),
                              const SizedBox(width: ThemeSizes.sm),
                              Expanded(
                                child: Text(
                                  widget.memory.eventName!,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: _getEventColor(relatedEvent?.type),
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                    // ---------- DESCRIPTION ----------
                    if (widget.memory.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: ThemeSizes.md),
                        child: Text(
                          widget.memory.text,
                          style: TextStyle(
                            fontSize: 16,
                            color: context.textPrimaryColor,
                            height: 1.4,
                            letterSpacing: .2,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ------------------- MEDIA WIDGETS -------------------

  Widget _buildAuthorAvatar() {
    final profileImageUrl = context
        .watch<AppLeagueCubit>()
        .getProfileImageFor(widget.memory.userId);

    return ProfileImageAvatar(
      imageUrl: profileImageUrl,
      size: 48,
      loaderColor: ColorPalette.info,
      fallback: _buildAuthorFallback(),
    );
  }

  Widget _buildAuthorFallback() {
    return Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: ColorPalette.getGradientFromId(widget.memory.userId),
        shape: BoxShape.circle,
      ),
      child: Text(
        widget.memory.participantName[0].toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildVideoPlayer(BuildContext context) {
    return SizedBox.expand(
      child: BetterVideoPlayer(
        videoSource: widget.memory.mediaUrl,
        fit: BoxFit.cover,
      ),
    );
  }

  Widget _buildImageViewer(BuildContext context) {
    return InteractiveViewer(
      minScale: .5,
      maxScale: 3.0,
      child: CachedNetworkImage(
        imageUrl: widget.memory.mediaUrl,
        fit: BoxFit.contain,
        placeholder: (_, __) => Loader(
          color: ColorPalette.info,
        ),
        errorWidget: (_, __, ___) => const Center(
          child: Icon(Icons.broken_image_rounded, color: Colors.red, size: 60),
        ),
      ),
    );
  }

  /// Placeholder statico usato dalla Hero mentre vola
  Widget _buildVideoThumbnailForHero(BuildContext context) {
    return Container(
      color: context.secondaryBgColor,
      child: Center(
        child: Icon(
          Icons.movie_rounded,
          size: 50,
          color: ColorPalette.info.withValues(alpha: .7),
        ),
      ),
    );
  }

  // ------------------- EVENT UTILS -------------------

  Color _getEventColor(RuleType? t) {
    switch (t) {
      case RuleType.bonus:
        return ColorPalette.success;
      case RuleType.malus:
        return ColorPalette.error;
      default:
        return ColorPalette.info;
    }
  }

  IconData _getEventIcon(RuleType? t) {
    switch (t) {
      case RuleType.bonus:
        return Icons.add_circle_outline_rounded;
      case RuleType.malus:
        return Icons.remove_circle_outline_rounded;
      default:
        return Icons.event_available_rounded;
    }
  }
}
