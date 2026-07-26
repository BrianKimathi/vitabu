import 'dart:io';
import 'dart:ui';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:yourappname/model/packagemodel.dart' show Result;
import 'package:yourappname/model/userscriptionmodel.dart' hide Result;
import 'package:yourappname/provider/homeprovider.dart';
import 'package:yourappname/provider/packageprovider.dart';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/provider/updateprofileprovider.dart';
import 'package:yourappname/provider/walletprovider.dart';
import 'package:yourappname/subscription/allpayment.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webpages/webgenresprefrneces.dart' hide SizedBox, Container, Row;
import 'package:yourappname/webpages/webhome.dart' hide SizedBox, Container, Row;
import 'package:yourappname/webpages/weblogin.dart' hide SizedBox, Container, Row;
import 'package:yourappname/webwidget/footerweb.dart';
import 'package:yourappname/webwidget/interactive_icon.dart';
import 'package:yourappname/webwidget/interactive_text.dart';
import 'package:yourappname/webwidget/interactivecontainer.dart';
import 'package:yourappname/webwidget/webappbar.dart';
import 'package:yourappname/widget/circularrevealclipper.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/widget/mytextformfield.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:iconify_flutter/icons/iconoir.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/ri.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class WebProfile extends StatefulWidget {
  const WebProfile({super.key});

  @override
  State<WebProfile> createState() => _WebProfileState();
}

class _WebProfileState extends State<WebProfile> {
  ProfileProvider profileProvider = ProfileProvider();
  late UpdateprofileProvider updateprofileProvider;

  late PackageProvider packageprovider;
  File? _image;
  bool iseditimg = false;
  String userid = "", name = "";
  String mobilenumber = "", countryCode = "";
  TextEditingController userNameController = TextEditingController();
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController numberController = TextEditingController();
  TextEditingController bioController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  String? userImage, categoryIds, categoryName, type;
  String? strDeviceType, strPrivacyAndTNC, strDeviceToken;
  final ScrollController _scrollController = ScrollController();
  late WalletProvider walletProvider;
  List<String> categoryNameList = [];

  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();

    /// Providers (SAFE in initState with listen:false)
    packageprovider = Provider.of<PackageProvider>(context, listen: false);
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    updateprofileProvider =
        Provider.of<UpdateprofileProvider>(context, listen: false);
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    /// ✅ ScrollController INIT FIRST
    scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    _getDeviceToken();

