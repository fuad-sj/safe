import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:path/path.dart';
import 'package:safe/controller/custom_progress_dialog.dart';
import 'package:safe/controller/custom_toast_message.dart';
import 'package:safe/models/FIREBASE_PATHS.dart';
import 'package:safe/models/customer.dart';
import 'package:safe/utils/alpha_numeric_utils.dart';

class CustomerProfileScreen extends StatefulWidget {
  static const String idScreen = "CustomerProfileScreen";

  const CustomerProfileScreen({Key? key}) : super(key: key);

  @override
  _CustomerProfileScreenState createState() => _CustomerProfileScreenState();
}

class _ImgCache {
  Widget img;
  bool isDefaultImg;
  bool isLocalImg;
  File? imgFile;

  _ImgCache({
    required this.img,
    required this.isDefaultImg,
    required this.isLocalImg,
    this.imgFile,
  });
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _emailController = TextEditingController();

  Customer? _currentCustomer;

  String get _getCustomerID => FirebaseAuth.instance.currentUser!.uid;

  final picker = ImagePicker();

  Map<String, _ImgCache> _cacheImgWidgets = Map();

  @override
  void initState() {
    super.initState();

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
    _emailController.text = _currentCustomer!.email ?? '';

    Widget defaultIcon = Icon(
      Icons.add_a_photo,
      size: 50,
      color: Colors.grey.shade600,
    );

    Map<String, dynamic> customerJSON = _currentCustomer!.toJson();

    loadFieldImage(customerJSON, defaultIcon, Customer.FIELD_LINK_IMG_PROFILE);

    setState(() {});
  }

  Future<void> loadFieldImage(Map<String, dynamic> customerJson,
      Widget defaultIcon, String fieldName) async {
    _cacheImgWidgets[fieldName] = _ImgCache(
      img: defaultIcon,
      isDefaultImg: true,
      isLocalImg: false,
    );

    if (customerJson[fieldName] != null) {
      Image m = Image.network(
        customerJson[fieldName],
        fit: BoxFit.scaleDown,
      );

      _cacheImgWidgets[fieldName] = _ImgCache(
        img: m,
        isDefaultImg: false,
        isLocalImg: false,
      );

      setState(() {});
    }
  }

  Widget _getCustomerFieldImage(
      BuildContext context, String fieldName, String fieldTitle) {
    final double IMG_HEIGHT = 150;

    _ImgCache cachedImg = _cacheImgWidgets[fieldName]!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          fieldTitle,
          style: TextStyle(fontFamily: 'Brand-Bold', fontSize: 16.0),
        ),
        SizedBox(height: 10.0),
        TextButton(
          onPressed: () async {
            XFile? pickedXFile =
                await picker.pickImage(source: ImageSource.gallery);

            if (pickedXFile != null) {
              setState(() {
                _ImgCache cache = _cacheImgWidgets[fieldName]!;

                cache.imgFile = File(pickedXFile.path);
                cache.img = Image.file(cache.imgFile!);
                cache.isLocalImg = true;
                cache.isDefaultImg = false;

                _cacheImgWidgets[fieldName] = cache;
              });
            }
          },
          child: cachedImg.isDefaultImg
              ? Container(
                  width: double.infinity,
                  child: Center(
                    child: cachedImg.img,
                  ),
                )
              : Container(
                  height: IMG_HEIGHT,
                  width: MediaQuery.of(context).size.width / 1.25,
                  child: cachedImg.img,
                ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 22.0),
              // don't bother to show UI if customer caching isn't complete
              if (_currentCustomer != null) ...[
                Padding(
                  padding: EdgeInsets.fromLTRB(22.0, 22.0, 22.0, 32.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 12.0),
                      Text('Enter Profile Details',
                          style: TextStyle(
                              fontFamily: 'Brand-Bold',
                              fontSize: 24.0,
                              fontWeight: FontWeight.bold)),

                      // Driver Name
                      SizedBox(height: 26.0),
                      TextField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10.0),
                        ),
                        style: TextStyle(fontSize: 15.0),
                      ),

                      // Car Model
                      SizedBox(height: 10.0),
                      TextField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          hintStyle:
                              TextStyle(color: Colors.grey, fontSize: 10.0),
                        ),
                        style: TextStyle(fontSize: 15.0),
                      ),

                      // Profile Image
                      SizedBox(height: 20.0),
                      _getCustomerFieldImage(
                        context,
                        Customer.FIELD_LINK_IMG_PROFILE,
                        'Profile Image',
                      ),

                      SizedBox(height: 42.0),

                      TextButton(
                        onPressed: () {
                          if (_nameController.text.trim().isEmpty) {
                            displayToastMessage('Please Specify Name', context);
                          } else {
                            updateCustomerInfo(context);
                          }
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(
                              horizontal: 45.0, vertical: 20.0),
                          backgroundColor: Colors.orange.shade800,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(35.0),
                          ),
                        ),
                        child: Container(
                          width: double.infinity,
                          child: Center(
                            child: Text(
                              'Update',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Open Sans',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
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
    updateFields[Customer.FIELD_EMAIL] = _emailController.text.trim();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) =>
          CustomProgressDialog(message: 'Updating Profile, Please Wait...'),
    );

    for (String fieldName in _cacheImgWidgets.keys) {
      _ImgCache imgCache = _cacheImgWidgets[fieldName]!;

      /**
       * This isn't a local picture, so ignore it.
       * Its either the default one, or already uploaded image
       */
      if (!imgCache.isLocalImg) continue;

      String fileName = basename(imgCache.imgFile!.path);

      String fileExtension =
          AlphaNumericUtil.extractFileExtensionFromName(fileName);

      String convertedFilePath = Customer.convertStoragePathToCustomerPath(
          _getCustomerID, fieldName, fileExtension);

      firebase_storage.Reference firebaseStorageRef = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child(convertedFilePath);
      firebase_storage.UploadTask uploadTask =
          firebaseStorageRef.putFile(imgCache.imgFile!);
      firebase_storage.TaskSnapshot taskSnapshot =
          await uploadTask.whenComplete(() => null);
      String downloadURL = await taskSnapshot.ref.getDownloadURL();

      updateFields[fieldName] = downloadURL;
    }

    await FirebaseFirestore.instance
        .collection(FIRESTORE_PATHS.COL_CUSTOMERS)
        .doc(_getCustomerID)
        .set(updateFields, SetOptions(merge: true));

    // dismiss progress dialog
    Navigator.pop(context);
  }
}
