import 'package:flutter/material.dart';
import 'package:raabta/features/home/widgets/glass_loading_card.dart';

class ExchangeLocatorSkeletonList extends StatelessWidget {
  const ExchangeLocatorSkeletonList({
    super.key,
    this.count = 4,
    this.itemHeight = 100,
  });

  final int count;
  final double itemHeight;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (_, _) => GlassLoadingCard(height: itemHeight),
    );
  }
}
