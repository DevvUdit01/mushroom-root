class OrderItem {
  final String productId;
  final String productName;
  final String productImage;
  final double price;
  final int quantity;
  final String unit;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.productImage,
    required this.price,
    required this.quantity,
    required this.unit,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    final prod = json['productId'];
    String name = '';
    String image = '';
    double price = (json['price'] ?? 0).toDouble();
    String unit = '';

    if (prod is Map<String, dynamic>) {
      name = prod['productName'] ?? '';
      final imgs = prod['images'];
      if (imgs is List && imgs.isNotEmpty) {
        image = imgs[0].toString().replaceAll('\\', '/');
        if (!image.startsWith('http')) {
          image = 'http://192.168.1.15:5000/$image';
        }
      }
      price = ((prod['sellingPrice'] ?? prod['mrpPrice'] ?? json['price']) as num).toDouble();
      unit = prod['unit'] ?? '';
    }

    return OrderItem(
      productId: (prod is Map) ? (prod['_id'] ?? '') : (prod?.toString() ?? ''),
      productName: name,
      productImage: image,
      price: price,
      quantity: (json['quantity'] as num?)?.toInt() ?? 1,
      unit: unit,
    );
  }
}

class AppOrder {
  final String id;
  final String vendorName;
  final String vendorImage;
  final List<OrderItem> items;
  final double totalAmount;
  final double deliveryCharge;
  final String orderStatus;
  final String paymentMethod;
  final String paymentStatus;
  final DateTime createdAt;

  AppOrder({
    required this.id,
    required this.vendorName,
    required this.vendorImage,
    required this.items,
    required this.totalAmount,
    required this.deliveryCharge,
    required this.orderStatus,
    required this.paymentMethod,
    required this.paymentStatus,
    required this.createdAt,
  });

  int get totalItemCount => items.fold(0, (sum, i) => sum + i.quantity);

  factory AppOrder.fromJson(Map<String, dynamic> json) {
    final vendor = json['vendorId'];
    String vendorName = 'Unknown Store';
    String vendorImage = '';
    if (vendor is Map<String, dynamic>) {
      vendorName = vendor['shopName'] ?? 'Unknown Store';
      vendorImage = vendor['shopImage'] ?? '';
    }

    final List<dynamic> rawItems = json['products'] ?? [];
    final items = rawItems.map((p) => OrderItem.fromJson(p as Map<String, dynamic>)).toList();

    return AppOrder(
      id: json['_id'] ?? '',
      vendorName: vendorName,
      vendorImage: vendorImage,
      items: items,
      totalAmount: ((json['totalAmount'] ?? 0) as num).toDouble(),
      deliveryCharge: ((json['deliveryCharge'] ?? 0) as num).toDouble(),
      orderStatus: json['orderStatus'] ?? 'pending',
      paymentMethod: json['paymentMethod'] ?? 'cod',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
