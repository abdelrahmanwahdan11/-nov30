import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

import '../../controllers/catalog_controller.dart';
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalog'),
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
                hintText: 'Search pods',
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
          Expanded(
            child: ValueListenableBuilder<List<Pod>>(
              valueListenable: controller.items,
              builder: (context, pods, child) {
                return GridView.builder(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
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
                              subtitle: Text(pod.location),
                              trailing: const AiInfoButton(),
                            ),
                          ],
                        ),
                      ),
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
              subtitle: Text(pod.location),
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
