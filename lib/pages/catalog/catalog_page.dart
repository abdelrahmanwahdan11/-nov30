import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../controllers/catalog_controller.dart';
import '../../l10n/app_localizations.dart';
import '../../models/pod.dart';
import '../../widgets/ai_info_button.dart';
import '../../widgets/glass_container.dart';
import '../../widgets/skeleton.dart';
import '../catalog_detail/catalog_detail_sheet.dart';

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final CatalogController controller = CatalogController();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (scrollController.position.pixels >
        scrollController.position.maxScrollExtent - 200) {
      controller.loadMore();
    }
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(strings.t('catalog.title')),
        actions: [
          IconButton(
            icon: const Icon(IconlyLight.search),
            onPressed: () => showSearch(
              context: context,
              delegate: _PodSearchDelegate(controller),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              decoration: InputDecoration(
                hintText: strings.t('catalog.search_hint'),
                prefixIcon: const Icon(IconlyLight.search),
                filled: true,
                fillColor: Theme.of(context).cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: controller.applySearch,
            ),
          ),
          _Filters(controller: controller, strings: strings),
          Expanded(
            child: ValueListenableBuilder<List<Pod>>(
              valueListenable: controller.items,
              builder: (context, pods, child) {
                return ValueListenableBuilder<bool>(
                  valueListenable: controller.isLoading,
                  builder: (context, loading, _) {
                    if (loading && pods.isEmpty) {
                      return const _CatalogSkeleton();
                    }
                    if (pods.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(IconlyLight.close_square),
                            const SizedBox(height: 12),
                            Text(strings.t('catalog.filters.reset')),
                            TextButton(
                              onPressed: controller.resetFilters,
                              child: Text(strings.t('catalog.filters.reset')),
                            ),
                          ],
                        ),
                      );
                    }
                    return GridView.builder(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: ResponsiveBreakpoints.columns(context),
                        childAspectRatio: 0.8,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: pods.length,
                      itemBuilder: (context, index) {
                        final pod = pods[index];
                        return Hero(
                          tag: pod.id,
                          child: GlassContainer(
                            onTap: () => showDialog(
                              context: context,
                              builder: (_) => CatalogDetailSheet(pod: pod),
                            ),
                            child: Column(
                              children: [
                                Expanded(
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(20),
                                    child: Image.network(pod.imageUrl, fit: BoxFit.cover),
                                  ),
                                ),
                                ListTile(
                                  title: Text(pod.name),
                                  subtitle: Text('${pod.location} • ${_statusText(pod, strings)}'),
                                  trailing: const AiInfoButton(),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          ValueListenableBuilder<bool>(
            valueListenable: controller.isLoading,
            builder: (context, loading, child) {
              if (!loading) return const SizedBox.shrink();
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Skeleton(height: 24, width: 120),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _PodSearchDelegate extends SearchDelegate<Pod?> {
  _PodSearchDelegate(this.controller);

  final CatalogController controller;

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => close(context, null));
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final strings = AppLocalizations.of(context);
    controller.applySearch(query);
    return ValueListenableBuilder<List<Pod>>(
      valueListenable: controller.items,
      builder: (context, pods, child) {
        return ListView.builder(
          itemCount: pods.length,
          itemBuilder: (context, index) {
            final pod = pods[index];
            return ListTile(
              title: Text(pod.name),
              subtitle: Text('${pod.location} • ${_statusText(pod, strings)}'),
              onTap: () => close(context, pod),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) => buildSuggestions(context);
}

class _Filters extends StatelessWidget {
  const _Filters({required this.controller, required this.strings});

  final CatalogController controller;
  final AppLocalizations strings;

  @override
  Widget build(BuildContext context) {
    final statusChips = [
      ('low', strings.t('common.status.low')),
      ('medium', strings.t('common.status.medium')),
      ('full', strings.t('common.status.full')),
    ];
    final onlineChips = [
      ('online', strings.t('catalog.filters.online_label')),
      ('offline', strings.t('catalog.filters.offline')),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(strings.t('filters.title'), style: Theme.of(context).textTheme.titleSmall),
              TextButton(
                onPressed: controller.resetFilters,
                child: Text(strings.t('catalog.filters.reset')),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 48,
          child: ValueListenableBuilder<Set<String>>(
            valueListenable: controller.statusFilters,
            builder: (context, selected, _) {
              return ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final chip in statusChips)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(chip.$2),
                        selected: selected.contains(chip.$1),
                        onSelected: (_) => controller.toggleStatus(chip.$1),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        SizedBox(
          height: 48,
          child: ValueListenableBuilder<Set<String>>(
            valueListenable: controller.onlineFilters,
            builder: (context, selected, _) {
              return ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final chip in onlineChips)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(chip.$2),
                        selected: selected.contains(chip.$1),
                        onSelected: (_) => controller.toggleOnline(chip.$1),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
        SizedBox(
          height: 48,
          child: ValueListenableBuilder<Set<String>>(
            valueListenable: controller.locationFilters,
            builder: (context, selected, _) {
              return ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  for (final location in controller.availableLocations)
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(location),
                        selected: selected.contains(location),
                        onSelected: (_) => controller.toggleLocation(location),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CatalogSkeleton extends StatelessWidget {
  const _CatalogSkeleton();

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveBreakpoints.columns(context),
        childAspectRatio: 0.8,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        return const Skeleton();
      },
    );
  }
}

class ResponsiveBreakpoints {
  static int columns(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width >= 1100) return 4;
    if (width >= 800) return 3;
    return 2;
  }
}

String _statusText(Pod pod, AppLocalizations strings) {
  final level = pod.waterLevelPercent;
  if (level < 0.4) return strings.t('common.status.low');
  if (level < 0.7) return strings.t('common.status.medium');
  return strings.t('common.status.full');
}
