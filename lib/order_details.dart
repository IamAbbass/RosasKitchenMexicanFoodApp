import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:sabzify/model/product_model.dart';
import 'package:sabzify/config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:sabzify/product_view.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

import 'cart.dart';
import 'config.dart';
import 'config.dart';
import 'config.dart';
import 'model/order_model.dart';

class OrderDetails extends StatefulWidget {
  final Order order;
  OrderDetails({this.order});
  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {

  String order_no;
  String order_status;
  String order_message;
  String coupon;
  String payment_method;
  String note;
  String orderTotal;
  String orderDiscount;
  String date;
  int delivery;

  bool _loading   = false;

  var _cartTotalRs = 0;
  var _cartItemCount = 0;
  

  void _calculateTotal(){
    _cartTotalRs = 0;
    _cartItemCount = 0;
    sharedProducts.forEach((p){
      if(p.qty == null || p.qty == 0){
        //ignore
      }else{
        setState(() {
          _cartTotalRs+= (int.parse(p.sale)*p.qty);
          _cartItemCount++;
        });
      }
    });
  }

  @override
  void initState() {
    getOrder();
    super.initState();
  }
  
  var orderJson;
  void getOrder() async{
    setState(() {
        _loading = true;
    });
    String url = "${baseUrl}myorders_details?api_token=$apiToken&order_no=${widget.order.order_no}&business_id=$businessId";
    print(url);
    try{      
      var response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      setState(() {
        orderJson = json.decode(response.body);

        order_no = orderJson['order']['order_no'];
        order_status = orderJson['order']['order_status'];
        order_message = orderJson['order']['order_message'];
        coupon = orderJson['order']['coupon'];
        payment_method = orderJson['order']['payment_method'];
        note = orderJson['order']['note'];
        orderTotal = orderJson['order']['total'].toString();
        orderDiscount = orderJson['order']['discount'].toString();
        date = orderJson['order']['date'].toString();
        delivery = orderJson['delivery'] ?? 0;

        _loading = false;
      });
    }catch(e){
      AwesomeDialog(
      context: context,
      dialogType: DialogType.ERROR,
      animType: AnimType.BOTTOMSLIDE,
        title: "Sorry, an unexpected error occurred!",
        desc: "[error_code: /myorders_details]",
      btnOkOnPress: (){},      
      )..show();

      setState(() {
        _loading = false;
      });
    } 
  } 

  Future<void> _pullRefresh() async {
    getOrder();
  }

  

  List<Widget> orderItems(orderJson){
    List<Widget> _orderItems = []; 

    var details = orderJson['details'];

    details.forEach((element) {

        var image = element['product']['image'];
        var name = element['product']['name'];
        var name_ur = element['product']['name_ur'];
        var name_ru = element['product']['name_ru'];        
        var sale = element['sale'].toString();      
        var qty = element['quantity'].toString();      
        var unit = element['unit'].toString();      
        var discount = element['discount'].toString();

        var itemTotal = element['total'];
        
        _orderItems.add(Container(
          decoration: BoxDecoration(            
            color: Colors.white,            
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              GestureDetector(
                child: Container(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[   
                          Column(
                            children: [                              
                            Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: lightColor, width: 2),
                                    color: Colors.white,
                                    borderRadius: BorderRadius.only(
                                      topLeft: Radius.circular(12),
                                      topRight: Radius.circular(12),
                                      bottomRight: Radius.circular(12),
                                    ),
                                  ),
                                  margin: EdgeInsets.all(2),
                                  padding: EdgeInsets.all(2),
                                  width: 75,  
                                  height: 75,
                                  alignment: Alignment.center,                  
                                  child: CachedNetworkImage(
                                    fit: BoxFit.contain,
                                    placeholder: (context, url) => Center(child: CircularProgressIndicator(),),
                                    imageUrl: "${imageUrl}${image}",
                                  ),
                                ),                                    
                            ],
                          )    ,

                          SizedBox(width: 10),                              
                                                  
                          Flexible(
                            // padding: EdgeInsets.only(left: 10, right: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Align(
                                      alignment: Alignment.centerLeft,                  
                                      child: Text(
                                        "EUR $sale / $unit",
                                        style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(width: 5,),
                                    (discount == "0" || discount == "") ? Container() : Container(
                                      decoration: BoxDecoration(
                                        color: themePrimary,
                                        // border: Border.all(color: lightColor, width: 2),
                                        borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(8),
                                          topLeft: Radius.circular(8),
                                          bottomRight: Radius.circular(8),
                                        ),
                                      ),
                                      margin: EdgeInsets.only(right: 2, top: 2),
                                      padding: EdgeInsets.all(2),                
                                      child: Text(
                                        "EUR ${int.parse(discount)} Off",
                                        style: GoogleFonts.lato(color: Colors.white, fontSize: 12,)
                                      )  
                                                    
                                    ),
                                  ],
                                ),
                                
                                
                                Align(
                                  alignment: Alignment.centerLeft,                  
                                  child: Text(
                                    "${name}",
                                    overflow: TextOverflow.ellipsis,                        
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,  
                                  child: Text(
                                    "${name_ru} (${name_ur})",
                                    overflow: TextOverflow.ellipsis, 
                                    style: GoogleFonts.lato(color: Colors.grey),                       
                                  ),                                         
                                ),
                                
                              ],
                            ),
                          ),
                          // Spacer(),                                    
                          SizedBox(width: 10),  
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                "${qty.toString()} x ${unit.toString()}",
                                style: GoogleFonts.lato(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.end, 
                              ), 
                              Text(
                                  "EUR ${itemTotal}",
                                  overflow: TextOverflow.ellipsis, 
                                  style: GoogleFonts.lato(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.end,                       
                                ),

                            ],
                          )                                 
                                                                                                  
                        ],
                      ),
                       
                    ],
                  )                  
                ),
              ),          
              
            ],
          ),
        ));
    });    
    return _orderItems;
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
          "Order Details",
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

        )
        : SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(12),
          child: Column(
            children: [           
              
                Container(
                  padding: EdgeInsets.all(12),
                  child: Text(order_message ?? '', style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 24, color: themePrimary), textAlign: TextAlign.center,),
                ),
                Divider(),
                Container(                  
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(color: lightColor, width: 2),
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),              
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Order #", style: GoogleFonts.lato(fontSize: 16),),
                          Text(order_no, style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16),),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Order Status:", style: GoogleFonts.lato(fontSize: 16),),
                          Text(order_status, style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16),),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Date:", style: GoogleFonts.lato(fontSize: 16),),
                          Text(date, style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16),),
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("Payment:", style: GoogleFonts.lato(fontSize: 16),),
                          Text(payment_method, style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 16),),
                        ],
                      ),
                                            
                    ],
                  ),
                ),
                SizedBox(height: 5,),
                Divider(),
                SizedBox(height: 5,),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Order Details", style: GoogleFonts.lato(color: themePrimary, fontWeight: FontWeight.bold, fontSize: 18),),
                ),
                _loading ? LinearProgressIndicator() : Container(                  
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    border: Border.all(color: lightColor, width: 2),
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),              
                  child: Column(
                    children: orderItems(orderJson),
                  ),
                ),

                SizedBox(height: 5,),
                Divider(),
                SizedBox(height: 5,),

               Row(
                  children: [
                    Text("Subtotal", style: GoogleFonts.lato(),),
                    Spacer(),
                    Row(
                      children: [
                        Text(
                          "EUR ${int.parse(orderTotal)+int.parse(orderDiscount)}",
                          style: GoogleFonts.lato(color: Colors.black,)
                        )             
                      ],                                  
                    )
                  ]
                ),
                SizedBox(height: 1),
                Row(
                  children: [
                    Text("Discount", style: GoogleFonts.lato(),),
                    Spacer(),
                    Container(
                      decoration: BoxDecoration(
                        color: themePrimary,
                        // border: Border.all(color: lightColor, width: 2),
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(8),
                          topLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      padding: EdgeInsets.all(2),                
                      child: Row(
                        children: [
                          Icon(Icons.remove, color: Colors.white),
                          SizedBox(width: 5),
                          Text(
                            "EUR ${orderDiscount}",
                            style: GoogleFonts.lato(color: Colors.white)
                          )             
                        ],                                  
                      )                                    
                    ),  
                  ]
                ),
                SizedBox(height: 1),
                Row(
                  children: [
                    Text("Delivery fee", style: GoogleFonts.lato(),),
                    Spacer(),
                    Row(
                      children: [
                        Text("EUR $delivery",style: GoogleFonts.lato(color: Colors.black, )),
                      ],
                    )
                  ]
                ),
                SizedBox(height: 1),
                Row(
                  children: [
                    Text("VAT", style: GoogleFonts.lato(),),
                    Spacer(),
                    Row(
                      children: [
                        Text(
                          "EUR 0",
                          style: GoogleFonts.lato(color: Colors.black, )
                        )
                      ],
                    )
                  ]
                ),
                SizedBox(height: 1),
                // Row(
                //   children: [
                //     Text("Extra", style: GoogleFonts.lato(),),
                //     Spacer(),
                //     Container(
                //       decoration: BoxDecoration(
                //         color: themePrimary,
                //         // border: Border.all(color: lightColor, width: 2),
                //         borderRadius: BorderRadius.only(
                //           topRight: Radius.circular(8),
                //           topLeft: Radius.circular(8),
                //           bottomRight: Radius.circular(8),
                //         ),
                //       ),
                //       padding: EdgeInsets.all(2),                
                //       child: Row(
                //         children: [
                //           Icon(Icons.card_giftcard, color: Colors.white),
                //           SizedBox(width: 5),
                //           Text(
                //             "Gift Included",
                //             style: GoogleFonts.lato(color: Colors.white,)
                //           )             
                //         ],                                  
                //       )                                    
                //     ),                    
                //   ]
                // ),
                Divider(),
                Row(
                  children: [
                    Text("Total", style: GoogleFonts.lato(fontSize: 18,fontWeight: FontWeight.bold),),
                    Spacer(),
                    Row(
                      children: [
                        Text(
                          "EUR ${orderTotal}",
                          style: GoogleFonts.lato(color: Colors.black,fontWeight: FontWeight.bold, fontSize: 18)
                        )             
                      ],                                  
                    )
                  ]
                ),
            ],
          ), 
        )
      ), 
      ), 
      bottomNavigationBar: _loading ? Container(height: 0, width: 0,) : Container(
        color: Colors.transparent,
        height: 60,
        margin: EdgeInsets.all(6),
        child: RaisedButton(
          padding: EdgeInsets.all(12),
          color: themePrimary,
          onPressed: (){
            //Temp List
            List<int> _tempProductId  = List<int>();
            List<int> _tempQty        = List<int>();
            var details = orderJson['details'];
            details.forEach((element) {
              var id  = element['product']['id'];
              var qty = element['quantity'];
              _tempProductId.add(id);
              _tempQty.add(qty);
            });

            //Add to Cart
            sharedProducts.forEach((p){
              if(_tempProductId.contains(p.id)){
                int index = _tempProductId.indexOf(p.id);
                int qty   = _tempQty[index];
                setState(() {
                  p.qty = qty;
                });
              }
            });  


            AwesomeDialog(
            context: context,
            dialogType: DialogType.SUCCES,
            animType: AnimType.BOTTOMSLIDE,
            title: "Added To Cart",
            desc: "Review your cart and place order",
            btnOkOnPress: (){},      
            )..show().then((value){
              Navigator.pop(context);
              Navigator.pop(context);
              Navigator.push(context,MaterialPageRoute(builder: (BuildContext context) =>
              Cart())).then((value){ 
                //sync with previous screen
                setState(() {
                  sharedProducts = sharedProducts;
                });
                _calculateTotal();
                FocusScope.of(context).requestFocus(FocusNode());
              });
            });     

                 
          },
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [  
              Text("Reorder",style: GoogleFonts.lato(color: Colors.white,fontSize: 16,),),
            ],
          )         
        ),
      ),      
    );
  }
}