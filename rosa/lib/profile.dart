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

class Profile extends StatefulWidget {
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {

  final _name     = TextEditingController();
  final _phone    = TextEditingController();
  final _email    = TextEditingController();
  final _address  = TextEditingController();
  final _note     = TextEditingController();
  String _products;
  String _qty;  

  bool _loading   = false;  

  void updateProfile() async{
    String url = "${baseUrl}profile/update?api_token=$apiToken&image=default.png&name=${_name.text}&phone=${_phone.text}&email=${_email.text}&address=${_address.text}&is_verified=1&business_id=$businessId";
    url = Uri.encodeFull(url);   
    print(url); 

    setState(() {
      _loading = true;
    });

    try{      
      var response = await http.get(url);
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      // final body = json.decode(response.body);
      // bool success  = body['success'];
      // String msg    = body['msg'];

      setState(() {
        _loading = false;
      });


      setState(() {
        profileName       = _name.text ?? '';
        profilePhone      = _phone.text ?? '';
        profileEmail      = _email.text ?? '';
        profileAddress    = _address.text ?? '';
      });

      AwesomeDialog(context: context,dialogType: DialogType.SUCCES,animType: AnimType.BOTTOMSLIDE,
      title: "Profile Updated",desc: "",btnOkOnPress: (){}, )..show();

    }catch(e){

      AwesomeDialog(
      context: context,
      dialogType: DialogType.ERROR,
      animType: AnimType.BOTTOMSLIDE,
        title: "Sorry, an unexpected error occurred!",
        desc: "[error_code: /profile/update]",
      btnOkOnPress: (){},      
      )..show();

      setState(() {
        _loading = false;
      });
    } 
  } 

  void getProfile() async{
    _name.text    = profileName;
    _phone.text   = profilePhone;
    _email.text   = profileEmail;
    _address.text = profileAddress;    
  } 

  @override
  void initState() {
    getProfile();    
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
          "Profile",
          style: GoogleFonts.lato(color: Colors.black,),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(12),
          child: Column(
            children: [
              

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
                keyboardType: TextInputType.phone,
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
              SizedBox(height: 12,),

              RaisedButton(
                
                padding: EdgeInsets.all(18),
                color: themePrimary,
                disabledColor: themePrimary,
                onPressed: _loading ? null : (){

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
                    updateProfile();
                  }   
                },
                child: _loading ? 

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [              
                    Text("Saving..",style: GoogleFonts.lato(color: Colors.white,fontSize: 16),),
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
        )
      ),
    );
  }
}