    /// API calls after first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getApi();
      fetchTransactionthistory("0", 0);
      packageprovider.getPackage();
    });
  }

  _scrollListener() {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      if ((walletProvider.currentPage ?? 0) < (walletProvider.totalPage ?? 0)) {
        walletProvider.setLoadMore(true);
        fetchTransactionthistory(
            walletProvider.currentIndex, walletProvider.currentPage ?? 0);
      }
    }
  }

  fetchTransactionthistory(type, int? nextPage) {
    walletProvider.setLoading(true);
    walletProvider.getTransactionHistory(type, (nextPage ?? 0) + 1);
  }

  getApi() async {
    await profileProvider.getProfile(Constant.userID ?? "");

    if (profileProvider.profileModel.status == 200) {
      userImage =
          profileProvider.profileModel.result?[0].image.toString() ?? "";
      userNameController.text =
          profileProvider.profileModel.result?[0].userName.toString() ?? "";
      firstnameController.text =
          profileProvider.profileModel.result?[0].firstName.toString() ?? "";
      lastnameController.text =
          profileProvider.profileModel.result?[0].lastName.toString() ?? "";
      numberController.text =
          profileProvider.profileModel.result?[0].mobileNumber.toString() ?? "";
      emailController.text =
          profileProvider.profileModel.result?[0].email.toString() ?? "";
      bioController.text =
          profileProvider.profileModel.result?[0].description.toString() ?? "";
      addressController.text =
          profileProvider.profileModel.result?[0].address.toString() ?? "";
      Constant.initialCountryCode = Utils().getCountryCodeFromNumber(
          profileProvider.profileModel.result?[0].mobileNumber.toString() ??
              "");
      categoryIds =
          profileProvider.profileModel.result?[0].categoryIds.toString() ?? "";
      categoryName =
          profileProvider.profileModel.result?[0].categoryName.toString() ?? "";

      if (categoryName != null) {
        categoryNameList = (categoryName ?? "").split(",");
      }
    }
  }

  _getDeviceToken() async {
    if (kIsWeb) {
      strDeviceType = "3";
      strDeviceToken = "123";
    } else if (Platform.isAndroid) {
      strDeviceType = "1";
      strDeviceToken = await FirebaseMessaging.instance.getToken();
    } else {
      strDeviceType = "2";
      strDeviceToken = OneSignal.User.pushSubscription.id.toString();
    }
  }

  @override
  void dispose() {
    profileProvider.clearWeb();
    walletProvider.clearProvider();
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
    final screenWidth = MediaQuery.of(context).size.width;
    const double maxContentWidth = 1400;
    final contentWidth =
        screenWidth > maxContentWidth ? maxContentWidth : screenWidth - 20;

    return WebAppBar(
      widget: SingleChildScrollView(
        child: Consumer4<ProfileProvider, UpdateprofileProvider, WalletProvider,
            PackageProvider>(
          builder: (context, profileProvider, updateprofileprovider,
              walletprovider, packageprovider, child) {
            return Column(
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints:
                        const BoxConstraints(maxWidth: maxContentWidth),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        /// 🔹 LOADING STATE
                        if (profileProvider.loading) ...[
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              20,
                              10,
                              screenWidth > 1000 ? 0 : 90,
                              10,
                            ),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: CustomWidget.roundrectborder(
                                width: 200,
                                height: 20,
                              ),
                            ),
                          ),
                        ]

                        /// 🔹 LOGGED IN USER
                        else if (profileProvider.profileModel.status == 200 &&
                            (profileProvider.profileModel.result?.isNotEmpty ??
                                false)) ...[
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Utils.buildWebDetailsAppBar(
                              context: context,
                              isHome: false,
                              title1: "account",
                              multilanguage: true,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              20,
                              10,
                              screenWidth > 600 ? 0 : 90,
                              10,
                            ),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: InteractiveText(
                                text:
                                    "${Locales.string(context, "welcome")} ${profileProvider.profileModel.result![0].firstName}",
                                multilanguage: false,
                                maxline: 2,
                                textalign: TextAlign.justify,
                                fontstyle: FontStyle.normal,
                                fontsizeWeb: Dimens.medium16TextSize,
                                fontweight: FontWeight.w500,
                                activeColor: colorPrimary,
                                inctiveColor: black,
                              ),
                            ),
                          ),
                        ]

                        /// 🔹 GUEST USER
                        else ...[
                          Padding(
                            padding: EdgeInsets.fromLTRB(
                              20,
                              10,
                              screenWidth > 600 ? 0 : 30,
                              10,
                            ),
                            child: Align(
                              alignment: Alignment.topRight,
                              child: InteractiveText(
                                text:
                                    "${Locales.string(context, "welcome")} Guest User",
                                multilanguage: false,
                                maxline: 2,
                                textalign: TextAlign.justify,
                                fontstyle: FontStyle.normal,
                                fontsizeWeb: Dimens.medium16TextSize,
                                fontweight: FontWeight.w500,
                                activeColor: colorPrimary,
                                inctiveColor: black,
                              ),
                            ),
                          ),
                        ],

                        /// 🔹 MAIN CONTENT
                        SizedBox(
                          width: contentWidth,
                          child: _buildData(),
                        ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
                FooterWeb(),
              ],
            );
          },
        ),
      ),
    );
  }

  /* Profile Data show */
  Widget _buildData() {
    final isMobile = MediaQuery.of(context).size.width < 800;

    return Padding(
      padding: isMobile
          ? const EdgeInsets.fromLTRB(20, 25, 20, 0)
          : const EdgeInsets.fromLTRB(0, 25, 0, 0),
      child: isMobile
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTopMenuTabs(),
                SizedBox(height: 20),
                rightSideData(),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                leftSideData(),
                SizedBox(width: 20),
                Expanded(child: rightSideData()),
              ],
            ),
    );
  }

  Widget buildTopMenuTabs() {
    String selectedTab = profileProvider.webSelectTabName ?? "";

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _topMenuItem(
            title: "my_profile",
            isSelected: selectedTab == "my_profile",
            onTap: () {
              profileProvider.setWebSelect("1", "my_profile");
            },
          ),
          const SizedBox(width: 8),
          _topMenuItem(
            title: "transaction_history",
            isSelected: selectedTab == "transaction_history",
            onTap: () {
              profileProvider.setWebSelect("2", "transaction_history");
            },
          ),
          const SizedBox(width: 8),
          _topMenuItem(
            title: "mysubscrption",
            isSelected: selectedTab == "mysubscrption",
            onTap: () {
              profileProvider.setWebSelect("3", "mysubscrption");
            },
          ),
          const SizedBox(width: 8),
          _topMenuItem(
            title: "subscriptionplan",
            isSelected: selectedTab == "subscriptionplan",
            onTap: () {
              profileProvider.setWebSelect("4", "subscriptionplan");
              packageprovider.getPackage();
            },
          ),
          const SizedBox(width: 8),
          _topMenuItem(
            title: "delete_account",
            isSelected: selectedTab == "delete_account",
            onTap: () {
              profileProvider.setWebSelect("4", "delete_account");
              _logoutDeleteDialog(
                title: "delete_account",
                subtitle: "delete_account_msg",
                isLogout: false,
              );
            },
          ),
          const SizedBox(width: 8),
          _topMenuItem(
            title: "logout",
            isSelected: selectedTab == "logout",
            onTap: () {
              profileProvider.setWebSelect("5", "log_out");
              _logoutDeleteDialog(
                title: "logout",
                subtitle: "sure_to_logout",
                isLogout: true,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _topMenuItem({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TopMenuButton(
        title: title,
        isSelected: isSelected,
        onTap: onTap,
      ),
    );
  }

  Widget leftSideData() {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF1F4F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionLabel("manage_account"),
          const SizedBox(height: 8),
          _navItem(icon: Icons.person_rounded, label: "my_profile", count: "1", onClick: () => profileProvider.setWebSelect("1", "my_profile")),

          const SizedBox(height: 24),
          _sectionLabel("my_wallet"),
          const SizedBox(height: 8),
          _navItem(icon: Icons.receipt_long_rounded, label: "transaction_history", count: "2", onClick: () {
            profileProvider.setWebSelect("2", "transaction_history");
            walletProvider.currentIndex = "0";
          }),
          _navItem(icon: Icons.subscriptions_rounded, label: "mysubscrption", count: "3", onClick: () {
            profileProvider.setWebSelect("3", "mysubscrption");
            walletProvider.currentIndex = "0";
            packageprovider.getuserplan();
          }),
          _navItem(icon: Icons.dashboard_rounded, label: "subscriptionplan", count: "4", onClick: () {
            profileProvider.setWebSelect("4", "subscriptionplan");
            walletProvider.currentIndex = "0";
            packageprovider.getPackage();
          }),

          const SizedBox(height: 24),
          _sectionLabel("other"),
          const SizedBox(height: 8),
          _navItem(icon: Icons.delete_outline_rounded, label: "delete_account", count: "4", isDestructive: true, onClick: () {
            profileProvider.setWebSelect("4", "delete_account");
            _logoutDeleteDialog(title: "delete_account", subtitle: "delete_account_msg", isLogout: false);
          }),
          _navItem(icon: Icons.logout_rounded, label: "logout", count: "5", isDestructive: true, onClick: () {
            profileProvider.setWebSelect("5", "log_out");
            _logoutDeleteDialog(title: "logout", subtitle: "sure_to_logout", isLogout: true);
          }),
        ],
      ),
    );
  }

  Widget _sectionLabel(String text) {
    return MyText(
      text: text,
      multilanguage: true,
      fontsize: 12,
      fontsizeWeb: 12,
      fontwaight: FontWeight.w700,
      color: const Color(0xFF94A3B8),
    );
  }

  Widget _navItem({required dynamic icon, required String label, required String count, required VoidCallback onClick, bool isDestructive = false}) {
    final isSelected = profileProvider.webSelect == count;
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: InkWell(
        onTap: onClick,
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: isDestructive && isSelected
                ? const Color(0xFFFEF2F2)
                : isSelected
                    ? colorPrimary.withOpacity(0.08)
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: isDestructive && isSelected
                  ? const Color(0xFFDC2626)
                  : isSelected
                      ? colorPrimary
                      : const Color(0xFF64748B)),
              const SizedBox(width: 12),
              Expanded(
                child: MyText(
                  text: label,
                  multilanguage: true,
                  fontsize: 14,
                  fontsizeWeb: 14,
                  fontwaight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  color: isDestructive && isSelected
                      ? const Color(0xFFDC2626)
                      : isSelected
                          ? colorPrimary
                          : const Color(0xFF334155),
                  maxline: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

/* logout and delete button */
  Widget _buildButtonLog({title, onTap, count}) {
    return InteractiveContainer(child: (isHovered) {
      return InkWell(
          hoverColor: transparent,
          splashColor: transparent,
          focusColor: transparent,
          highlightColor: transparent,
          onTap: onTap,
          borderRadius: BorderRadius.circular(5),
          child: AnimatedScale(
            scale: isHovered ? 1.05 : 1,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeInOut,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              decoration: BoxDecoration(
                color: isHovered ? colorPrimary : colorPrimary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: MyText(
                  color: white,
                  multilanguage: true,
                  text: title,
                  textalign: TextAlign.left,
                  fontsize: Dimens.medium14TextSize,
                  fontsizeWeb: Dimens.medium14TextSize,
                  maxline: 1,
                  fontwaight: FontWeight.w500,
                  overflow: TextOverflow.ellipsis,
                  fontstyle: FontStyle.normal),
            ),
          ));
    });
  }

/* Rigth side data stared */

  Widget rightSideData() {
    if (profileProvider.webSelect == "1") {
      return _myProfileData();
    }

    if (profileProvider.webSelect == "2") {
      return _buildTransactionData();
    }

    if (profileProvider.webSelect == "3") {
      return userPlanSection();
    }

    if (profileProvider.webSelect == "4") {
      return subscrptionplan();
    }

    return const SizedBox.shrink();
  }

  Widget _myProfileData() {
    final isWebLayout = MediaQuery.of(context).size.width > 1000;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 800),
        child: Container(
          padding: EdgeInsets.symmetric(
              horizontal: isWebLayout ? 60 : 20, vertical: isWebLayout ? 32 : 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFF1F4F9)),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4, height: 24,
                decoration: BoxDecoration(color: colorPrimary, borderRadius: BorderRadius.circular(2)),
              ),
              const SizedBox(width: 12),
              MyText(
                text: "edit_profile",
                multilanguage: true,
                fontsize: 20,
                fontsizeWeb: 20,
                fontwaight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ],
          ),
          SizedBox(height: isWebLayout ? 30 : 20),
          Align(alignment: Alignment.center, child: _buildImage()),
          SizedBox(height: isWebLayout ? 30 : 20),
          isWebLayout ? _buildWeb() : _buildMobile(),
          SizedBox(height: isWebLayout ? 40 : 20),
          Align(
            alignment: Alignment.centerRight,
            child: InteractiveContainer(child: (isHovered) {
              return InkWell(
                hoverColor: transparent,
                splashColor: transparent,
                focusColor: transparent,
                highlightColor: transparent,
                onTap: () {
                  dynamic image;
                  if (kIsWeb) {
                    image = profileProvider.imageBytes;
                  } else {
                    image =
                        iseditimg && _image != null ? File(_image!.path) : null;
                  }
                  updateAPI(
                    userNameController.text,
                    firstnameController.text,
                    lastnameController.text,
                    emailController.text,
                    numberController.text,
                    addressController.text,
                    bioController.text,
                    categoryIds ?? "",
                    image,
                    strDeviceToken,
                    strDeviceType,
                  );
                },
                borderRadius: BorderRadius.circular(5),
                child: AnimatedScale(
                  scale: isHovered ? 1.05 : 1,
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeInOut,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: isWebLayout ? 45 : 30, vertical: 16),
                    decoration: BoxDecoration(
                      color: isHovered ? colorPrimary : colorPrimary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: updateprofileProvider.isUpdate
                        ? const SizedBox(
                            width: 25,
                            height: 25,
                            child: CircularProgressIndicator(
                              color: white,
                              strokeWidth: 2,
                            ),
                          )
                        : MyText(
                            color: isHovered ? white : white,
                            multilanguage: true,
                            text: "save_changes",
                            textalign: TextAlign.center,
                            fontsize: Dimens.medium16TextSize,
                            fontsizeWeb: Dimens.medium16TextSize,
                            maxline: 1,
                            fontwaight: FontWeight.w500,
                            overflow: TextOverflow.ellipsis,
                          ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    )));
  }

  Widget _buildWeb() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: MyTextFormField(
                controller: firstnameController,
                backgroundColor: white,
                obscureText: false,
                keyboardType: TextInputType.name,
                prefixIcon:
                    Icon(FontAwesomeIcons.user, size: 20, color: colorPrimary),
                borderRadius: 8,
                hintText: "Enter the First name",
                labelText: Locales.string(context, "firstname"),
              ),
            ),
            SizedBox(width: 20),
            Expanded(
              child: MyTextFormField(
                controller: lastnameController,
                prefixIcon:
                    Icon(FontAwesomeIcons.user, size: 20, color: colorPrimary),
                obscureText: false,
                backgroundColor: white,
                borderRadius: 8,
                hintText: 'Enter the Last Name',
                labelText: Locales.string(context, "lastname"),
              ),
            ),
          ],
        ),
        SizedBox(height: 20),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: MyTextFormField(
                controller: emailController,
                backgroundColor: white,
                obscureText: false,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icon(FontAwesomeIcons.envelope,
                    size: 20, color: colorPrimary),
                borderRadius: 8,
                hintText: "Enter the email",
                labelText: Locales.string(context, "email"),
              ),
            ),
            SizedBox(width: 20),
            Expanded(child: numberTextField()),
          ],
        ),
        SizedBox(height: 20),
        MyTextFormField(
          controller: addressController,
          backgroundColor: white,
          obscureText: false,
          keyboardType: TextInputType.text,
          prefixIcon:
              Icon(FontAwesomeIcons.locationPin, size: 20, color: colorPrimary),
          borderRadius: 8,
          hintText: "Enter the Address",
          labelText: Locales.string(context, "address"),
        ),
        SizedBox(height: 20),
        MyTextFormField(
          controller: bioController,
          maxLines: 5,
          minLines: 2,
          prefixIcon:
              Icon(FontAwesomeIcons.file, size: 20, color: colorPrimary),
          obscureText: false,
          backgroundColor: white,
          borderRadius: 8,
          hintText: 'Enter the Bio',
          labelText: Locales.string(context, "bio"),
        ),
        SizedBox(height: 20),
        categoryData(),
      ],
    );
  }

  Widget _buildMobile() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyTextFormField(
          controller: firstnameController,
          backgroundColor: white,
          obscureText: false,
          keyboardType: TextInputType.name,
          prefixIcon:
              Icon(FontAwesomeIcons.user, size: 20, color: colorPrimary),
          borderRadius: 8,
          hintText: "Enter the First name",
          labelText: Locales.string(context, "firstname"),
        ),
        SizedBox(height: 15),
        MyTextFormField(
          controller: lastnameController,
          prefixIcon:
              Icon(FontAwesomeIcons.user, size: 20, color: colorPrimary),
          obscureText: false,
          backgroundColor: white,
          borderRadius: 8,
          hintText: 'Enter the Last Name',
          labelText: Locales.string(context, "lastname"),
        ),
        SizedBox(height: 15),
        MyTextFormField(
          controller: emailController,
          backgroundColor: white,
          obscureText: false,
          keyboardType: TextInputType.emailAddress,
          prefixIcon:
              Icon(FontAwesomeIcons.envelope, size: 20, color: colorPrimary),
          borderRadius: 8,
          hintText: "Enter the email",
          labelText: Locales.string(context, "email"),
        ),
        SizedBox(height: 15),
        numberTextField(),
        SizedBox(height: 15),
        MyTextFormField(
          controller: addressController,
          backgroundColor: white,
          obscureText: false,
          keyboardType: TextInputType.text,
          prefixIcon:
              Icon(FontAwesomeIcons.locationPin, size: 20, color: colorPrimary),
          borderRadius: 8,
          hintText: "Enter the Address",
          labelText: Locales.string(context, "address"),
        ),
        SizedBox(height: 15),
        MyTextFormField(
          controller: bioController,
          maxLines: 5,
          minLines: 2,
          prefixIcon:
              Icon(FontAwesomeIcons.file, size: 20, color: colorPrimary),
          obscureText: false,
          backgroundColor: white,
          borderRadius: 8,
          hintText: 'Enter the Bio',
          labelText: Locales.string(context, "bio"),
        ),
        SizedBox(height: 15),
        categoryData(),
      ],
    );
  }

  Widget _buildImage() {
    return Consumer<ProfileProvider>(builder: (context, provider, child) {
      return Container(
          padding: const EdgeInsets.all(6),
          alignment: Alignment.center,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                  width: 1, color: colorPrimary, style: BorderStyle.solid)),
          child: Stack(children: [
            provider.imageBytes != null
                ? Container(
                    height: 100,
                    width: 100,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: MemoryImage(provider.imageBytes!),
                          fit: BoxFit.contain,
                        )))
                : MyNetworkImage(
                    imagePath: provider.profileModel.status == 200 &&
                            (provider.profileModel.result?.length ?? 0) > 0
                        ? (provider.profileModel.result?[0].image ?? "")
                        : "https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=500&auto=format&fit=crop&q=60&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8NXx8d29tYW58ZW58MHx8MHx8fDA%3D",
                    height: 120,
                    width: 120,
                    radius: 200,
                    fit: BoxFit.contain),
            Positioned(
              bottom: 0,
              right: 2,
              child: InteractiveIcon(
                iconData: FontAwesomeIcons.camera,
                onTap: () async {
                  await provider.pickImageWEB();
                },
                size: 25,
                secondColor: white,
                color: colorPrimary,
              ),
            )
          ]));
    });
  }

  Widget numberTextField() {
    return IntlPhoneField(
      disableLengthCheck: true,
      textAlignVertical: TextAlignVertical.center,
      autovalidateMode: AutovalidateMode.disabled,
      controller: numberController,
      cursorColor: gray,
      style: Utils.googleFontStyle(
          1, 16, FontStyle.normal, black, FontWeight.w500),
      showCountryFlag: false,
      showDropdownIcon: false,
      initialCountryCode: Constant.initialCountryCode,
      dropdownTextStyle: Utils.googleFontStyle(
          1, 16, FontStyle.normal, black, FontWeight.w500),
      keyboardType: TextInputType.phone,
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        fillColor: white,
        border: InputBorder.none,
        filled: true,
        hintStyle: Utils.googleFontStyle(
            1, 14, FontStyle.normal, gray, FontWeight.w500),
        hintText: Locales.string(context, "enteryourmobilenumber"),
        enabledBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(7.0)),
          borderSide: BorderSide(color: gray, width: 1),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(7.0)),
          borderSide: BorderSide(color: gray, width: 1),
        ),
      ),
      onChanged: (phone) {
        mobilenumber = phone.completeNumber;
      },
      onCountryChanged: (country) {
        mobilenumber =
            "+${country.dialCode.toString()} ${numberController.text.toString()}";
        countryCode = "+${country.dialCode.toString()}";
      },
    );
  }

