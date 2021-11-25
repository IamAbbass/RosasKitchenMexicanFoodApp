import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:rosa/checkout.dart';
import 'package:rosa/model/product_model.dart';
import 'package:rosa/config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rosa/product_view.dart';
import 'package:google_fonts/google_fonts.dart';

class Cart extends StatefulWidget {
  @override
  _CartState createState() => _CartState();
}

class _CartState extends State<Cart> {

  var _cartTotalRs = 0;
  var _grandTotalRs = 0;
  var _cartTotalDiscount = 0;
  var _cartItemCount = 0;
  bool _freeDelivery = false;
  var _moreForFreeDelivery = 0;
  var _moreForFreeDeliveryBar = 0.0;
  

  void _calculateTotal(){
    _cartTotalRs = 0;
    _cartItemCount = 0;
    _cartTotalDiscount = 0;
    sharedProducts.forEach((p){
      if(p.qty == null || p.qty == 0){
        //ignore

      }else{
        setState(() {

          if(p.discount != null && p.discount != "0"){
            _cartTotalDiscount = _cartTotalDiscount + (int.parse(p.discount)*p.qty);
          }

          _cartTotalRs+= (int.parse(p.sale)*p.qty);
          _cartItemCount++;
        });
      }
    });

    if(_cartTotalRs < int.parse(freeDeliveryAfter)){
      setState(() {
        _grandTotalRs = _cartTotalRs+int.parse(deliveryFee);        _freeDelivery = false;
        _moreForFreeDelivery = int.parse(freeDeliveryAfter) - _cartTotalRs;
        _moreForFreeDeliveryBar = ((_cartTotalRs*100)/int.parse(freeDeliveryAfter))/100;
      });

    }else{
      setState(() {
        _grandTotalRs = _cartTotalRs;
        _freeDelivery = true;
      });
    }
  }

  @override
  void initState() {
    _calculateTotal();
    super.initState();
  }

