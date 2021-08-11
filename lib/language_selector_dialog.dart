import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:safe/current_locale.dart';
import 'package:safe/utils/pref_util.dart';

class LanguageSelectorDialog extends StatelessWidget {
  static const List<_LanguageOption> LANGUAGE_OPTIONS = [
    _LanguageOption(languageName: 'አማርኛ', localeCode: 'am'),
    _LanguageOption(languageName: 'Afaan Oromoo', localeCode: 'it'),
    _LanguageOption(languageName: 'English', localeCode: 'en'),
    //_LanguageOption(languageName: '中文', localeCode: 'zh'),
  ];

  const LanguageSelectorDialog({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double edgePadding = screenWidth * 0.20 / 2.0; // 20% of screen width

    return Dialog(
      elevation: 2.0,
      insetPadding: EdgeInsets.symmetric(horizontal: edgePadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            color: Colors.red.shade400,
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: Text(
                'ቋንቋ ምርጫ | Choose Language',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18.0,
                ),
              ),
            ),
          ),
          SizedBox(height: 5.0),

          // Language Options
          Container(
            width: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: LANGUAGE_OPTIONS.map((option) {
                return TextButton(
                  onPressed: () async {
                    await PrefUtil.setUserLanguageLocale(option.localeCode);
                    Provider.of<CurrentLocale>(context, listen: false)
                        .setLocale(option.localeCode);
                    Navigator.pop(context);
                  },
                  child: Container(
                    padding: EdgeInsets.all(20.0),
                    child: Text(
                      option.languageName,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: PrefUtil.getUserLanguageLocale() ==
                                option.localeCode
                            ? 20.0
                            : 18.0,
                        fontWeight: PrefUtil.getUserLanguageLocale() ==
                                option.localeCode
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          SizedBox(height: 5.0),
        ],
      ),
    );
  }
}

class _LanguageOption {
  final String languageName;
  final String localeCode;

  const _LanguageOption({required this.languageName, required this.localeCode});
}
