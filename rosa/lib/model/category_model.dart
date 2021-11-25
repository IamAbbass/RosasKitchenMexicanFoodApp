import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:rosa/config.dart';

Future<List<ProductCategory>> fetchCategories(http.Client client) async {
  String url = "${baseUrl}category?api_token=$apiToken&business_id=$businessId";
  print(url);
  final response = await client.get(url);
  return compute(parseCategories, response.body);
}

List<ProductCategory> parseCategories(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<ProductCategory>((json) => ProductCategory.fromJson(json)).toList();
}

class ProductCategory {
  final int id;
  final String name;
  final String image;
  ProductCategory({this.id, this.name, this.image});
  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['id'] as int,
      name: json['name'] as String,
      image: json['image'] as String,
    );
  }
}