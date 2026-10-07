import 'package:flutter_app/features/cart/presentation/cart_notifier.dart';
import 'package:flutter_app/features/products/domain/product.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _product = Product(
  id: 1,
  title: 'Product of test',
  description: 'Description of test',
  price: 10,
  rating: 4.5,
  thumbnail: 'https://example.com/img.png',
  category: 'test',
);

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    addTearDown(container.dispose);
  });

  test('Adding a new product makes item with quantity of 1', () {
    container.read(cartProvider.notifier).add(_product);

    final items = container.read(cartProvider);

    expect(items.length, 1);
    expect(items.first.quantity, 1);
  });

  test('Adding the same product again increments its quantity', () {
    container.read(cartProvider.notifier).add(_product);
    container.read(cartProvider.notifier).add(_product);

    final items = container.read(cartProvider);

    expect(items.length, 1);
    expect(items.first.quantity, 2);
  });

  test('Changing the quantity of a product to 0 removes it from the cart', () {
    container.read(cartProvider.notifier).add(_product);
    container.read(cartProvider.notifier).changeQuantity(_product.id, 0);

    final items = container.read(cartProvider);

    expect(items, isEmpty);
  });

  test('total price is calculated correctly', () {
    container.read(cartProvider.notifier).add(_product);
    container.read(cartProvider.notifier).add(_product);

    final total = container.read(cartTotalProvider);

    expect(total, 20);
  });
}
