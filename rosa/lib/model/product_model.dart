import 'dart:async';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:rosa/config.dart';

Future<List<Product>> fetchProducts(http.Client client, categoryId) async {
  if(categoryId == null){
    String url = "${baseUrl}product?api_token=$apiToken&business_id=$businessId";  
    print(url);  
    final response = await client.get(url);
    return compute(parseProducts, response.body);
  }else{
    String url = "${baseUrl}category/$categoryId?api_token=$apiToken&business_id=$businessId";
    print(url);
    final response = await client.get(url);
    return compute(parseProducts, response.body);
  }
}

List<Product> parseProducts(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Product>((json) => Product.fromJson(json)).toList();
}

class Product {
  final int id;
  //final String sku; //not in use
  final String badge; //Default ?
  final String type; //Default ? not in use
  final String category; //Vegetables ? 
  final String image;
  final String name;
  final String name_ur;
  final String name_ru;
  final String unit;
  final String sale;
  final String discount;
  final String description;
  final String dated;
  int qty;

  Product({this.id, this.badge, this.type, this.category, this.image, this.name, this.name_ur, this.name_ru,  this.unit, this.sale, this.discount, this.description, this.dated});
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
        id: json['id'] as int,
        badge: json['badge'] as String,
        type: json['type'] as String,
        category: json['category'] as String,
        image: json['image'] as String,
        name: json['name'] as String,
        name_ur: json['name_ur'] as String,
        name_ru: json['name_ru'] as String,        
        unit: json['unit'].toString() as String,
        sale: json['sale'].toString() as String,
        discount: json['discount'].toString() as String,
        description: json['description'] as String,
        dated: json['dated'] as String,
    );
  }
}

