import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'config/supabase_config.dart';
import 'data/mock_products.dart';
import 'features/auth/account_page.dart';
import 'features/group_buying/group_deal_widget.dart';
import 'features/sustainability/green_score_panel.dart';
import 'models/product.dart';
import 'state/app_state.dart';
import 'ui/responsive.dart';

// --- MAIN APP ---

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hasSupabaseConfig = SupabaseConfig.isConfigured;
  if (hasSupabaseConfig) {
    await Supabase.initialize(
      url: SupabaseConfig.url,
      anonKey: SupabaseConfig.anonKey,
    );
  }

  await initAppState();
  runApp(MyApp(hasSupabase: hasSupabaseConfig));
}

class MyApp extends StatelessWidget {
  final bool hasSupabase;

  const MyApp({super.key, required this.hasSupabase});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeModel,
      builder: (context, child) {
        return MaterialApp(
          title: 'Flutter Shop',
          debugShowCheckedModeBanner: false,
          themeMode: themeModel.mode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2A2D3E)),
            scaffoldBackgroundColor: const Color(0xFFF5F5F7),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.transparent,
              iconTheme: IconThemeData(color: Colors.black87),
              titleTextStyle: TextStyle(
                  color: Colors.black87,
                  fontSize: 20,
                  fontWeight: FontWeight.bold),
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF2A2D3E),
              brightness: Brightness.dark,
            ),
            scaffoldBackgroundColor: const Color(0xFF0F1118),
            appBarTheme: const AppBarTheme(
              elevation: 0,
              backgroundColor: Colors.transparent,
            ),
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            inputDecorationTheme: InputDecorationTheme(
              filled: true,
              fillColor: const Color(0xFF171A24),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade800),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade800),
              ),
            ),
          ),
          home: hasSupabase ? const MainShell() : const _SupabaseNotConfiguredPage(),
        );
      },
    );
  }
}

