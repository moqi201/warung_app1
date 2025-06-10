class Product {
  final int? id;
  final String name;
  final String brand;
  final int price;
  final int stock;
  final String? image;

  Product({
    this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.stock,
    this.image,
  });

  Map<String, dynamic> toMap() {
    final map = {
      'name': name,
      'brand': brand,
      'price': price,
      'stock': stock,
      'image': image,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      brand: map['brand'],
      price: map['price'],
      stock: map['stock'],
      image: map['image'],
    );
  }
}
