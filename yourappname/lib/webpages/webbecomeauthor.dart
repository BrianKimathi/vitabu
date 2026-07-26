import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_locales/flutter_locales.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webwidget/footerweb.dart';
import 'package:yourappname/webwidget/interactivecontainer.dart';
import 'package:yourappname/webwidget/webappbar.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/widget/mytextformfield.dart';

class WebBecomeAuthor extends StatefulWidget {
  const WebBecomeAuthor({super.key});

  @override
  State<WebBecomeAuthor> createState() => _WebBecomeAuthorState();
}

class _WebBecomeAuthorState extends State<WebBecomeAuthor> {
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final bankHolderNameController = TextEditingController();
  final mpesaPhoneController = TextEditingController();
  final contactPhoneController = TextEditingController();
  final passwordController = TextEditingController();
  final otpController = TextEditingController();

  String role = 'author';
  String paymentMethod = 'bank';
  String? bankCode;

  String _safeMessage(String? message) {
    final m = (message ?? '').trim();
    return m.isEmpty ? "something_went_wrong" : m;
  }

  String _selectedBankName() {
    if ((bankCode ?? '').isEmpty) return '';
    final match = profileProvider.paystackBanks
        .cast<Map<String, dynamic>?>()
        .firstWhere(
          (bank) => (bank?['code']?.toString() ?? '') == bankCode,
          orElse: () => null,
        );
    return (match?['name']?.toString() ?? '').trim();
  }

  late ProfileProvider profileProvider;

