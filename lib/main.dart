import 'package:flutter/material.dart';
import 'package:proudcut_listing_app/models/product_model.dart';
import 'package:proudcut_listing_app/repositories/product_repository.dart';
import 'package:proudcut_listing_app/screens/product_details_screen.dart';
import 'package:proudcut_listing_app/widgets/product_card.dart';

void main() {
  runApp(const ProudcutListingApp());
}

class ProudcutListingApp extends StatefulWidget {
  const ProudcutListingApp({super.key, this.loadProducts});

  final Future<List<ProductModel>> Function()? loadProducts;

  @override
  State<ProudcutListingApp> createState() => _ProudcutListingAppState();
}

class _ProudcutListingAppState extends State<ProudcutListingApp> {
  late Future<List<ProductModel>> _productsFuture;
  ProductSort _sort = ProductSort.featured;
  bool _sortMenuOpen = false;
  bool _searchOpen = false;
  int _loadAttempt = 0;
  final TextEditingController _searchController = TextEditingController();
  final Object _searchRegion = Object();

  @override
  void initState() {
    super.initState();
    // Temporary preview of the error screen. Retry still loads the products.
    _productsFuture =
        widget.loadProducts?.call() ??
        Future<List<ProductModel>>.value(const []);
  }

  Future<List<ProductModel>> _loadProducts() {
    return widget.loadProducts?.call() ?? ProductRepository().fetchProducts();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _hideSearch() {
    if (!_searchOpen) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _searchOpen = false);
  }

  void _retry() {
    setState(() {
      _loadAttempt++;
      _productsFuture = _loadProducts();
    });
  }

  List<ProductModel> _sortedProducts(List<ProductModel> products) {
    final sorted = List<ProductModel>.of(products);
    switch (_sort) {
      case ProductSort.featured:
        return sorted;
      case ProductSort.priceLowToHigh:
        sorted.sort((a, b) => a.price.compareTo(b.price));
      case ProductSort.priceHighToLow:
        sorted.sort((a, b) => b.price.compareTo(a.price));
      case ProductSort.ratingHighToLow:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
      case ProductSort.name:
        sorted.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
    }
    return sorted;
  }

