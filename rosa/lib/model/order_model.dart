import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:rosa/config.dart';


Future<List<Order>> fetchMyOrders(http.Client client) async {
  String url = "${baseUrl}myorders?api_token=$apiToken&business_id=$businessId";    
  print(url);
  final response = await client.get(url);
  return compute(parseOrders, response.body);
}

List<Order> parseOrders(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Order>((json) => Order.fromJson(json)).toList();
}

class Order {
  final String order_no;
  final String order_status;
  final String order_message;
  final String coupon;
  final String payment_method;
  final String note;
  final String discount;
  final String total;
  final String date;

  Order({this.order_no, this.order_status, this.order_message, this.coupon, this.payment_method, this.note, this.discount, this.total, this.date});

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
        order_no: json['order_no'] as String,
        order_status: json['order_status'] as String,
        order_message: json['order_message'] as String,
        coupon: json['coupon'] as String,
        payment_method: json['payment_method'] as String,
        note: json['note'] as String,
        discount: json['discount'].toString() as String,     
        total: json['total'].toString() as String,
        date: json['date'].toString() as String,
    );
  }
}