  @override
  void initState() {
    profileProvider = Provider.of<ProfileProvider>(context, listen: false);
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (Constant.userID != null) {
        await profileProvider.getProfile(Constant.userID);
      }
      await profileProvider.getPaystackBanks(country: 'kenya');
      final profile = profileProvider.profileModel.result?.isNotEmpty == true
          ? profileProvider.profileModel.result?.first
          : null;
      final mobile = profile?.mobileNumber ?? '';
      if (!mounted) return;
      if (mpesaPhoneController.text.isEmpty && mobile.isNotEmpty) {
        mpesaPhoneController.text = mobile;
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    bankNameController.dispose();
    accountNumberController.dispose();
    bankHolderNameController.dispose();
    mpesaPhoneController.dispose();
    contactPhoneController.dispose();
    passwordController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const double maxContentWidth = 1400;
    final contentWidth =
        screenWidth > maxContentWidth ? maxContentWidth : screenWidth - 20;

    return WebAppBar(
      widget: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          profileProvider = provider;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: contentWidth,
                    padding: EdgeInsets.symmetric(
                        horizontal: screenWidth <= 1000 ? 10 : 0),
                    child: Utils.buildWebDetailsAppBar(
                      context: context,
                      title1: "become_author",
                      multilanguage: true,
                      isHome: false,
                    ),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: _buildData(),
                  ),
                ),
                Center(
                  child: SizedBox(
                    width: contentWidth,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth > 800 ? 100 : 20,
                      ),
                      child: _buildSubmitButton(),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                FooterWeb(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildData() {
    if (MediaQuery.of(context).size.width > 800) {
      return _buildDesktopLayout();
    } else {
      return _buildMobileLayout();
    }
  }

  // ---------------------------------------------------------------
  //  Desktop Layout
  // ---------------------------------------------------------------
  Widget _buildDesktopLayout() {
    final profile = profileProvider.profileModel.result?.isNotEmpty == true
        ? profileProvider.profileModel.result?.first
        : null;
    final fullName = [profile?.firstName ?? '', profile?.lastName ?? '']
        .join(' ')
        .trim();
    final displayName =
        fullName.isNotEmpty ? fullName : (profile?.userName ?? '');
    final hasPhone = (profile?.mobileNumber ?? '').isNotEmpty;

    return Padding(
      padding: const EdgeInsets.fromLTRB(100, 24, 100, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // === Title ===
          Center(
            child: MyText(
              text: "become_author",
              maxline: 1,
              multilanguage: true,
              fontsize: Dimens.text28Size,
              fontsizeWeb: Dimens.text28Size,
              fontwaight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 24),

          // === Profile Card ===
          _buildProfileCard(displayName, profile?.email ?? '',
              profile?.mobileNumber ?? ''),
          const SizedBox(height: 20),

          // === Two Column Layout ===
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left Column: Role + Payment + KYC
              Expanded(
                child: Column(
                  children: [
                    _buildRoleSection(),
                    const SizedBox(height: 20),
                    _buildPaymentSection(),
                    const SizedBox(height: 20),
                    _buildKycSection(),
                  ],
                ),
              ),
              const SizedBox(width: 20),

              // Right Column: Password + OTP
              Expanded(
                child: Column(
                  children: [
                    if (profile?.type != 4)
                      _buildPasswordSection(),
                    if (profile?.type != 4) const SizedBox(height: 20),
                    _buildOtpSection(),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  //  Mobile Layout (web responsive)
  // ---------------------------------------------------------------
  Widget _buildMobileLayout() {
    final profile = profileProvider.profileModel.result?.isNotEmpty == true
        ? profileProvider.profileModel.result?.first
        : null;
    final fullName = [profile?.firstName ?? '', profile?.lastName ?? '']
        .join(' ')
        .trim();
    final displayName =
        fullName.isNotEmpty ? fullName : (profile?.userName ?? '');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: MyText(
              text: "become_author",
              maxline: 1,
              multilanguage: true,
              fontsize: Dimens.text28Size,
              fontsizeWeb: Dimens.text28Size,
              fontwaight: FontWeight.w700,
              color: const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 16),
          _buildProfileCard(displayName, profile?.email ?? '',
              profile?.mobileNumber ?? ''),
          const SizedBox(height: 16),
          if (profile?.type != 4) ...[
            _buildPasswordSection(),
            const SizedBox(height: 16),
          ],
          _buildKycSection(),
          const SizedBox(height: 16),
          _buildRoleSection(),
          const SizedBox(height: 16),
          _buildPaymentSection(),
          const SizedBox(height: 16),
          _buildOtpSection(),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  //  Profile Card
  // ---------------------------------------------------------------
  Widget _buildProfileCard(String name, String email, String phone) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8F0), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFEEF0FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.person, color: Color(0xFF4E45B8), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name.isNotEmpty ? name : 'User',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Email: $email',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                Text(
                  'Phone: $phone',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                if (phone.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: _webTextField(
                      controller: contactPhoneController,
                      hint: "Enter Phone Number",
                      icon: Icons.phone_android_outlined,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  //  KYC Section
  // ---------------------------------------------------------------
  Widget _buildKycSection() {
    final isPublisher = role == 'publisher';
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.folder_copy_outlined,
                  size: 18, color: Color(0xFF4E45B8)),
              const SizedBox(width: 8),
              Text(
                isPublisher ? "Publisher Verification Documents" : "KYC Documents",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            isPublisher
                ? "Upload Company Registration Certificate, KRA PIN & Representative ID"
                : "Upload your identification documents",
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildKycUploadCard(
                  isPublisher ? "Reg Cert" : "ID Front",
                  isPublisher ? Icons.business_outlined : Icons.credit_card_outlined,
                  'idFront',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKycUploadCard(
                  isPublisher ? "KRA Pin" : "ID Back",
                  isPublisher ? Icons.receipt_long_outlined : Icons.credit_card_outlined,
                  'idBack',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildKycUploadCard(
                  isPublisher ? "Rep. ID" : "Selfie",
                  isPublisher ? Icons.badge_outlined : Icons.camera_alt_outlined,
                  'selfie',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKycUploadCard(String label, IconData icon, String type) {
    Uint8List? preview;
    String? fileName;
    if (type == 'idFront') {
      preview = profileProvider.idFrontBytes;
      fileName = profileProvider.idFrontName;
    } else if (type == 'idBack') {
      preview = profileProvider.idBackBytes;
      fileName = profileProvider.idBackName;
    } else {
      preview = profileProvider.selfieBytes;
      fileName = profileProvider.selfieName;
    }

    return GestureDetector(
      onTap: () => _pickKycImage(type),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: preview != null
                ? const Color(0xFF4E45B8)
                : const Color(0xFFE0E0F0),
            width: 1.5,
          ),
        ),
        child: Column(
          children: [
            if (preview != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  preview,
                  height: 80,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 56,
                width: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF0FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: const Color(0xFF4E45B8), size: 28),
              ),
            const SizedBox(height: 8),
            Text(
              preview != null ? (fileName ?? 'Selected') : label,
              style: GoogleFonts.inter(
                fontSize: 12,
                fontWeight:
                    preview != null ? FontWeight.w600 : FontWeight.w400,
                color: preview != null
                    ? const Color(0xFF4E45B8)
                    : const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            if (preview != null) ...[
              const SizedBox(height: 4),
              InkWell(
                onTap: () {
                  if (type == 'idFront') {
                    profileProvider.idFrontBytes = null;
                    profileProvider.idFrontName = null;
                  } else if (type == 'idBack') {
                    profileProvider.idBackBytes = null;
                    profileProvider.idBackName = null;
                  } else {
                    profileProvider.selfieBytes = null;
                    profileProvider.selfieName = null;
                  }
                  profileProvider.providerNotifi();
                },
                child: Text(
                  "Remove",
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    color: const Color(0xFFDC2626),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickKycImage(String type) async {
    try {
      if (kIsWeb) {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
          withData: true,
        );
        if (result != null && result.files.single.bytes != null) {
          final bytes = result.files.single.bytes!;
          final name = result.files.single.name;
          if (type == 'idFront') {
            profileProvider.setIdFront(bytes, name);
          } else if (type == 'idBack') {
            profileProvider.setIdBack(bytes, name);
          } else {
            profileProvider.setSelfie(bytes, name);
          }
        }
      } else {
        final result = await FilePicker.platform.pickFiles(
          type: FileType.image,
          allowMultiple: false,
        );
        if (result != null && result.files.single.path != null) {
          final file = File(result.files.single.path!);
          final bytes = await file.readAsBytes();
          final name = result.files.single.name;
          if (type == 'idFront') {
            profileProvider.setIdFront(bytes, name);
          } else if (type == 'idBack') {
            profileProvider.setIdBack(bytes, name);
          } else {
            profileProvider.setSelfie(bytes, name);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        Utils.showSnackbar(context, "Failed to pick image", false);
      }
    }
  }

  // ---------------------------------------------------------------
  //  Role Section
  // ---------------------------------------------------------------
  Widget _buildRoleSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.person_outline,
                  size: 18, color: Color(0xFF4E45B8)),
              const SizedBox(width: 8),
              Text(
                "Account Type",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _webDropdown<String>(
            value: role,
            label: "I want to register as",
            items: const [
              DropdownMenuItem(value: 'author', child: Text('Author')),
              DropdownMenuItem(value: 'publisher', child: Text('Publisher')),
            ],
            onChanged: (v) {
              if (v != null) setState(() => role = v);
            },
          ),
          const SizedBox(height: 12),
          _webDropdown<String>(
            value: paymentMethod,
            label: "Payment Method",
            items: const [
              DropdownMenuItem(value: 'bank', child: Text('Bank Transfer')),
              DropdownMenuItem(value: 'mpesa', child: Text('M-Pesa')),
            ],
            onChanged: (v) {
              if (v != null) setState(() => paymentMethod = v);
            },
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  //  Payment Section
  // ---------------------------------------------------------------
  Widget _buildPaymentSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.account_balance_wallet_outlined,
                  size: 18, color: Color(0xFF4E45B8)),
              const SizedBox(width: 8),
              Text(
                "Payment Details",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (paymentMethod == 'bank') ...[
            // Dedup by bank code at UI level to prevent Flutter assertion errors
            // when Paystack returns duplicate codes (KES + USD variants).
            _webDropdown<String>(
              value: bankCode,
              label: "Select Bank",
              items: () {
                final seen = <String>{};
                final deduped = <DropdownMenuItem<String>>[];
                for (final bank in profileProvider.paystackBanks) {
                  final code = (bank['code'] ?? '').toString();
                  if (code.isNotEmpty && seen.add(code)) {
                    deduped.add(DropdownMenuItem<String>(
                      value: code,
                      child: Text(bank['name']?.toString() ?? ''),
                    ));
                  }
                }
                return deduped;
              }(),
              onChanged: (v) => setState(() {
                bankCode = v;
                bankNameController.text = _selectedBankName();
              }),
            ),
            const SizedBox(height: 12),
            _webTextField(
              controller: bankNameController,
              hint: "Bank Name",
              icon: Icons.account_balance_outlined,
            ),
            const SizedBox(height: 12),
            _webTextField(
              controller: accountNumberController,
              hint: "Account Number",
              icon: Icons.receipt_long_outlined,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            _webTextField(
              controller: bankHolderNameController,
              hint: "Account Holder Name",
              icon: Icons.person_outline,
            ),
          ] else ...[
            _webTextField(
              controller: mpesaPhoneController,
              hint: "M-Pesa Phone Number",
              icon: Icons.phone_android_outlined,
              keyboardType: TextInputType.phone,
            ),
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  //  Password Section
  // ---------------------------------------------------------------
  Widget _buildPasswordSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.lock_outline,
                  size: 18, color: Color(0xFF4E45B8)),
              const SizedBox(width: 8),
              Text(
                "Dashboard Access",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            "Set a password for the Author Dashboard",
            style: GoogleFonts.inter(
              fontSize: 13,
              color: const Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 12),
          _webTextField(
            controller: passwordController,
            hint: "Set Author Dashboard Password",
            icon: Icons.lock_outline,
            obscureText: true,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  //  OTP Section
  // ---------------------------------------------------------------
  Widget _buildOtpSection() {
    final isSending = profileProvider.otpSending;
    final isSent = profileProvider.otpSent;
    final isVerified = profileProvider.otpVerified;
    final timer = profileProvider.otpTimerSeconds;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8F0), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.verified_outlined,
                  size: 18,
                  color: isVerified
                      ? const Color(0xFF059669)
                      : const Color(0xFF6B7280)),
              const SizedBox(width: 8),
              Text(
                isVerified ? "Contact Verified ✓" : "Verify your email & phone",
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isVerified
                      ? const Color(0xFF059669)
                      : const Color(0xFF1A1A2E),
                ),
              ),
            ],
          ),
          if (!isVerified) ...[
            const SizedBox(height: 8),
            Text(
              "We'll send a one-time code to your registered email and phone.",
              style: GoogleFonts.inter(
                fontSize: 13,
                color: const Color(0xFF6B7280),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: _webTextField(
                    controller: otpController,
                    hint: "Enter 6-digit OTP",
                    icon: Icons.pin_outlined,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  height: 48,
                  width: 130,
                  child: ElevatedButton(
                    onPressed: isSending || isSent
                        ? null
                        : () {
                            profileProvider.resetOtpState();
                            profileProvider.sendOtp();
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4E45B8),
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: const Color(0xFFD1D5DB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: isSending
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            isSent ? "Resend" : "Send OTP",
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            if (isSent && timer > 0) ...[
              const SizedBox(height: 8),
              Text(
                "Resend in ${(timer ~/ 60)}:${(timer % 60).toString().padLeft(2, '0')}",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF9CA3AF),
                ),
              ),
            ],
            if (profileProvider.otpMessage.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                profileProvider.otpMessage,
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: profileProvider.otpSent
                      ? const Color(0xFF059669)
                      : const Color(0xFFDC2626),
                ),
              ),
            ],
            if (isSent) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  onPressed: () async {
                    final otp = otpController.text.trim();
                    if (otp.length != 6) {
                      Utils.showSnackbar(
                          context, "Please enter a valid 6-digit OTP", false);
                      return;
                    }
                    await profileProvider.verifyOtp(otp);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF059669),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Verify OTP",
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  //  Submit Button
  // ---------------------------------------------------------------
  Widget _buildSubmitButton() {
    final isLoading = profileProvider.becomeAUthorLoading;
    final isOtpVerified = profileProvider.otpVerified;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        InteractiveContainer(child: (isHovered) {
          return InkWell(
            hoverColor: Colors.transparent,
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () {
              _resetForm();
            },
            borderRadius: BorderRadius.circular(12),
            child: AnimatedScale(
              scale: isHovered ? 1.05 : 1,
              duration: const Duration(milliseconds: 100),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                decoration: BoxDecoration(
                  border: Border.all(
                      width: 1,
                      color: isHovered
                          ? const Color(0xFF4E45B8)
                          : const Color(0xFF6B7280)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  "Reset",
                  style: GoogleFonts.inter(
                    color: isHovered
                        ? const Color(0xFF4E45B8)
                        : const Color(0xFF6B7280),
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          );
        }),
        const SizedBox(width: 16),
        SizedBox(
          width: 220,
          height: 50,
          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : () async {
                    await _handleSubmit();
                  },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4E45B8),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFD1D5DB),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.send_rounded, size: 18),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          "Submit Application",
                          style: GoogleFonts.inter(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  void _resetForm() {
    bankNameController.clear();
    accountNumberController.clear();
    bankHolderNameController.clear();
    mpesaPhoneController.clear();
    contactPhoneController.clear();
    passwordController.clear();
    otpController.clear();
    paymentMethod = 'bank';
    profileProvider.becomeAUthorLoading = false;
    profileProvider.clearKycImages();
    profileProvider.resetOtpState();
    setState(() {});
    Utils.showSnackbar(context, 'form_reset_successfully', true);
  }

  // ---------------------------------------------------------------
  //  Submit Logic
  // ---------------------------------------------------------------
  Future<void> _handleSubmit() async {
    final isLogin = await Utils.checkLoginUser(context);
    if (!mounted) return;
    if (!isLogin) return;

    final profile = profileProvider.profileModel.result?.isNotEmpty == true
        ? profileProvider.profileModel.result?.first
        : null;

    if ((profile?.mobileNumber ?? '').isEmpty) {
      final contactDigits = contactPhoneController.text
          .trim()
          .replaceAll(RegExp(r'[^0-9]'), '');
      if (contactDigits.isEmpty) {
        Utils.showSnackbar(context, "Please Enter Phone Number", false);
        return;
      }
      contactPhoneController.text = contactDigits;
    }

    if (profile?.type != 4) {
      if (passwordController.text.trim().length < 6) {
        Utils.showSnackbar(
            context, "Password must be at least 6 characters.", false);
        return;
      }
    }

    if (paymentMethod == 'bank') {
      if ((bankCode ?? '').isEmpty) {
        Utils.showSnackbar(context, "please_enter_your_bank_name", true);
        return;
      }
      if (accountNumberController.text.isEmpty) {
        Utils.showSnackbar(
            context, "please_enter_your_account_number", true);
        return;
      }
      if (!RegExp(r'^[0-9]+$').hasMatch(accountNumberController.text)) {
        Utils.showSnackbar(
            context, "please_enter_valid_account_number", true);
        return;
      }
    } else {
      final mpesaRaw = mpesaPhoneController.text.trim();
      final mpesaDigits = mpesaRaw.replaceAll(RegExp(r'[^0-9]'), '');
      if (mpesaDigits.isEmpty) {
        Utils.showSnackbar(
            context, "please_enter_your_mobilenumber", true);
        return;
      }
      mpesaPhoneController.text = mpesaDigits;
    }

    // Validate KYC - at least one doc recommended
    if (profileProvider.idFrontBytes == null &&
        profileProvider.idBackBytes == null &&
        profileProvider.selfieBytes == null) {
      Utils.showSnackbar(
          context, "Please upload at least your ID document", false);
      return;
    }

    // Validate OTP
    if (!profileProvider.otpVerified) {
      Utils.showSnackbar(
          context, "Please verify your email/phone with OTP first", false);
      return;
    }

    // Prepare image files
    dynamic idFrontFile;
    dynamic idBackFile;
    dynamic selfieFile;

    if (!kIsWeb) {
      if (profileProvider.idFrontBytes != null && profileProvider.idFrontName != null) {
        final dir = Directory.systemTemp;
        final file = File('${dir.path}/${profileProvider.idFrontName}');
        await file.writeAsBytes(profileProvider.idFrontBytes!);
        idFrontFile = file;
      }
      if (profileProvider.idBackBytes != null && profileProvider.idBackName != null) {
        final dir = Directory.systemTemp;
        final file = File('${dir.path}/${profileProvider.idBackName}');
        await file.writeAsBytes(profileProvider.idBackBytes!);
        idBackFile = file;
      }
      if (profileProvider.selfieBytes != null && profileProvider.selfieName != null) {
        final dir = Directory.systemTemp;
        final file = File('${dir.path}/${profileProvider.selfieName}');
        await file.writeAsBytes(profileProvider.selfieBytes!);
        selfieFile = file;
      }
    } else {
      idFrontFile = profileProvider.idFrontBytes;
      idBackFile = profileProvider.idBackBytes;
      selfieFile = profileProvider.selfieBytes;
    }

    await profileProvider.getBecomeAuthor(
      role: role,
      paymentMethod: paymentMethod,
      bankCode: bankCode,
      bankname: _selectedBankName(),
      bankholdername: bankHolderNameController.text,
      accountno: accountNumberController.text,
      mpesaPhone: mpesaPhoneController.text,
      mobileNumber: contactPhoneController.text,
      password: passwordController.text.trim(),
      idFrontImage: idFrontFile,
      idBackImage: idBackFile,
      selfieImage: selfieFile,
      otpCode: otpController.text.trim(),
    );

    if (!mounted) return;
    if (profileProvider.successModel.status == 200) {
      profileProvider.clearKycImages();
      profileProvider.resetOtpState();
      Utils.showSnackbar(
        context,
        _safeMessage(profileProvider.successModel.message),
        false,
      );
    } else {
      Utils.showSnackbar(
        context,
        _safeMessage(profileProvider.successModel.message),
        false,
      );
    }
  }

  // ---------------------------------------------------------------
  //  Reusable Web Widgets
  // ---------------------------------------------------------------
  Widget _webTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType ?? TextInputType.text,
      maxLength: maxLength,
      style: GoogleFonts.inter(
        fontSize: 14,
        color: const Color(0xFF1A1A2E),
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: GoogleFonts.inter(
          fontSize: 13,
          color: const Color(0xFF9CA3AF),
        ),
        prefixIcon: Icon(icon, size: 20, color: const Color(0xFF4E45B8)),
        filled: true,
        fillColor: const Color(0xFFF8F9FF),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        counterText: '',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF4E45B8), width: 1.5),
        ),
      ),
    );
  }

  Widget _webDropdown<T>({
    required T? value,
    required String label,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,
      dropdownColor: Colors.white,
      style: GoogleFonts.inter(
        fontSize: 14,
        color: const Color(0xFF1A1A2E),
        fontWeight: FontWeight.w500,
      ),
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.inter(
          fontSize: 13,
          color: const Color(0xFF6B7280),
        ),
        filled: true,
        fillColor: const Color(0xFFF8F9FF),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE8E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: Color(0xFF4E45B8), width: 1.5),
        ),
      ),
    );
  }
}
