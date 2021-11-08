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

class CheckOut extends StatefulWidget {
  @override
  _CheckOutState createState() => _CheckOutState();
}

class _CheckOutState extends State<CheckOut> {

  var _cartTotalRs = 0;
  var _cartTotalDiscount = 0;
  var _cartItemCount = 0;

  final _name     = TextEditingController();
  final _phone    = TextEditingController();
  final _email    = TextEditingController();
  final _address  = TextEditingController();
  final _note     = TextEditingController();
  String _products;
  String _qty;  

  bool _loading   = false;


  var _grandTotalRs = 0;
  bool _freeDelivery = false;
  var _moreForFreeDelivery = 0;
  var _moreForFreeDeliveryBar = 0.0;




  void _calculateTotal(){

    List<int> _productsArr = [];
    List<int> _qtyArr = [];

    _cartTotalRs = 0;
    _cartItemCount = 0;
    _cartTotalDiscount = 0;




    sharedProducts.forEach((p){
      if(p.qty == null || p.qty == 0){
        //ignore

      }else{

        _productsArr.add(p.id);
        _qtyArr.add(p.qty);

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
        _grandTotalRs = _cartTotalRs+int.parse(deliveryFee);
        _freeDelivery = false;
        _moreForFreeDelivery = int.parse(freeDeliveryAfter) - _cartTotalRs;
        _moreForFreeDeliveryBar = ((_cartTotalRs*100)/int.parse(freeDeliveryAfter))/100;

      });
    }else{
      setState(() {
        _grandTotalRs = _cartTotalRs;
        _freeDelivery = true;
      });
    }

    setState(() {
      _products = _productsArr.join(",");
      _qty = _qtyArr.join(",");
    });
  }

  void getProfile() async{
    _name.text    = profileName ?? '';
    _phone.text   = profilePhone ?? '';
    _email.text   = profileEmail ?? '';
    _address.text = profileAddress ?? '';    
  }

  @override
  void initState() {
    getProfile();
    _calculateTotal();
    super.initState();
  }

  final GlobalKey<ScaffoldState> _scaffoldstate = new GlobalKey<ScaffoldState>();

  void _showBar(String text){
    _scaffoldstate.currentState.showSnackBar(new SnackBar(
      duration: Duration(seconds: 2) ,
      action: SnackBarAction(
        label: 'Okay',
        onPressed: () {
          // Some code to undo the change.
        },  
      ),
      content: new Text(text))
      );
  }

  void _placeOrder() async{

    String _location = "&location=null,null,null";
    if(sharedLocation != null){
      _location = "&location=${sharedLocation.latitude ?? ''},${sharedLocation.longitude ?? ''},${sharedLocation.accuracy ?? ''}";
    }

    String url = "${baseUrl}order?api_token=$apiToken";
    url += "&name=${_name.text}";
    url += "&phone=${_phone.text}";
    url += "&email=${_email.text}";
    url += "&address=${_address.text}";
    url += "&location=$_location";
    // if(_freeDelivery){
    //   url += "&delivery_id=0";
    // }else{
    //   url += "&delivery_id=1";
    // }
    url += "&coupon=-";
    url += "&payment_method=COD";
    url += "&note=${_note.text}";
    url += "&products=$_products";
    url += "&qty=$_qty";
    url += "&gift=$configGift";
    url += "&business_id=$businessId";
    url = url.replaceAll("#", "No.");
    url = Uri.encodeFull(url);
    print(url);    

    setState(() {
      _loading = true;
    });

    try{
      var response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      final body = json.decode(response.body);
      bool success  = body['success'];
      String msg    = body['msg'];
      String title  = body['title'];

      if(success){

        sharedProducts.forEach((p){
          p.qty = 0; //reset all
        });

        //yahan
        AwesomeDialog(context: context,dialogType: DialogType.SUCCES,animType: AnimType.BOTTOMSLIDE,
        title: title ?? "Order Submitted!",desc: msg ?? '',btnOkOnPress: (){}, )..show().then((value){
          Navigator.of(context).pop();
          Navigator.of(context).pop();
        });

      }else{
        AwesomeDialog(context: context,dialogType: DialogType.ERROR,animType: AnimType.BOTTOMSLIDE,
        title: "Sorry, an unexpected error occurred!",desc: "[error_code: /order] Please call us at $helpLine",btnOkOnPress: (){}, )..show();
      }

      setState(() {
        _loading = false;
      });

    }catch(e){
      AwesomeDialog(
      context: context,
      dialogType: DialogType.ERROR,
      animType: AnimType.BOTTOMSLIDE,
      title: "Oops, unknown error occurred!",
      desc: "Please check your internet connection and try again!",
      btnOkOnPress: (){},
      )..show();

      setState(() {
        _loading = false;
      });
    }
  }

