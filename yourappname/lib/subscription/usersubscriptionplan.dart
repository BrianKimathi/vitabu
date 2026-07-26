import 'package:yourappname/model/userscriptionmodel.dart';
import 'package:yourappname/pages/bottombar.dart';
import 'package:yourappname/provider/packageprovider.dart';
import 'package:yourappname/subscription/subscriptionhistory.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:iconify_flutter/icons/ion.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/ri.dart';
import 'package:iconify_flutter/icons/uit.dart';
import 'package:provider/provider.dart';

class Usersubscriptionplan extends StatefulWidget {
  const Usersubscriptionplan({super.key});

  @override
  State<Usersubscriptionplan> createState() => _UsersubscriptionplanState();
}

class _UsersubscriptionplanState extends State<Usersubscriptionplan> {
  late PackageProvider packageProvider;

  @override
  void initState() {
    super.initState();
    packageProvider = Provider.of<PackageProvider>(context, listen: false);

    packageProvider.getuserplan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.isDarkMode ? appbarcolor : white,
      appBar: AppBar(
        backgroundColor: Constant.isDarkMode ? appbarcolor : white,
        surfaceTintColor: transparent,
        leading: Utils.backButton(context),
        titleSpacing: 0,
        centerTitle: false,
        title: MyText(
          text: "mysubscription",
          fontsize: Dimens.medium16TextSize,
          fontwaight: FontWeight.w600,
          isfont: 3,
          multilanguage: true,
        ),
      ),
      body: Consumer<PackageProvider>(
        builder: (context, provider, child) {
          /// LOADING
          if (provider.planloading) {
            return subscriptionShimmer();
          }

          final model = provider.usersubscriptionmodel;

          if (model.status != 200 ||
              model.result == null ||
              model.result!.isEmpty) {
            return NoData();
          }

          final data = model.result!.first;
          final activePlan = data.activePlan;
          final upcomingPlan = data.upcomingPlan;

          if (activePlan == null) {
            return NoData();
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _subscriptionCard(
                  plan: activePlan,
                  isActive: true,
                  provider: provider,
                  context: context,
                ),
                if (upcomingPlan != null)
                  _subscriptionCard(
                    plan: upcomingPlan,
                    isActive: false,
                    provider: provider,
                    context: context,
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _subscriptionCard({
    required Plan plan,
    required bool isActive,
    required PackageProvider provider,
    required BuildContext context,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Constant.isDarkMode ? const Color(0xFF272828) : white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Constant.isDarkMode
              ? gray.withOpacity( 0.2)
              : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              MyText(
                text: plan.planName ?? "",
                fontsize: Dimens.medium20TextSize,
                fontwaight: FontWeight.w600,
                isfont: 3,
                maxline: 1,
                overflow: TextOverflow.ellipsis,
                color: Constant.isDarkMode ? white : black,
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isActive
                      ? Constant.isDarkMode
                          ? green.withOpacity( 0.3)
                          : green.withOpacity( 0.4) // green
                      : Constant.isDarkMode
                          ? colorAccent
                          : colorAccent.withOpacity( 0.3), // yellow
                  borderRadius: BorderRadius.circular(7),
                ),
                child: MyText(
                  text: isActive ? "active" : "upcoming",
                  fontsize: Dimens.medium12TextSize,
                  fontwaight: FontWeight.w600,
                  multilanguage: true,
                  color: isActive
                      ? Constant.isDarkMode
                          ? white
                          : green
                      : Constant.isDarkMode
                          ? black
                          : colorAccent,
                ),
              )
            ],
          ),

          MyText(
            text: isActive ? "active_subscription" : "upcoming_subscription",
            fontsize: Dimens.medium13TextSize,
            multilanguage: true,
            color: Constant.isDarkMode ? white : gray,
          ),

          Divider(height: 20),

          _infoRow(
            icon: Ion.ios_pricetags_outline,
            title: "price",
            value: "\$${plan.price}/${plan.planType?.toLowerCase() ?? ""}",
          ),

          _infoRow(
            icon: Uit.calender,
            title: isActive ? "renewal_date" : "starts_on",
            value: Utils.formatDate(isActive ? plan.expiryDate : plan.startsAt),
          ),

          _infoRow(
            icon: MaterialSymbols.autorenew,
            title: "auto_renew",
            value: plan.autoRenew == 1 ? "Enabled" : "Disabled",
            subText: plan.autoRenew == 1 ? "auto_renew_desc" : null,
          ),

          _infoRow(
            icon: Ri.device_line,
            title: "device_access",
            value: "2 of 3 devices",
            subText: "device_access_desc",
          ),
          if (isActive)
            Container(
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(width: 1, color: gray)),
              width: double.infinity,
              height: 42,
              child: InkWell(
                onTap: () {
                  Utils.push(context, Subscriptionhistory());
                },
                child: MyText(
                  text: "view_billing_history",
                  fontsize: Dimens.medium14TextSize,
                  fontwaight: FontWeight.w600,
                  isfont: 3,
                  multilanguage: true,
                  color: Constant.isDarkMode ? colorPrimaryDark : black,
                ),
              ),
            ),

          SizedBox(height: 10),

          if (isActive && plan.autoRenew == 1 && plan.cancelAnytime == 1)
            _cancelSection(plan, provider, context),
        ],
      ),
    );
  }

  Widget _cancelSection(
    Plan plan,
    PackageProvider provider,
    BuildContext context,
  ) {
    return Column(
      children: [
        if (plan.autoRenew == 1 && plan.cancelAnytime == 1)
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            height: 42,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(width: 1, color: red),
            ),
            child: InkWell(
              onTap: provider.cancelsubloading
                  ? null
                  : () async {
                      await packageProvider.cancelsubscription(
                        provider.usersubscriptionmodel.result?[0].activePlan?.id
                            .toString(),
                      );
                      if (packageProvider.successModel.status == 200) {
                        if (!context.mounted) return;
                        showSubscriptionfailDialog(
                          context,
                          planName: plan.planName ?? "",
                          renewDate: Utils.formatDate(plan.expiryDate),
                        );
                      } else {
                        if (!context.mounted) return;
                        Utils.showSnackbar(
                            context, 'cancel_subscription_failed', true);
                      }
                    },
              child: provider.cancelsubloading
                  ? SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : MyText(
                      text: "cancel_subscription",
                      fontsize: Dimens.medium14TextSize,
                      fontwaight: FontWeight.w500,
                      isfont: 3,
                      multilanguage: true,
                      color: red,
                    ),
            ),
          ),
        SizedBox(height: 14),
        if (plan.autoRenew == 1 && plan.cancelAnytime == 1)
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Constant.isDarkMode ? appbarcolor : Color(0xFFF2F9FF),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: 5),
                  child: Icon(
                    Icons.info_outline,
                    size: 18,
                    color:
                        Constant.isDarkMode ? colorPrimaryDark : colorPrimary,
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: MyText(
                    text:
                        " ${Locales.string(context, "cancel_note_with_date")} ${Utils.formatDate(plan.expiryDate)}",
                    fontsize: Dimens.medium13TextSize,
                    fontwaight: FontWeight.w400,
                    isfont: 3,
                    multilanguage: false,
                    color: Constant.isDarkMode ? colorPrimaryDark : black,
                    maxline: 3,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget subscriptionShimmer() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Constant.isDarkMode ? appbarcolor : white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Color(0xFFE5E7EB)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// HEADER
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomWidget.roundrectborder(
                  width: 180,
                  height: 20,
                ),
                CustomWidget.roundcorner(
                  width: 60,
                  height: 22,
                ),
              ],
            ),

            SizedBox(height: 8),

            CustomWidget.roundrectborder(
              width: 140,
              height: 14,
            ),

            Divider(height: 24),

            _infoRowShimmer(),
            SizedBox(height: 14),
            _infoRowShimmer(),
            SizedBox(height: 14),
            _infoRowShimmer(),
            SizedBox(height: 14),
            _infoRowShimmer(),
            SizedBox(height: 14),
            CustomWidget.roundcorner(
              height: 25,
            ),
            SizedBox(height: 14),

            CustomWidget.roundcorner(
              height: 42,
            ),

            SizedBox(height: 12),

            /// CANCEL BUTTON
            CustomWidget.roundcorner(
              height: 42,
            ),

            SizedBox(height: 16),

            /// INFO NOTE
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomWidget.circular(
                  width: 18,
                  height: 18,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Column(
                    children: [
                      CustomWidget.roundrectborder(height: 12),
                      SizedBox(height: 6),
                      CustomWidget.roundrectborder(height: 12),
                      SizedBox(height: 6),
                      CustomWidget.roundrectborder(height: 12),
                    ],
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRowShimmer() {
    return Row(
      children: [
        CustomWidget.circular(
          width: 18,
          height: 18,
        ),
        SizedBox(width: 10),
        Expanded(
          child: Column(
            spacing: 15,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomWidget.roundrectborder(height: 14),
              CustomWidget.roundrectborder(
                width: 80,
                height: 14,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// ================= INFO ROW (REUSABLE) =================
  Widget _infoRow({
    required String icon,
    required String title,
    required String value,
    String? subText,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(top: 3),
            child: Iconify(icon,
                size: 18,
                color:
                    Constant.isDarkMode ? white : black.withOpacity( 0.8)),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              spacing: 6,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MyText(
                  text: title,
                  fontsize: Dimens.medium14TextSize,
                  fontwaight: FontWeight.w400,
                  isfont: 3,
                  fontstyle: FontStyle.normal,
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                  multilanguage: true,
                  color: Constant.isDarkMode ? white : gray,
                ),
                MyText(
                  text: value,
                  fontsize: Dimens.medium14TextSize,
                  fontwaight: FontWeight.w500,
                  fontstyle: FontStyle.normal,
                  overflow: TextOverflow.ellipsis,
                  maxline: 2,
                  isfont: 3,
                  multilanguage: false,
                  color: Constant.isDarkMode ? colorPrimaryDark : colorPrimary,
                ),
                if (subText != null)
                  MyText(
                    text: subText,
                    fontsize: Dimens.medium12TextSize,
                    fontwaight: FontWeight.w400,
                    isfont: 3,
                    multilanguage: true,
                    fontstyle: FontStyle.normal,
                    overflow: TextOverflow.ellipsis,
                    maxline: 2,
                    color: gray,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void showSubscriptionfailDialog(
    BuildContext context, {
    required String planName,
    required String renewDate,
  }) {
    showDialog(
      barrierColor: white,
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          backgroundColor: white,
          insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 80),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          child: Container(
            decoration: BoxDecoration(
              color: white,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: gray.withOpacity( 0.3),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: black.withOpacity( 0.7),
                  blurRadius: 25,
                  spreadRadius: 2,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                /// TOP BLACK BAR
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 14,
                    decoration: BoxDecoration(
                      color: black,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(18),
                      ),
                    ),
                  ),
                ),

                /// ⭐ small stars (same)
                Positioned(
                  top: 40,
                  left: 30,
                  child: MyImage(
                    imagePath: 'star.png',
                    height: 14,
                    width: 14,
                  ),
                ),
                Positioned(
                  top: 60,
                  right: 30,
                  child: MyImage(
                    imagePath: 'star.png',
                    height: 14,
                    width: 14,
                  ),
                ),

                /// MAIN CONTENT
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 50, 20, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MyImage(
                        imagePath: 'ic_cancle.png', // red cross image
                        height: 120,
                        width: 120,
                        fit: BoxFit.cover,
                      ),

                      SizedBox(height: 16),

                      MyText(
                        text: "subscription_cancelled",
                        fontsize: Dimens.medium22TextSize,
                        fontwaight: FontWeight.w600,
                        multilanguage: true,
                        isfont: 3,
                        textalign: TextAlign.center,
                        color: black,
                      ),

                      SizedBox(height: 6),

                      /// DESC
                      MyText(
                        text: "subscription_cancelled_desc",
                        fontsize: Dimens.medium14TextSize,
                        fontwaight: FontWeight.w400,
                        multilanguage: true,
                        isfont: 3,
                        textalign: TextAlign.center,
                        color: black,
                        maxline: 2,
                      ),

                      SizedBox(height: 16),

                      /// INFO BOX
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: gray.withOpacity( 0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  text: "plan_type",
                                  fontsize: Dimens.smallTextSize,
                                  multilanguage: true,
                                  color: gray,
                                ),
                                MyText(
                                  text: planName,
                                  fontsize: Dimens.medium14TextSize,
                                  fontwaight: FontWeight.w600,
                                  isfont: 3,
                                  multilanguage: false,
                                  color: black,
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                MyText(
                                  text: "access_until",
                                  fontsize: Dimens.smallTextSize,
                                  multilanguage: true,
                                  color: gray,
                                ),
                                MyText(
                                  text: renewDate,
                                  fontsize: Dimens.medium14TextSize,
                                  fontwaight: FontWeight.w600,
                                  isfont: 3,
                                  multilanguage: false,
                                  color: black,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 18),

                      /// CONTINUE READING
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
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => Bottombar()),
                              (route) => false,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Iconify(
                                Ic.round_menu_book,
                                color: white,
                                size: 20,
                              ),
                              SizedBox(width: 6),
                              MyText(
                                text: "continue_reading",
                                fontsize: Dimens.medium14TextSize,
                                fontwaight: FontWeight.w600,
                                multilanguage: true,
                                isfont: 3,
                                color: white,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 10),

                      /// GO HOME
                      SizedBox(
                        width: double.infinity,
                        height: 46,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                              side: BorderSide(
                                color: gray.withOpacity( 0.5),
                              ),
                            ),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(builder: (_) => Bottombar()),
                              (route) => false,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Iconify(
                                Ri.home_4_line,
                                color: black,
                                size: 22,
                              ),
                              SizedBox(width: 6),
                              MyText(
                                text: "go_home",
                                fontsize: Dimens.medium13TextSize,
                                fontwaight: FontWeight.w600,
                                multilanguage: true,
                                isfont: 3,
                                color: black,
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
