import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:rosa/model/product_model.dart';

//Constants
const String appName        = "Rosa's Kitchen";
//Live
// const String serverUrl      = "https://sabzify.pk/";

//Development
//ROSA's Kitchen
const String serverUrl      = "https://phplaravel-552536-2250106.cloudwaysapps.com/";

const String baseUrl        = "${serverUrl}api/";
const String imageUrl       = "${serverUrl}assets/attachment/product/";
const Color lightColor      = Colors.red;
const Color themePrimary    = Colors.red;
const Color themeSecondary  = Colors.purple;
const String helpLine       = "";

const int businessId      = 1;
const colorizeColors = [
  Colors.green,
  Colors.greenAccent,
  themePrimary,
];
const colorizeTextStyle = TextStyle(
  fontSize: 14.0,
  fontWeight: FontWeight.bold
);

//Shared Variables
String configNote = "";
String configExpectedDelivery = "";
int configMinOrder = 0;
bool configGift = false;
String deliveryFee = "0"; //delivery_fee
String freeDeliveryAfter = "0"; //free_delivery_after

String apiToken;
List<Product> sharedProducts = [];
List<Product> sharedProductsSearchResult = [];
//phone

LocationData sharedLocation;

//Profile
String profileName;
String profilePhone;
String profileEmail;
String profileAddress;
String profileWallet;
bool profileIsVerified;



