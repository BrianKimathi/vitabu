import 'dart:developer';
import 'dart:ui';

// import 'package:yourappname/subscription/allpayment.dart';
import 'package:yourappname/model/packagemodel.dart' show Result;
import 'package:yourappname/subscription/allpayment.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/provider/packageprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/iconoir.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class Subscription extends StatefulWidget {
  const Subscription({super.key});

  @override
  State<Subscription> createState() => _SubscriptionState();
}

class _SubscriptionState extends State<Subscription> {
  SharedPref sharedPre = SharedPref();
  String price = "", packageid = "";
  late PackageProvider packageprovider;
  String? userName, userEmail, userMobileNo, isBuy;

  @override
  void initState() {
    packageprovider = Provider.of<PackageProvider>(context, listen: false);
    getData();
    getApi();
    super.initState();
  }

  getData() async {
    userName = await sharedPre.read("fullname");
    userEmail = await sharedPre.read("newEmail");
    userMobileNo = await sharedPre.read("mobilenumber");
    isBuy = await sharedPre.read("userpremium");
    log("Suc======$isBuy");
    printLog("username -----?? $userName");
    printLog("userEmail -----?? $userEmail");
    printLog("userMobileNo -----?? $userMobileNo");
  }

  updateDataDialog({
    required bool isNameReq,
    required bool isEmailReq,
    required bool isMobileReq,
  }) async {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final mobileController = TextEditingController();
    if (!mounted) return;
    dynamic result = await showModalBottomSheet<dynamic>(
      context: context,
      backgroundColor: white,
      isScrollControlled: true,
      isDismissible: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      clipBehavior: Clip.antiAliasWithSaveLayer,
      builder: (BuildContext context) {
        return Wrap(
          children: [
            Utils.dataUpdateDialog(
              context,
              isNameReq: isNameReq,
              isEmailReq: isEmailReq,
              isMobileReq: isMobileReq,
              nameController: nameController,
              emailController: emailController,
              mobileController: mobileController,
            ),
          ],
        );
      },
    );
    if (result != null) {
      await getData();
    }
  }

  getApi() {
    packageprovider.getPackage();
  }

  @override
  void dispose() {
    packageprovider.clearProvider();
    super.dispose();
  }

