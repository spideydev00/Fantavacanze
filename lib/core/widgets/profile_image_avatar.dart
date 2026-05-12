import 'package:cached_network_image/cached_network_image.dart';
import 'package:fantavacanze_official/core/widgets/loader.dart';
import 'package:flutter/material.dart';

class ProfileImageAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final Widget fallback;
  final Color loaderColor;
  final Decoration? decoration;

  const ProfileImageAvatar({
    super.key,
    required this.imageUrl,
    required this.size,
    required this.fallback,
    required this.loaderColor,
    this.decoration,
  });

  @override
  Widget build(BuildContext context) {
    final hasImage = imageUrl != null && imageUrl!.isNotEmpty;

    return Container(
      width: size,
      height: size,
      decoration: decoration ?? const BoxDecoration(shape: BoxShape.circle),
      clipBehavior: Clip.antiAlias,
      child: hasImage
          ? CachedNetworkImage(
              imageUrl: imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholder: (_, __) => Loader(color: loaderColor),
              errorWidget: (_, __, ___) => fallback,
            )
          : fallback,
    );
  }
}
