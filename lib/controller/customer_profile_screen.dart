import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart';
import 'package:rounded_loading_button/rounded_loading_button.dart';
import 'package:safe/controller/custom_progress_dialog.dart';
import 'package:safe/controller/custom_toast_message.dart';
import 'package:safe/controller/dialogs/delete_customer_dialog.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/customer.dart';
import 'package:safe/utils/alpha_numeric_utils.dart';
import 'package:widget_mask/widget_mask.dart';
import 'package:safe/controller/toggle_switch.dart';

class CustomerProfileScreenNew extends StatefulWidget {
  static const String idScreen = "CustomerProfileScreen";

  const CustomerProfileScreenNew({Key? key}) : super(key: key);

  @override
  _CustomerProfileScreenNewState createState() =>
      _CustomerProfileScreenNewState();
}

enum Gender { female, male }

class _CustomerProfileScreenNewState extends State<CustomerProfileScreenNew> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String get _getCustomerID => FirebaseAuth.instance.currentUser!.uid;
  final picker = ImagePicker();
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();

  late ImageProvider _defaultProfileImage;

  Customer? _currentCustomer;

  Gender _character = Gender.female;
  File? _profileFile;
  FileImage? _profileImage;

  bool _networkProfileLoaded = false;
  late ImageProvider _networkProfileImage;
  bool _enableRegisterBtn = false;

  final RoundedLoadingButtonController _CustomerLoadingBtnController =
      RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();

    _defaultProfileImage = AssetImage('images/mask2.png');

    __initAsync__();
  }

  void __initAsync__() async {
    _currentCustomer = Customer.fromSnapshot(
      await FirebaseFirestore.instance
          .collection(FIRESTORE_PATHS.COL_CUSTOMERS)
          .doc(_getCustomerID)
          .get(),
    );

    if (!_currentCustomer!.documentExists()) {
      _currentCustomer = null;
      return;
    }

    _nameController.text = _currentCustomer!.user_name ?? '';
    _lastNameController.text = _currentCustomer!.last_user_name ?? '';
    _emailController.text = _currentCustomer!.email ?? '';

    var gender_value = _currentCustomer!.gender;

    if (gender_value == 1) {
      _character = Gender.female;
    } else {
      _character = Gender.male;
    }

    Map<String, dynamic> customerJSON = _currentCustomer!.toJson();

    loadNetworkProfileImage();

    setState(() {});
  }

  final Shader linearGradient = LinearGradient(
    colors: <Color>[Color(0xffDE0000), Color(0xff990000)],
  ).createShader(Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            decoration: new BoxDecoration(
                image: new DecorationImage(
                    image: AssetImage('images/safeLogo.png'),
                    fit: BoxFit.cover)),
            child: Column(
              children: [
                SizedBox(height: 20.0),
                // don't bother to show UI if customer caching isn't complete
                if (_currentCustomer != null) ...[
                  Padding(
                    padding: EdgeInsets.fromLTRB(22.0, 22.0, 22.0, 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 12.0),
                        BackButton(color: Color(0xff990000)),
                        SizedBox(height: 12.0),
                        Text(
                          'Welcome, ${_nameController.text.trim()}',
                          style: TextStyle(
                              fontFamily: 'Lato',
                              fontSize: 30.0,
                              letterSpacing: 2,
                              fontWeight: FontWeight.w900,
                              foreground: Paint()..shader = linearGradient),
                        ),

                        // Driver Name
                        SizedBox(height: 26.0),
                        GestureDetector(
                          onTap: () async {
                            XFile? pickedXFile = await picker.pickImage(
                                source: ImageSource.gallery);

                            if (pickedXFile != null) {
                              _profileFile = File(pickedXFile.path);
                              _profileImage = FileImage(_profileFile!);
                            } else {
                              _profileFile = null;
                              _profileImage = null;
                            }
                            setState(() {});
                          },
                          child: Container(
                            child: WidgetMask(
                              blendMode: BlendMode.srcATop,
                              childSaveLayer: true,
                              mask: Image(
                                  image: _networkProfileLoaded
                                      ? _networkProfileImage
                                      : _defaultProfileImage,
                                  fit: BoxFit.fill),
                              child: Image.asset(
                                'images/mask2.png',
                                width: MediaQuery.of(context).size.width * 0.20,
                                height:
                                    MediaQuery.of(context).size.height * 0.10,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 26.0),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: Color(0xffE1E0DF),
                          ),
                          child: TextField(
                            controller: _nameController,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 13.0, horizontal: 20.7),
                                hintText: 'Last Name',
                                hintStyle: TextStyle(color: Colors.black),
                                fillColor: Colors.white),
                            style: TextStyle(fontSize: 15.0),
                          ),
                        ),
                        // Car Model
                        SizedBox(height: 10.0),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: Color(0xffE1E0DF),
                          ),
                          child: TextField(
                            controller: _lastNameController,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 13.0, horizontal: 20.7),
                                hintText: 'Last Name',
                                hintStyle: TextStyle(color: Colors.black),
                                fillColor: Colors.white),
                            style: TextStyle(fontSize: 15.0),
                          ),
                        ),
                        Center(
                            child: Container(
                          margin: EdgeInsets.only(
                              top: MediaQuery.of(context).size.height * 0.01),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text('ፆታ : ',
                                  style: TextStyle(
                                      color: Colors.grey.shade700,
                                      fontFamily: 'Lato',
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800)),
                              SizedBox(
                                  width:
                                      MediaQuery.of(context).size.width * 0.05),
                              Container(
                                //width: MediaQuery.of(context).size.width * 0.8,
                                child: ToggleSwitch(
                                  minWidth:
                                      MediaQuery.of(context).size.width * 0.20,
                                  cornerRadius: 20.0,
                                  activeBgColors: [
                                    [Colors.blue[900]!],
                                    [Color(0xFFFC2085)],
                                  ],
                                  activeFgColor: Colors.white,
                                  inactiveBgColor: Colors.grey,
                                  inactiveFgColor: Colors.white,
                                  initialLabelIndex:
                                      _character == Gender.male ? 0 : 1,
                                  totalSwitches: 2,
                                  labels: ['ወንድ', 'ሴት'],
                                  animate: true,
                                  animationDuration: 200,
                                  customTextStyles: [
                                    TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14.0)
                                  ],
                                  radiusStyle: true,
                                  onToggle: (index) {
                                    _character = (index == 0)
                                        ? Gender.male
                                        : Gender.female;
                                    if (mounted) {
                                      setState(() {});
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        )),

                        SizedBox(height: 10.0),

                        Container(
                          width: MediaQuery.of(context).size.width * 0.9,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            color: Color(0xffE1E0DF),
                          ),
                          child: TextField(
                            style: TextStyle(color: Colors.black),
                            // keyboardType: TextInputType.text,
                            controller: _emailController,
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 13.0, horizontal: 20.7),
                                hintText: 'Email ',
                                hintStyle: TextStyle(color: Colors.black),
                                fillColor: Colors.white),
                          ),
                        ),

                        SizedBox(height: 40.0),
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    height: MediaQuery.of(context).size.height *
                                        0.042,
                                    child: RoundedLoadingButton(
                                      child: Text('Update',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      controller: _CustomerLoadingBtnController,
                                      onPressed: () {
                                        if (_nameController.text
                                            .trim()
                                            .isEmpty) {
                                          displayToastMessage(
                                              'Please Specify Name', context);
                                        } else if (_lastNameController.text
                                            .trim()
                                            .isEmpty) {
                                        } else {
                                          updateCustomerInfo(context);
                                        }
                                      },
                                      color: _enableRegisterBtn
                                          ? Color(0xffDD0000)
                                          : Color(0xff990000),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 40.0),
                        Center(
                          child: Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: Row(
                              children: <Widget>[
                                Expanded(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.35,
                                    height: MediaQuery.of(context).size.height *
                                        0.042,
                                    child: RoundedLoadingButton(
                                      child: Text('Delete Account ',
                                          style:
                                              TextStyle(color: Colors.white)),
                                      controller: _CustomerLoadingBtnController,
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (_) => DeleteDialog()
                                        );
                                      },
                                      color: _enableRegisterBtn
                                          ? Color(0xff03702a)
                                          : Color(0xff016b2b),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: 26.0),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  String getFileExtension(String filename) {
    int lastIndex = filename.lastIndexOf(".");
    return filename.substring(lastIndex);
  }

  void updateCustomerInfo(BuildContext context) async {
    Map<String, dynamic> updateFields = Map();

    updateFields[Customer.FIELD_USER_NAME] = _nameController.text.trim();
    updateFields[Customer.FIELD_USER_LAST_NAME] =
        _lastNameController.text.trim();
    updateFields[Customer.FIELD_EMAIL] = _emailController.text.trim();
    updateFields[Customer.FIELD_GENDER] = _character == Gender.female
        ? Customer.GENDER_FEMALE
        : Customer.GENDER_MALE;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          CustomProgressDialog(message: 'Updating Profile, Please Wait...'),
    );

    /**
     * This isn't a local picture, so ignore it.
     * Its either the default one, or already uploaded image
     */

    String fileName = basename(_profileFile!.path);

    String fileExtension =
        AlphaNumericUtil.extractFileExtensionFromName(fileName);

    String convertedFilePath = Customer.convertStoragePathToCustomerPath(
        _getCustomerID, fileName, fileExtension);

    firebase_storage.Reference firebaseStorageRef = firebase_storage
        .FirebaseStorage.instance
        .ref()
        .child(convertedFilePath);
    firebase_storage.UploadTask uploadTask =
        firebaseStorageRef.putFile(_profileFile!);
    firebase_storage.TaskSnapshot taskSnapshot =
        await uploadTask.whenComplete(() => null);
    String downloadURL = await taskSnapshot.ref.getDownloadURL();

    updateFields[fileName] = downloadURL;

    await FirebaseFirestore.instance
        .collection(FIRESTORE_PATHS.COL_CUSTOMERS)
        .doc(_getCustomerID)
        .set(updateFields, SetOptions(merge: true));

    _CustomerLoadingBtnController.reset();
    // dismiss progress dialog
    Navigator.pop(context);
  }

  void loadNetworkProfileImage() async {
    _networkProfileLoaded = false;
    if (_currentCustomer == null ||
        _currentCustomer!.link_img_profile == null) {
      return;
    }

    try {
      _networkProfileImage = NetworkImage(_currentCustomer!.link_img_profile!);

      _networkProfileImage
          .resolve(new ImageConfiguration())
          .addListener(ImageStreamListener(
            (_, __) {
              _networkProfileLoaded = true;
              setState(() {});
            },
            onError: (_, __) {
              _networkProfileLoaded = false;
              setState(() {});
            },
          ));
    } catch (err) {}
  }
}
