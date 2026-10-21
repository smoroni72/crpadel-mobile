import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/media_url.dart';
import '../../../core/widgets/async_value_view.dart';
import '../domain/explore_models.dart';
import 'explore_providers.dart';

class GalleryScreen extends ConsumerWidget {
  const GalleryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => Scaffold(
    appBar: AppBar(title: const Text('Gallery')),
    body: RefreshIndicator(
      onRefresh: () => ref.refresh(galleryProvider.future),
      child: AsyncValueView(
        value: ref.watch(galleryProvider),
        errorText: 'Non riesco a caricare la gallery',
        onRetry: () => ref.invalidate(galleryProvider),
        data: (events) => events.isEmpty
            ? const Center(child: Text('Nessuna fotografia pubblicata'))
            : GridView.builder(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: .76,
                ),
                itemCount: events.length,
                itemBuilder: (_, index) => _GalleryCard(events[index]),
              ),
      ),
    ),
  );
}

class _GalleryCard extends StatelessWidget {
  const _GalleryCard(this.event);
  final GalleryEvent event;

  @override
  Widget build(BuildContext context) {
    final image = absoluteMediaUrl(
      event.coverImage ??
          (event.images.isEmpty ? null : event.images.first.url),
    );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _openGallery(context, event),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: image == null
                  ? ColoredBox(
                      color: context.colors.divider,
                      child: const Icon(Icons.photo_library_outlined, size: 42),
                    )
                  : Image.network(
                      image,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) =>
                          const Icon(Icons.broken_image_outlined, size: 42),
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    DateFormat('d MMM yyyy', 'it_IT').format(event.eventDate),
                    style: TextStyle(
                      fontSize: 11,
                      color: context.colors.textSecondary,
                    ),
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

void _openGallery(BuildContext context, GalleryEvent event) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) => DraggableScrollableSheet(
      expand: false,
      initialChildSize: .84,
      maxChildSize: .96,
      builder: (_, controller) => ListView(
        controller: controller,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
        children: [
          Text(event.title, style: Theme.of(context).textTheme.headlineSmall),
          if (event.description?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 8),
            Text(event.description!),
          ],
          const SizedBox(height: 16),
          for (final image in event.images) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Image.network(
                absoluteMediaUrl(image.url) ?? image.url,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox.shrink(),
              ),
            ),
            if (image.caption?.trim().isNotEmpty == true)
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 6, 4, 14),
                child: Text(
                  image.caption!,
                  style: TextStyle(color: context.colors.textSecondary),
                ),
              )
            else
              const SizedBox(height: 14),
          ],
        ],
      ),
    ),
  );
}
