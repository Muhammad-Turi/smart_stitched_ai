import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String? get currentUid => FirebaseAuth.instance.currentUser?.uid;

  Stream<QuerySnapshot> getOrdersStream(String uid) {
    return _db.collection('users').doc(uid).collection('orders')
        .snapshots();
  }
  // Future<void> saveOrder(Map<String, dynamic> orderData) async {
  //   final uid = currentUid;
  //   if (uid == null) return;
  //
  //   await _db.collection('users').doc(uid)
  //       .collection('orders').doc(orderData['orderId'])
  //       .set({
  //     ...orderData,
  //     'createdAt': FieldValue.serverTimestamp(),
  //   }, SetOptions(merge: true));
  // }
  Future<void> saveOrder(Map<String, dynamic> orderData) async {
    final uid = currentUid;
    if (uid == null) return;

    await _db.collection('users').doc(uid)
        .collection('orders').doc(orderData['orderId'])
        .set({
      ...orderData,
      'createdAt': orderData['createdAt'] ?? DateTime.now(),
    }, SetOptions(merge: true));
  }

  Future<void> updateOrder(String orderId, Map<String, dynamic> updates) async {
    final uid = currentUid;
    if (uid == null) return;
    await _db.collection('users').doc(uid)
        .collection('orders').doc(orderId)
        .set(updates, SetOptions(merge: true));
  }

  Stream<QuerySnapshot> getInventoryStream(String uid) {
    return _db.collection('users').doc(uid).collection('inventory').snapshots();
  }
  Future<void> saveInventoryItem(Map<String, dynamic> itemData) async {
    final uid = currentUid;
    if (uid == null) return;

    await _db.collection('users').doc(uid)
        .collection('inventory').doc(itemData['id'])
        .set(itemData);
  }
  Future<QuerySnapshot> getInventorySales(String uid) async {
    return await _db.collection('users').doc(uid).collection('inventory_sales').get();
  }
  Future<void> updateInventoryItem(String id, Map<String, dynamic> data) async {
    final uid = currentUid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).collection('inventory').doc(id).update(data);
  }

  Future<void> deleteInventoryItem(String id) async {
    final uid = currentUid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).collection('inventory').doc(id).delete();
  }

  Future<void> saveInventorySale(Map<String, dynamic> saleData) async {
    final uid = currentUid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).collection('inventory_sales').add({
      ...saleData,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }
  Future<QuerySnapshot> getInventory(String uid) async {
    return await _db.collection('users').doc(uid).collection('inventory').get();
  }
  Stream<QuerySnapshot> getInventorySalesStream(String uid) {
    return _db.collection('users').doc(uid).collection('inventory_sales').snapshots();
  }

  Future<void> saveExpense(Map<String, dynamic> expenseData) async {
    final uid = currentUid;
    if (uid == null) return;
    await _db.collection('users').doc(uid).collection('expenses').add({
      ...expenseData,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<QuerySnapshot> getOrders() async {
    final uid = currentUid;
    if (uid == null) throw Exception("User not logged in");
    return await _db.collection('users').doc(uid).collection('orders').get();
  }
  // Future<int> getLastOrderCount(String uid) async {
  //   try {
  //     final snapshot = await _db
  //         .collection('users')
  //         .doc(uid)
  //         .collection('orders')
  //         .get();
  //
  //     int maxCount = 0;
  //     for (var doc in snapshot.docs) {
  //       String id = doc.id.toString();
  //       if (id.contains('-')) {
  //         int? num = int.tryParse(id.split('-').last);
  //         if (num != null && num > maxCount) {
  //           maxCount = num;
  //         }
  //       }
  //     }
  //     return maxCount;
  //   } catch (e) {
  //     debugPrint("Error getting last order count: $e");
  //     return 0;
  //   }
  // }
  Future<int> getLastOrderCount(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get()
          .timeout(const Duration(seconds: 3));
      if (doc.exists && doc.data() != null) {
        return doc.data()!['lastOrderCount'] ?? 0;
      }
      return 0;
    } catch (e) {
      debugPrint("Error getting last order count: $e");
      return 0;
    }
  }

  Future<QuerySnapshot> getExpenses() async {
    final uid = currentUid;
    if (uid == null) throw Exception("User not logged in");
    return await _db.collection('users').doc(uid).collection('expenses').get();
  }
  Stream<DocumentSnapshot> getUserProfile(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots();
  }
  Future<void> updateOrderCount(String uid, int count) async {
    await _db.collection('users').doc(uid).set({
      'lastOrderCount': count,
    }, SetOptions(merge: true))
        .timeout(const Duration(seconds: 3));
  }
  Future<void> deleteOrder(String orderId, String uid) async {
    await _db
        .collection('users')
        .doc(uid)
        .collection('orders')
        .doc(orderId)
        .delete();
  }
}