  List<Widget> _cartItems(){
    List<Widget> cartItems = []; 
    sharedProducts.forEach((element) {

      if(element.qty == null || element.qty == 0){
        
      }else{
        cartItems.add(Container(
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
                       
                    ],
                  )                  
                ),
              ),          
              
            ],
          ),
        ));
      }  
    });    
    return cartItems;
  }

  bool _validateNumber(number){
    bool isValid = true;
    if(number.length == 10){
      number.split('').forEach((ch) {
        if (["0","1","2","3","4","5","6","7","8","9"].contains(ch)) {
        }else{
          isValid = false;
        }
      });
    }else{
      isValid = false;
    }
    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldstate,
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
          "Checkout",
          style: GoogleFonts.lato(color: Colors.black,),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(12),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text("Please enter your contact information,", style: GoogleFonts.lato(color: themePrimary, fontWeight: FontWeight.bold, fontSize: 18),),
              ),
              SizedBox(height: 12),

              TextField(     
                controller: _name,
                style:  GoogleFonts.lato(fontSize: 18),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.supervised_user_circle),
                  border: OutlineInputBorder(),
                  labelText: 'Your Name',
                  labelStyle: GoogleFonts.lato(fontSize: 18),                  
                ),
              ),
              SizedBox(height: 12),
              TextField(
                maxLength: 10,
                controller: _phone,
                style:  GoogleFonts.lato(fontSize: 18),
                keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.call),
                  border: OutlineInputBorder(),
                  prefixText: '',
                  labelText: 'Your Phone Number',
                  labelStyle: GoogleFonts.lato(fontSize: 18),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _email,
                style:  GoogleFonts.lato(fontSize: 18),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                  labelText: 'Your Email',
                  labelStyle: GoogleFonts.lato(fontSize: 18),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _address,
                style:  GoogleFonts.lato(fontSize: 18),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.location_city),
                  border: OutlineInputBorder(),
                  labelText: 'Your Address',
                  labelStyle: GoogleFonts.lato(fontSize: 18),
                ),
              ),
              SizedBox(height: 12),
              TextField(
                controller: _note,
                style:  GoogleFonts.lato(fontSize: 18),
                keyboardType: TextInputType.multiline,
                maxLines: null,
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.edit),
                  border: OutlineInputBorder(),
                  labelText: 'Note (Optional)',
                  labelStyle: GoogleFonts.lato(fontSize: 18),
                ),
              ), 

              Divider(),             
              
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text("Order Summary", style: GoogleFonts.lato(color: themePrimary, fontWeight: FontWeight.bold, fontSize: 18),),
                ),
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
                    children: _cartItems(),
                  ),
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
                        Text(
                          "EUR $_grandTotalRs",
                          style: GoogleFonts.lato(color: Colors.black,fontWeight: FontWeight.bold, fontSize: 18)
                        )             
                      ],                                  
                    )
                  ]
                ),

              SizedBox(height: 6),

              Container(
                color: Colors.transparent,
                height: 50,
                // margin: EdgeInsets.all(6),
                child: RaisedButton(
                    padding: EdgeInsets.all(6),
                    color: themePrimary,
                    disabledColor: themePrimary,
                    onPressed: _loading ? null : (){

                      _validateNumber(_phone.text);

                      if(_name.text.length == 0){
                        AwesomeDialog(context: context,dialogType: DialogType.WARNING,animType: AnimType.BOTTOMSLIDE,
                          title: "Name is required",desc: "Opps, you forgot to enter your name",btnOkOnPress: (){}, )..show();
                      }else if(_validateNumber(_phone.text) == false){
                        AwesomeDialog(context: context,dialogType: DialogType.WARNING,animType: AnimType.BOTTOMSLIDE,
                          title: "Invalid phone number",desc: "Phone number must contain only numbers, please make sure there are no spaces.",btnOkOnPress: (){}, )..show();
                      }else if(_email.text.length == 0){
                        AwesomeDialog(context: context,dialogType: DialogType.WARNING,animType: AnimType.BOTTOMSLIDE,
                          title: "Email address is required",desc: "Opps, you forgot to enter your email address",btnOkOnPress: (){}, )..show();
                      }else if(!EmailValidator.validate(_email.text.toString())){
                        AwesomeDialog(context: context,dialogType: DialogType.WARNING,animType: AnimType.BOTTOMSLIDE,
                          title: "Valid email address required",desc: "Opps, your email address doesn't looks good",btnOkOnPress: (){}, )..show();
                      }else if(_address.text.length == 0){
                        AwesomeDialog(context: context,dialogType: DialogType.WARNING,animType: AnimType.BOTTOMSLIDE,
                          title: "Address is required",desc: "Write complete address (+ nearest landmark) so that our rider can find you easily",btnOkOnPress: (){}, )..show();
                      }else{
                        _placeOrder();
                      }
                    },
                    child: _loading ?

                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text("Please wait ..",style: GoogleFonts.lato(color: Colors.white,fontSize: 16),),
                        LinearProgressIndicator()
                      ],
                    )
                        :
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                            width: 100,
                            child: Text(" ",style: GoogleFonts.lato(color: Colors.white,fontSize: 16),)
                        ),
                        Text("Place Order",style: GoogleFonts.lato(color: Colors.white,fontSize: 16),),
                        SizedBox(
                          width: 100,
                          child: Text(
                            " ",style: GoogleFonts.lato(color: Colors.white,fontSize: 16),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    )
                ),
              )
              

              

            ],
          ), 
        )
      ),
    );
  }
}