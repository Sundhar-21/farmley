import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:farmconnect/shared/design_constants.dart';
import 'package:farmconnect/shared/widgets/farm_product_card.dart';
import 'package:farmconnect/features/consumer/data/product_provider.dart';
import 'package:farmconnect/features/consumer/data/search_provider.dart';

class DedicatedSearchScreen extends ConsumerStatefulWidget {
  const DedicatedSearchScreen({super.key});

  @override
  ConsumerState<DedicatedSearchScreen> createState() => _DedicatedSearchScreenState();
}

class _DedicatedSearchScreenState extends ConsumerState<DedicatedSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchQuery = ref.watch(searchQueryProvider);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FFF8),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(DesignSpacing.m),
                child: Row(
                  children: [
                    if (Navigator.of(context).canPop())
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_rounded, color: DesignColors.textPrimary),
                      ),
                    Expanded(
                      child: Container(
                        height: 50,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(DesignRadius.l),
                          boxShadow: DesignShadows.small,
                        ),
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          onChanged: (value) {
                            ref.read(searchQueryProvider.notifier).state = value;
                          },
                          onSubmitted: (value) {
                            if (value.trim().isNotEmpty) {
                              ref.read(recentSearchesProvider.notifier).addSearch(value.trim());
                            }
                          },
                          decoration: InputDecoration(
                            hintText: 'Search products...',
                            hintStyle: GoogleFonts.poppins(color: DesignColors.textTertiary, fontSize: 13),
                            prefixIcon: const Icon(Icons.search, color: DesignColors.primary, size: 20),
                            suffixIcon: searchQuery.isNotEmpty
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: DesignColors.textSecondary, size: 18),
                                    onPressed: () {
                                      _searchController.clear();
                                      ref.read(searchQueryProvider.notifier).state = '';
                                    },
                                  )
                                : null,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(DesignRadius.l),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(DesignRadius.l),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(DesignRadius.l),
                              borderSide: const BorderSide(color: DesignColors.primary, width: 2),
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                          ),
                          style: GoogleFonts.poppins(
                            color: DesignColors.textPrimary,
                            fontSize: 13,
                          ),
                          textAlignVertical: TextAlignVertical.center,
                        ),
                      ),
                    ),
                    const SizedBox(width: DesignSpacing.s),
                  ],
                ),
              ),
              
              if (searchQuery.isEmpty) ...[
                // Recent Searches
                Expanded(
                  child: Consumer(
                    builder: (context, ref, child) {
                      final recentSearches = ref.watch(recentSearchesProvider);
                      if (recentSearches.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.history_rounded, size: 64, color: DesignColors.textSecondary.withOpacity(0.2)),
                              const SizedBox(height: 16),
                              Text(
                                'No recent searches',
                                style: GoogleFonts.poppins(color: DesignColors.textSecondary),
                              ),
                            ],
                          ),
                        );
                      }
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m, vertical: DesignSpacing.s),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Recent Searches',
                                  style: GoogleFonts.poppins(
                                    color: DesignColors.textPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () => ref.read(recentSearchesProvider.notifier).clearAll(),
                                  icon: const Icon(Icons.delete_sweep_outlined, color: DesignColors.error, size: 20),
                                  tooltip: 'Clear All',
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m),
                              itemCount: recentSearches.length,
                              separatorBuilder: (context, index) => Divider(color: DesignColors.secondary.withOpacity(0.1)),
                              itemBuilder: (context, index) {
                                final query = recentSearches[index];
                                return ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: const Icon(Icons.history_rounded, color: DesignColors.textTertiary, size: 20),
                                  title: Text(
                                    query,
                                    style: GoogleFonts.poppins(color: DesignColors.textPrimary, fontSize: 14),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.close_rounded, size: 18, color: DesignColors.textSecondary),
                                    onPressed: () => ref.read(recentSearchesProvider.notifier).removeSearch(query),
                                  ),
                                  onTap: () {
                                    _searchController.text = query;
                                    ref.read(searchQueryProvider.notifier).state = query;
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ] else ...[
                // Search Results
                Expanded(
                  child: ref.watch(productsProvider).when(
                    data: (products) {
                      final filteredProducts = products.where((p) {
                        final name = (p['name'] as String).toLowerCase();
                        final description = (p['description'] as String?)?.toLowerCase() ?? '';
                        return name.contains(searchQuery.toLowerCase()) || description.contains(searchQuery.toLowerCase());
                      }).toList();

                      if (filteredProducts.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search_off_rounded, size: 64, color: DesignColors.textSecondary.withOpacity(0.3)),
                              const SizedBox(height: DesignSpacing.m),
                              Text(
                                'No products found for "$searchQuery"',
                                style: GoogleFonts.poppins(color: DesignColors.textSecondary, fontSize: 16),
                              ),
                            ],
                          ),
                        );
                      }

                      return GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: DesignSpacing.m),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.72,
                          crossAxisSpacing: DesignSpacing.m,
                          mainAxisSpacing: DesignSpacing.m,
                        ),
                        itemCount: filteredProducts.length,
                        itemBuilder: (context, index) {
                          return FarmProductCard(product: filteredProducts[index]);
                        },
                      );
                    },
                    loading: () => const Center(child: CircularProgressIndicator(color: DesignColors.primary)),
                    error: (e, _) => Center(child: Text('Error: $e')),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