  final List<Map<String, dynamic>> _featureConfig = [
    {
      "key": 1,
      "title": "Unlimited Reading",
      "image": 'ic_reading.png',
    },
    {
      "key": 2,
      "title": "Access on Mobile & Web",
      "image": 'ic_phone.png',
    },
    {
      "key": 3,
      "title": "Dark Mode Reading",
      "image": 'ic_lightdark.png',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.isDarkMode ? appbarcolor : white,
      appBar: Utils.cusstomAppBar(
          name: "subscription",
          centerTitle: false,
          multilanguage: true,
          context: context),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: Consumer<PackageProvider>(
          builder: (context, provider, child) {
            if (provider.loading) {
              return subscriptionPageShimmer();
            }

            if (provider.getpackageModel.result == null ||
                provider.getpackageModel.result!.isEmpty) {
              return NoData();
            }

            final selectedPlan = provider.selectedPlan;

            return SingleChildScrollView(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  MyText(
                    text: 'choosesubplan',
                    fontsize: Dimens.text28Size,
                    fontwaight: FontWeight.w600,
                    multilanguage: true,
                    textalign: TextAlign.center,
                  ),
                  const SizedBox(height: 7),
                  MyText(
                    text: 'choosesubplandesc',
                    fontsize: Dimens.medium14TextSize,
                    fontwaight: FontWeight.w400,
                    multilanguage: true,
                    textalign: TextAlign.center,
                    maxline: 2,
                  ),
                  const SizedBox(height: 20),
                  if (selectedPlan != null)
                    Consumer<PackageProvider>(
                      builder: (context, provider, _) {
                        if (provider.featureLoading) {
                          return planFeaturesShimmer();
                        }
                        return planFeaturesWidget(
                          accessType: selectedPlan.accessType ?? "",
                          cancelAnytime: selectedPlan.cancelAnytime ?? 0,
                        );
                      },
                    ),
                  const SizedBox(height: 20),
                  ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.getpackageModel.result!.length,
                    itemBuilder: (context, index) {
                      final plan = provider.getpackageModel.result![index];
                      final isSelected = provider.selectedIndex == index;

                      return GestureDetector(
                        onTap: () {
                          provider.selectPlan(index);
                        },
                        child: MediaQuery.removePadding(
                          context: context,
                          removeBottom: true,
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSelected
                                    ? Constant.isDarkMode
                                        ? colorPrimaryDark
                                        : colorPrimary
                                    : const Color(0xFFC4CCCC),
                                width: 2,
                              ),
                              color: Constant.isDarkMode ? black : white,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    MyText(
                                      text: plan.name ?? "",
                                      fontsize: Dimens.largeTextSize,
                                      fontwaight: FontWeight.w700,
                                      color:
                                          Constant.isDarkMode ? white : black,
                                      fontstyle: FontStyle.normal,
                                      isfont: 3,
                                      maxline: 1,
                                      multilanguage: false,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),

                                MyText(
                                  text: getPlanSubtitle(plan.type ?? ""),
                                  fontsize: Dimens.medium13TextSize,
                                  isfont: 3,
                                  fontstyle: FontStyle.normal,
                                  maxline: 1,
                                  fontwaight: FontWeight.w400,
                                  overflow: TextOverflow.ellipsis,
                                  multilanguage: false,
                                  textalign: TextAlign.left,
                                  color: Constant.isDarkMode ? white : black,
                                ),

                                const SizedBox(height: 8),

                                Row(
                                  children: [
                                    MyText(
                                      text: "\$${plan.price}",
                                      fontsize: Dimens.text30Size,
                                      fontwaight: FontWeight.w600,
                                      isfont: 3,
                                      fontstyle: FontStyle.normal,
                                      maxline: 1,
                                      overflow: TextOverflow.ellipsis,
                                      multilanguage: false,
                                      textalign: TextAlign.left,
                                      color: Constant.isDarkMode
                                          ? colorPrimaryDark
                                          : black,
                                    ),
                                    MyText(
                                      text: getPlanPriceSuffix(plan.type ?? ""),
                                      fontsize: Dimens.medium14TextSize,
                                      isfont: 3,
                                      fontstyle: FontStyle.normal,
                                      maxline: 1,
                                      fontwaight: FontWeight.w400,
                                      overflow: TextOverflow.ellipsis,
                                      multilanguage: false,
                                      textalign: TextAlign.left,
                                      color:
                                          Constant.isDarkMode ? white : black,
                                    ),
                                  ],
                                ),

                                /// AUTO RENEW
                                if (plan.autoRenew == 1)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Row(
                                      children: [
                                        Icon(Icons.check,
                                            size: 16,
                                            color: Constant.isDarkMode
                                                ? colorPrimaryDark
                                                : colorPrimary),
                                        const SizedBox(width: 6),
                                        MyText(
                                          text: "autorenew",
                                          fontsize: Dimens.medium14TextSize,
                                          fontstyle: FontStyle.normal,
                                          isfont: 3,
                                          fontwaight: FontWeight.w400,
                                          maxline: 1,
                                          multilanguage: true,
                                          overflow: TextOverflow.ellipsis,
                                          color: Constant.isDarkMode
                                              ? white
                                              : black.withOpacity( 0.9),
                                        ),
                                        SizedBox(
                                          width: 5,
                                        ),
                                        MyText(
                                          text: "${plan.type}",
                                          fontsize: Dimens.medium14TextSize,
                                          fontstyle: FontStyle.normal,
                                          isfont: 3,
                                          fontwaight: FontWeight.w400,
                                          maxline: 1,
                                          multilanguage: false,
                                          overflow: TextOverflow.ellipsis,
                                          color: Constant.isDarkMode
                                              ? white
                                              : black.withOpacity( 0.9),
                                        ),
                                      ],
                                    ),
                                  ),

                                if (plan.cancelAnytime == 1)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Row(
                                      children: [
                                        Icon(Icons.check,
                                            size: 16,
                                            color: Constant.isDarkMode
                                                ? colorPrimaryDark
                                                : colorPrimary),
                                        const SizedBox(width: 6),
                                        MyText(
                                          text: "cancleanytime",
                                          fontsize: Dimens.medium14TextSize,
                                          fontstyle: FontStyle.normal,
                                          isfont: 3,
                                          fontwaight: FontWeight.w400,
                                          maxline: 1,
                                          multilanguage: true,
                                          overflow: TextOverflow.ellipsis,
                                          color: Constant.isDarkMode
                                              ? white
                                              : black.withOpacity( 0.9),
                                        ),
                                      ],
                                    ),
                                  ),

                                if (isSelected) ...[
                                  const SizedBox(height: 12),
                                  Divider(
                                    thickness: 1,
                                    color: Constant.isDarkMode ? white : black,
                                  ),
                                  // const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.check,
                                          size: 18,
                                          color: Constant.isDarkMode
                                              ? colorPrimaryDark
                                              : colorPrimary),
                                      const SizedBox(width: 6),
                                      MyText(
                                          text: 'selectedplan',
                                          maxline: 1,
                                          fontsize: Dimens.medium14TextSize,
                                          fontwaight: FontWeight.w600,
                                          isfont: 3,
                                          fontstyle: FontStyle.normal,
                                          multilanguage: true,
                                          color: Constant.isDarkMode
                                              ? colorPrimaryDark
                                              : colorPrimary),
                                      const SizedBox(width: 6),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  InkWell(
                    onTap: () {
                      showPlanDetailsBottomSheet(context);
                    },
                    child: MyText(
                      text: 'viewplandetails',
                      fontsize: Dimens.medium16TextSize,
                      fontwaight: FontWeight.w600,
                      color:
                          Constant.isDarkMode ? colorPrimaryDark : colorPrimary,
                      overflow: TextOverflow.ellipsis,
                      underline: true,
                      isfont: 3,
                      fontstyle: FontStyle.normal,
                      underlineColor:
                          Constant.isDarkMode ? colorPrimaryDark : colorPrimary,
                      underlineThickness: 1.2,
                      multilanguage: true,
                      textalign: TextAlign.center,
                      maxline: 2,
                    ),
                  ),
                  Consumer<PackageProvider>(
                    builder: (context, provider, child) {
                      final selectedPlan = provider.selectedPlan;

                      return Padding(
                        padding: const EdgeInsets.only(top: 20),
                        child: SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            onPressed: selectedPlan == null
                                ? null
                                : () {
                                    showConfirmSubscriptionDialog(
                                        context, selectedPlan);
                                  },
                            child: MyText(
                              text: selectedPlan == null
                                  ? "chooseplan"
                                  : getStartButtonText(selectedPlan),
                              fontsize: Dimens.medium15TextSize,
                              fontwaight: FontWeight.w600,
                              isfont: 3,
                              fontstyle: FontStyle.normal,
                              maxline: 1,
                              overflow: TextOverflow.ellipsis,
                              multilanguage: selectedPlan == null,
                              color: white,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  /* Bill Model bottom sheet */

  void showConfirmSubscriptionDialog(BuildContext context, Result plan) {
    final nextBillingDate = calculateNextBillingDate(
      type: plan.type ?? "",
      time: plan.time ?? 1,
    );

    String formatDate(DateTime date) {
      return DateFormat("MMMM dd, yyyy").format(date);
    }

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Confirm Subscription",
      barrierColor: black.withOpacity( 0.2), // dim
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 6,
            sigmaY: 6,
          ),
          child: Center(
            child: Dialog(
              backgroundColor:
                  Constant.isDarkMode ? const Color(0xFF313333) : white,
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /// TITLE
                    Center(
                      child: MyText(
                        text: "confirmsubscription",
                        fontsize: Dimens.medium16TextSize,
                        fontwaight: FontWeight.w600,
                        isfont: 2,
                        multilanguage: true,
                        color: Constant.isDarkMode ? colorAccent : black,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// PLAN
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(
                          text: "plan",
                          fontsize: Dimens.medium16TextSize,
                          multilanguage: true,
                          fontwaight: FontWeight.w400,
                          isfont: 3,
                          color: Constant.isDarkMode
                              ? white.withOpacity( 0.6)
                              : gray,
                        ),
                        MyText(
                          text: plan.name ?? "",
                          fontsize: Dimens.medium15TextSize,
                          fontwaight: FontWeight.w600,
                          isfont: 3,
                          color: Constant.isDarkMode ? white : black,
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    /// AMOUNT
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(
                          text: "amt",
                          fontsize: Dimens.medium16TextSize,
                          multilanguage: true,
                          fontwaight: FontWeight.w400,
                          isfont: 3,
                          color: Constant.isDarkMode
                              ? white.withOpacity( 0.6)
                              : gray,
                        ),
                        MyText(
                          text:
                              "\$${plan.price}${getPlanPriceSuffix(plan.type ?? "")}",
                          fontsize: Dimens.medium15TextSize,
                          fontwaight: FontWeight.w600,
                          isfont: 3,
                          color: Constant.isDarkMode ? white : black,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),
                    const Divider(),

                    /// NEXT BILLING DATE
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        MyText(
                          text: "nextbillingdate",
                          fontsize: Dimens.medium14TextSize,
                          multilanguage: true,
                          fontwaight: FontWeight.w400,
                          isfont: 3,
                          color: gray,
                        ),
                        MyText(
                          text: formatDate(nextBillingDate),
                          fontsize: Dimens.medium15TextSize,
                          fontwaight: FontWeight.w600,
                          isfont: 3,
                          color: Constant.isDarkMode ? white : black,
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    if (plan.autoRenew == 1) _dot(text: "autorenew_note"),
                    if (plan.cancelAnytime == 1) _dot(text: "cancel_note"),
                    _dot(text: "reminder_note"),

                    const SizedBox(height: 20),

                    /// CONFIRM BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 46,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                          Utils.push(
                            context,
                            AllPayment(
                              issubscription: 1,
                              itemId: plan.id.toString(),
                              price: plan.price.toString(),
                              itemTitle: plan.name,
                              renewdate: formatDate(nextBillingDate),
                            ),
                          );
                        },
                        child: const MyText(
                          text: "confirmandsubscribe",
                          fontsize: Dimens.medium14TextSize,
                          fontwaight: FontWeight.bold,
                          multilanguage: true,
                          isfont: 3,
                          color: white,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// GO BACK
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(4)),
                        width: double.infinity,
                        height: 46,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Iconify(
                              MaterialSymbols.home_outline_rounded,
                              color: Constant.isDarkMode
                                  ? colorPrimaryDark
                                  : black,
                            ),
                            MyText(
                              text: "goback",
                              fontsize: Dimens.medium14TextSize,
                              fontwaight: FontWeight.bold,
                              multilanguage: true,
                              isfont: 3,
                              color: Constant.isDarkMode
                                  ? colorPrimaryDark
                                  : black,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.0).animate(anim1),
            child: child,
          ),
        );
      },
    );
  }

  void showBlurDialog(BuildContext context, Widget child) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Blur Dialog",
      barrierColor: black.withOpacity( 0.2), // optional dim
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 6,
            sigmaY: 6,
          ),
          child: SafeArea(
            child: Center(
              child: child, // your dialog widget
            ),
          ),
        );
      },
      transitionBuilder: (context, anim1, anim2, child) {
        return FadeTransition(
          opacity: anim1,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.9, end: 1.0).animate(anim1),
            child: child,
          ),
        );
      },
    );
  }

  Widget planFeaturesWidget({
    required String accessType, // "1,2,3"
    required int cancelAnytime, // 0 or 1
  }) {
    final accessList = accessType
        .split(',')
        .map((e) => int.tryParse(e.trim()))
        .whereType<int>()
        .toList();

    final List<Map<String, dynamic>> features = [];

    for (var feature in _featureConfig) {
      if (accessList.contains(feature["key"])) {
        features.add(feature);
      }
    }

    if (cancelAnytime == 1) {
      features.add({
        "key": 99,
        "title": "Cancel Anytime",
        "image": 'ic_cancle.png',
      });
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.9,
      ),
      itemCount: features.length,
      itemBuilder: (context, index) {
        final item = features[index];

        return MediaQuery.removePadding(
          context: context,
          removeBottom: true,
          child: Container(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            decoration: BoxDecoration(
              color: Constant.isDarkMode ? Color(0xFF272828) : white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: Constant.isDarkMode ? black : Color(0xFFEEF0F3)),
              boxShadow: [
                BoxShadow(
                  color: black.withOpacity( 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(height: 5),
                MyImage(
                  imagePath: item["image"],
                  fit: BoxFit.contain,
                  height: 24,
                  width: 24,
                ),
                const SizedBox(height: 15),
                Expanded(
                  child: MyText(
                    text: item["title"],
                    fontsize: Dimens.medium14TextSize,
                    fontwaight: FontWeight.w600,
                    color: Constant.isDarkMode ? white : black,
                    fontstyle: FontStyle.normal,
                    isfont: 3,
                    multilanguage: false,
                    overflow: TextOverflow.ellipsis,
                    textalign: TextAlign.center,
                    maxline: 2,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  static Widget _dot({required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 30),
      child: Row(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 5,
            width: 5,
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Constant.isDarkMode ? white : black),
          ),
          Expanded(
            child: MyText(
              text: text,
              fontsize: Dimens.medium13TextSize,
              fontwaight: FontWeight.w400,
              isfont: 3,
              fontstyle: FontStyle.normal,
              textalign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              multilanguage: true,
              color: Constant.isDarkMode ? white : black.withOpacity( 0.6),
              maxline: 2,
            ),
          ),
        ],
      ),
    );
  }

/* Helper functions */

  String getStartButtonText(Result plan) {
    final type = plan.type?.toLowerCase() ?? "";

    String label;
    switch (type) {
      case "month":
        label = "Monthly";
        break;
      case "year":
        label = "Yearly";
        break;
      case "week":
        label = "Weekly";
        break;
      case "day":
        label = "Daily";
        break;
      default:
        label = "";
    }

    return "Start $label - \$${plan.price}";
  }

  String getPlanSubtitle(String type) {
    switch (type.toLowerCase()) {
      case "month":
        return "Flexible month-to-month billing";
      case "year":
        return "Save with annual billing";
      case "week":
        return "Flexible weekly billing";
      case "day":
        return "Daily access";
      default:
        return "";
    }
  }

  String getPlanPriceSuffix(String type) {
    switch (type.toLowerCase()) {
      case "month":
        return "/ Month";
      case "year":
        return "/ Year";
      case "week":
        return "/ Week";
      case "day":
        return "/ Day";
      default:
        return "";
    }
  }

  DateTime calculateNextBillingDate({
    required String type,
    required int time,
    DateTime? fromDate,
  }) {
    final DateTime baseDate = fromDate ?? DateTime.now();

    switch (type.toLowerCase()) {
      case "day":
        return baseDate.add(Duration(days: time));

      case "week":
        return baseDate.add(Duration(days: 7 * time));

      case "month":
        return DateTime(
          baseDate.year,
          baseDate.month + time,
          baseDate.day,
        );

      case "year":
        return DateTime(
          baseDate.year + time,
          baseDate.month,
          baseDate.day,
        );

      default:
        return baseDate;
    }
  }

/* View plan Model Bottom sheet */

  void showPlanDetailsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Constant.isDarkMode ? Color(0xFF313333) : white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return const PlanDetailsBottomSheet();
      },
    );
  }

/* ================================= Shimmmer widget ========================== */

  Widget subscriptionPageShimmer() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          const SizedBox(height: 10),

          const CustomWidget.roundrectborder(height: 28, width: 220),
          const SizedBox(height: 7),

          const CustomWidget.roundrectborder(
              height: 14, width: double.infinity),
          const SizedBox(height: 6),
          const CustomWidget.roundrectborder(height: 14, width: 260),

          const SizedBox(height: 20),

          /// Features shimmer
          planFeaturesShimmer(),

          const SizedBox(height: 20),

          /// Plan list shimmer
          planListShimmer(),
          const CustomWidget.roundrectborder(height: 16, width: 160),

          const SizedBox(height: 20),

          /// Start button shimmer
          const CustomWidget.roundcorner(height: 48),
        ],
      ),
    );
  }

  Widget planListShimmer() {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 2,
      itemBuilder: (_, __) {
        return Container(
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFC4CCCC), width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              CustomWidget.roundrectborder(height: 18, width: 160),
              SizedBox(height: 6),
              CustomWidget.roundrectborder(height: 14, width: 120),
              SizedBox(height: 10),
              CustomWidget.roundrectborder(height: 30, width: 140),
              SizedBox(height: 8),
              CustomWidget.roundrectborder(height: 14, width: 180),
            ],
          ),
        );
      },
    );
  }

  Widget planFeaturesShimmer() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 14,
        crossAxisSpacing: 14,
        childAspectRatio: 1.9,
      ),
      itemCount: 2,
      itemBuilder: (context, index) {
        return Container(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
          decoration: BoxDecoration(
            color: Constant.isDarkMode ? graycolor : white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEEF0F3)),
            boxShadow: [
              BoxShadow(
                color: black.withOpacity( 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CustomWidget.circular(height: 24, width: 24),
              SizedBox(height: 12),
              CustomWidget.roundrectborder(height: 14, width: 90),
              SizedBox(height: 6),
              CustomWidget.roundrectborder(height: 14, width: 70),
            ],
          ),
        );
      },
    );
  }
}

