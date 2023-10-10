import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:country_list_pick/country_list_pick.dart';
import 'package:ez_orgnize/General/BirthdayInputWidget.dart';
import 'package:ez_orgnize/General/city_picker.dart';
import 'package:ez_orgnize/General/phone_number.dart';
import 'package:ez_orgnize/General/textFormField.dart';
import 'package:ez_orgnize/General/upload_image_to_firebase.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RegisterInfo extends StatefulWidget {
  final Function(String)? onNationalitySelected;

  const RegisterInfo({this.onNationalitySelected});

  @override
  State<RegisterInfo> createState() => _RegisterInfoState();
}

class _RegisterInfoState extends State<RegisterInfo> {
  var scafoldKey = GlobalKey<FormState>();

  bool editMode = false;

  void _valdiate() async {
    final isValid = scafoldKey.currentState!.validate();

    if (!isValid) {
      return;
    }

    print(FirebaseAuth.instance.currentUser!.uid);


    await FirebaseFirestore.instance
        .collection('Users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .set({
      "FirstName": firstNameCont.text,
      "LastName": lastNameCont.text,
      "PhoneNumber": phone.toString(),
      "City": city.toString(),
      "Nationality": selectedNationality,
      "TimeStamp": DateTime.now(),
    }).then((value) async {

      print('done');
      // Navigator.of(context).pop();
    });
    print('-------------------------------------------------------');
    print(selectedImage);
    await uploadImageToFirestore(selectedImage);
    print('-------------------------------------------------------');
  }

  //Nationality
  String selectedNationality = 'Saudi Arabia';

  //to save birthday
  late DateTime selectedDate;

  var selectedImage;

  String editModeImageURL = '';

  void handleDateSelected(DateTime date) {
    setState(() {
      selectedDate = date;
    });
    // Do something with the selected date
    print('Selected date: $selectedDate');
  }

  var firstNameCont = TextEditingController();
  var lastNameCont = TextEditingController();
  var tallCont = TextEditingController();
  var weightCont = TextEditingController();

  var phone = '';
  var city = 'Riyadh';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Form(
            key: scafoldKey,
            child: Column(
              children: [
                TextForm(
                  hint: 'first name',
                  controler: firstNameCont,
                  valid: (value) {
                    if (value.isEmpty) {
                      return 'pls enter your first name';
                    } else if (value.length == 1) {
                      return 'enter valid name';
                    }
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextForm(
                  hint: 'last name',
                  controler: lastNameCont,
                  valid: (value) {
                    if (value.isEmpty) {
                      return 'pls enter yur last name';
                    } else if (value.length == 1) {
                      return 'pls enter valid name';
                    }
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                BirthdayInputWidget(onDateSelected: handleDateSelected),
                SizedBox(
                  height: 20,
                ),
                TextForm(
                  hint: 'Tall in CM',
                  controler: tallCont,
                  valid: (value) {
                    if (value.isEmpty) {
                      return 'pls enter valid tall in CM';
                    } else if (int.parse(value) < 140 ||
                        int.parse(value) > 220) {
                      return 'pls enter valid tall';
                    }
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                TextForm(
                  hint: 'weight in  KG',
                  controler: weightCont,
                  valid: (value) {
                    if (value.isEmpty) {
                      return 'pls enter weight in KG';
                    } else if (int.parse(value) < 35 ||
                        int.parse(value) > 170) {
                      return 'pls enter valid tall';
                    }
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                PhoneNumberInputWidget(onPhoneNumberChanged: (value) {
                  phone = value;
                }),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Nationality',
                  style: TextStyle(
                    color: Theme.of(context).hintColor,
                  ),
                ),
                SizedBox(height: 8),
                CountryListPick(
                  theme: CountryTheme(
                    initialSelection: 'Saudi Arabia',
                    isShowCode: false,
                  ),
                  initialSelection: '966',
                  onChanged: (CountryCode? code) {
                    setState(
                      () {
                        selectedNationality = code!.name!;
                        print(selectedNationality);
                      },
                    );
                    widget.onNationalitySelected!(selectedNationality);
                  },
                ),
                SizedBox(
                  height: 20,
                ),
                CityPickerWidget(onCitySelected: (value) {
                  city = value;
                }),
                SizedBox(
                  height: 20,
                ),
                Visibility(
                  visible: editMode,
                  child: Container(
                    height: 150,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        image: DecorationImage(
                            image: NetworkImage(editModeImageURL))),
                  ),
                  replacement: GestureDetector(
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: ((builder) => bottomSheet()),
                      );
                    },
                    child: selectedImage != null
                        ? Container(
                            height: 150,
                            width: MediaQuery.of(context).size.width,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: Image.file(
                                selectedImage as File,
                                fit: BoxFit.cover,
                              ),
                            ),
                          )
                        : Container(
                            // margin: EdgeInsets.symmetric(horizontal: 50),
                            height: 150,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Colors.teal,
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(6)),
                            width: MediaQuery.of(context).size.width,
                            child: Column(
                              children: [
                                SizedBox(height: 30),
                                Icon(Icons.account_box, size: 50.0),
                                Text(
                                  'Upload your photo',
                                  style: TextStyle(),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                Divider(),
                ElevatedButton(
                  onPressed: _valdiate,
                  child: Text('savve iinfo'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget bottomSheet() {
    return Container(
      height: 100.0,
      width: MediaQuery.of(context).size.width,
      margin: EdgeInsets.symmetric(
        horizontal: 95,
        vertical: 20,
      ),
      child: Column(
        children: <Widget>[
          Text(
            "",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                TextButton.icon(
                  icon: Icon(Icons.camera,
                      color: Theme.of(context).iconTheme.color),
                  onPressed: () {
                    getImage(ImageSource.camera);
                  },
                  label: Text(
                    "Camera",
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
                Spacer(),
                TextButton.icon(
                  icon: Icon(Icons.image,
                      color: Theme.of(context).iconTheme.color),
                  onPressed: () {
                    getImage(ImageSource.gallery);
                  },
                  label: Text(
                    "Gallery",
                    style: TextStyle(color: Colors.teal),
                  ),
                ),
              ])
        ],
      ),
    );
  }

  Future getImage(ImageSource source) async {
    var image = await ImagePicker.platform
        .getImageFromSource(source: source); //pickImage
    print('printing source of image $source');
    setState(() {
      selectedImage = File(image!.path);
    });
  }
}