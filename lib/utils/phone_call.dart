import 'package:url_launcher/url_launcher.dart';

class PhoneCaller {
  static Future<void> callPhone(String phoneNumber) async {
    String url = "tel:$phoneNumber";
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not call $phoneNumber';
    }
  }

}
