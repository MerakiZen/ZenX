import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/design/design_tokens.dart';
import '../../../../core/design/hevy_colors.dart';
import '../../../../core/presentation/base_screen.dart';
import '../providers/analytics_providers.dart';

/// Personal records screen (Hevy style)
class PersonalRecordsScreen extends BaseScreen {
  const PersonalRecordsScreen({super.key});

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      backgroundColor: HevyColors.background,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        color: HevyColors.textPrimary,
        onPressed: () => context.pop(),
      ),
      title: const Text(
        'Personal Records',
        style: TextStyle(
          fontSize: DesignTokens.titleLarge,
          fontWeight: FontWeight.w600,
          color: HevyColors.textPrimary,
        ),
      ),
    );
  }

  @override
  Widget buildBody(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(personalRecordsProvider);
    return recordsAsync.when(
      data: (records) => RefreshIndicator(
        onRefresh: () => ref.refresh(personalRecordsProvider.future),
        child: ListView.builder(
          padding: const EdgeInsets.all(DesignTokens.paddingScreen),
          itemCount: records.length,
          itemBuilder: (context, index) {
            final record = records[index];
            return _PRRecordCard(record: record);
          },
        ),
      ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Unable to load personal records'),
            const SizedBox(height: DesignTokens.spacingS),
            TextButton(
              onPressed: () => ref.refresh(personalRecordsProvider.future),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

/// PR record card
class _PRRecordCard extends StatelessWidget {
  final PersonalRecordData record;

  const _PRRecordCard({required this.record});

  String _formatValue(double value, String type) {
    if (type.contains('RM') ||
        type.contains('WEIGHT') ||
        type.contains('VOLUME')) {
      return '${value.toStringAsFixed(1)} kg';
    } else {
      return value.toStringAsFixed(0);
    }
  }

  String _formatDate(DateTime? date) {
    if (date == null) {
      return 'Recently';
    }
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final exerciseName = record.exercise?.name;
    final exerciseLabel = (exerciseName != null && exerciseName.isNotEmpty)
        ? exerciseName
        : record.exerciseId;
    final typeLabel = record.recordType.toUpperCase();

    return Card(
      margin: const EdgeInsets.only(bottom: DesignTokens.spacingM),
      child: Padding(
        padding: const EdgeInsets.all(DesignTokens.paddingScreen),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(DesignTokens.spacingM),
              decoration: BoxDecoration(
                color: HevyColors.accentOrange.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(DesignTokens.radiusM),
              ),
              child: const Icon(
                Icons.emoji_events,
                color: HevyColors.accentOrange,
                size: DesignTokens.iconLarge, // 32dp
              ),
            ),
            const SizedBox(width: DesignTokens.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exerciseLabel,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: DesignTokens.spacingXS),
                  Row(
                    children: [
                      Text(
                        _formatValue(record.value, typeLabel),
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  color: HevyColors.accentOrange,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      const SizedBox(width: DesignTokens.spacingXS),
                      Chip(
                        label: Text(typeLabel),
                        backgroundColor: HevyColors.surfaceElevated,
                        padding: EdgeInsets.zero,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ],
                  ),
                  const SizedBox(height: DesignTokens.spacingXXS),
                  Text(
                    _formatDate(record.achievedAt),
                    style: Theme.of(context).textTheme.bodySmall,
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
