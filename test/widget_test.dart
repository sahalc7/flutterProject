import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:proudcut_listing_app/main.dart';
import 'package:proudcut_listing_app/models/product_model.dart';
import 'package:proudcut_listing_app/widgets/product_card.dart';

void main() {
  testWidgets('shows Product loading... while products are loading', (
    WidgetTester tester,
  ) async {
    final products = Completer<List<ProductModel>>();
    await tester.pumpWidget(
      ProudcutListingApp(loadProducts: () => products.future),
    );

    expect(find.text('Product loading...'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    products.complete(const []);
    await tester.pumpAndSettle();
  });

  testWidgets('shows the failure screen and retries loading', (
    WidgetTester tester,
  ) async {
    var attempts = 0;
    final firstLoad = Completer<List<ProductModel>>();
    final retryLoad = Completer<List<ProductModel>>();

    await tester.pumpWidget(
      ProudcutListingApp(
        loadProducts: () {
          attempts++;
          return attempts == 1 ? firstLoad.future : retryLoad.future;
        },
      ),
    );

    firstLoad.completeError(Exception('offline'));
    await tester.pumpAndSettle();

    expect(find.text('Failed to load products'), findsOneWidget);
    expect(
      find.text('Something went wrong. Please try again.'),
      findsOneWidget,
    );
    expect(find.text('Retry'), findsOneWidget);

    await tester.tap(find.text('Retry'));
    await tester.pump();

    expect(find.text('Product loading...'), findsOneWidget);
    expect(attempts, 2);

    retryLoad.complete(const []);
    await tester.pumpAndSettle();
  });

  testWidgets('shows every product title and price from the response', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProudcutListingApp(
        loadProducts: () => Future.value(const [
          ProductModel(
            id: 1,
            title: 'Nike Air Max 270 Running Shoes',
            price: 299.99,
            description: 'Running shoes',
            imageUrl: '',
            rating: 4.5,
            category: 'fashion',
          ),
          ProductModel(
            id: 2,
            title: 'Apple iPhone 14',
            price: 999,
            description: 'Phone',
            imageUrl: '',
            rating: 3,
            category: 'fashion',
          ),
        ]),
      ),
    );
    await tester.pump();

    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Nike Air Max 270 Running Shoes'), findsOneWidget);
    expect(find.text('\$299.99'), findsOneWidget);
    expect(find.text('4.5'), findsOneWidget);
    expect(find.byIcon(Icons.star_half), findsOneWidget);
    expect(find.text('Apple iPhone 14'), findsOneWidget);
    expect(find.text('\$999.00'), findsOneWidget);

    await tester.tap(find.byType(ProductCard).first);
    await tester.pumpAndSettle();

    expect(find.text('Product Details'), findsOneWidget);
    expect(find.text('Running shoes'), findsOneWidget);
    expect(find.text('Phone'), findsNothing);
    expect(find.text('Related products'), findsOneWidget);
    expect(find.text('Apple iPhone 14'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    expect(find.text('Products'), findsOneWidget);
    expect(find.text('Product Details'), findsNothing);
  });

  testWidgets('sorts products by price from high to low', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProudcutListingApp(
        loadProducts: () => Future.value(const [
          ProductModel(
            id: 1,
            title: 'Nike Air Max 270 Running Shoes',
            price: 299.99,
            description: 'Running shoes',
            imageUrl: '',
            rating: 4.5,
          ),
          ProductModel(
            id: 2,
            title: 'Apple iPhone 14',
            price: 999,
            description: 'Phone',
            imageUrl: '',
            rating: 3,
          ),
        ]),
      ),
    );
    await tester.pump();

    expect(
      tester.widget<ProductCard>(find.byType(ProductCard).first).product.title,
      'Nike Air Max 270 Running Shoes',
    );

    await tester.tap(find.byIcon(Icons.sort));
    await tester.pumpAndSettle();
    expect(find.text('Price: low to high'), findsOneWidget);
    await tester.tap(find.text('Price: high to low'));
    await tester.pumpAndSettle();

    expect(
      tester.widget<ProductCard>(find.byType(ProductCard).first).product.title,
      'Apple iPhone 14',
    );
  });

  testWidgets('filters the grid by the search text', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProudcutListingApp(
        loadProducts: () => Future.value(const [
          ProductModel(
            id: 1,
            title: 'Nike Air Max 270 Running Shoes',
            price: 299.99,
            description: 'Running shoes',
            imageUrl: '',
            rating: 4.5,
          ),
          ProductModel(
            id: 2,
            title: 'Apple iPhone 14',
            price: 999,
            description: 'Phone',
            imageUrl: '',
            rating: 3,
          ),
        ]),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.search));
    await tester.pump();
    await tester.enterText(find.byType(TextField), 'iphone');
    await tester.pump();

    expect(find.text('Apple iPhone 14'), findsOneWidget);
    expect(find.text('Nike Air Max 270 Running Shoes'), findsNothing);

    await tester.tap(find.text('Products'));
    await tester.pump();
    expect(find.byType(TextField), findsNothing);

    await tester.tap(find.byTooltip('Search'));
    await tester.pump();
    expect(find.byType(TextField), findsOneWidget);

    await tester.drag(find.byType(GridView), const Offset(0, -80));
    await tester.pump();
    expect(find.byType(TextField), findsNothing);
  });

  testWidgets('product card shows a hover and tap effect', (
    WidgetTester tester,
  ) async {
    var taps = 0;
    const product = ProductModel(
      id: 1,
      title: 'Nike Air Max 270 Running Shoes',
      price: 299.99,
      description: 'Running shoes',
      imageUrl: '',
      rating: 4.5,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 180,
            height: 260,
            child: ProductCard(product: product, onTap: () => taps++),
          ),
        ),
      ),
    );

    final card = find.byType(ProductCard);
    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);
    await tester.pump();
    await gesture.moveTo(tester.getCenter(card));
    await tester.pump();

    await tester.tap(card);
    await tester.pump();

    expect(taps, 1);
  });
}