/* ======================================= Profile Data END ======================================= */

/* ======================================= transaction Data started ======================================= */

  Widget _buildTransactionData() {
    final transactions = walletProvider.transactionHistory ?? [];
    String dateRangeText = "Date Range N/A";
    final isLoading = walletProvider.loading; // Check loading state

    if (transactions.isNotEmpty && !isLoading) {
      final firstDate = transactions.first.createdAt;
      final lastDate = transactions.last.createdAt;
      final formattedFirstDate =
          Utils.dateConvert(firstDate ?? "", 'MMM d, yyyy');
      final formattedLastDate =
          Utils.dateConvert(lastDate ?? "", 'MMM d, yyyy');

      if (transactions.length == 1) {
        dateRangeText = formattedFirstDate;
      } else {
        dateRangeText = "$formattedLastDate - $formattedFirstDate";
      }
    }
    Widget dateRangeWidget;

    if (isLoading) {
      dateRangeWidget =
          const CustomWidget.roundrectborder(width: 180, height: 15);
    } else {
      dateRangeWidget = MyText(
          color: white,
          multilanguage: false,
          text: dateRangeText,
          fontsize: Dimens.medium16TextSize,
          fontsizeWeb: Dimens.medium16TextSize,
          maxline: 1,
          fontwaight: FontWeight.w500,
          overflow: TextOverflow.ellipsis,
          fontstyle: FontStyle.normal);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 20,
      children: [
        MyText(
          text: "transaction_history",
          multilanguage: true,
          fontsize: Dimens.medium24TextSize,
          fontsizeWeb: Dimens.medium24TextSize,
          fontwaight: FontWeight.w600,
          color: colorPrimary,
        ),
        Row(
          spacing: 20,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            InteractiveContainer(child: (isHovered) {
              return InkWell(
                  hoverColor: transparent,
                  splashColor: transparent,
                  focusColor: transparent,
                  highlightColor: transparent,
                  onTap:
                      isLoading ? null : () {}, // Disable onTap during loading
                  borderRadius: BorderRadius.circular(5),
                  child: AnimatedScale(
                    scale: isHovered ? 1.05 : 1,
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.easeInOut,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: isHovered ? colorPrimary : colorPrimary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        spacing: 10,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          dateRangeWidget,
                          Icon(
                            Icons.calendar_month_rounded,
                            size: 20,
                            color: white,
                          )
                        ],
                      ),
                    ),
                  ));
            }),
          ],
        ),
        const SizedBox(height: 30),
        _buildTransaction()
      ],
    );
  }

  Widget _buildTransaction() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF1F4F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          tabButton(),
          Container(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 16),
            decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                border: Border(
                    bottom: BorderSide(color: const Color(0xFFE2E8F0)))),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: MyText(
                      color: white.withOpacity( 0.7),
                      text: "ref_id",
                      multilanguage: true,
                      fontsize: Dimens.medium14TextSize,
                      fontsizeWeb: Dimens.medium14TextSize,
                      fontwaight: FontWeight.w600,
                      maxline: 2,
                      textalign: TextAlign.left,
                      fontstyle: FontStyle.normal),
                ),
                Expanded(
                  flex: 3,
                  child: MyText(
                      color: white.withOpacity( 0.7),
                      multilanguage: true,
                      text: "transaction_date",
                      fontsize: Dimens.medium14TextSize,
                      fontsizeWeb: Dimens.medium14TextSize,
                      fontwaight: FontWeight.w600,
                      maxline: 2,
                      textalign: TextAlign.left,
                      fontstyle: FontStyle.normal),
                ),
                Expanded(
                  flex: 3,
                  child: MyText(
                      color: white.withOpacity( 0.7),
                      multilanguage: true,
                      text: "books",
                      fontsize: Dimens.medium14TextSize,
                      fontsizeWeb: Dimens.medium14TextSize,
                      fontwaight: FontWeight.w600,
                      maxline: 2,
                      textalign: TextAlign.left,
                      fontstyle: FontStyle.normal),
                ),
                Expanded(
                  flex: 2,
                  child: MyText(
                      color: white.withOpacity( 0.7),
                      multilanguage: true,
                      text: "amount",
                      fontsize: Dimens.medium14TextSize,
                      fontsizeWeb: Dimens.medium14TextSize,
                      fontwaight: FontWeight.w600,
                      maxline: 2,
                      textalign: TextAlign.left,
                      fontstyle: FontStyle.normal),
                ),
                Expanded(
                  flex: 2,
                  child: MyText(
                      color: white.withOpacity( 0.7),
                      multilanguage: true,
                      text: "status",
                      fontsize: Dimens.medium14TextSize,
                      fontsizeWeb: Dimens.medium14TextSize,
                      fontwaight: FontWeight.w600,
                      maxline: 2,
                      textalign: TextAlign.left,
                      fontstyle: FontStyle.normal),
                ),
              ],
            ),
          ),
          _buildtrMain()
        ],
      ),
    );
  }

  Widget tabButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
              spacing: 25,
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTab(
                    title: "all",
                    count: "0",
                    onTap: () {
                      walletProvider.setTab("0");
                      walletProvider.clearData();
                      fetchTransactionthistory("0", 0);
                    }),
                _buildTab(
                    title: "audio_book",
                    count: "1",
                    onTap: () {
                      walletProvider.setTab("1");
                      walletProvider.clearData();
                      fetchTransactionthistory("1", 0);
                    }),
                _buildTab(
                    title: "books",
                    count: "2",
                    onTap: () {
                      walletProvider.setTab("2");
                      walletProvider.clearData();
                      fetchTransactionthistory("2", 0);
                    }),
                _buildTab(
                    title: "magazines",
                    count: "3",
                    onTap: () {
                      walletProvider.setTab("3");
                      walletProvider.clearData();
                      fetchTransactionthistory("3", 0);
                    }),
              ])),
    );
  }

  Widget _buildTab({title, onTap, count}) {
    final isSelected = walletProvider.currentIndex == count;
    return InteractiveContainer(child: (isHovered) {
      final borderColor = isHovered || isSelected ? colorPrimary : transparent;
      final textColor = isHovered || isSelected ? colorPrimary : white;

      return InkWell(
        hoverColor: transparent,
        splashColor: transparent,
        focusColor: transparent,
        highlightColor: transparent,
        onTap: onTap,
        child: AnimatedScale(
          scale: isHovered || isSelected ? 1 : 0.95,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeInOut,
          child: Container(
            alignment: Alignment.bottomCenter,
            decoration: BoxDecoration(
                border: Border(
                    bottom: BorderSide(
                        width: 2,
                        color: borderColor,
                        style: BorderStyle.solid))),
            padding: const EdgeInsets.only(bottom: 20),
            child: MyText(
                color: textColor,
                multilanguage: true,
                text: title,
                textalign: TextAlign.left,
                fontsize: Dimens.medium18TextSize,
                fontsizeWeb: Dimens.medium18TextSize,
                maxline: 1,
                fontwaight: FontWeight.w500,
                overflow: TextOverflow.ellipsis,
                fontstyle: FontStyle.normal),
          ),
        ),
      );
    });
  }

  Widget _buildtrMain() {
    if (walletProvider.loading &&
        !walletProvider.loadMore &&
        walletProvider.transactionHistory?.isEmpty == true) {
      return _buildtrShimmer();
    } else {
      if (walletProvider.transactionHistory != null &&
          (walletProvider.transactionHistory?.length ?? 0) > 0) {
        return Column(
          children: [
            _buildtrData(),
            const SizedBox(height: 30),
            if (!(walletProvider.loading || walletProvider.loadMore))
              _buildPaginationControls(),
            const SizedBox(height: 30),
          ],
        );
      } else {
        return const NoData();
      }
    }
  }

  Widget _buildPaginationControls() {
    final currentPageInt = walletProvider.currentPage ?? 0;
    final totalPages = walletProvider.totalPage ?? 0;
    final isLoading = walletProvider.loading || walletProvider.loadMore;
    final currentApiPage = currentPageInt > 0 ? currentPageInt - 1 : 0;

    if (totalPages <= 1) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedOpacity(
          opacity: currentApiPage > 0 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: InkWell(
            onTap: isLoading || currentApiPage <= 0
                ? null
                : () {
                    int newApiPage = currentApiPage - 1;

                    walletProvider.setPagination(walletProvider.totalRows,
                        totalPages, newApiPage + 1, walletProvider.isMorePage);
                    walletProvider.clearData();
                    fetchTransactionthistory(
                        walletProvider.currentIndex, newApiPage);
                  },
            child: Icon(Icons.arrow_back_ios,
                color: isLoading || currentApiPage <= 0 ? gray : colorPrimary,
                size: 20),
          ),
        ),
        const SizedBox(width: 20),
        MyText(
          text: "${currentApiPage + 1} / $totalPages",
          multilanguage: false,
          fontsize: Dimens.medium16TextSize,
          fontwaight: FontWeight.w500,
          color: white,
        ),
        const SizedBox(width: 20),
        AnimatedOpacity(
          opacity: currentApiPage < totalPages - 1 ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 200),
          child: InkWell(
            onTap: isLoading || currentApiPage >= totalPages - 1
                ? null
                : () {
                    int newApiPage = currentApiPage + 1;

                    walletProvider.setPagination(walletProvider.totalRows,
                        totalPages, newApiPage + 1, walletProvider.isMorePage);
                    walletProvider.clearData();
                    fetchTransactionthistory(
                        walletProvider.currentIndex, newApiPage);
                  },
            child: Icon(Icons.arrow_forward_ios,
                color: isLoading || currentApiPage >= totalPages - 1
                    ? gray
                    : colorPrimary,
                size: 20),
          ),
        ),
      ],
    );
  }

  Widget _buildtrData() {
    final transactions = walletProvider.transactionHistory ?? [];

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: transactions.length,
      separatorBuilder: (context, index) {
        return Divider(thickness: 1, color: gray, height: 10);
      },
      itemBuilder: (context, index) {
        final trans = transactions[index];

        final subContentId = trans.subContentId;
        String contentName = subContentId == 1
            ? (trans.subContentName ?? "Episode N/A")
            : (trans.contentName ?? "Content N/A");

        int statusValue = trans.status ?? 0;
        String statusText;
        Color statusColor;
        switch (statusValue) {
          case 1:
            statusText = "active";
            statusColor = green;
            break;
          case 2:
            statusText = "fail";
            statusColor = red;
            break;
          case 0:
          default:
            statusText = "processing";
            statusColor = colorPrimary;
            break;
        }

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: MyText(
                    text: trans.id.toString(),
                    multilanguage: false,
                    maxline: 1,
                    fontsize: Dimens.medium13TextSize,
                    fontsizeWeb: Dimens.medium14TextSize,
                    color: white,
                    fontwaight: FontWeight.w400),
              ),
              Expanded(
                flex: 3,
                child: MyText(
                    text: Utils.dateConvert(
                        trans.createdAt ?? "", 'd MMM yyyy, h:mm a'),
                    multilanguage: false,
                    maxline: 1,
                    fontsize: Dimens.medium15TextSize,
                    fontsizeWeb: Dimens.medium15TextSize,
                    color: white.withOpacity( .5),
                    fontwaight: FontWeight.w400),
              ),
              Expanded(
                flex: 3,
                child: MyText(
                    text: contentName,
                    multilanguage: false,
                    maxline: 1,
                    fontsize: Dimens.medium16TextSize,
                    fontsizeWeb: Dimens.medium16TextSize,
                    color: white,
                    fontwaight: FontWeight.w400),
              ),
              Expanded(
                flex: 2,
                child: MyText(
                    text: "${Constant.currencyCode} ${trans.price ?? 0}",
                    multilanguage: false,
                    maxline: 1,
                    fontsize: Dimens.medium16TextSize,
                    fontsizeWeb: Dimens.medium16TextSize,
                    color: white,
                    fontwaight: FontWeight.w400),
              ),
              Expanded(
                flex: 2,
                child: MyText(
                    text: statusText,
                    multilanguage: true,
                    maxline: 1,
                    fontsize: Dimens.medium16TextSize,
                    fontsizeWeb: Dimens.medium16TextSize,
                    color: statusColor,
                    fontwaight: FontWeight.w400),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildtrShimmer() {
    const int shimmerItemCount = 10;

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: shimmerItemCount,
      separatorBuilder: (context, index) {
        return Divider(thickness: 1, color: gray, height: 10);
      },
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CustomWidget.roundrectborder(width: 50, height: 12),
                ),
              ),
              const Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CustomWidget.roundrectborder(width: 130, height: 12),
                ),
              ),
              const Expanded(
                flex: 3,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CustomWidget.roundrectborder(width: 100, height: 15),
                ),
              ),
              const Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CustomWidget.roundrectborder(width: 60, height: 12),
                ),
              ),
              const Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: CustomWidget.roundrectborder(width: 70, height: 15),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