  List<ProductModel> _visibleProducts(List<ProductModel> products) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) return _sortedProducts(products);
    final filtered = products
        .where((product) => product.title.toLowerCase().contains(query))
        .toList();
    return _sortedProducts(filtered);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Product Listing',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 8,
          shadowColor: const Color(0x66000000),
          leadingWidth: kToolbarHeight,
          title: const Text('Products'),
          actions: [
            TapRegion(
              groupId: _searchRegion,
              child: IconButton(
                tooltip: 'Search',
                icon: const Icon(Icons.search),
                onPressed: () => setState(() => _searchOpen = !_searchOpen),
              ),
            ),
            IconButton(
              tooltip: 'Sort',
              icon: const Icon(Icons.sort),
              onPressed: () => setState(() => _sortMenuOpen = !_sortMenuOpen),
            ),
          ],
        ),
        body: Column(
          children: [
            if (_sortMenuOpen)
              _SortMenu(
                selected: _sort,
                onSelected: (sort) {
                  setState(() {
                    _sort = sort;
                    _sortMenuOpen = false;
                  });
                },
              ),
            Expanded(
              child: FutureBuilder<List<ProductModel>>(
                future: _productsFuture,
                builder: (context, snapshot) {
                  final Widget child;
                  if (snapshot.connectionState != ConnectionState.done) {
                    child = Center(
                      key: ValueKey('loading-$_loadAttempt'),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Product loading...'),
                        ],
                      ),
                    );
                  } else {
                    final products = snapshot.data;
                    if (snapshot.hasError ||
                        products == null ||
                        products.isEmpty) {
                      child = Center(
                        key: const ValueKey('error'),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const DecoratedBox(
                                decoration: BoxDecoration(
                                  color: Color(0xFFF8D4D4),
                                  shape: BoxShape.circle,
                                ),
                                child: SizedBox(
                                  width: 72,
                                  height: 72,
                                  child: Center(
                                    child: Text(
                                      '!',
                                      style: TextStyle(
                                        color: Color(0xFFE04B4B),
                                        fontSize: 28,
                                        fontWeight: FontWeight.w600,
                                        height: 1,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Failed to load products',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Something went wrong. Please try again.',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Color(0xFF666666)),
                              ),
                              const SizedBox(height: 20),
                              FilledButton(
                                onPressed: _retry,
                                style: FilledButton.styleFrom(
                                  backgroundColor: const Color(0xFF2F6BFF),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 28,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                child: const Text('Retry'),
                              ),
                            ],
                          ),
                        ),
                      );
                    } else {
                      final visibleProducts = _visibleProducts(products);
                      child = Column(
                        key: const ValueKey('products'),
                        children: [
                          if (_searchOpen)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                              child: TapRegion(
                                groupId: _searchRegion,
                                onTapOutside: (_) => _hideSearch(),
                                child: TextField(
                                  controller: _searchController,
                                  autofocus: true,
                                  textInputAction: TextInputAction.search,
                                  decoration: InputDecoration(
                                    hintText: 'Search products',
                                    prefixIcon: const Icon(Icons.search),
                                    suffixIcon: _searchController.text.isEmpty
                                        ? null
                                        : IconButton(
                                            tooltip: 'Clear',
                                            onPressed: () {
                                              _searchController.clear();
                                              setState(() {});
                                            },
                                            icon: const Icon(Icons.close),
                                          ),
                                    isDense: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onChanged: (_) => setState(() {}),
                                ),
                              ),
                            ),
                          Expanded(
                            child: visibleProducts.isEmpty
                                ? const Center(child: Text('No products found'))
                                : NotificationListener<ScrollNotification>(
                                    onNotification: (notification) {
                                      if (_searchOpen &&
                                          notification
                                              is ScrollStartNotification &&
                                          notification.dragDetails != null) {
                                        WidgetsBinding.instance
                                            .addPostFrameCallback((_) {
                                              if (mounted) _hideSearch();
                                            });
                                      }
                                      return false;
                                    },
                                    child: GridView.builder(
                                      physics: const BouncingScrollPhysics(
                                        parent: AlwaysScrollableScrollPhysics(),
                                      ),
                                      padding: const EdgeInsets.all(16),
                                      gridDelegate:
                                          const SliverGridDelegateWithFixedCrossAxisCount(
                                            crossAxisCount: 2,
                                            crossAxisSpacing: 12,
                                            mainAxisSpacing: 12,
                                            childAspectRatio: 0.6,
                                          ),
                                      itemCount: visibleProducts.length,
                                      itemBuilder: (context, index) {
                                        final product = visibleProducts[index];
                                        return RepaintBoundary(
                                          child: ProductCard(
                                            product: product,
                                            onTap: () {
                                              Navigator.of(context).push(
                                                MaterialPageRoute<void>(
                                                  builder: (context) =>
                                                      ProductDetailsScreen(
                                                        product: product,
                                                        products: products,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                          ),
                        ],
                      );
                    }
                  }

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeIn,
                    child: child,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SortMenu extends StatelessWidget {
  const _SortMenu({required this.selected, required this.onSelected});

  final ProductSort selected;
  final ValueChanged<ProductSort> onSelected;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 6,
      shadowColor: const Color(0x33000000),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final sort in ProductSort.values)
            ListTile(
              dense: true,
              title: Text(
                sort.label,
                style: TextStyle(
                  color: sort == selected
                      ? Colors.blue
                      : const Color(0xFF1A1A1A),
                  fontWeight: sort == selected
                      ? FontWeight.w600
                      : FontWeight.w400,
                ),
              ),
              trailing: sort == selected
                  ? const Icon(Icons.check, color: Colors.blue)
                  : null,
              onTap: () => onSelected(sort),
            ),
        ],
      ),
    );
  }
}

enum ProductSort {
  featured('Default'),
  priceLowToHigh('Price: low to high'),
  priceHighToLow('Price: high to low'),
  ratingHighToLow('Rating: high to low'),
  name('Name: A to Z');

  const ProductSort(this.label);

  final String label;
}
