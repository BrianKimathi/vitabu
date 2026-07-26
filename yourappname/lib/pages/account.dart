import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/pages/audiobookplaying.dart';
import 'package:flutter_locales/flutter_locales.dart';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/gg.dart';
import 'package:iconify_flutter/icons/ic.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:iconify_flutter/icons/ph.dart';
import 'package:provider/provider.dart';

import 'package:yourappname/pages/auther.dart';
import 'package:yourappname/pages/becomeauthor.dart';
import 'package:yourappname/pages/commonpage.dart';
import 'package:yourappname/pages/login.dart';
import 'package:yourappname/pages/mybook.dart';
import 'package:yourappname/pages/setting.dart';
import 'package:yourappname/pages/updateprofile.dart';
import 'package:yourappname/pages/wallate.dart';
import 'package:yourappname/provider/homeprovider.dart';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/provider/themeprovider.dart';
import 'package:yourappname/subscription/subscription.dart';
import 'package:yourappname/subscription/usersubscriptionplan.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';

import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/utils/utils.dart';

import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/widget/myimage.dart';
import 'package:yourappname/widget/mynetworkimg.dart';


class Account extends StatefulWidget {
  const Account({super.key});

  @override
  State<Account> createState() => _AccountState();
}

class _AccountState extends State<Account> {
  SharedPref sharedpre = SharedPref();
  dynamic selectedLanguagecode;
  late ProfileProvider profileProvider;
  late HomeProvider homeProvider;
  late ThemeProvider themeSwitcherProvider;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    homeProvider = Provider.of<HomeProvider>(context, listen: false);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getApi();
    });
  }

  getApi() {
    profileProvider.setLoding(true);
    profileProvider.getProfile(Constant.userID);
    profileProvider.getPages();
    profileProvider.getsociallinkdata();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    selectedLanguagecode = LocaleNotifier.of(context)?.locale!.languageCode;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF12121A) : const Color(0xFFF8F9FD),
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: isDark ? Colors.white : const Color(0xFF1F2937), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          "Profile",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : const Color(0xFF1F2937),
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer2<ProfileProvider, HomeProvider>(
        builder: (context, profileProvider, provider, child) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                profileSection(),
                const SizedBox(height: 20),
                upgradesubscription(),
                const SizedBox(height: 20),
                _buildFeatureField(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFeatureField() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isApprovedAuthor =
        (profileProvider.profileModel.result?[0].isAuthor ?? 0) == 1 &&
            Constant.isAuthor == "1";

    return Column(
      children: [
        if (!isApprovedAuthor) ...[
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.campaign_rounded, color: Colors.white, size: 28),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Become an Author",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Publish books and start earning royalties.",
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Utils.push(context, BecomeAuthor()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF6D28D9),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  child: const Text(
                    "Join",
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
        _myTitle(
          iconData: MaterialSymbols.subscriptions,
          title: 'My Subscription',
          onTap: () {
            if (Utils.checkLoginUser(context)) {
              Utils.push(context, Usersubscriptionplan());
            }
          },
        ),
        const SizedBox(height: 12),
        _myTitle(
          iconData: Ic.sharp_person,
          title: (profileProvider.profileModel.result?[0].isAuthor ?? 0) == 1
              ? "Author Dashboard"
              : "Become Author",
          onTap: () {
            if (Utils.checkLoginUser(context)) {
              if ((profileProvider.profileModel.result?[0].isAuthor.toString()) == "1" &&
                  Constant.isAuthor == "1") {
                Utils.launchURL("https://console.vitabu.online/public/author/login");
              } else {
                Utils.push(context, BecomeAuthor());
              }
            }
          },
        ),
        const SizedBox(height: 12),
        _myTitle(
          iconData: Ph.wallet_fill,
          title: 'My Transactions',
          onTap: () {
            if (Utils.checkLoginUser(context)) {
              Utils.push(context, Wallet());
            }
          },
        ),
        const SizedBox(height: 12),
        _myTitle(
          iconData: Gg.profile,
          title: 'Profile Details',
          onTap: () {
            if (Utils.checkLoginUser(context)) {
              Utils.push(context, UpdateProfile());
            }
          },
        ),
        const SizedBox(height: 12),
        _myTitle(
          iconData: MaterialSymbols.shopping_cart_outline_rounded,
          title: 'My Books',
          onTap: () {
            if (Utils.checkLoginUser(context)) {
              Utils.push(context, MyBook());
            }
          },
        ),
        const SizedBox(height: 12),
        _myTitle(
          iconData: MaterialSymbols.settings_outline,
          title: 'Settings',
          onTap: () {
            if (Utils.checkLoginUser(context)) {
              Utils.push(context, Setting());
            }
          },
        ),
        const SizedBox(height: 12),

        /* Custom / Legal Pages dynamic */
        if (profileProvider.pagesModel.result != null)
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: profileProvider.pagesModel.result!.length,
            itemBuilder: (context, index) {
              final page = profileProvider.pagesModel.result![index];
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Utils.push(
                      context,
                      CommonPage(
                        appBarTitle: page.title.toString(),
                        loadURL: page.url ?? "",
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark ? Colors.grey[800]! : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: Row(
                      children: [
                        MyNetworkImage(
                          imagePath: page.icon.toString(),
                          fit: BoxFit.cover,
                          height: 24,
                          width: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            page.title.toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.grey[200] : const Color(0xFF374151),
                            ),
                          ),
                        ),
                        const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: colorPrimary),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),

        if (Constant.userID != null) ...[
          const SizedBox(height: 12),
          _buildLogOut(),
        ],
        const SizedBox(height: 24),
        _buildSocialLink(),
        const SizedBox(height: 24),
        companyDetails(context),
      ],
    );
  }

  Widget _myTitle({
    required String iconData,
    required String title,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: colorPrimary.withOpacity(0.1),
              ),
              child: Iconify(
                iconData,
                size: 20,
                color: colorPrimary,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.grey[200] : const Color(0xFF374151),
                ),
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: colorPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogOut() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        if (Constant.userID == "" || Constant.userID == null) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const Login()));
        } else {
          showDeleteAccountDialog(title: "Are you sure you want to logout?", btnName: "Logout");
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isDark ? Colors.grey[800]! : const Color(0xFFE5E7EB),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: Colors.red.withOpacity(0.1),
              ),
              child: const Iconify(Ph.sign_out_bold, size: 20, color: Colors.red),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                Constant.userID == "" || Constant.userID == null ? "Login" : "Logout",
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  showDeleteAccountDialog({title, btnName}) {
    return showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 70,
                width: 70,
                decoration: const BoxDecoration(color: colorPrimary, shape: BoxShape.circle),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(35),
                  child: const MyImage(imagePath: "appicon.png", fit: BoxFit.cover),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Vitabu",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: colorPrimary),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 24),
              _biuldButtonRow(btnName),
            ],
          ),
        ),
      ),
    );
  }

  Widget profileSection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bool hasUserCreds = Constant.userID != null &&
        Constant.userID.toString().trim().isNotEmpty &&
        Constant.userID.toString() != "0";

    return Consumer<ProfileProvider>(
      builder: (context, profileData, child) {
        if (profileData.loading || (hasUserCreds && profileData.profileModel.result == null)) {
          return profileShimmer();
        }

        final isLogged = profileData.profileModel.status == 200 &&
            (profileData.profileModel.result?.length ?? 0) > 0;

        if (isLogged) {
          final user = profileData.profileModel.result?[0];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.3) : Colors.black.withOpacity(0.04),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colorPrimary.withOpacity(0.2), width: 3),
                  ),
                  child: MyNetworkImage(
                    height: 60,
                    width: 60,
                    fit: BoxFit.cover,
                    radius: 30,
                    imagePath: user?.image ?? Constant.userimage ?? "",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${user?.firstName ?? ''} ${user?.lastName ?? ''}".trim(),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        user?.email ?? "",
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? Colors.grey[400] : const Color(0xFF6B7280),
                        ),
                      ),
                    ],
                  ),
                ),
                if (user?.isSubscription == 1)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFFF59E0B), Color(0xFFD97706)]),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Premium",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          );
        } else if (hasUserCreds) {
          return profileShimmer();
        } else {
          return _staticUserData();
        }
      },
    );
  }

  Widget profileShimmer() {
    return const CustomWidget.roundcorner(height: 90);
  }

  Widget _staticUserData() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          const MyImage(
            height: 60,
            radius: 30,
            width: 60,
            imagePath: "ic_userprofile.png",
            fit: BoxFit.cover,
          ),
          const SizedBox(width: 16),
          Text(
            "Guest User",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : const Color(0xFF1F2937),
            ),
          ),
        ],
      ),
    );
  }

  Widget _biuldButtonRow(String title) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () => Navigator.pop(context),
            child: Container(
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[400]!),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "Cancel",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: InkWell(
            onTap: () async {
              await Utils.removeUser();
              profileProvider.clearProvider();
              await _auth.signOut();
              await GoogleSignIn().signOut();

              Constant.userID = null;
              Constant.isAuthor = null;
              Constant.isSubscription = null;
              Constant.userCategoryId = null;

              await sharedpre.save("isEdit", "0");
              if (!mounted) return;
              Navigator.pop(context);
              Utils.push(context, Login());
              audioPlayer.stop();
              audioPlayer.pause();
              profileProvider.providerNotifi();
              homeProvider.getProfile(Constant.userID);
            },
            child: Container(
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget upgradesubscription() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () {
        if (Utils.checkLoginUser(context)) {
          Utils.push(context, Subscription());
        }
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFF59E0B).withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.star_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Upgrade to Premium",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Unlock unlimited books, audiobooks, and magazines.",
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSocialLink() {
    if (profileProvider.isLoading) return const SizedBox.shrink();

    final results = profileProvider.getsociallinkmodel.result;
    if (results == null || results.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Connect with us",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: results.length,
            itemBuilder: (context, index) {
              final item = results[index];
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: InkWell(
                  onTap: () {
                    Utils.push(
                      context,
                      CommonPage(
                        appBarTitle: item.name ?? '',
                        loadURL: item.url ?? '',
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E1E2E) : Colors.white,
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark ? Colors.grey[800]! : const Color(0xFFE5E7EB),
                      ),
                    ),
                    child: MyNetworkImage(
                      width: 24,
                      height: 24,
                      imagePath: item.image ?? '',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget companyDetails(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E1E2E) : Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            "Vitabu Platform",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "Version ${Constant.appversion ?? '1.3.0'}",
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
          const SizedBox(height: 12),
          Text(
            "© ${Constant.appyear ?? '2026'} Vitabu. All rights reserved.",
            style: TextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }
}
