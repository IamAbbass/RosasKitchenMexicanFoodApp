import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:sabzify/model/product_model.dart';
import 'package:sabzify/config.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'cart.dart';
import 'package:google_fonts/google_fonts.dart';

import 'config.dart';

class ProductView extends StatefulWidget {
  final Product product;
  ProductView({this.product});
  @override
  _ProductViewState createState() => _ProductViewState();
}

class _ProductViewState extends State<ProductView> {

  var _cartTotalRs    = 0;
  var _cartItemCount  = 0;

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
    _calculateTotal();
    super.initState();
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.product.name,
                style: GoogleFonts.lato(color: Colors.black,),
              ),
              Text(
                widget.product.category,
                style: GoogleFonts.lato(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          actions: [
          IconButton(
            onPressed: (){
              Navigator.push(context,MaterialPageRoute(builder: (BuildContext context) =>
              Cart())).then((value){ 
                //sync with previous screen
                setState(() {
                  sharedProducts = sharedProducts;
                });
                _calculateTotal();
              });
            },
            icon: Badge(
              showBadge: (_cartItemCount > 0),
              badgeColor: themePrimary,
              badgeContent: Text(_cartItemCount.toString(), style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold),),
              child: Icon(Icons.shopping_bag_outlined, color: themePrimary,),
              animationType: BadgeAnimationType.slide,
            ),
          ),          
        ],
        ),
        body: SingleChildScrollView(
          child: Container(
            width: MediaQuery.of(context).size.width,
            // color: Colors.white,
            child: Column(              
              children: <Widget>[  
                Hero(
                  tag: widget.product.id.toString(),
                  child: CachedNetworkImage(
                    fit: BoxFit.fitWidth,                  
                    placeholder: (context, url) => Container(height: 200, child: Center(child: CircularProgressIndicator(),),),
                    imageUrl: "$imageUrl${widget.product.image}",
                  ),
                ),
                              
                Container(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,                    
                    children: [   

                        (widget.product.badge == "" || widget.product.badge == null) ? Container() :  Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            decoration: BoxDecoration(
                              color: themeSecondary,
                              // border: Border.all(color: lightColor, width: 2),
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(8),
                                topLeft: Radius.circular(8),
                                bottomRight: Radius.circular(8),
                              ),
                            ),
                            margin: EdgeInsets.only(right: 2, top: 2),
                            padding: EdgeInsets.all(4),                
                            child: Text(
                              widget.product.badge,
                              style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold)
                            )                
                          ),
                        ), 
                        Text(
                          "EUR ${widget.product.sale} / ${widget.product.unit}",
                          style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 24),                          
                        ), 
                        // Text(
                        //   "Price updated ${widget.product.dated}",
                        //   style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey),
                        // ),
                        (widget.product.discount == "0" || widget.product.discount == "") ? Container() : 
                        Align(
                          alignment: Alignment.centerLeft,                  
                            child: Container(
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
                            padding: EdgeInsets.all(4),                
                            child: Text(
                              "EUR ${widget.product.discount} Off",
                              style: GoogleFonts.lato(color: Colors.white,)
                            )                
                          ),                                        
                        ),  
                        Text(
                          "${widget.product.name} ${(widget.product.type == null || widget.product.type == '') ? '' : '(widget.product.type)'}",
                          overflow: TextOverflow.ellipsis,   
                          style: GoogleFonts.lato(fontSize: 18),                     
                        ),
                        Text(
                          "${widget.product.name_ru} (${widget.product.name_ur})",
                          overflow: TextOverflow.ellipsis, 
                          style: GoogleFonts.lato(color: Colors.grey, fontSize: 18),
                        ),   
                        (widget.product.qty == null || widget.product.qty == 0) ? Container() : Align(
                          alignment: Alignment.centerLeft,                  
                          child: Text(
                            "Total EUR ${widget.product.qty*int.parse(widget.product.sale)} (${widget.product.sale} x ${widget.product.qty})",
                            overflow: TextOverflow.ellipsis, 
                            style: GoogleFonts.lato(color: themePrimary, fontSize: 18),                
                          ),
                        ),                     
                        Divider(),
                        Text(
                          widget.product.description ?? "",
                          style: GoogleFonts.lato(color: Colors.grey, fontSize: 14),
                        ),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
        bottomNavigationBar: Container(
        color: Colors.transparent,
        height: 50,
        margin: EdgeInsets.all(6),
        child: 
        
        (widget.product.qty == null || widget.product.qty == 0) ? RaisedButton(
          padding: EdgeInsets.all(6),
          color: themePrimary,
          onPressed: (){
            setState(() {
              (widget.product.qty == null) ? widget.product.qty = 1 : widget.product.qty++;                      
            });
            _calculateTotal();            
          },
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Spacer(),
              Icon(Icons.add,size: 30, color: Colors.white,),
              Text("Add to cart",style: GoogleFonts.lato(color: Colors.white,fontSize: 18,),),  
              Spacer(),                         
            ],
          )         
        ) : Row(
          children: [

            
            MaterialButton(
              onPressed: (){
                if(widget.product.qty > 0){
                  setState(() {                          
                    (widget.product.qty == null) ? widget.product.qty = 0 : widget.product.qty--;                                                       
                  });
                }
                _calculateTotal();
              },
              color: Colors.white,
              textColor: Colors.redAccent,
              child: Icon(Icons.remove,size: 30,),
              padding: EdgeInsets.zero,
              shape: CircleBorder(
                // borderRadius: BorderRadius.circular(18.0),
                side: BorderSide(color: Colors.redAccent)
              ),
            ),
            Text(
              widget.product.qty == null ? "0" : widget.product.qty.toString(),
              style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            MaterialButton(
              onPressed: (){
                setState(() {
                  (widget.product.qty == null) ? widget.product.qty = 1 : widget.product.qty++;                      
                });
                _calculateTotal();
              },                          
              color: themePrimary,
              textColor: Colors.white,
              child: Icon(Icons.add, size: 30,),
              padding: EdgeInsets.zero,
              shape: CircleBorder(
                //side: BorderSide(color: themePrimary)
              ),
            ),
            Expanded(
              child: RaisedButton(
                // shape: RoundedRectangleBorder(
                //   borderRadius: BorderRadius.zero,
                //   side: BorderSide(color: Colors.red)
                // ),
                padding: EdgeInsets.all(6),
                color: themePrimary,
                onPressed: (){
                  Navigator.push(context,MaterialPageRoute(builder: (BuildContext context) =>
                  Cart())).then((value){ 
                    //sync with previous screen
                    setState(() {
                      sharedProducts = sharedProducts;
                    });
                    _calculateTotal();
                  });         
                },
                child: Text("View Cart",style: GoogleFonts.lato(color: Colors.white,fontSize: 18,),)        
              ),
            )
          ],
        ),


      ),
    );
  }
}