  List<Widget> _cartItems(){
    List<Widget> cartItems = []; 
    sharedProducts.forEach((element) {

      if(element.qty == null || element.qty == 0){
        
      }else{
        cartItems.add(Container(
          decoration: BoxDecoration(
            border: Border.all(color: lightColor, width: 2),
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(12),
              topRight: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Stack(
            alignment: Alignment.topCenter,
            children: <Widget>[
              GestureDetector(
                child: Container(
                  padding: EdgeInsets.only(left: 6, right: 6),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        // mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[   
                          Column(
                            children: [                              
                            Hero(
                                tag: element.id.toString(),
                                child: Container(
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
                                    imageUrl: "$imageUrl${element.image}",
                                  ),
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
                                        "EUR ${element.sale} / ${element.unit}",
                                        style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    SizedBox(width: 5,),
                                    (element.discount == "0" || element.discount == "") ? Container() : Container(
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
                                        "EUR ${int.parse(element.discount)} Off",
                                        style: GoogleFonts.lato(color: Colors.white, fontSize: 12,)
                                      )  
                                                    
                                    ),
                                  ],
                                ),
                                
                                
                                Align(
                                  alignment: Alignment.centerLeft,                  
                                  child: Text(
                                    "${element.name}",
                                    overflow: TextOverflow.ellipsis,                        
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.centerLeft,  
                                  child: Text(
                                    "${element.name_ru} (${element.name_ur})",
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
                                "${element.qty.toString()} x ${element.unit.toString()}",
                                style: GoogleFonts.lato(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.end, 
                              ), 
                              (element.qty == null || element.qty == 0) ? Container() :Text(
                                  "EUR ${element.qty*int.parse(element.sale)}",
                                  overflow: TextOverflow.ellipsis, 
                                  style: GoogleFonts.lato(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16), textAlign: TextAlign.end,                       
                                ),

                            ],
                          ) 
                              
                                                              
                                                                                                  
                        ],
                      ),
                      Container(   
                        child:                                   
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: <Widget>[                               
                          (element.qty == null || element.qty == 0) ? Container() : RaisedButton(
                            onPressed: (){
                              setState(() {                          
                                element.qty = 0;                                                  
                              });
                              _calculateTotal();
                            },
                            color: Colors.white,
                            textColor: Colors.redAccent,
                            child: Row(
                              children: [
                                Icon(Icons.delete,size: 30,),
                                // Text("Delete"),
                              ],
                            ),
                          ),  
                          Spacer(),
                          (element.qty == null || element.qty == 0) ? Container() : RaisedButton(
                            onPressed: (){
                              if(element.qty > 0){
                                setState(() {                          
                                  (element.qty == null) ? element.qty = 0 : element.qty--;                                                       
                                });
                                _calculateTotal();
                              }
                            },
                            color: Colors.white,
                            textColor: Colors.redAccent,
                            child: Row(
                              children: [                                
                                Icon(Icons.remove,size: 30,),
                                // Text("Minus"),
                              ],
                            ),
                          ),
                          (element.qty == null || element.qty == 0)  ? Container() : SizedBox(width: 5,),
                          (element.qty == null || element.qty == 0)  ? Container() : RaisedButton(
                            onPressed: (){
                              setState(() {
                                (element.qty == null) ? element.qty = 1 : element.qty++;                      
                              });
                              _calculateTotal();
                            },
                            color: themePrimary,
                            textColor: Colors.white,
                            child: Row(
                              children: [                                
                                Icon(Icons.add,size: 30,),
                                // Text("Add more"),
                              ],
                            ),
                          ),
                          (element.qty == null || element.qty == 0)  ? Align(
                            alignment: Alignment.centerRight,
                            child: RaisedButton(
                            onPressed: (){
                              setState(() {
                                (element.qty == null) ? element.qty = 1 : element.qty++;                      
                              });
                              _calculateTotal();
                            },
                            color: themePrimary,
                            textColor: Colors.white,
                            child: Row(
                              children: [                                
                                Icon(Icons.add,size: 30,),
                                Text("Add to cart"),
                              ],
                            ),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(color: themePrimary)
                            ),
                          ),
                          ) : Container(),
                                          
                        ],
                      ),   
                      ),
                    ],
                  )                  
                ),
                onTap: (){
                  Navigator.push(context,MaterialPageRoute(builder: (BuildContext context) =>
                  ProductView(product: element,))).then((value){ 
                    //sync with previous screen
                    setState(() {
                      sharedProducts = sharedProducts;
                    });
                    _calculateTotal();
                  });
                },
              ),          
              
            ],
          ),
        ));
      }  
    });    
    return cartItems;
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
          "Cart",
          style: GoogleFonts.lato(color: Colors.black,),
        ),
      ),
      body: _cartItemCount == 0 ? Container(
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,            
            children: [
              Badge(
                showBadge: true,
                badgeColor: themePrimary,
                badgeContent: Text("0", style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),),
                child: Icon(Icons.shopping_bag_outlined, color: themePrimary, size: 74,),
                animationType: BadgeAnimationType.slide,
              ),
              SizedBox(height: 10),
              Text("Your Cart is Empty", style: GoogleFonts.lato(color: themePrimary, fontWeight: FontWeight.bold, fontSize: 24),),
              SizedBox(height: 5),
              SizedBox(
                width: 250,
                child: Text("Looks like you haven't added anything to cart", style: GoogleFonts.lato(color: Colors.grey, fontSize: 18), textAlign: TextAlign.center,),
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

      ) : SingleChildScrollView(
        child: Container(
            margin: EdgeInsets.all(8),
           child: Column(
              children: [
                Container(
                  
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: lightColor, width: 2),
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),              
                  child: Row(
                    // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.electric_moped_outlined, color: themePrimary, size: 56,),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Estimated Delivery", style: GoogleFonts.lato(color: Colors.grey),),
                          Text(configExpectedDelivery ?? '', style: GoogleFonts.lato(color: themePrimary, fontWeight: FontWeight.bold, fontSize: 18),),        
                          Row(
                            children: [
                              Icon(Icons.speed_rounded, color: themePrimary,),
                              SizedBox(width: 5),
                              Container(
                                width: MediaQuery.of(context).size.width-150,
                                child: Text(configNote ?? '', style: GoogleFonts.lato(color: themePrimary, fontWeight: FontWeight.bold),),
                              ),
                            ],
                          ),     
                        ],
                      )
                    ],
                  )
                ),
                Divider(),
                Align(
                    alignment: Alignment.centerLeft,
                    child: Text("$_cartItemCount Item${_cartItemCount > 1 ? 's' : ''} in cart,", style: GoogleFonts.lato(color: themePrimary, fontWeight: FontWeight.bold, fontSize: 18),),
                  ),
                Column(
                  children: _cartItems(),
                ),
                Divider(),

                Row(
                  children: [
                    Text("Subtotal", style: GoogleFonts.lato(),),
                    Spacer(),
                    Row(
                      children: [
                        Text(
                          "EUR ${_cartTotalRs+_cartTotalDiscount}",
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
                          Icon(Icons.remove, color: Colors.white, size: 15),
                          SizedBox(width: 5),
                          Text(
                            "EUR $_cartTotalDiscount",
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
                    (_cartTotalRs < int.parse(freeDeliveryAfter)) ?
                    Row(
                      children: [
                        Text(
                            "EUR $deliveryFee",
                            style: GoogleFonts.lato(color: Colors.black, )
                        )
                      ],
                    ):
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
                            Text(
                                "Free",
                                style: GoogleFonts.lato(color: Colors.white)
                            )
                          ],
                        )
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
                configGift ? Row(
                  children: [
                    Text("Extra", style: GoogleFonts.lato(),),
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
                          Icon(Icons.card_giftcard, color: Colors.white, size: 15),
                          SizedBox(width: 5),
                          Text(
                            "Gift Included",
                            style: GoogleFonts.lato(color: Colors.white,)
                          )             
                        ],                                  
                      )                                    
                    ),                    
                  ]
                ) : Container(height: 0, width: 0,),
                Divider(),
                Row(
                  children: [
                    Text("Total", style: GoogleFonts.lato(fontSize: 18,fontWeight: FontWeight.bold),),
                    Spacer(),
                    Row(
                      children: [
                        Text("EUR $_grandTotalRs",
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
      bottomNavigationBar: _cartItemCount == 0 ? Container(height: 0, width: 0,) : Container(
        color: Colors.transparent,
        height: 80,
        margin: EdgeInsets.all(6),
        child: RaisedButton(
          disabledColor: Colors.grey,
          padding: EdgeInsets.all(6),
          color: themePrimary,
          onPressed: (){
            if(_cartTotalRs < (configMinOrder ?? 300)){
              AwesomeDialog(
              context: context,
              dialogType: DialogType.ERROR,
              animType: AnimType.BOTTOMSLIDE,
              title: "Minimum Order EUR $configMinOrder",
              desc: "",
              btnOkOnPress: (){},      
              )..show();
            }else{
              Navigator.push(context,MaterialPageRoute(builder: (BuildContext context) =>
              CheckOut())).then((value){ 
                //sync with previous screen
                setState(() {
                  sharedProducts = sharedProducts;
                });
                _calculateTotal();
              });
            }            
          },
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child:
                _freeDelivery ? Text("🥳 You've got free delivery !", style: GoogleFonts.lato(color: Colors.white,fontSize: 14,),) :
                Text("EUR $_moreForFreeDelivery more to get EUR $deliveryFee off delivery fee", style: GoogleFonts.lato(color: Colors.white,fontSize: 14,),),
              ),
              SizedBox(height: 5),
              _freeDelivery ? Container(height: 0, width: 0) : LinearProgressIndicator(
                backgroundColor: Colors.green,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                value: _moreForFreeDeliveryBar,
              ),
              Divider(),
              Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Badge(
                    showBadge: (_cartItemCount > 0),
                    badgeColor: Colors.white,
                    badgeContent: Text(_cartItemCount.toString(), style: TextStyle(color: themePrimary,),),
                    child: Icon(Icons.shopping_bag_outlined, color: Colors.white,),
                    animationType: BadgeAnimationType.slide,
                  ),
                  SizedBox(width: 20,),
                  Text("Review Address",style: GoogleFonts.lato(color: Colors.white,fontSize: 16,),),
                  Spacer(),
                  Text(
                    "EUR $_grandTotalRs",style: GoogleFonts.lato(color: Colors.white,fontSize: 16),
                    textAlign: TextAlign.right,
                  ),
                ],
              )
            ],
          )
        ),
      ), 
    );
  }
}