import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tool_kit/config/app_preference.dart';
import 'package:gh_tool_package/extension/time.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/theme/app_theme.dart';

final InAppReview inAppReview = InAppReview.instance;

void showCustomRateView(BuildContext? context, String key) {
  if (AppPreference.instance.getInt(key) != null) return;
  showRateView();
  AppPreference.instance.setInt(key, currentMilliseconds());

  // BuildContext? showContext = context ?? navigatorKey.currentState?.overlay?.context;
  // if (showContext != null) {
  //   showRateDialog(showContext);
  //   AppPreference.instance.setInt(key, currentMilliseconds());
  // }
}

Future<void> showRateView() async {
  if (await inAppReview.isAvailable()) inAppReview.requestReview();
}

void openStorePage() async {
  final InAppReview inAppReview = InAppReview.instance;
  var appStoreId = "";
  var microsoftStoreId = "";
  inAppReview.openStoreListing(appStoreId: appStoreId, microsoftStoreId: microsoftStoreId);
}

Future<void> showRateDialog(BuildContext context) async {
  Widget getStartIcon() {
    return const Expanded(
      child: Icon(
        Icons.star,
        size: 35,
        color: Colors.amber,
      ),
    );
  }

  return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          content: SizedBox(
            height: 140,
            child: Column(
              children: [
                const Text(
                  "rate_title",
                  style: TextStyle(color: AppTheme.nearlyBlack, fontSize: 17),
                ).tr(),
                const SizedBox(height: 10),
                SizedBox(
                  height: 40,
                  child: Row(
                    children: [
                      getStartIcon(),
                      getStartIcon(),
                      getStartIcon(),
                      getStartIcon(),
                      getStartIcon(),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 40,
                  child: TextButton(
                    style: ButtonStyle(backgroundColor: MaterialStateProperty.resolveWith((states) {
                      if (states.contains(MaterialState.pressed)) {
                        return AppTheme.actionGreen;
                      } else if (states.contains(MaterialState.disabled)) {
                        return AppTheme.actionGreen;
                      }
                      return AppTheme.actionGreen;
                    })),
                    child: const Text(
                      'rate_now',
                      style: TextStyle(color: AppTheme.white, fontSize: 17),
                    ).tr(),
                    onPressed: () {
                      AppNavigator.popPage();
                      Future.delayed(const Duration(milliseconds: 300)).then((value) => openStorePage());
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      });
}
