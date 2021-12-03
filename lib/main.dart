import 'dart:async';
import 'dart:convert';

import 'package:connectivity/connectivity.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:http/http.dart' as http;
import 'package:device_info/device_info.dart';
import 'package:sabzify/my_orders.dart';
import 'package:sabzify/profile.dart';
import 'package:sabzify/wallet.dart';
import 'package:share/share.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:location/location.dart';

import 'package:sabzify/config.dart';
import 'package:sabzify/cart.dart';
import 'package:sabzify/model/product_model.dart';

import 'package:badges/badges.dart';

import 'package:url_launcher/url_launcher.dart';

import 'config.dart';
import 'product_view.dart';

import 'package:awesome_dialog/awesome_dialog.dart';

import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:firebase_core/firebase_core.dart';

import 'package:flutter/services.dart';

import 'package:package_info/package_info.dart';



void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class Splash extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Image.asset('assets/logo.png'),
      ),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.black, 
      systemNavigationBarColor: Colors.black
    ));
    // return FutureBuilder(
    //   future: Future.delayed(Duration(seconds: 1)),
    //   builder: (context, AsyncSnapshot snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       return MaterialApp(home: Splash());
    //     } else {
          return MaterialApp(
            title: appName,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              primarySwatch: themePrimary,
            ),
            home: MyHomePage(),
          );
        // }
      // },
    // );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();
  int bottomNavigationIndex = 0;
  bool _loading   = true;
  var _cartTotalRs    = 0;
  var _cartItemCount  = 0;
  bool isSearching = false;
  String _category = "All";

  PageController _pageViewController = PageController();

  final searchController     = TextEditingController();

  void _launchURL(_url) async =>
    await canLaunch(_url) ? await launch(_url) : throw 'Could not launch $_url';

  final GlobalKey<ScaffoldState> _scaffoldstate = new GlobalKey<ScaffoldState>();

  bool checkAlreadyRegisteredOnce = false;
  void networkChanged(connectivityResult){
    if (connectivityResult == ConnectivityResult.none) {
      
      AwesomeDialog(
      context: context,
      dialogType: DialogType.ERROR,
      animType: AnimType.BOTTOMSLIDE,
      title: "No Internet Connection",
      desc: "Please check your internet connection!",
      btnOkOnPress: (){},      
      )..show();

    } else {
      if(checkAlreadyRegisteredOnce == false){
        checkAlreadyRegisteredOnce = true;
        checkAlreadyRegistered();        
      }      
    }
  }

  void checkNetwork() async{
    var connectivityResult = await (Connectivity().checkConnectivity());
    networkChanged(connectivityResult);
  }

  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();

  void getFCMToken() async{
     _firebaseMessaging.requestNotificationPermissions();
    _firebaseMessaging.configure();
    // For testing purposes print the Firebase Messaging token
    String token = await _firebaseMessaging.getToken();
    print("FirebaseMessaging token: $token");
    registerFCM(token);

    _firebaseMessaging.configure(
        onMessage: (Map<String, dynamic> message) async {
          print('on message $message');
          AwesomeDialog(
          context: context,
          dialogType: DialogType.SUCCES,
          animType: AnimType.BOTTOMSLIDE,
          title: message["notification"]["title"] ?? '',
          desc: message["notification"]["body"] ?? '',
          btnOkOnPress: (){},      
          )..show();
    }, onResume: (Map<String, dynamic> message) async {
          print('on resume $message');
          AwesomeDialog(
          context: context,
          dialogType: DialogType.SUCCES,
          animType: AnimType.BOTTOMSLIDE,
          title: message["notification"]["title"] ?? '',
          desc: message["notification"]["body"] ?? '',
          btnOkOnPress: (){},      
          )..show();
    }, onLaunch: (Map<String, dynamic> message) async {
        print('on launch $message');
        AwesomeDialog(
        context: context,
        dialogType: DialogType.SUCCES,
        animType: AnimType.BOTTOMSLIDE,
        title: message["notification"]["title"] ?? '',
        desc: message["notification"]["body"] ?? '',
        btnOkOnPress: (){},      
        )..show();
    });
  }

  @override
  void initState() {
    Connectivity().onConnectivityChanged.listen((ConnectivityResult connectivityResult) {
      networkChanged(connectivityResult);
    });
    super.initState();
  }

  @override
  dispose() {
    super.dispose();
    // subscription.cancel();
  }

  void _showBar(text){
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

  void registerDevice(){
    deviceInfoPlugin.androidInfo.then((value) async{  
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String param = "welcome?device_token=${value.androidId}&brand=${value.brand}&manufacturer=${value.manufacturer}&android_id=${value.model}&model=${value.androidId}&os=Android&business_id=$businessId";
      String url = '$baseUrl$param';
      print(url);

      try{
        var response = await http.get(url);
        
        final body = json.decode(response.body);
        setState(() {
          apiToken = body['api_token'];
        });

        await prefs.setString('apiToken', apiToken);
        
        // registerFCM(); //one-time
        getFCMToken();// -> registerFCM();
        loadProducts();
        estimateDelivery();
        getProfile();        
      }catch(e){
        AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        animType: AnimType.BOTTOMSLIDE,
        title: "Sorry, an unexpected error occurred!",
        desc: "[error_code: /welcome]",
        btnOkOnPress: (){},      
        )..show();
      }
    });
  }

  Location location = new Location();

  void _showNoteDialog(context,configNote,configGift){
    AwesomeDialog(
      context: context,
      dialogType: DialogType.INFO,
      animType: AnimType.BOTTOMSLIDE,
      title: configNote,
      desc: configGift ? "You will get a Free Gift 🎁 with your order!" : "",
      btnOkOnPress: (){},
    )..show().then((value){

    });
  }
  

  void registerFCM(fcmToken) async{

    String param = "fcm?fcm_token=$fcmToken&api_token=$apiToken&business_id=$businessId";
    try{
      String url = '$baseUrl$param';
      print(url);
      
      var response = await http.get(url);
      print('Response body: ${response.body}');
      // _showBar("FCM Registered");

    }catch(e){
      AwesomeDialog(
      context: context,
      dialogType: DialogType.ERROR,
      animType: AnimType.BOTTOMSLIDE,
        title: "Sorry, an unexpected error occurred!",
        desc: "[error_code: /fcm]",
      btnOkOnPress: (){},      
      )..show();
    }
  }

  bool _loadingEstimate = true;
  // int locationTryCount  = 0;
  bool mainPopupOnce = false;

  void estimateDelivery() async{    
    location.changeSettings(accuracy: LocationAccuracy.high, interval: 10000);
    // locationTryCount++;
    // print("TRY: $locationTryCount A");
    setState(() {
      _loadingEstimate = true;
    });

    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;
    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (!_serviceEnabled) {

        AwesomeDialog(
        context: context,
        dialogType: DialogType.WARNING,
        animType: AnimType.BOTTOMSLIDE,
        title: "Please Enable Your Location",
        desc: "We use accurate location information for fast delivery of your order!",
        btnOkOnPress: (){},      
        )..show().then((value){
          if(sharedLocation == null){
            estimateDelivery();
          }          
        });

        return;
      }
    }
    // print("TRY: $locationTryCount B");

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) {

        AwesomeDialog(
        context: context,
        dialogType: DialogType.WARNING,
        animType: AnimType.BOTTOMSLIDE,
        title: "Please Accept GPS Permission",
        desc: "We need access to your location for fast delivery of your order",
        btnOkOnPress: (){},      
        )..show().then((value){
          if(sharedLocation == null){
            estimateDelivery();
          }  
        });

        return;
      }
    }   

    // print("TRY: $locationTryCount C");
    
    _locationData = await location.getLocation().timeout(Duration(seconds: 5)).whenComplete((){
      if(sharedLocation == null){
        estimateDelivery();
      }  
    });


    setState(() {
      sharedLocation = _locationData;
    });

    // print("TRY: $locationTryCount D");

    PackageInfo packageInfo = await PackageInfo.fromPlatform();

    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;

    try{

      // print("TRY: $locationTryCount E");

      String url = "${baseUrl}order/timings?api_token=$apiToken";      
      url += "&location=${sharedLocation.latitude},${sharedLocation.longitude},${sharedLocation.accuracy}";
      url += "&business_id=$businessId";
      url += "&package_name=$packageName";
      url += "&version=$version";
      url += "&build_number=$buildNumber";

      print(url);
      
      var response = await http.get(url);
      final body = json.decode(response.body);
      print(body);

      setState(() {
        configNote              = body['note'];
        configExpectedDelivery  = body['expected_delivery'];
        configMinOrder          = body['min_order'];
        configGift              = body['is_gift'];
        deliveryFee             = body['delivery_fee'].toString();
        freeDeliveryAfter       = body['free_delivery_after'].toString();
      });


      if(configNote != null && mainPopupOnce == false){
        mainPopupOnce = true;
        _showNoteDialog(context,configNote,configGift);

      }

      // print("TRY: $locationTryCount F");
      
    }catch(e){
      print(e.toString());
      AwesomeDialog(
      context: context,
      dialogType: DialogType.ERROR,
      animType: AnimType.BOTTOMSLIDE,
        title: "Sorry, an unexpected error occurred!",
        desc: "[error_code: /order/timings]",
      btnOkOnPress: (){},      
      )..show();
      // print("TRY: $locationTryCount G");
    }

    // print("TRY: $locationTryCount H");

    setState(() {
      _loadingEstimate = false;
    });
  }

  void getProfile() async{
    String url = "${baseUrl}profile?api_token=$apiToken&business_id=$businessId";
    print(url);       

    try{      
      var response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      final body = json.decode(response.body);

      setState(() {
        profileName       = body['name'] ?? '';
        profilePhone      = body['phone'] ?? '';
        profileEmail      = body['email'] ?? '';
        profileAddress    = body['address'] ?? '';
        profileWallet     = body['wallet'].toString() ?? '';
        profileIsVerified = body['is_verified']  ?? false;
      });

      if(profilePhone == null || profilePhone == "null" || profilePhone == ""){
        _numberInputDialog();
      }

    }catch(e){
      AwesomeDialog(
      context: context,
      dialogType: DialogType.ERROR,
      animType: AnimType.BOTTOMSLIDE,
        title: "Sorry, an unexpected error occurred!",
        desc: "[error_code: /profile]",
      btnOkOnPress: (){},      
      )..show();
    } 
  } 

  Future<bool> checkAlreadyRegistered() async{
    SharedPreferences prefs = await SharedPreferences.getInstance();
    apiToken = prefs.getString('apiToken');    
    if(apiToken != null){
      setState(() {
        apiToken = prefs.getString('apiToken');
      });

      //recurring user
      getFCMToken();// -> registerFCM();
      loadProducts();
      estimateDelivery();
      getProfile();
    }else{
      //new user
      registerDevice();
    }
  }

  
  void loadProducts() async{    

    //Save Cart
    List<int> _tempProductId  = List<int>();
    List<int> _tempQty        = List<int>();  
    sharedProducts.forEach((p){
      if(p.qty == null || p.qty == 0){
        //ignore
      }else{
        _tempProductId.add(p.id);
        _tempQty.add(p.qty);
      }
    });

    var products = await fetchProducts(http.Client(), null);
    
    setState((){
      sharedProducts = products;
      _loading = false;
    });

    sharedProducts.forEach((p){
      if(_tempProductId.contains(p.id)){
        int index = _tempProductId.indexOf(p.id);
        int qty   = _tempQty[index];
        setState(() {
          p.qty = qty;
        });
      }
    });
  }

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

  void _savePhoneNumber() async{
    String url = "${baseUrl}profile/update?api_token=$apiToken&phone=${_phone.text}&business_id=$businessId";
    url = Uri.encodeFull(url);
    print(url);

    Navigator.pop(context);
    AwesomeDialog(context: context,dialogType: DialogType.SUCCES,animType: AnimType.BOTTOMSLIDE, title: "Congratulations !",desc: "EUR 30 added in your wallet !",btnOkOnPress: (){}, )..show();

    try{
      var response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      final body = json.decode(response.body);

      setState(() {
        profilePhone      = body['phone'] ?? '';
        profileWallet     = body['wallet'] ?? '';
      });

      setState(() {
        profilePhone  = _phone.text ?? '';
      });
    }catch(e){}
  }

  Future<void> _pullRefresh() async {    
    loadProducts();
    estimateDelivery();
    getProfile();
  }

  final _phone    = TextEditingController();

  void _numberInputDialog() {
    showModalBottomSheet(
        isDismissible: false,
        enableDrag: false,
        isScrollControlled: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25.0))),
        context: context,
        builder: (context) {
          return WillPopScope(
            onWillPop: () async => false,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text("SignUp & Get EUR 30 in Wallet", style: GoogleFonts.lato(color: themePrimary, fontWeight: FontWeight.bold, fontSize: 22),),
                  ),
                  SizedBox(height: 18,),
                  Padding(
                    padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                    child:  TextField(
                      maxLength: 10,
                      onChanged: (String phone){
                        if(phone.length == 10){
                          FocusScope.of(context).requestFocus(FocusNode());
                        }
                      },
                      controller: _phone,
                      autofocus: true,
                      style:  GoogleFonts.lato(fontSize: 18),
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.call),
                        border: OutlineInputBorder(),
                        prefixText: '',
                        labelText: 'Your Phone Number',
                        labelStyle: GoogleFonts.lato(fontSize: 18),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  RaisedButton(
                      padding: EdgeInsets.all(18),
                      color: themePrimary,
                      disabledColor: themePrimary,
                      onPressed: (){
                        if(_validateNumber(_phone.text) == false){
                          AwesomeDialog(context: context,dialogType: DialogType.WARNING,animType: AnimType.BOTTOMSLIDE,
                          title: "Invalid phone number",desc: "Phone number must contain only numbers, please make sure there are no spaces.",btnOkOnPress: (){}, )..show();
                        }else{
                          _savePhoneNumber();
                        }
                      },
                      child:
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                              width: 100,
                              child: Text(" ",style: GoogleFonts.lato(color: Colors.white,fontSize: 16),)
                          ),
                          Text("Save",style: GoogleFonts.lato(color: Colors.white,fontSize: 16),),
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
                ],
              ),
            ),
          );
        }
    );
  }

  List<Widget> _cartItemsThumb(){
    List<Widget> cartItems = [];
    sharedProducts.forEach((element) {

      if(element.qty == null || element.qty == 0){

      }else{
        cartItems.add(Column(
          children: [
            Container(
              margin: EdgeInsets.all(2),
              width: 35,
              height: 35,
              alignment: Alignment.center,
              child: ClipRRect(
                  borderRadius: BorderRadius.circular(10000.0),
                  child: CachedNetworkImage(
                    fit: BoxFit.contain,
                    placeholder: (context, url) => Center(child: CircularProgressIndicator(),),
                    imageUrl: "$imageUrl${element.image}",
                  ),
              )
            ),
          ],
        ));
      }
    });
    return cartItems;
  }

  void _changeCategory(index){
    if(index == 0){
      setState(() {
        _category = "All";
        isSearching = false;
      });
    }else if(index == 1){
      setState(() {
        _category = "Vegetable";
        isSearching = true;
        sharedProductsSearchResult = sharedProducts.where((i) => (i.category.contains(_category))).toList();
      });
    }else if(index == 2){
      setState(() {
        _category = "Fruits";
        isSearching = true;
        sharedProductsSearchResult = sharedProducts.where((i) => (i.category.contains(_category))).toList();
      });
    }
  }

  Widget _buildChip(index, label) {
    return GestureDetector(
      onTap: (){
        _changeCategory(index);
      },
      child: Container(
        margin: EdgeInsets.only(right: 4),
        child: Chip(

          // labelPadding: EdgeInsets.all(2.0),
          // avatar: CircleAvatar(
          //   backgroundColor: Colors.white70,
          //   child: Text(label[0].toUpperCase()),
          // ),
          label: Text(
            label,
            style: TextStyle(
              color:  _category == label ? Colors.white : themePrimary ,
            ),
          ),

          backgroundColor: _category == label ? themePrimary : Colors.white,
          elevation: 2.0,
          shadowColor: Colors.grey[60],
          padding: EdgeInsets.all(6.0),
        ),
      ),
    );
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

  Widget _renderProducts(){
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
      itemBuilder: (context, index){

        var data = isSearching ? sharedProductsSearchResult : sharedProducts;

        return Container(
          margin: EdgeInsets.all(4),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    // mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Hero(
                        tag: data[index].id.toString(),
                        child: Container(
                          width: 92,
                          height: 92,
                          alignment: Alignment.center,
                          child: CachedNetworkImage(
                            fit: BoxFit.contain,
                            placeholder: (context, url) => Center(child: CircularProgressIndicator(),),
                            imageUrl: "$imageUrl${data[index].image}",
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.only(left: 10, right: 10),
                        child: Column(
                          children: [
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "EUR ${data[index].sale} / ${data[index].unit}",
                                style: GoogleFonts.lato(fontWeight: FontWeight.bold),
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "${data[index].name}",
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "${data[index].name_ru} (${data[index].name_ur})",
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.lato(color: Colors.black54),
                              ),
                            ),
                            (data[index].qty == null || data[index].qty == 0) ? Container() : Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                "Total EUR ${data[index].qty*int.parse(data[index].sale)}",
                                overflow: TextOverflow.ellipsis,
                                style: GoogleFonts.lato(color: themePrimary, fontWeight: FontWeight.bold),
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                onTap: (){
                  Navigator.push(context,MaterialPageRoute(builder: (BuildContext context) =>
                      ProductView(product: data[index],))).then((value){
                    //sync with previous screen
                    setState(() {
                      data = data;
                    });
                    _calculateTotal();
                    FocusScope.of(context).requestFocus(FocusNode());
                  });
                },
              ),
              (data[index].badge == "" || data[index].badge == null) ? Container() :  Positioned(
                top: 0,
                left: 0,
                child: Container(
                    decoration: BoxDecoration(
                      color: themeSecondary,
                      // border: Border.all(color: lightColor, width: 2),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8),
                      ),
                    ),
                    margin: EdgeInsets.only(right: 2, top: 2),
                    padding: EdgeInsets.all(4),
                    child: Text(
                        data[index].badge,
                        style: GoogleFonts.lato(color: Colors.white, fontSize: 12,)
                    )
                ),
              ),
              (data[index].discount == "0" || data[index].discount == "") ? Container() : Positioned(
                top: 0,
                right: 0,
                child: Container(
                    decoration: BoxDecoration(
                      color: themePrimary,
                      // border: Border.all(color: lightColor, width: 2),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(8),
                      ),
                    ),
                    margin: EdgeInsets.only(right: 2, top: 2),
                    padding: EdgeInsets.all(4),
                    child: Text(
                        "EUR ${data[index].discount} Off",
                        style: GoogleFonts.lato(color: Colors.white, fontSize: 12,)
                    )
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 50,

                  decoration: BoxDecoration(
                      color: Colors.white30,
                      borderRadius:
                      BorderRadius.only(
                          bottomRight: Radius.circular(12)
                      )
                  ),
                  child: Column(
                    children: <Widget>[
                      (data[index].qty == null || data[index].qty <= 1) ? Container() : MaterialButton(
                        onPressed: (){
                          setState(() {
                            data[index].qty = 0;
                          });
                          _calculateTotal();
                        },
                        color: Colors.white,
                        textColor: Colors.redAccent,
                        child: Icon(Icons.delete,size: 24,),
                        padding: EdgeInsets.zero,
                        shape: CircleBorder(
                            side: BorderSide(color: Colors.redAccent)
                        ),
                      ),
                      (data[index].qty == null || data[index].qty == 0) ? Container() : MaterialButton(
                        onPressed: (){
                          if(data[index].qty > 0){
                            setState(() {
                              (data[index].qty == null) ? data[index].qty = 0 : data[index].qty--;
                            });
                          }
                          _calculateTotal();
                        },
                        color: Colors.white,
                        textColor: Colors.redAccent,
                        child: Icon(Icons.remove,size: 24,),
                        padding: EdgeInsets.zero,
                        shape: CircleBorder(
                          // borderRadius: BorderRadius.circular(18.0),
                            side: BorderSide(color: Colors.redAccent)
                        ),
                      ),
                      (data[index].qty == null || data[index].qty == 0) ? Container() :
                      Text(
                        data[index].qty == null ? "0" : data[index].qty.toString(),
                        style: GoogleFonts.lato(fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                      MaterialButton(
                        onPressed: (){
                          setState(() {
                            (data[index].qty == null) ? data[index].qty = 1 : data[index].qty++;
                          });
                          _calculateTotal();
                        },
                        color: themePrimary,
                        textColor: Colors.white,
                        child: Icon(Icons.add, size: 24,),
                        padding: EdgeInsets.zero,
                        shape: CircleBorder(
                          //side: BorderSide(color: themePrimary)
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Positioned(
              //   bottom: 0,
              //   right: 0,
              //   child: Container(
              //     padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
              //     child: Icon(
              //       Icons.favorite_border,
              //     ),
              //   ),
              // )
            ],
          ),
        );
      },
      itemCount: isSearching ? sharedProductsSearchResult.length : sharedProducts.length, //products.length <= 5 ? products.length : 5
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(


      key: _scaffoldstate,      
      drawer: Drawer(
        child: ListView(
          children: [
            GestureDetector(
              onTap: (){
                Navigator.pop(context);
                Navigator.push(context,MaterialPageRoute(builder: (BuildContext context) => Profile())).then((value){
                  FocusScope.of(context).requestFocus(FocusNode());
                });
              },
              child: DrawerHeader(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text((profileName == null || profileName == "") ? "Welcome to $appName!" : "$profileName", style: GoogleFonts.lato(fontWeight: FontWeight.bold, color: themePrimary, fontSize: 28), textAlign: TextAlign.center,),
                      //Text((profileEmail == null || profileEmail == "") ? '' : "$profileEmail", style: GoogleFonts.lato(color: themePrimary, fontSize: 14), textAlign: TextAlign.center,),
                      Text((profilePhone == null || profilePhone == "") ? '' : "92$profilePhone", style: GoogleFonts.lato(color: themePrimary, fontSize: 20), textAlign: TextAlign.center,),
                    ],
                  )
              ),
            ),
            ListTile(
              leading: Icon(Icons.supervised_user_circle, color: themePrimary, size: 32),
              title: Text("Profile", style: GoogleFonts.lato(color: themePrimary, fontSize: 18)),
              // subtitle: Text("Get PKR 50 in your wallet"),
              onTap: (){
                Navigator.pop(context);                
                Navigator.push(context,MaterialPageRoute(builder: (BuildContext context) => Profile())).then((value){
                  FocusScope.of(context).requestFocus(FocusNode());
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.wallet_giftcard, color: themePrimary, size: 32),
              title: Text("Wallet", style: GoogleFonts.lato(color: themePrimary, fontSize: 18)),
              // subtitle: Text("Get PKR 50 in your wallet"),
              trailing: Text(profileWallet ?? '', style: GoogleFonts.lato(color: themePrimary, fontSize: 14, fontWeight: FontWeight.bold)),
              onTap: (){
                Navigator.push(context,MaterialPageRoute(builder: (BuildContext context) => Wallet())).then((value){
                  FocusScope.of(context).requestFocus(FocusNode());
                });
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: themePrimary, size: 32),
              title: Text("My Orders", style: GoogleFonts.lato(color: themePrimary, fontSize: 18)),
              // subtitle: Text("Get PKR 50 in your wallet"),
              onTap: (){
                Navigator.pop(context);                
                Navigator.push(context,MaterialPageRoute(builder: (BuildContext context) => MyOrders())).then((value){
                  FocusScope.of(context).requestFocus(FocusNode());
                });
              },
            ),
            Divider(),
            // ListTile(
            //   leading: Icon(Icons.message, color: themePrimary, size: 32),
            //   title: Text("WhatsApp Chat Support", style: GoogleFonts.lato(color: themePrimary, fontSize: 18)),
            //   subtitle: Text("Tap to chat with us at WhatsApp"),
            //   onTap: (){
            //     _launchURL("https://wa.me/message/Z7SJ6S5J5Z7VL1");
            //   },
            // ),
            // ListTile(
            //   leading: Icon(Icons.call, color: themePrimary, size: 32),
            //   title: Text("Customer Care", style: GoogleFonts.lato(color: themePrimary, fontSize: 18)),
            //   subtitle: Text("Tap to call us at 0334-7229439"),
            //   onTap: (){
            //     _launchURL("tel:923347229439");
            //   },
            // ),
            // ListTile(
            //   leading: Icon(Icons.rate_review, color: themePrimary, size: 32),
            //   title: Text("Rate Us", style: GoogleFonts.lato(color: themePrimary, fontSize: 18)),
            //   subtitle: Text("Like our app? Give us 5 stars"),
            //   onTap: (){
            //     _launchURL("https://play.google.com/store/apps/details?id=com.rosa.kitchen");
            //   },
            // ),
            // ListTile(
            //   leading: Icon(Icons.share, color: themePrimary, size: 32),
            //   title: Text("Share $appName App", style: GoogleFonts.lato(color: themePrimary, fontSize: 18)),
            //   subtitle: Text("Share $appName with your friends & family "),
            //   onTap: (){
            //     Share.share('$appName\nSasti | Taazi | Jaldi\nFresh Fruits & Vegetables Delivery\nStay Home, We Deliver\nOrder Now: https://sabzify.pk/');
            //   },
            // ),
          ],
        ),
      ),
      appBar: _loading ? null : AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: (){

            FocusScope.of(context).requestFocus(FocusNode());

            setState(() {
              profileName       = profileName;
              profilePhone      = profilePhone;
              profileEmail      = profileEmail;
              profileAddress    = profileAddress;
              profileWallet     = profileWallet;
            });

            _scaffoldstate.currentState.openDrawer();
          },
          color: themePrimary,
          tooltip: 'Menu',
        ),
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/logo-sm.png', width: 45,),
              SizedBox(
                width: 120,
                child: TextLiquidFill(          
                  text: appName,
                  waveColor: themePrimary,
                  boxBackgroundColor: Colors.white,
                  textStyle: GoogleFonts.lato(color: themePrimary, fontWeight: FontWeight.bold, fontSize: 18),
                  loadDuration: const Duration(seconds: 3),
                ),
              ),
            ],
           ),
        ),
        actions: [  
          
          // IconButton(
          //   tooltip: "How To Order",
          //   onPressed: (){
          //     _launchURL("https://youtu.be/uDdfTF3qOEs");
          //   },
          //   icon: Icon(Icons.help_outline, color: themePrimary,),
          // ),

          IconButton(
            tooltip: "Cart",
            onPressed: (){
              Navigator.push(context,MaterialPageRoute(builder: (BuildContext context) =>
                  Cart())).then((value){
                //sync with previous screen
                setState(() {
                  sharedProducts = sharedProducts;
                });
                _calculateTotal();
                FocusScope.of(context).requestFocus(FocusNode());
              });
            },
            icon: Badge(
              showBadge: (_cartItemCount > 0),
              badgeColor: themePrimary,
              badgeContent: Text(_cartItemCount.toString(), style: TextStyle(color: Colors.white,),),
              child: Icon(Icons.shopping_bag_outlined, color: themePrimary,),
              animationType: BadgeAnimationType.slide,
            ),
          ),

        ],
      ), 
      body: _loading ? Container(
        color: Colors.white,
        child: Column(
			    crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: Container(
                color: Colors.white,
                child: TextLiquidFill(          
                  text: appName,
                  waveColor: themePrimary,
                  boxBackgroundColor: Colors.white,
                  textStyle: GoogleFonts.lato(color: themePrimary, fontWeight: FontWeight.bold, fontSize: 50),
                  loadDuration: const Duration(seconds: 3),
                ),
              )
            ),
            LinearProgressIndicator(),
            SizedBox(height: 5),
            Center(
              child: Text("Loading Menu .. ", style: GoogleFonts.lato(color: themePrimary, fontSize: 16),),
            ),
          ],
        ),

      ) : RefreshIndicator(
      onRefresh: _pullRefresh,
      child:  Container(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(left:6,right:6,top:3,bottom:3),
                color: themePrimary,
                height: 32,
                child: _loadingEstimate ?


                Column(
                  children: [
                    Text("Loading Estimate Delivery ..", style: GoogleFonts.lato(color: Colors.white,)),
                    LinearProgressIndicator(),
                  ],
                ) : GestureDetector(
                    onTap: (){
                      _showNoteDialog(context,configNote,configGift);
                      },
                    onTapDown: (i){
                      _showNoteDialog(context,configNote,configGift);
                    },
                    child: Row(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.delivery_dining, color: Colors.white, size: 24,),
                            SizedBox(width: 3),
                            Text(
                              "$configExpectedDelivery",
                              style: GoogleFonts.lato(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        configGift ? Row(
                          children: [
                            Icon(Icons.card_giftcard_rounded, color: Colors.white, size: 24,),
                            SizedBox(width: 3),
                            Text(
                              "Free Gift",
                              style: GoogleFonts.lato(
                                color: Colors.white,
                                fontSize: 14.0,
                              ),
                            ),
                          ],
                        ) : Container(height: 0, width: 0,),
                      ],
                  ),
                )
                // _loadingEstimate
              ),
              Container(
                padding: EdgeInsets.only(top: 6, left: 6, right: 6),
                child: TextField(
                  controller: searchController,
                  decoration: new InputDecoration(
                    contentPadding: EdgeInsets.all(0),
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.cancel),
                      onPressed: (){
                        setState(() {
                          searchController.text = "";
                          isSearching = false;
                        });
                        FocusScope.of(context).requestFocus(FocusNode());
                      },
                    ),
                    hintText: 'Search Potato, Alu or آلو ..',
                    border: new OutlineInputBorder(
                        borderSide: new BorderSide(color: themePrimary),
                        borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  onChanged: (String _search){
                    //reset category
                    _changeCategory(0);

                    if(_search.length > 0){
                      _search = _search.toLowerCase();
                      setState(() {
                        isSearching = true;
                        sharedProductsSearchResult = sharedProducts.where((i) => (
                          i.name.toLowerCase().contains(_search) ||
                          i.name_ru.toLowerCase().contains(_search) ||
                          i.name_ur.toLowerCase().contains(_search)
                        )).toList();
                      });
                    }else{
                      setState(() {
                        isSearching = false;
                      });
                    }
                  },
                ),
              ),
              Container(
                height: 50,
                padding: EdgeInsets.all(6),
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildChip(0,"All"),
                    _buildChip(1,"Vegetable"),
                    _buildChip(2,"Fruits"),
                  ],
                ),
              ),
              (isSearching && sharedProductsSearchResult.length == 0) ?
              Container(
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search, color: themePrimary, size: 74,),
                      SizedBox(height: 10),
                      Text("Sorry, we can't find it 😢", style: GoogleFonts.lato(color: themePrimary, fontWeight: FontWeight.bold, fontSize: 24),),
                      SizedBox(height: 5),
                      SizedBox(
                        width: 250,
                        child: Text("We couldn't find anything like '${searchController.text}'", style: GoogleFonts.lato(color: Colors.grey, fontSize: 18), textAlign: TextAlign.center,),
                      ),
                    ],
                  ),
                ),
              ) : Container(),


              Expanded(
                // height: MediaQuery.of(context).size.height-125,
                child: _renderProducts(),
              )
            ],
          ),
      ),
      
      ),
      bottomNavigationBar: (_cartItemCount == 0) ? Container(height: 0, width: 0,) : Container(
        color: Colors.transparent,
        height: 78,
        margin: EdgeInsets.all(6),
        child: RaisedButton(
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

              FocusScope.of(context).requestFocus(FocusNode());
            });
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                children: [
                  Badge(
                    showBadge: (_cartItemCount > 0),
                    badgeColor: Colors.white,
                    badgeContent: Text(_cartItemCount.toString(), style: TextStyle(color: themePrimary,),),
                    child: Icon(Icons.shopping_bag_outlined, color: Colors.white,),
                    animationType: BadgeAnimationType.slide,
                  ),
                  SizedBox(width: 20,),
                  Text("View Cart",style: GoogleFonts.lato(color: Colors.white,fontSize: 16,),),
                  Spacer(),
                  Text(
                    "EUR $_cartTotalRs",style: GoogleFonts.lato(color: Colors.white,fontSize: 16),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
              Container(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: _cartItemsThumb(),
                ),
              )
            ],
          )
        ),
      ),
    );
  }
}