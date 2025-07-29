import 'package:flutter/material.dart';

class RobustNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final String fallbackAsset;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final String debugLabel;

  const RobustNetworkImage({
    Key? key,
    required this.imageUrl,
    required this.fallbackAsset,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.debugLabel = 'Image',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Container(
        width: width,
        height: height,
        child: imageUrl != null
            ? Image.network(
                imageUrl!,
                fit: fit,
                width: width,
                height: height,
                headers: {
                  'Accept': 'image/png,image/jpeg,image/*',
                },
                gaplessPlayback: true,
                filterQuality: FilterQuality.low,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    fallbackAsset,
                    fit: fit,
                    width: width,
                    height: height,
                  );
                },
              )
            : Image.asset(
                fallbackAsset,
                fit: fit,
                width: width,
                height: height,
              ),
      ),
    );
  }
} 