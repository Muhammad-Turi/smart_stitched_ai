class OrderModel {
  final String id;
  final String customerName;
  final String customerPhone;
  final String? fabricBrand;
  final String? fabricColor;
  final Map<String, dynamic> measurements;
  final DateTime orderDate;
  final DateTime deliveryDate;

  final double totalBill;
  final double materialCost;
  double advancePayment;
  String status;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.customerPhone,
    this.fabricBrand,
    this.fabricColor,
    required this.measurements,
    required this.orderDate,
    required this.deliveryDate,
    required this.totalBill,
    this.materialCost = 0.0,
    required this.advancePayment,
    this.status = 'Pending',
  });

  double get orderProfit => totalBill - materialCost;

  double get balanceAmount => totalBill - advancePayment;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'fabricBrand': fabricBrand,
      'fabricColor': fabricColor,
      'measurements': measurements,
      'orderDate': orderDate.toIso8601String(),
      'deliveryDate': deliveryDate.toIso8601String(),
      'totalBill': totalBill,
      'materialCost': materialCost,
      'advancePayment': advancePayment,
      'status': status,
    };
  }
}






























// import 'package:flutter/material.dart';

//
// class OrderModel {
//   final String id;
//   final String customerName;
//   final String customerPhone;
//
//
//   final String? fabricBrand;
//   final String? fabricColor;
//
//   final Map<String, dynamic> measurements;
//
//   final DateTime orderDate;
//   final DateTime deliveryDate;
//
//   final double totalBill;
//    double advancePayment;
//   String status;
//
//   OrderModel({
//     required this.id,
//     required this.customerName,
//     required this.customerPhone,
//     this.fabricBrand,
//     this.fabricColor,
//     required this.measurements,
//     required this.orderDate,
//     required this.deliveryDate,
//     required this.totalBill,
//     required this.advancePayment,
//     this.status = 'Pending',
//   });
//
//   double get balanceAmount => totalBill - advancePayment;
//
//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'customerName': customerName,
//       'customerPhone': customerPhone,
//       'fabricBrand': fabricBrand,
//       'fabricColor': fabricColor,
//       'measurements': measurements,
//       'orderDate': orderDate.toIso8601String(),
//       'deliveryDate': deliveryDate.toIso8601String(),
//       'totalBill': totalBill,
//       'advancePayment': advancePayment,
//       'status': status,
//     };
//   }
// }