/* ======================================= Transaction data END  ======================================= */

/*======================================= Subscrption plan  ======================================= */

  Widget subscrptionplan() {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isMobile = screenWidth < 800;

    return Padding(
      padding: isMobile
          ? const EdgeInsets.fromLTRB(16, 10, 16, 20)
          : const EdgeInsets.fromLTRB(0, 10, 0, 30),
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

          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /// TITLE
              MyText(
                text: 'choosesubplan',
                fontsizeWeb: Dimens.text28Size,
                fontwaight: FontWeight.w600,
                multilanguage: true,
                textalign: TextAlign.center,
              ),

              const SizedBox(height: 6),

              /// SUB TITLE
              MyText(
                text: 'choosesubplandesc',
                fontsizeWeb: Dimens.medium14TextSize,
                fontwaight: FontWeight.w400,
                multilanguage: true,
                textalign: TextAlign.center,
                maxline: 2,
              ),

              const SizedBox(height: 22),

              /// FEATURES GRID
              if (selectedPlan != null)
                provider.featureLoading
                    ? planFeaturesShimmer()
                    : planFeaturesWidget(
                        accessType: selectedPlan.accessType ?? "",
                        cancelAnytime: selectedPlan.cancelAnytime ?? 0,
                      ),

              const SizedBox(height: 24),

              planGrid(provider.getpackageModel.result!, packageprovider),
              const SizedBox(height: 20),

              /// VIEW DETAILS
              InkWell(
                onTap: () => showPlanDetailsDialog(context),
                child: MyText(
                  text: 'viewplandetails',
                  fontsizeWeb: Dimens.medium16TextSize,
                  fontwaight: FontWeight.w600,
                  underline: true,
                  multilanguage: true,
                  color: Constant.isDarkMode ? colorPrimary : colorPrimary,
                ),
              ),

              const SizedBox(height: 20),

              /// START BUTTON
              SizedBox(
                width: MediaQuery.sizeOf(context).width / 6,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  onPressed: selectedPlan == null
                      ? null
                      : () {
                          showConfirmSubscriptionDialog(context, selectedPlan);
                        },
                  child: MyText(
                    text: selectedPlan == null
                        ? "chooseplan"
                        : getStartButtonText(selectedPlan),
                    fontsize: Dimens.medium15TextSize,
                    fontwaight: FontWeight.w600,
                    multilanguage: selectedPlan == null,
                    color: white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
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

    return ResponsiveGridList(
      listViewBuilderOptions: ListViewBuilderOptions(
          shrinkWrap: true, physics: NeverScrollableScrollPhysics()),
      horizontalGridSpacing: 14,
      verticalGridSpacing: 20,
      maxItemsPerRow: 4,
      minItemsPerRow: 2,
      minItemWidth: 200,
      children: List.generate(
        features.length,
        (index) => _featureCard(features[index]),
      ),
    );
  }

  Widget _featureCard(Map<String, dynamic> item) {
    return Container(
      padding: const EdgeInsets.fromLTRB(5, 10, 5, 15),
      decoration: BoxDecoration(
        color: Constant.isDarkMode ? const Color(0xFF272828) : white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Constant.isDarkMode ? black : const Color(0xFFEEF0F3),
        ),
        boxShadow: [
          BoxShadow(
            color: black.withOpacity( 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          MyImage(
            imagePath: item["image"],
            height: 24,
            width: 24,
          ),
          const SizedBox(height: 15),
          Expanded(
            child: MyText(
              text: item["title"],
              fontsize: Dimens.medium14TextSize,
              fontwaight: FontWeight.w600,
              textalign: TextAlign.center,
              maxline: 2,
            ),
          ),
        ],
      ),
    );
  }

  Widget planGrid(List<Result> plans, PackageProvider provider) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktopOrTablet = screenWidth >= 800;

    if (!isDesktopOrTablet) {
      // 📱 Mobile – SAME as app
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: plans.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: _planItem(plans[index], provider, index),
          );
        },
      );
    }

    return ResponsiveGridList(
      listViewBuilderOptions: ListViewBuilderOptions(
          shrinkWrap: true, physics: NeverScrollableScrollPhysics()),
      maxItemsPerRow: 2,
      minItemsPerRow: 2,
      horizontalGridSpacing: 16,
      verticalGridSpacing: 16,
      minItemWidth: 220, // tune once (400–460 best)

      children: List.generate(plans.length, (index) {
        return _planItem(plans[index], provider, index);
      }),
    );
  }

  Widget _planItem(Result plan, PackageProvider provider, int index) {
    final isSelected = provider.selectedIndex == index;

    return GestureDetector(
      onTap: () => provider.selectPlan(index),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? colorPrimary : const Color(0xFFC4CCCC),
            width: 2,
          ),
        ),
        child: _planCard(plan, isSelected),
      ),
    );
  }

  Widget _planCard(Result plan, bool isSelected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MyText(
          text: plan.name ?? "",
          fontsizeWeb: Dimens.largeTextSize,
          fontwaight: FontWeight.w700,
          color: Constant.isDarkMode ? white : black,
        ),
        MyText(
          text: getPlanSubtitle(plan.type ?? ""),
          fontsizeWeb: Dimens.medium13TextSize,
          color: Constant.isDarkMode ? white : black,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            MyText(
              text: "\$${plan.price}",
              fontsizeWeb: Dimens.text30Size,
              fontwaight: FontWeight.w600,
              color: Constant.isDarkMode ? colorPrimary : black,
            ),
            MyText(
              text: getPlanPriceSuffix(plan.type ?? ""),
              fontsizeWeb: Dimens.medium14TextSize,
              color: Constant.isDarkMode ? white : black,
            ),
          ],
        ),
        if (plan.autoRenew == 1) _checkRow("autorenew"),
        if (plan.cancelAnytime == 1) _checkRow("cancleanytime"),
        if (isSelected) ...[
          const SizedBox(height: 12),
          Divider(color: Constant.isDarkMode ? white : black),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check,
                  size: 18,
                  color: Constant.isDarkMode ? colorPrimary : colorPrimary),
              const SizedBox(width: 6),
              MyText(
                text: 'selectedplan',
                fontsizeWeb: Dimens.medium14TextSize,
                fontwaight: FontWeight.w600,
                multilanguage: true,
                color: Constant.isDarkMode ? colorPrimary : colorPrimary,
              ),
            ],
          ),
        ]
      ],
    );
  }

  Widget _checkRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          Icon(Icons.check,
              size: 16,
              color: Constant.isDarkMode ? colorPrimary : colorPrimary),
          const SizedBox(width: 6),
          MyText(
            text: text,
            fontsize: Dimens.medium14TextSize,
            multilanguage: true,
            color: Constant.isDarkMode ? white : black,
          ),
        ],
      ),
    );
  }

