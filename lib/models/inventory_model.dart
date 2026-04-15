import 'package:flutter/material.dart';

class SmartInventoryItem {
  final String id;
  final String brand;
  final String category;
  final double quantity;
  final Color itemColor;
  final String customColorName;
  final String unit;
  final DateTime dateAdded;

  final double buyingPrice;
  final double initialPrice;
  final double? pricePerUnit;

  SmartInventoryItem({
    required this.id,
    required this.brand,
    required this.category,
    required this.quantity,
    required this.itemColor,
    required this.customColorName,
    required this.unit,
    required this.buyingPrice,
    required this.initialPrice,
    required this.dateAdded,
    this.pricePerUnit,
  });

  int get estimatedSuits => (unit == "Mtr") ? (quantity / 4.5).floor() : 0;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'brand': brand,
      'category': category,
      'quantity': quantity,
      'itemColor': itemColor.value,
      'customColorName': customColorName,
      'unit': unit,
      'buyingPrice': buyingPrice,
      'initialPrice': initialPrice,
      'pricePerUnit': pricePerUnit,
      'dateAdded': dateAdded.toIso8601String(),
    };
  }

  factory SmartInventoryItem.fromMap(Map<String, dynamic> map) {
    return SmartInventoryItem(
      id: map['id'] ?? '',
      brand: map['brand'] ?? '',
      category: map['category'] ?? '',
      quantity: (map['quantity'] as num).toDouble(),
      itemColor: Color(map['itemColor']),
      customColorName: map['customColorName'] ?? '',
      unit: map['unit'] ?? '',
      buyingPrice: (map['buyingPrice'] as num).toDouble(),
      initialPrice: (map['initialPrice'] as num).toDouble(),
      pricePerUnit: map['pricePerUnit'] != null ? (map['pricePerUnit'] as num).toDouble() : null,
      dateAdded: DateTime.parse(map['dateAdded']),
    );
  }

}