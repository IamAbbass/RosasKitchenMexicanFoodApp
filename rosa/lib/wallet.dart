import 'dart:convert';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rosa/model/product_model.dart';
import 'package:rosa/config.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rosa/product_view.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

class Wallet extends StatefulWidget {
  @override
  _WalletState createState() => _WalletState();
}

class _WalletState extends State<Wallet> {

  @override
  void initState() {
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
        title: Text(
          "Wallet",
          style: GoogleFonts.lato(color: Colors.black,),
        ),
      ),
      body: Align(
        alignment: Alignment.center,
        child: Container(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.account_balance_wallet, color: themePrimary, size: 48),
              Text("You have", style: GoogleFonts.lato(color: themePrimary, fontSize: 18)),
              Text(profileWallet, style: GoogleFonts.lato(color: themePrimary, fontSize: 48)),
              Text("In Your Wallet", style: GoogleFonts.lato(color: themePrimary, fontSize: 18)),
            ],
          ),
        ),
      ),
    );
  }
}