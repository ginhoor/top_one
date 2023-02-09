import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:top_one/app/app.dart';
import 'package:top_one/app/app_navigator_observer.dart';
import 'package:top_one/app/app_preferences.dart';
import 'package:top_one/theme/fitness_app_theme.dart';
import 'package:top_one/tool/time.dart';

final InAppReview inAppReview = InAppReview.instance;

void showCustomRateView(BuildContext? context, String key) {
  if (AppPreference().getInt(key) != null) return;
  BuildContext? showContext =
      context ?? navigatorKey.currentState?.overlay?.context;
  if (showContext != null) {
    showRateDialog(showContext);
    AppPreference().setInt(key, currentMilliseconds());
  }
}

void showRateView() async {
  if (await inAppReview.isAvailable()) inAppReview.requestReview();
}

void openStorePage() async {
  final InAppReview inAppReview = InAppReview.instance;
  var appStoreId = "";
  var microsoftStoreId = "";
  inAppReview.openStoreListing(
      appStoreId: appStoreId, microsoftStoreId: microsoftStoreId);
}

Future<void> showRateDialog(BuildContext context) async {
  return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          content: LayoutBuilder(builder: (context, constraints) {
            Widget getStartIcon() {
              return const Expanded(
                child: Icon(
                  Icons.star,
                  size: 35,
                  color: Colors.amber,
                ),
              );
            }

            return SizedBox(
              width: constraints.maxWidth,
              height: 140,
              child: Column(
                children: [
                  const Text(
                    "rate_title",
                    style: TextStyle(
                        color: FitnessAppTheme.nearlyBlack, fontSize: 17),
                  ).tr(),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: constraints.maxWidth,
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
                    width: constraints.maxWidth,
                    child: TextButton(
                      style: ButtonStyle(backgroundColor:
                          MaterialStateProperty.resolveWith((states) {
                        if (states.contains(MaterialState.pressed)) {
                          return FitnessAppTheme.actionGreen;
                        } else if (states.contains(MaterialState.disabled)) {
                          return FitnessAppTheme.actionGreen;
                        }
                        return FitnessAppTheme.actionGreen;
                      })),
                      child: const Text(
                        'rate_now',
                        style: TextStyle(
                            color: FitnessAppTheme.white, fontSize: 17),
                      ).tr(),
                      onPressed: () {
                        openStorePage();
                        AppNavigator.popPage();
                      },
                    ),
                  ),
                ],
              ),
            );
          }),
        );
      });
}