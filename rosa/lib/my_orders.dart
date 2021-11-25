import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:rosa/model/product_model.dart';
import 'package:rosa/config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rosa/product_view.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

import 'config.dart';
import 'model/order_model.dart';
import 'order_details.dart';

class MyOrders extends StatefulWidget {
  @override
  _MyOrdersState createState() => _MyOrdersState();
}

class _MyOrdersState extends State<MyOrders> {
  bool _loading   = true;

  @override
  void initState() {
    loadOrders();
    super.initState();
  }

  List<Order> orders = [];
  void loadOrders() async{  
    setState(() {
      _loading   = true;
    }); 
    
    List<Order> _temp = await fetchMyOrders(http.Client());    
    setState((){
      _loading = false;
      orders = _temp;
    });
  }

  Future<void> _pullRefresh() async { 
     
    loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        // elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
          color: Colors.black,
          tooltip: 'Back',
        ),
        title: Text(
          "My Orders",
          style: GoogleFonts.lato(color: Colors.black,),
        ),
      ),
      body: RefreshIndicator(
      onRefresh: _pullRefresh,
      child: _loading ?  
        Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              
              CircularProgressIndicator(),
              SizedBox(height: 5),
              Center(
                child: Text("Please wait .. ", style: GoogleFonts.lato(color: Colors.grey, fontSize: 18),),
              ),              
              
            ],
          ),

        ):(orders.length > 0) ?
          ListView.separated(
          separatorBuilder: (context, index) => Divider(),
          itemBuilder: (context, index){

            return ListTile(
              leading: Icon(Icons.shopping_bag_outlined, color: themePrimary, size: 32,),
              title: Text("${orders[index].order_status ?? ''} - ${orders[index].order_no ?? ''}"),
              subtitle: Text(orders[index].date ?? ''),
              trailing: Text("EUR ${orders[index].total ?? ''}", style: TextStyle(color: themePrimary, fontWeight: FontWeight.bold, fontSize: 16),),
              onTap: (){
                Navigator.push(context,MaterialPageRoute(builder: (BuildContext context) => OrderDetails(order: orders[index],)));
              },
            );
          },
          itemCount: orders.length
        ) : Container(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_bag_outlined, color: themePrimary, size: 74,),
              SizedBox(height: 10),
              Text("No Orders!", style: GoogleFonts.lato(color: themePrimary, fontWeight: FontWeight.bold, fontSize: 24),),
              SizedBox(height: 5),
              SizedBox(
                width: 250,
                child: Text("Looks like you haven't ordered anything yet", style: GoogleFonts.lato(color: Colors.grey, fontSize: 18), textAlign: TextAlign.center,),
              ),
              Container(
                margin: EdgeInsets.all(12),
                child: RaisedButton(
                  padding: EdgeInsets.all(12),
                  color: themePrimary,
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text("Go Back",style: GoogleFonts.lato(color: Colors.white,fontSize: 16),),
                ),
              )
            ],
          ),
        ),

      )
      ),
    );
  }
}