class PlanDetailsBottomSheet extends StatelessWidget {
  const PlanDetailsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 15, right: 10, top: 15, bottom: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                text: "plan_details",
                fontsize: Dimens.medium20TextSize,
                fontwaight: FontWeight.w600,
                color: Constant.isDarkMode ? white : black,
                isfont: 3,
                multilanguage: true,
              ),
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.close, color: gray),
              ),
            ],
          ),
        ),
        Divider(color: gray, thickness: 2),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Color(0xFFD0FAE5),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Icon(Icons.check, color: green, size: 20),
                  ),
                  SizedBox(width: 8),
                  MyText(
                    text: "whats_included",
                    fontsize: Dimens.medium15TextSize,
                    fontwaight: FontWeight.w600,
                    isfont: 3,
                    multilanguage: true,
                    color: Constant.isDarkMode ? white : black,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _bullet(
                text: "included_1",
              ),
              _bullet(
                text: "included_2",
              ),
              _bullet(
                text: "included_3",
              ),
              _bullet(
                text: "included_4",
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Color(0xFFFFE2E2),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Iconify(Iconoir.cancel, color: red, size: 20),
                    ),
                  ),
                  SizedBox(width: 8),
                  MyText(
                    text: "not_included",
                    fontsize: Dimens.medium15TextSize,
                    fontwaight: FontWeight.w600,
                    isfont: 3,
                    multilanguage: true,
                    color: Constant.isDarkMode ? white : black,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _bullet(
                text: "not_included_1",
                isNegative: true,
              ),
              _bullet(
                text: "not_included_2",
                isNegative: true,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      color: Color(0xFFDBEAFE),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: Iconify(
                        MaterialSymbols.autorenew,
                        color: Color(0xFF4C6EF5),
                        size: 20,
                      ),
                    ),
                  ),
                  SizedBox(width: 8),
                  MyText(
                    text: "billing_details",
                    fontsize: Dimens.medium15TextSize,
                    fontwaight: FontWeight.w600,
                    isfont: 3,
                    multilanguage: true,
                    color: Constant.isDarkMode ? white : black,
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _dot(
                text: "billing_1",
              ),
              _dot(
                text: "billing_2",
              ),
              _dot(
                text: "billing_3",
              ),
              _dot(
                text: "billing_4",
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const MyText(
                    text: "got_it",
                    fontsize: Dimens.medium14TextSize,
                    fontwaight: FontWeight.w600,
                    isfont: 3,
                    multilanguage: true,
                    color: white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  static Widget _bullet({
    required String text,
    bool isNegative = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 30),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            isNegative ? Icons.close : Icons.check,
            size: 16,
            color: isNegative ? red : green,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: MyText(
              text: text,
              fontsize: Dimens.medium15TextSize,
              fontwaight: FontWeight.w400,
              isfont: 3,
              multilanguage: true,
              color: Constant.isDarkMode ? white : black,
              maxline: 2,
            ),
          ),
        ],
      ),
    );
  }

  /// • dot bullet
  static Widget _dot({required String text}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 30),
      child: Row(
        spacing: 10,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 5,
            width: 5,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Constant.isDarkMode ? white : black,
            ),
          ),
          Expanded(
            child: MyText(
              text: text,
              fontsize: Dimens.medium15TextSize,
              fontwaight: FontWeight.w400,
              isfont: 3,
              fontstyle: FontStyle.normal,
              overflow: TextOverflow.ellipsis,
              multilanguage: true,
              color: Constant.isDarkMode ? white : black,
              maxline: 2,
            ),
          ),
        ],
      ),
    );
  }
}
