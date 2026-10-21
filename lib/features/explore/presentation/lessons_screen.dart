import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/media_url.dart';
import '../../../core/widgets/async_value_view.dart';
import '../../bookings/domain/coach.dart';
import 'explore_providers.dart';

class LessonsScreen extends ConsumerWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Lezioni')),
    body: RefreshIndicator(
      onRefresh: () => ref.refresh(publicCoachesProvider.future),
      child: AsyncValueView(
        value: ref.watch(publicCoachesProvider),
        errorText: 'Non riesco a caricare gli istruttori',
        onRetry: () => ref.invalidate(publicCoachesProvider),
        data: (coaches) => coaches.isEmpty
            ? const Center(child: Text('Nessun istruttore disponibile'))
            : ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                itemCount: coaches.length,
                separatorBuilder: (_, _) => const SizedBox(height: 12),
                itemBuilder: (_, index) => _CoachCard(coaches[index]),
              ),
      ),
    ),
  );
}

class _CoachCard extends StatelessWidget {
  const _CoachCard(this.coach);
  final Coach coach;

  @override
  Widget build(BuildContext context) {
    final photo = absoluteMediaUrl(coach.photoUrl);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (photo != null)
            Image.network(
              photo,
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        coach.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                    _Level(coach.level),
                  ],
                ),
                if (coach.bio?.trim().isNotEmpty == true) ...[
                  const SizedBox(height: 8),
                  Text(coach.bio!),
                ],
                if (coach.specialties.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final specialty in coach.specialties)
                        Chip(label: Text(specialty)),
                    ],
                  ),
                ],
                const SizedBox(height: 14),
                Row(
                  children: [
                    if (coach.pricePerHour > 0)
                      Expanded(
                        child: Text(
                          '€ ${coach.pricePerHour.toStringAsFixed(0)}/ora',
                          style: context.fonts
                              .monoStyle(fontWeight: FontWeight.w700)
                              .copyWith(color: context.colors.primaryText),
                        ),
                      )
                    else
                      const Spacer(),
                    FilledButton.icon(
                      onPressed: () => context.goNamed(
                        AppRoutes.book,
                        queryParameters: const {'mode': 'lesson'},
                      ),
                      icon: const Icon(Icons.calendar_month, size: 18),
                      label: const Text('Prenota'),
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
}

class _Level extends StatelessWidget {
  const _Level(this.value);
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
    decoration: BoxDecoration(
      color: context.colors.primaryTint,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(
      switch (value) {
        'head_coach' => 'Head coach',
        'maestro' => 'Maestro',
        _ => 'Istruttore',
      },
      style: TextStyle(
        color: context.colors.primaryText,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}