/* ================================= Shimmmer widget ========================== */

  Widget subscriptionPageShimmer() {
    double startButtonWidth(BuildContext context) {
      final width = MediaQuery.of(context).size.width;
      return width < 800 ? double.infinity : width / 6;
    }

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

          /// Plan grid shimmer
          planGridShimmer(),

          const SizedBox(height: 20),

          /// Start button shimmer (FIXED)
          SizedBox(
            width: startButtonWidth(context),
            height: 48,
            child: const CustomWidget.roundcorner(height: 48),
          ),
        ],
      ),
    );
  }

  Widget planGridShimmer() {
    final screenWidth = MediaQuery.of(context).size.width;
    final bool isDesktopOrTablet = screenWidth >= 800;

    if (!isDesktopOrTablet) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 2,
        itemBuilder: (_, __) {
          return Container(
            margin: const EdgeInsets.only(bottom: 15),
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
                CustomWidget.roundrectborder(height: 14, width: 200),
                SizedBox(height: 10),
                CustomWidget.roundrectborder(height: 30, width: 120),
                SizedBox(height: 8),
                CustomWidget.roundrectborder(height: 14, width: 180),
              ],
            ),
          );
        },
      );
    }

    return ResponsiveGridList(
      listViewBuilderOptions: ListViewBuilderOptions(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
      ),
      minItemWidth: 220,
      maxItemsPerRow: 2,
      minItemsPerRow: 2,
      horizontalGridSpacing: 16,
      verticalGridSpacing: 16,
      children: List.generate(2, (index) {
        return Container(
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
              CustomWidget.roundrectborder(height: 14, width: 200),
              SizedBox(height: 10),
              CustomWidget.roundrectborder(height: 30, width: 120),
              SizedBox(height: 8),
              CustomWidget.roundrectborder(height: 14, width: 180),
            ],
          ),
        );
      }),
    );
  }

  Widget planFeaturesShimmer() {
    return ResponsiveGridList(
      listViewBuilderOptions: ListViewBuilderOptions(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
      ),
      horizontalGridSpacing: 14,
      verticalGridSpacing: 20,
      maxItemsPerRow: 4,
      minItemsPerRow: 2,
      minItemWidth: 200,
      children: List.generate(4, (index) {
        return Container(
          padding: const EdgeInsets.fromLTRB(5, 10, 5, 15),
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
              CustomWidget.roundrectborder(height: 14, width: 120),
            ],
          ),
        );
      }),
    );
  }

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
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 400,
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
                          color: Constant.isDarkMode ? colorPrimary : black,
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
                            backgroundColor: colorPrimary,
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
                                    ? colorPrimary
                                    : black,
                              ),
                              MyText(
                                text: "goback",
                                fontsize: Dimens.medium14TextSize,
                                fontwaight: FontWeight.bold,
                                multilanguage: true,
                                isfont: 3,
                                color: Constant.isDarkMode
                                    ? colorPrimary
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

/* View plan Model Bottom sheet */

  void showPlanDetailsDialog(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "Plan Details",
      barrierColor: Colors.black.withOpacity( 0.3),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, anim1, anim2) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Center(
            child: Dialog(
              backgroundColor:
                  Constant.isDarkMode ? const Color(0xFF313333) : white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 420, // ✅ FIXED WIDTH
                ),
                child: const PlanDetailsBottomSheet(),
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

/*======================================= Subscrption plan  ======================================= */
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

/* ================================= USer Subscrption plan STart  ================================= */

  Widget userPlanSection() {
    return Consumer<PackageProvider>(
      builder: (context, provider, child) {
        if (!provider.planloading &&
            provider.usersubscriptionmodel.status == null) {
          provider.getuserplan();
        }

        /// ⏳ LOADING
        if (provider.planloading) {
          return Column(
            children: [
              _subscriptionCardShimmer(),
              const SizedBox(height: 20),
              _subscriptionCardShimmer(),
            ],
          );
        }

        final model = provider.usersubscriptionmodel;

        if (model.status != 200 ||
            model.result == null ||
            model.result!.isEmpty) {
          return NoData();
        }

        if (provider.showBillingHistory) {
          return BillingHistorySection(
            onBack: () => packageprovider.showPlan(),
          );
        }

        final data = model.result!.first;
        final activePlan = data.activePlan;
        final upcomingPlan = data.upcomingPlan;

        if (activePlan == null) {
          return NoData();
        }

        return Column(
          children: [
            _subscriptionWebCard(
              plan: activePlan,
              isActive: true,
            ),
            const SizedBox(height: 20),
            if (upcomingPlan != null)
              _subscriptionWebCard(
                plan: upcomingPlan,
                isActive: false,
              ),
          ],
        );
      },
    );
  }

  Widget _subscriptionWebCard({
    required Plan plan,
    required bool isActive,
  }) {
    final badgeColor =
        isActive ? const Color(0xFF9AD0C3) : const Color(0xFFFFE8A3);
    final badgeTextColor = isActive ? green : const Color(0xFF8A6D00);
    final badgeText = isActive ? "active" : "upcoming";

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: black.withOpacity( 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MyText(
                    text: plan.planName ?? "",
                    fontsize: Dimens.medium18TextSize,
                    fontwaight: FontWeight.w600,
                  ),
                  const SizedBox(height: 4),
                  MyText(
                    text: isActive
                        ? "active_subscription"
                        : "upcoming_subscription",
                    fontsize: Dimens.medium13TextSize,
                    color: gray,
                    fontstyle: FontStyle.normal,
                    isfont: 3,
                    maxline: 1,
                    multilanguage: true,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: MyText(
                  text: badgeText,
                  fontsize: Dimens.medium12TextSize,
                  fontwaight: FontWeight.w600,
                  isfont: 3,
                  fontstyle: FontStyle.normal,
                  fontsizeWeb: Dimens.medium13TextSize,
                  overflow: TextOverflow.ellipsis,
                  multilanguage: true,
                  maxline: 1,
                  color: badgeTextColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          /// BODY
          /// BODY
          LayoutBuilder(
            builder: (context, constraints) {
              final bool isMobile = constraints.maxWidth < 850;

              if (isMobile) {
                /// 📱 MOBILE / SMALL SCREEN (STACKED)
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _infoItem(
                      icon: Icons.sell_outlined,
                      title: "price",
                      value:
                          "\$${plan.planPrice}/${plan.planType?.toLowerCase()}",
                    ),
                    const SizedBox(height: 14),
                    _infoItem(
                      icon: Icons.calendar_today_outlined,
                      title: isActive ? "renewal_date" : "starts_on",
                      value: Utils.formatDate(plan.expiryDate),
                    ),
                    const SizedBox(height: 14),
                    _infoItem(
                      icon: Icons.autorenew,
                      title: "auto_renew",
                      value: plan.autoRenew == 1 ? "Enabled" : "Disabled",
                      subtitle: plan.autoRenew == 1 ? "auto_renew_desc" : null,
                    ),
                    const SizedBox(height: 14),
                    _infoItem(
                      icon: Icons.devices_outlined,
                      title: "device_access",
                      value: "2 of 3 devices",
                      subtitle: "device_access_desc",
                    ),
                    const SizedBox(height: 20),
                    if (isActive)
                      Consumer<PackageProvider>(
                          builder: (context, provider, child) {
                        return InkWell(
                          onTap: () {
                            printLog("Tap on view billing screen");
                            Provider.of<PackageProvider>(context, listen: false)
                                .showBilling();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: double.infinity,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(width: 1, color: colorPrimary),
                            ),
                            child: MyText(
                              text: "view_billing_history",
                              fontsize: Dimens.medium13TextSize,
                              fontwaight: FontWeight.w600,
                              multilanguage: true,
                              color: colorPrimary,
                            ),
                          ),
                        );
                      }),
                    const SizedBox(height: 12),
                    if (isActive &&
                        plan.cancelAnytime == 1 &&
                        plan.autoRenew == 1)
                      Consumer<PackageProvider>(
                        builder: (context, provider, child) {
                          return InkWell(
                            onTap: () async {
                              await provider.cancelsubscription(
                                provider.usersubscriptionmodel.result?[0]
                                    .activePlan?.id
                                    .toString(),
                              );
                              if (provider.successModel.status == 200) {
                                if (!context.mounted) return;
                                showSubscriptionfailDialog(
                                  context,
                                  planName: plan.planName ?? "",
                                  renewDate: Utils.formatDate(plan.expiryDate),
                                );
                              } else {
                                if (!context.mounted) return;
                                Utils.showSnackbar(context,
                                    'cancel_subscription_failed', true);
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              width: double.infinity,
                              height: 40,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(width: 1, color: red),
                              ),
                              child: MyText(
                                text: "cancel_subscription",
                                fontsize: Dimens.medium13TextSize,
                                fontwaight: FontWeight.w600,
                                multilanguage: true,
                                color: red,
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                );
              }

              /// 🖥️ WEB / LARGE SCREEN (CURRENT UI)
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        _infoItem(
                          icon: Icons.sell_outlined,
                          title: "price",
                          value:
                              "\$${plan.planPrice}/${plan.planType?.toLowerCase()}",
                        ),
                        const SizedBox(height: 18),
                        _infoItem(
                          icon: Icons.calendar_today_outlined,
                          title: isActive ? "renewal_date" : "starts_on",
                          value: Utils.formatDate(plan.expiryDate),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        _infoItem(
                          icon: Icons.autorenew,
                          title: "auto_renew",
                          value: plan.autoRenew == 1 ? "Enabled" : "Disabled",
                          subtitle:
                              plan.autoRenew == 1 ? "auto_renew_desc" : null,
                        ),
                        const SizedBox(height: 18),
                        _infoItem(
                          icon: Icons.devices_outlined,
                          title: "device_access",
                          value: "2 of 3 devices",
                          subtitle: "device_access_desc",
                        ),
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      if (isActive)
                        InkWell(
                          onTap: () {
                            printLog("Tap on view billing screen");
                            Provider.of<PackageProvider>(context, listen: false)
                                .showBilling();
                          },
                          child: Container(
                            alignment: Alignment.center,
                            width: 200,
                            height: 40,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(width: 1, color: colorPrimary),
                            ),
                            child: MyText(
                              text: "view_billing_history",
                              fontsize: Dimens.medium13TextSize,
                              fontwaight: FontWeight.w600,
                              multilanguage: true,
                              color: colorPrimary,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      if (isActive &&
                          plan.cancelAnytime == 1 &&
                          plan.autoRenew == 1)
                        Consumer<PackageProvider>(
                          builder: (context, provider, child) {
                            return InkWell(
                              onTap: () async {
                                await provider.cancelsubscription(
                                  provider.usersubscriptionmodel.result?[0]
                                      .activePlan?.id
                                      .toString(),
                                );
                                if (provider.successModel.status == 200) {
                                  if (!context.mounted) return;
                                  showSubscriptionfailDialog(
                                    context,
                                    planName: plan.planName ?? "",
                                    renewDate:
                                        Utils.formatDate(plan.expiryDate),
                                  );
                                } else {
                                  if (!context.mounted) return;
                                  Utils.showSnackbar(context,
                                      'cancel_subscription_failed', true);
                                }
                              },
                              child: Container(
                                alignment: Alignment.center,
                                width: 200,
                                height: 40,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(width: 1, color: red),
                                ),
                                child: MyText(
                                  text: "cancel_subscription",
                                  fontsize: Dimens.medium13TextSize,
                                  fontwaight: FontWeight.w600,
                                  multilanguage: true,
                                  color: red,
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ],
              );
            },
          ),

          /// INFO NOTE (ACTIVE ONLY)
          if (isActive && plan.cancelAnytime == 1 && plan.autoRenew == 1) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F9FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: colorPrimary, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: MyText(
                      text:
                          " ${Locales.string(context, "cancel_note_with_date")} ${Utils.formatDate(plan.expiryDate)}",
                      fontsize: Dimens.medium13TextSize,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _infoItem({
    required IconData icon,
    required String title,
    required String value,
    String? subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: gray),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyText(
                text: title,
                fontsize: Dimens.medium13TextSize,
                color: gray,
                fontstyle: FontStyle.normal,
                isfont: 3,
                maxline: 1,
                multilanguage: true,
              ),
              const SizedBox(height: 4),
              MyText(
                text: value,
                color: black,
                fontstyle: FontStyle.normal,
                isfont: 3,
                maxline: 1,
                fontsize: Dimens.medium14TextSize,
                fontwaight: FontWeight.w600,
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                MyText(
                  text: subtitle,
                  fontsize: Dimens.medium12TextSize,
                  color: gray,
                  fontstyle: FontStyle.normal,
                  isfont: 3,
                  multilanguage: true,
                  fontsizeWeb: Dimens.medium13TextSize,
                  overflow: TextOverflow.ellipsis,
                  maxline: 3,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _subscriptionCardShimmer() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Constant.isDarkMode ? appbarcolor : white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              CustomWidget.roundrectborder(width: 160, height: 20),
              CustomWidget.roundcorner(width: 60, height: 22),
            ],
          ),

          const SizedBox(height: 12),
          const CustomWidget.roundrectborder(width: 140, height: 14),

          const SizedBox(height: 16),
          const Divider(),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(child: _infoRowShimmer()),
              const SizedBox(width: 20),
              Expanded(child: _infoRowShimmer()),
              const SizedBox(width: 20),
              Column(
                children: const [
                  CustomWidget.roundcorner(width: 160, height: 40),
                  SizedBox(height: 12),
                  CustomWidget.roundcorner(width: 160, height: 40),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          const CustomWidget.roundcorner(height: 50),
        ],
      ),
    );
  }

  Widget _infoRowShimmer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        CustomWidget.roundrectborder(height: 14, width: 120),
        SizedBox(height: 6),
        CustomWidget.roundrectborder(height: 16, width: 160),
        SizedBox(height: 12),
        CustomWidget.roundrectborder(height: 12),
      ],
    );
  }

/* ------ USer Subscrption plan  Fail Dailog ------- */

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
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 400,
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
                              backgroundColor: colorPrimary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushAndRemoveUntil(
                                context,
                                MaterialPageRoute(builder: (_) => WebHome()),
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
                                MaterialPageRoute(builder: (_) => WebHome()),
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
          ),
        );
      },
    );
  }

/* ================================= USer Subscrption plan ENd  ================================= */

  /* Logout and delete Account */

  void _logoutDeleteDialog({
    required String? title,
    required String subtitle,
    required bool isLogout,
  }) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: white,
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
          contentPadding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          actionsPadding:
              const EdgeInsets.only(bottom: 20, right: 20, left: 20),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 50,
                width: 50,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colorPrimary.withOpacity( .2),
                  shape: BoxShape.circle,
                ),
                child: Container(
                  height: 25,
                  width: 25,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: colorPrimary.withOpacity( 0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isLogout
                        ? FontAwesomeIcons.rightFromBracket
                        : FontAwesomeIcons.trash,
                    size: 20,
                    color: colorPrimary,
                  ),
                ),
              ),
              InkWell(
                splashColor: transparent,
                focusColor: transparent,
                hoverColor: transparent,
                onTap: () => Navigator.of(context).pop(),
                child:
                    const Icon(FontAwesomeIcons.xmark, size: 20, color: gray),
              ),
            ],
          ),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              MyText(
                color: black,
                text: title ?? "",
                multilanguage: true,
                textalign: TextAlign.start,
                fontsize: Dimens.medium18TextSize,
                fontsizeWeb: Dimens.medium18TextSize,
                fontwaight: FontWeight.w600,
                maxline: 2,
              ),
              const SizedBox(height: 8),
              MyText(
                color: black,
                text: subtitle,
                multilanguage: true,
                textalign: TextAlign.start,
                fontsize: Dimens.medium14TextSize,
                fontsizeWeb: Dimens.medium14TextSize,
                fontwaight: FontWeight.w400,
                maxline: 3,
              ),
              const SizedBox(height: 10),
            ],
          ),
          actions: [
            Column(
              children: [
                InkWell(
                  splashColor: transparent,
                  hoverColor: transparent,
                  focusColor: transparent,
                  onTap: () async {
                    if (Navigator.canPop(context)) Navigator.pop(context);

                    await Utils.removeUser();
                    Constant.userID = null;
                    Constant.userimage = null;
                    Constant.email = null;
                    if (!context.mounted) return;
                    Navigator.of(context).pushReplacement(
                      PageRouteBuilder(
                        pageBuilder: (context, animation, secondaryAnimation) =>
                            const Weblogin(),
                        transitionsBuilder:
                            (context, animation, secondaryAnimation, child) {
                          const begin = Offset(1.0, 0.0);
                          const end = Offset.zero;
                          const curve = Curves.ease;
                          var tween = Tween(begin: begin, end: end)
                              .chain(CurveTween(curve: curve));
                          return SlideTransition(
                            position: animation.drive(tween),
                            child: child,
                          );
                        },
                      ),
                    );
                  },
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 75),
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: colorPrimary,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorPrimary, width: 1),
                    ),
                    child: MyText(
                      color: white,
                      text: "confirm",
                      multilanguage: true,
                      textalign: TextAlign.center,
                      fontsize: Dimens.medium16TextSize,
                      fontsizeWeb: Dimens.medium16TextSize,
                      fontwaight: FontWeight.w600,
                      maxline: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                InkWell(
                  onTap: () {
                    if (Navigator.canPop(context)) Navigator.pop(context);
                  },
                  child: Container(
                    constraints: const BoxConstraints(minWidth: 75),
                    height: 50,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      border: Border.all(color: gray, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: MyText(
                      color: colorPrimary,
                      text: "cancel",
                      multilanguage: true,
                      textalign: TextAlign.center,
                      fontsize: Dimens.medium16TextSize,
                      fontsizeWeb: Dimens.medium16TextSize,
                      fontwaight: FontWeight.w600,
                      maxline: 1,
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

/* Category Widget Show */
  Widget categoryData() {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.of(context).push(PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) {
            return WebGenresPrefrences(
              isCategoryType: false,
              categoryIds: categoryIds,
              categoryName: categoryName,
              isEditType: "1",
            );
          },
          transitionDuration: Duration(milliseconds: 150),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return ClipPath(
                  clipper: CircularRevealClipper(progress: animation.value),
                  child: child,
                );
              },
              child: child,
            );
          },
        ));

        if (result != null && result is Map<String, dynamic>) {
          type = result['type'] ?? "";
          categoryIds = result['ids'] ?? "";
          categoryName = result['name'] ?? "";
          if (type == '1') {
            categoryNameList = (categoryName ?? "").split(",");
            printLog("New Selected Categories: $categoryNameList");
          }
          updateprofileProvider.providerNotified();
        }

        printLog("New Selected Category: $categoryName");
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Constant.isDarkMode ? colorPrimary : white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: List.generate(
                  categoryNameList.length,
                  (index) {
                    return Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: Constant.isDarkMode ? white : black,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        categoryNameList[index],
                        style: TextStyle(
                          color: Constant.isDarkMode ? black : white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 16),
            Icon(
              Icons.arrow_forward_ios_outlined,
              size: 20,
              color: Constant.isDarkMode ? white : black,
            ),
          ],
        ),
      ),
    );
  }

  /* Updateb profile api */

  updateAPI(
    userName,
    firstName,
    lastName,
    email,
    number,
    address,
    description,
    categoryId,
    image,
    deviceToken,
    deviceType,
  ) async {
    try {
      await updateprofileProvider.getUpdateProfile(
          userName,
          firstName,
          lastName,
          email,
          number,
          address,
          description,
          categoryId,
          image,
          deviceToken,
          deviceType);
      if (updateprofileProvider.userModel.status == 200) {
        Utils.saveUserCreds(
            userID:
                updateprofileProvider.userModel.result?[0].id.toString() ?? "",
            categoryId: updateprofileProvider.userModel.result?[0].categoryIds
                    .toString() ??
                "",
            firstName: updateprofileProvider.userModel.result?[0].firstName
                    .toString() ??
                "",
            lastName:
                updateprofileProvider.userModel.result?[0].lastName.toString() ??
                    "",
            userName:
                updateprofileProvider.userModel.result?[0].userName.toString() ??
                    "",
            userImage:
                updateprofileProvider.userModel.result?[0].image.toString() ??
                    "",
            userEmail:
                updateprofileProvider.userModel.result?[0].email.toString() ??
                    "",
            mobileNumber:
                updateprofileProvider.userModel.result?[0].mobileNumber.toString() ?? "",
            walletCoin: updateprofileProvider.userModel.result?[0].walletAmount.toString() ?? "",
            address: updateprofileProvider.userModel.result?[0].address.toString() ?? "",
            isAuthor: updateprofileProvider.userModel.result?[0].isAuthor.toString() ?? "",
            deviceType: updateprofileProvider.userModel.result?[0].deviceType.toString() ?? "",
            deviceToken: updateprofileProvider.userModel.result?[0].deviceToken.toString() ?? "",
            description: updateprofileProvider.userModel.result?[0].description.toString() ?? "");
        if (!mounted) return;
        final profileProvider =
            Provider.of<ProfileProvider>(context, listen: false);

        profileProvider.setLoding(false);
        profileProvider.getProfile(Constant.userID);

        final homeProvider = Provider.of<HomeProvider>(context, listen: false);
        await homeProvider.getProfile(Constant.userID);

        await CachedNetworkImage.evictFromCache(
            updateprofileProvider.userModel.result?[0].image ?? "");
        if (!mounted) return;
      } else {
        if (!mounted) return;
        Utils.showSnackbar(
            context, updateprofileProvider.userModel.message ?? "", false);
      }
    } catch (e) {
      if (!mounted) return;
      Utils.showSnackbar(
          context, updateprofileProvider.userModel.message ?? "", false);
    }
  }
}

class TopMenuButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;
  final bool isSelected;

  const TopMenuButton({
    super.key,
    required this.title,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? colorPrimary.withOpacity(0.1) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? colorPrimary.withOpacity(0.2) : const Color(0xFFE2E8F0),
          ),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: isSelected ? colorPrimary : const Color(0xFF64748B),
          ),
        ),
      ),
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
                    backgroundColor: colorPrimary,
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

class BillingHistorySection extends StatefulWidget {
  final VoidCallback? onBack;

  const BillingHistorySection({super.key, this.onBack});

  @override
  State<BillingHistorySection> createState() => _BillingHistorySectionState();
}

class _BillingHistorySectionState extends State<BillingHistorySection> {
  late ScrollController _scrollController;
  late PackageProvider provider;

  String selectedFilterLabel = "all";
  int? selectedStatus; // null = all

  @override
  void initState() {
    super.initState();
    provider = context.read<PackageProvider>();

    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.changeHistoryFilter(null);
    });
  }

  void _scrollListener() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        provider.loadmore == false &&
        (provider.historycurrentPage ?? 0) < (provider.historytotalPage ?? 0)) {
      provider.loadMoreHistory(selectedStatus);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PackageProvider>(
      builder: (context, provider, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.onBack != null)
              Row(
                children: [
                  IconButton(
                    onPressed: widget.onBack,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  MyText(
                    text: "subscrptionhistory",
                    fontsize: Dimens.medium18TextSize,
                    fontwaight: FontWeight.w600,
                    multilanguage: true,
                    color: colorPrimary,
                    fontstyle: FontStyle.normal,
                    isfont: 3,
                    maxline: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),

            Container(
              padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 20),
              height: 50,
              // decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(10),
              //     color: colorPrimary),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  MyText(
                    text: selectedFilterLabel,
                    fontsizeWeb: Dimens.medium18TextSize,
                    fontwaight: FontWeight.w500,
                    color: colorPrimary,
                    fontstyle: FontStyle.normal,
                    isfont: 3,
                    overflow: TextOverflow.ellipsis,
                    multilanguage: true,
                  ),
                  InkWell(
                    onTap: _showFilterDialog,
                    child: Iconify(
                      MaterialSymbols.filter_alt_sharp,
                      size: 35,
                      color: Constant.isDarkMode ? white : black,
                    ),
                  ),
                ],
              ),
            ),

            /// LIST
            SizedBox(
              height: 700,
              child: Builder(
                builder: (_) {
                  if (provider.historyloading &&
                      (provider.historyList?.isEmpty ?? true)) {
                    return _transactionShimmer();
                  }

                  if (!provider.historyloading &&
                      (provider.historyList?.isEmpty ?? true)) {
                    return NoData();
                  }

                  return ListView.separated(
                    controller: _scrollController,
                    itemCount: provider.historyList!.length +
                        (provider.loadmore ? 1 : 0),
                    separatorBuilder: (_, __) => const Divider(height: 24),
                    itemBuilder: (_, index) {
                      if (index >= provider.historyList!.length) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final item = provider.historyList![index];
                      final status = item.status ?? 0;
                      final debit = status == 0 || status == 3;

                      return Row(
                        children: [
                          CircleAvatar(
                            radius: 22,
                            backgroundColor: getBgColor(status),
                            child: MyText(
                              text: item.planName
                                      ?.substring(0, 1)
                                      .toUpperCase() ??
                                  "",
                              color: getTextColor(status),
                              fontwaight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  text: item.planName ?? "",
                                  fontwaight: FontWeight.w600,
                                ),
                                MyText(
                                  text: Utils.formatTransactionDate(
                                      item.buyDate ?? ""),
                                  fontsize: Dimens.medium13TextSize,
                                  color: gray,
                                ),
                              ],
                            ),
                          ),
                          MyText(
                            text: "${debit ? "-" : "+"}\$${item.price ?? 0}",
                            fontwaight: FontWeight.w600,
                            color: getTextColor(status),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }

  /// FILTER SHEET
  void _showFilterDialog() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 12),
                _filterItem("all", null),
                _filterItem("expired", 0),
                _filterItem("active", 1),
                _filterItem("upcoming", 2),
                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _filterItem(String label, int? status) {
    return ListTile(
      title: MyText(
        text: label,
        multilanguage: true,
        color: colorPrimary,
        fontsizeWeb: Dimens.medium14TextSize,
        fontstyle: FontStyle.normal,
        isfont: 3,
        fontwaight: FontWeight.w600,
        maxline: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: () {
        Navigator.pop(context);
        setState(() {
          selectedFilterLabel = label;
          selectedStatus = status;
        });
        provider.changeHistoryFilter(status);
      },
    );
  }

  Widget _transactionShimmer() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (_, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: const [
              CustomWidget.circular(height: 40, width: 40),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomWidget.roundrectborder(height: 14, width: 120),
                    SizedBox(height: 6),
                    CustomWidget.roundrectborder(height: 12, width: 160),
                  ],
                ),
              ),
              CustomWidget.roundrectborder(height: 14, width: 50),
            ],
          ),
        );
      },
    );
  }

  Color getBgColor(int status) {
    switch (status) {
      case 0:
        return Colors.red.shade100;
      case 1:
        return Colors.green.shade100;
      case 2:
        return Colors.orange.shade100;
      case 3:
        return Colors.grey.shade300;
      default:
        return Colors.blue.shade100;
    }
  }

  Color getTextColor(int status) {
    switch (status) {
      case 0:
        return Colors.red.shade900;
      case 1:
        return Colors.green.shade900;
      case 2:
        return Colors.orange.shade900;
      case 3:
        return Colors.grey.shade800;
      default:
        return Colors.blue.shade900;
    }
  }
}