class _SupabaseNotConfiguredPage extends StatelessWidget {
  const _SupabaseNotConfiguredPage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup required')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Supabase is not configured.',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  'Run the app with the following defines (from the project root):\n'
                  'flutter run --dart-define=SUPABASE_URL=... --dart-define=SUPABASE_ANON_KEY=...\n\n'
                  'You can find these in Supabase: Project Settings → API.',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _setTab(int i) => setState(() => _index = i);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomePage(onOpenCart: () => _setTab(2)),
          const FavoritesPage(),
          const CartPage(),
          const AccountPage(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: AnimatedBuilder(
          animation: Listenable.merge([cartModel, favoritesModel]),
          builder: (context, child) {
            return NavigationBar(
              selectedIndex: _index,
              onDestinationSelected: _setTab,
              destinations: [
                const NavigationDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon: Icon(Icons.storefront),
                  label: 'Home',
                ),
                NavigationDestination(
                  icon: _NavBadge(
                    count: favoritesModel.count,
                    child: const Icon(Icons.favorite_border),
                  ),
                  selectedIcon: _NavBadge(
                    count: favoritesModel.count,
                    child: const Icon(Icons.favorite),
                  ),
                  label: 'Favorites',
                ),
                NavigationDestination(
                  icon: _NavBadge(
                    count: cartModel.itemCount,
                    child: const Icon(Icons.shopping_bag_outlined),
                  ),
                  selectedIcon: _NavBadge(
                    count: cartModel.itemCount,
                    child: const Icon(Icons.shopping_bag),
                  ),
                  label: 'Cart',
                ),
                const NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Account',
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _NavBadge extends StatelessWidget {
  final int count;
  final Widget child;

  const _NavBadge({required this.count, required this.child});

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return child;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        Positioned(
          right: -6,
          top: -6,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              count > 99 ? '99+' : '$count',
              style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }
}

// --- SCREENS ---

enum _CategoryFilter { all, electronics, fashion, accessories, sustainable }

enum _SortOption { featured, priceLow, priceHigh, greenest }

class HomePage extends StatefulWidget {
  final VoidCallback onOpenCart;

  const HomePage({super.key, required this.onOpenCart});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  _CategoryFilter _category = _CategoryFilter.all;
  _SortOption _sort = _SortOption.featured;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final columns = responsiveGridColumns(width);
        final spacing = width >= Breakpoints.tablet ? 20.0 : 16.0;
        final searchMaxWidth = width >= Breakpoints.tablet ? 720.0 : double.infinity;

        final normalizedQuery = _query.trim().toLowerCase();
        final filteredProducts = _filterProducts(normalizedQuery);
        final sortedProducts = _sortProducts(filteredProducts);

        return Scaffold(
      appBar: AppBar(
        title: const Text('Discover'),
        actions: const [ThemeModeAction()],
      ),
      body: Stack(
        children: [
          maxWidthContainer(
            child: RefreshIndicator(
              onRefresh: () async {
                HapticFeedback.lightImpact();
                await Future<void>.delayed(const Duration(milliseconds: 650));
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Updated'),
                    duration: Duration(seconds: 1),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              child: CustomScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Align(
                            alignment: Alignment.centerLeft,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(maxWidth: searchMaxWidth),
                              child: SearchBar(
                                controller: _searchController,
                                hintText: 'Search products...',
                                leading: const Icon(Icons.search, color: Colors.grey),
                                trailing: [
                                  if (_query.isNotEmpty)
                                    IconButton(
                                      tooltip: 'Clear',
                                      icon: const Icon(Icons.clear, color: Colors.grey),
                                      onPressed: () {
                                        HapticFeedback.selectionClick();
                                        _searchController.clear();
                                        setState(() => _query = '');
                                        FocusScope.of(context).unfocus();
                                      },
                                    ),
                                ],
                                onChanged: (value) => setState(() => _query = value),
                                elevation: const MaterialStatePropertyAll(0),
                                backgroundColor: const MaterialStatePropertyAll(Colors.white),
                                shape: MaterialStatePropertyAll(
                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _CategoryChips(
                                  value: _category,
                                  onChanged: (v) {
                                    HapticFeedback.selectionClick();
                                    setState(() => _category = v);
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              _SortMenu(
                                value: _sort,
                                onChanged: (v) {
                                  HapticFeedback.selectionClick();
                                  setState(() => _sort = v);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'Trending',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 150,
                            child: ListView.separated(
                              scrollDirection: Axis.horizontal,
                              itemCount: mockProducts.take(6).length,
                              separatorBuilder: (_, __) => const SizedBox(width: 12),
                              itemBuilder: (context, index) {
                                final p = mockProducts[index];
                                return _TrendingCard(
                                  product: p,
                                  onAdd: () {
                                    HapticFeedback.lightImpact();
                                    cartModel.addItem(p);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('${p.name} added to cart'),
                                        duration: const Duration(seconds: 1),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 12),
                          const Text(
                            'All products',
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (sortedProducts.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: _HomeEmptyState(
                        query: _query,
                        onClear: () {
                          HapticFeedback.selectionClick();
                          _searchController.clear();
                          setState(() {
                            _query = '';
                            _category = _CategoryFilter.all;
                          });
                        },
                        onPickCategory: (c) {
                          HapticFeedback.selectionClick();
                          setState(() => _category = c);
                        },
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(spacing, spacing, spacing, 120),
                      sliver: SliverGrid(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) => ProductCard(product: sortedProducts[index]),
                          childCount: sortedProducts.length,
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: columns,
                          childAspectRatio: width >= Breakpoints.tablet ? 0.85 : 0.75,
                          crossAxisSpacing: spacing,
                          mainAxisSpacing: spacing,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 12,
            child: maxWidthContainer(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: CartSummaryPill(onTap: widget.onOpenCart),
              ),
            ),
          ),
        ],
      ),
    );
      },
    );
  }

  List<Product> _filterProducts(String normalizedQuery) {
    return mockProducts.where((p) {
      final matchesQuery = normalizedQuery.isEmpty ||
          p.name.toLowerCase().contains(normalizedQuery) ||
          p.description.toLowerCase().contains(normalizedQuery);

      final matchesCategory = switch (_category) {
        _CategoryFilter.all => true,
        _CategoryFilter.sustainable => p.isSustainable,
        _CategoryFilter.electronics => p.category == 'electronics',
        _CategoryFilter.fashion => p.category == 'fashion',
        _CategoryFilter.accessories => p.category == 'accessories',
      };

      return matchesQuery && matchesCategory;
    }).toList(growable: false);
  }

  List<Product> _sortProducts(List<Product> list) {
    final copy = List<Product>.of(list);
    switch (_sort) {
      case _SortOption.featured:
        // Keep original ordering.
        return copy;
      case _SortOption.priceLow:
        copy.sort((a, b) => a.price.compareTo(b.price));
        return copy;
      case _SortOption.priceHigh:
        copy.sort((a, b) => b.price.compareTo(a.price));
        return copy;
      case _SortOption.greenest:
        copy.sort((a, b) => a.carbonKg.compareTo(b.carbonKg));
        return copy;
    }
  }
}

class CartSummaryPill extends StatelessWidget {
  final VoidCallback onTap;

  const CartSummaryPill({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: cartModel,
      builder: (context, child) {
        if (cartModel.itemCount == 0) return const SizedBox();

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              HapticFeedback.selectionClick();
              onTap();
            },
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF2A2D3E),
                borderRadius: BorderRadius.circular(999),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.20),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.shopping_bag, color: Colors.white),
                  const SizedBox(width: 10),
                  Text(
                    '${cartModel.itemCount} items',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 1,
                    height: 18,
                    color: Colors.white24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '\$${cartModel.totalAmount.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.white70, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 10),
                  const Icon(Icons.chevron_right, color: Colors.white70),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SortMenu extends StatelessWidget {
  final _SortOption value;
  final ValueChanged<_SortOption> onChanged;

  const _SortMenu({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonHideUnderline(
      child: DropdownButton<_SortOption>(
        value: value,
        borderRadius: BorderRadius.circular(14),
        items: const [
          DropdownMenuItem(value: _SortOption.featured, child: Text('Featured')),
          DropdownMenuItem(value: _SortOption.priceLow, child: Text('Price ↑')),
          DropdownMenuItem(value: _SortOption.priceHigh, child: Text('Price ↓')),
          DropdownMenuItem(value: _SortOption.greenest, child: Text('Greenest')),
        ],
        onChanged: (v) {
          if (v == null) return;
          onChanged(v);
        },
      ),
    );
  }
}

class _CategoryChips extends StatelessWidget {
  final _CategoryFilter value;
  final ValueChanged<_CategoryFilter> onChanged;

  const _CategoryChips({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final entries = <(_CategoryFilter, String, IconData)>[
      (_CategoryFilter.all, 'All', Icons.grid_view),
      (_CategoryFilter.electronics, 'Electronics', Icons.headphones),
      (_CategoryFilter.fashion, 'Fashion', Icons.checkroom),
      (_CategoryFilter.accessories, 'Accessories', Icons.watch),
      (_CategoryFilter.sustainable, 'Eco', Icons.eco_outlined),
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: entries.map((e) {
          final selected = value == e.$1;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              selected: selected,
              label: Text(e.$2),
              avatar: Icon(e.$3, size: 18, color: selected ? Colors.white : Colors.black54),
              onSelected: (_) => onChanged(e.$1),
              selectedColor: const Color(0xFF2A2D3E),
              labelStyle: TextStyle(color: selected ? Colors.white : Colors.black87),
              side: BorderSide(color: selected ? Colors.transparent : Colors.grey.shade200),
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final Product product;
  final VoidCallback onAdd;

  const _TrendingCard({required this.product, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProductDetailPage(product: product)),
        );
      },
      child: Container(
        width: 280,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 10))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: CachedNetworkImage(
                imageUrl: product.imageUrl,
                width: 92,
                height: 126,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: Colors.grey[200]),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 6),
                  Text('\$${product.price.toStringAsFixed(2)}', style: const TextStyle(color: Colors.grey)),
                  const Spacer(),
                  SizedBox(
                    height: 40,
                    child: FilledButton.icon(
                      onPressed: onAdd,
                      icon: const Icon(Icons.add),
                      label: const Text('Add'),
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

class _HomeEmptyState extends StatelessWidget {
  final String query;
  final VoidCallback onClear;
  final ValueChanged<_CategoryFilter> onPickCategory;

  const _HomeEmptyState({
    required this.query,
    required this.onClear,
    required this.onPickCategory,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.search_off, size: 72, color: Colors.grey),
            const SizedBox(height: 12),
            Text(
              query.trim().isEmpty ? 'No products in this category' : 'No results for "$query"',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              alignment: WrapAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: onClear,
                  icon: const Icon(Icons.clear),
                  label: const Text('Clear'),
                ),
                OutlinedButton.icon(
                  onPressed: () => onPickCategory(_CategoryFilter.all),
                  icon: const Icon(Icons.grid_view),
                  label: const Text('All'),
                ),
                OutlinedButton.icon(
                  onPressed: () => onPickCategory(_CategoryFilter.sustainable),
                  icon: const Icon(Icons.eco_outlined),
                  label: const Text('Eco'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class ProductDetailPage extends StatefulWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> {
  GroupDealOption _deal = GroupDealOption.solo;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isWide = width >= Breakpoints.tablet;

        final product = widget.product;
        final groupPrice = product.price * 0.8;
        final selectedPrice = _deal == GroupDealOption.group ? groupPrice : product.price;
        final selectedLabel = _deal == GroupDealOption.group ? 'Group deal' : 'Solo';

        final details = _ProductDetailsPanel(
          product: product,
          deal: _deal,
          onDealChanged: (d) => setState(() => _deal = d),
        );
        final heroImage = _ProductHeroImage(product: product);

        return Scaffold(
          backgroundColor: product.backgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            actions: [
              AnimatedBuilder(
                animation: favoritesModel,
                builder: (context, child) {
                  final isFav = favoritesModel.isFavorite(product.id);
                  return IconButton(
                    tooltip: isFav ? 'Remove from favorites' : 'Add to favorites',
                    icon: Icon(
                      isFav ? Icons.favorite : Icons.favorite_border,
                      color: isFav ? Colors.red : Colors.black87,
                    ),
                    onPressed: () => favoritesModel.toggleFavorite(product.id),
                  );
                },
              ),
              const CartIconAction(),
            ],
          ),
          body: maxWidthContainer(
            child: isWide
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Row(
                      children: [
                        Expanded(flex: 6, child: heroImage),
                        const SizedBox(width: 16),
                        Expanded(
                          flex: 5,
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: details,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: [
                      Expanded(child: Center(child: heroImage)),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(28),
                            topRight: Radius.circular(28),
                          ),
                        ),
                        child: SizedBox(
                          height: 320,
                          child: SingleChildScrollView(child: details),
                        ),
                      ),
                    ],
                  ),
          ),
          bottomNavigationBar: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              child: SizedBox(
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    final qtyToAdd = _deal == GroupDealOption.group ? 2 : 1;
                    cartModel.addItems(
                      product,
                      quantity: qtyToAdd,
                      unitPrice: selectedPrice,
                      priceLabel: selectedLabel,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${product.name} added ($selectedLabel) x$qtyToAdd • \$${selectedPrice.toStringAsFixed(2)} each',
                        ),
                        duration: const Duration(seconds: 1),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2A2D3E),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    'Add to Cart • \$${selectedPrice.toStringAsFixed(2)}',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _ProductHeroImage extends StatelessWidget {
  final Product product;

  const _ProductHeroImage({required this.product});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: product.id,
      child: Container(
        constraints: const BoxConstraints(maxHeight: 420),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.10),
              blurRadius: 20,
              offset: const Offset(0, 10),
            )
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: CachedNetworkImage(
            imageUrl: product.imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Center(
              child: CircularProgressIndicator(),
            ),
            errorWidget: (context, url, error) => const Center(
              child: Icon(Icons.broken_image, size: 90, color: Colors.white54),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductDetailsPanel extends StatelessWidget {
  final Product product;
  final GroupDealOption deal;
  final ValueChanged<GroupDealOption> onDealChanged;

  const _ProductDetailsPanel({
    required this.product,
    required this.deal,
    required this.onDealChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          product.name,
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          '\$${product.price.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w700,
              ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Description',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          product.description,
          style: const TextStyle(color: Colors.grey, height: 1.4),
        ),
        const SizedBox(height: 16),
        GroupDealWidget(
          productId: product.id,
          soloPrice: product.price,
          groupPrice: (product.price * 0.8),
          endsAt: DateTime.now().add(const Duration(hours: 2)),
          selected: deal,
          onChanged: onDealChanged,
        ),
      ],
    );
  }
}

class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isWide = width >= Breakpoints.tablet;

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Cart'),
            centerTitle: true,
            actions: const [ThemeModeAction()],
          ),
          body: AnimatedBuilder(
            animation: cartModel,
            builder: (context, child) {
              if (cartModel.items.isEmpty) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Your cart is empty', style: TextStyle(color: Colors.grey, fontSize: 18)),
                    ],
                  ),
                );
              }

              final list = ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: cartModel.items.length,
                separatorBuilder: (c, i) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final item = cartModel.items[index];
                  return Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 1, blurRadius: 8)
                      ],
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: CachedNetworkImage(
                            imageUrl: item.product.imageUrl,
                            width: 76,
                            height: 76,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              width: 76,
                              height: 76,
                              color: Colors.grey[200],
                            ),
                            errorWidget: (context, url, error) => Container(
                              width: 76,
                              height: 76,
                              color: Colors.grey[200],
                              child: const Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(item.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              const SizedBox(height: 4),
                              Text(
                                '\$${item.unitPrice.toStringAsFixed(2)}'
                                '${item.priceLabel == null ? '' : ' • ${item.priceLabel}'}',
                                style: const TextStyle(color: Colors.grey),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '~${item.totalCarbonKg.toStringAsFixed(1)} kg CO2e',
                                style: const TextStyle(color: Colors.grey, fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        _QuantityStepper(
                          quantity: item.quantity,
                          onAdd: () {
                            final step = item.priceLabel == 'Group deal' ? 2 : 1;
                            cartModel.addItems(
                              item.product,
                              quantity: step,
                              unitPrice: item.unitPrice,
                              priceLabel: item.priceLabel,
                            );
                          },
                          onRemove: () {
                            final step = item.priceLabel == 'Group deal' ? 2 : 1;
                            for (var i = 0; i < step; i++) {
                              cartModel.removeSingleItem(
                                item.product.id,
                                unitPrice: item.unitPrice,
                                priceLabel: item.priceLabel,
                              );
                            }
                          },
                        ),
                      ],
                    ),
                  );
                },
              );

              final summary = _CartSummaryCard(
                total: cartModel.totalAmount,
                onCheckout: () {
                  cartModel.clearCart();
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Success!'),
                      content: const Text('Thank you for your purchase.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK')),
                      ],
                    ),
                  );
                },
              );

              return maxWidthContainer(
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: isWide
                      ? Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 7,
                              child: Column(
                                children: [
                                  const GreenScorePanel(),
                                  const SizedBox(height: 12),
                                  Expanded(child: list),
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 4,
                              child: Column(
                                children: [
                                  summary,
                                ],
                              ),
                            ),
                            const SizedBox(width: 16),
                          ],
                        )
                      : Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: GreenScorePanel(),
                            ),
                            Expanded(child: list),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                              child: summary,
                            ),
                          ],
                        ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  final int quantity;
  final VoidCallback onAdd;
  final VoidCallback onRemove;

  const _QuantityStepper({
    required this.quantity,
    required this.onAdd,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: onAdd,
            visualDensity: VisualDensity.compact,
          ),
          Text('$quantity', style: const TextStyle(fontWeight: FontWeight.bold)),
          IconButton(
            icon: const Icon(Icons.remove),
            onPressed: onRemove,
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _CartSummaryCard extends StatelessWidget {
  final double total;
  final VoidCallback onCheckout;

  const _CartSummaryCard({
    required this.total,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              Text(
                '\$${total.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: onCheckout,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2A2D3E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: const Text('Checkout', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
        centerTitle: true,
        actions: const [ThemeModeAction()],
      ),
      body: AnimatedBuilder(
        animation: favoritesModel,
        builder: (context, child) {
          final favorites = mockProducts
              .where((p) => favoritesModel.isFavorite(p.id))
              .toList(growable: false);

          if (favorites.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(color: Colors.grey, fontSize: 18),
                  ),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final product = favorites[index];
              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProductDetailPage(product: product),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.05),
                        spreadRadius: 1,
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: product.imageUrl,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            width: 72,
                            height: 72,
                            color: Colors.grey[200],
                          ),
                          errorWidget: (context, url, error) => Container(
                            width: 72,
                            height: 72,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '\$${product.price.toStringAsFixed(2)}',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        tooltip: 'Remove from favorites',
                        icon: const Icon(Icons.favorite, color: Colors.red),
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          favoritesModel.toggleFavorite(product.id);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class ThemeModeAction extends StatelessWidget {
  const ThemeModeAction({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: themeModel,
      builder: (context, child) {
        final isDark = themeModel.isDark;
        return IconButton(
          tooltip: isDark ? 'Dark mode' : 'Light mode',
          icon: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
          onPressed: () {
            HapticFeedback.selectionClick();
            showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (context) {
                return SafeArea(
                  child: AnimatedBuilder(
                    animation: themeModel,
                    builder: (context, child) {
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text('Appearance'),
                            subtitle: Text(themeModel.isDark ? 'Dark' : 'Light'),
                          ),
                          SwitchListTile(
                            title: const Text('Dark mode'),
                            value: themeModel.isDark,
                            onChanged: (v) async {
                              HapticFeedback.selectionClick();
                              await themeModel.setDark(v);
                            },
                            secondary: Icon(themeModel.isDark ? Icons.dark_mode : Icons.light_mode),
                          ),
                          const SizedBox(height: 8),
                        ],
                      );
                    },
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

// --- WIDGETS ---

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductDetailPage(product: product)),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.05),
                spreadRadius: 1,
                blurRadius: 10,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: product.backgroundColor.withOpacity(0.3),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      width: double.infinity,
                      child: Hero(
                        tag: product.id,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: CachedNetworkImage(
                            imageUrl: product.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: Colors.grey[200],
                            ),
                            errorWidget: (context, url, error) => const Center(
                              child: Icon(Icons.broken_image, color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      top: 8,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: AnimatedBuilder(
                            animation: favoritesModel,
                            builder: (context, child) {
                              final isFav = favoritesModel.isFavorite(product.id);
                              return IconButton(
                                padding: EdgeInsets.zero,
                                visualDensity: VisualDensity.compact,
                                splashRadius: 18,
                                iconSize: 18,
                                icon: Icon(
                                  isFav ? Icons.favorite : Icons.favorite_border,
                                  color: isFav ? Colors.red : Colors.black54,
                                ),
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  favoritesModel.toggleFavorite(product.id);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      left: 10,
                      top: 10,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (product.isSustainable)
                            _ProductBadge(
                              icon: Icons.eco_outlined,
                              label: 'Eco',
                              background: const Color(0xFF0B8F5B),
                            ),
                          const SizedBox(height: 6),
                          const _ProductBadge(
                            icon: Icons.groups_2_outlined,
                            label: 'Group deal',
                            background: Color(0xFF2A2D3E),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '\$${product.price.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color background;

  const _ProductBadge({required this.icon, required this.label, required this.background});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.white),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class FavoritesIconAction extends StatelessWidget {
  const FavoritesIconAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            tooltip: 'Favorites',
            icon: const Icon(Icons.favorite_border),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const FavoritesPage()),
              );
            },
          ),
          Positioned(
            right: 8,
            top: 8,
            child: AnimatedBuilder(
              animation: favoritesModel,
              builder: (context, child) {
                if (favoritesModel.count == 0) return const SizedBox();
                return Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '${favoritesModel.count}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CartIconAction extends StatelessWidget {
  const CartIconAction({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 16.0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.shopping_bag_outlined),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const CartPage()));
            },
          ),
          Positioned(
            right: 8,
            top: 8,
            child: AnimatedBuilder(
              animation: cartModel,
              builder: (context, child) {
                if (cartModel.itemCount == 0) return const SizedBox();
                return Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Text(
                    '${cartModel.itemCount}',
                    style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}