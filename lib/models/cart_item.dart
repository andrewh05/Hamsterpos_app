import 'menu_item.dart';

class CartItem {
  final MenuItem menuItem;
  int quantity;
  String? notes;
  String? sku;
  int priceLevel;
  String? attributeSetInstanceId;

  CartItem({
    required this.menuItem,
    this.quantity = 1,
    this.notes,
    this.sku,
    this.priceLevel = 0,
    this.attributeSetInstanceId,
  });

  double get totalPrice => menuItem.price * quantity;
  double get lineTotal => menuItem.price * quantity;
}
