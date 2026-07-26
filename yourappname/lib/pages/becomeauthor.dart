import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:yourappname/provider/profileprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/mytext.dart';

class BecomeAuthor extends StatefulWidget {
  const BecomeAuthor({super.key});

  @override
  State<BecomeAuthor> createState() => _BecomeAuthorState();
}

class _BecomeAuthorState extends State<BecomeAuthor> {
  final bankNameController = TextEditingController();
  final accountNumberController = TextEditingController();
  final bankHolderNameController = TextEditingController();
  final mpesaPhoneController = TextEditingController();
  final contactPhoneController = TextEditingController();
  final otpController = TextEditingController();

  String role = 'author';
  String paymentMethod = 'bank';
  String? bankCode;
  bool _needsPhoneInput = false;

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
      _needsPhoneInput = mobile.isEmpty;
      if (mpesaPhoneController.text.isEmpty && mobile.isNotEmpty) {
        mpesaPhoneController.text = mobile;
      }
      setState(() {});
    });
  }

  @override
  void dispose() {
    bankNameController.dispose();
    accountNumberController.dispose();
    bankHolderNameController.dispose();
    mpesaPhoneController.dispose();
    contactPhoneController.dispose();
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: Utils.backButton(context),
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: MyText(
          text: "author_register",
          fontsize: Dimens.medium18TextSize,
          multilanguage: true,
          fontwaight: FontWeight.w700,
          color: const Color(0xFF1A1A2E),
        ),
      ),
      body: Consumer<ProfileProvider>(
        builder: (context, provider, child) {
          profileProvider = provider;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // === User Profile Card ===
                _buildProfileCard(),
                const SizedBox(height: 16),

                // === Role & Payment Section ===
                _buildSectionTitle("Account Type", Icons.person_outline),
                const SizedBox(height: 8),
                _buildRoleSection(),
                const SizedBox(height: 20),

                // === Payment Details Section ===
                _buildSectionTitle("Payment Details", Icons.account_balance_wallet_outlined),
                const SizedBox(height: 8),
                _buildPaymentSection(),
                const SizedBox(height: 20),

                // === KYC Documents Section ===
                _buildSectionTitle(
                  role == 'publisher' ? "Publisher Verification Documents" : "KYC Documents",
                  Icons.folder_copy_outlined,
                ),
                const SizedBox(height: 8),
                _buildKycSection(),
                const SizedBox(height: 20),

                // === OTP Verification Section ===
                _buildSectionTitle("Verify Contact", Icons.verified_outlined),
                const SizedBox(height: 8),
                _buildOtpSection(),
                const SizedBox(height: 24),

                // === Submit Button ===
                _buildSubmitButton(),

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  // ---------------------------------------------------------------
  //  Profile Card
  // ---------------------------------------------------------------
  Widget _buildProfileCard() {
    final profile = profileProvider.profileModel.result?.isNotEmpty == true
        ? profileProvider.profileModel.result?.first
        : null;
    final fullName = [profile?.firstName ?? '', profile?.lastName ?? '']
        .join(' ')
        .trim();
    final displayName =
        fullName.isNotEmpty ? fullName : (profile?.userName ?? '');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE8E8F0), width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFEEF0FF),
              child: const Icon(Icons.person, color: Color(0xFF4E45B8), size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1A1A2E),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Email: ${profile?.email ?? ''}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  Text(
                    'Phone: ${profile?.mobileNumber ?? ''}',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  if (_needsPhoneInput) ...[
                    const SizedBox(height: 8),
                    _buildTextField(
                      controller: contactPhoneController,
                      hint: "Enter Phone Number",
                      icon: Icons.phone_android_outlined,
                      keyboardType: TextInputType.phone,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  //  KYC Section - ID Front, ID Back, Selfie
  // ---------------------------------------------------------------
  Widget _buildKycSection() {
    final isPublisher = role == 'publisher';
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE8E8F0), width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isPublisher
                  ? "Upload Company Reg. Certificate, KRA PIN & Representative ID"
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
        decoration: BoxDecoration(
          color: const Color(0xFFF8F9FF),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: preview != null ? const Color(0xFF4E45B8) : const Color(0xFFE0E0F0),
            width: 1.5,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (preview != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  preview,
                  height: 64,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF0FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFF4E45B8), size: 24),
              ),
            const SizedBox(height: 6),
            Text(
              preview != null ? (fileName ?? 'Selected') : label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: preview != null ? FontWeight.w600 : FontWeight.w400,
                color: preview != null ? const Color(0xFF4E45B8) : const Color(0xFF6B7280),
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
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
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE8E8F0), width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDropdown(
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
            _buildDropdown(
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
      ),
    );
  }

  // ---------------------------------------------------------------
  //  Payment Details Section
  // ---------------------------------------------------------------
  Widget _buildPaymentSection() {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE8E8F0), width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (paymentMethod == 'bank') ...[
              _buildDropdown(
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
              _buildTextField(
                controller: bankNameController,
                hint: "Bank Name",
                icon: Icons.account_balance_outlined,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: accountNumberController,
                hint: "Account Number",
                icon: Icons.receipt_long_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              _buildTextField(
                controller: bankHolderNameController,
                hint: "Account Holder Name",
                icon: Icons.person_outline,
              ),
            ] else ...[
              _buildTextField(
                controller: mpesaPhoneController,
                hint: "M-Pesa Phone Number",
                icon: Icons.phone_android_outlined,
                keyboardType: TextInputType.phone,
              ),
            ],
          ],
        ),
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

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE8E8F0), width: 1),
      ),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.verified_outlined,
                    size: 20,
                    color: isVerified
                        ? const Color(0xFF059669)
                        : const Color(0xFF6B7280)),
                const SizedBox(width: 8),
                Text(
                  isVerified
                      ? "Contact Verified ✓"
                      : "Verify your email & phone",
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isVerified
                        ? const Color(0xFF059669)
                        : const Color(0xFF1A1A2E),
                  ),
                ),
              ],
            ),
            if (!isVerified) ...[
              const SizedBox(height: 12),
              Text(
                "We'll send a one-time code to your registered email and phone.",
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: const Color(0xFF6B7280),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: _buildTextField(
                      controller: otpController,
                      hint: "Enter 6-digit OTP",
                      icon: Icons.pin_outlined,
                      keyboardType: TextInputType.number,
                      maxLength: 6,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: isSending || isSent
                            ? null
                            : () {
                                profileProvider.resetOtpState();
                                profileProvider.sendOtp();
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color(0xFF4E45B8),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor:
                              const Color(0xFFD1D5DB),
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
      ),
    );
  }

  // ---------------------------------------------------------------
  //  Submit Button
  // ---------------------------------------------------------------
  Widget _buildSubmitButton() {
    final isLoading = profileProvider.becomeAUthorLoading;
    final isOtpVerified = profileProvider.otpVerified;

    return SizedBox(
      width: double.infinity,
      height: 52,
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
            borderRadius: BorderRadius.circular(14),
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
    );
  }

  // ---------------------------------------------------------------
  //  Submit Logic
  // ---------------------------------------------------------------
  Future<void> _handleSubmit() async {
    final isLogin = await Utils.checkLoginUser(context);
    if (!mounted) return;
    if (!isLogin) return;

    // Validate phone
    if (_needsPhoneInput) {
      final contactDigits =
          contactPhoneController.text.trim().replaceAll(RegExp(r'[^0-9]'), '');
      if (contactDigits.isEmpty) {
        Utils.showSnackbar(context, "Please Enter Phone Number", false);
        return;
      }
      contactPhoneController.text = contactDigits;
    }

    // Validate payment
    if (paymentMethod == 'bank') {
      if ((bankCode ?? '').isEmpty) {
        Utils.showSnackbar(context, "Please Select Bank", false);
        return;
      }
      if (accountNumberController.text.toString().isEmpty) {
        Utils.showSnackbar(context, "Please Enter Your Account Number", false);
        return;
      }
      if (bankHolderNameController.text.toString().isEmpty) {
        Utils.showSnackbar(context, "Please Enter Bank Holder Name", false);
        return;
      }
    } else {
      final mpesaRaw = mpesaPhoneController.text.trim();
      final mpesaDigits = mpesaRaw.replaceAll(RegExp(r'[^0-9]'), '');
      if (mpesaDigits.isEmpty) {
        Utils.showSnackbar(context, "Please Enter Your M-Pesa Phone Number", false);
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

    // Validate OTP verified
    if (!profileProvider.otpVerified) {
      Utils.showSnackbar(
          context, "Please verify your email/phone with OTP first", false);
      return;
    }

    // Get image files for mobile
    dynamic idFrontFile;
    dynamic idBackFile;
    dynamic selfieFile;

    if (!kIsWeb) {
      // Mobile — pass File objects
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
      // Web — pass Uint8List directly
      idFrontFile = profileProvider.idFrontBytes;
      idBackFile = profileProvider.idBackBytes;
      selfieFile = profileProvider.selfieBytes;
    }

    await profileProvider.getBecomeAuthor(
      role: role,
      paymentMethod: paymentMethod,
      bankCode: bankCode,
      bankname: _selectedBankName(),
      bankholdername: bankHolderNameController.text.toString(),
      accountno: accountNumberController.text.toString(),
      mpesaPhone: mpesaPhoneController.text.toString(),
      mobileNumber: contactPhoneController.text.toString(),
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
          context, _safeMessage(profileProvider.successModel.message), false);
      Navigator.pop(context);
    } else {
      Utils.showSnackbar(
          context, _safeMessage(profileProvider.successModel.message), false);
    }
  }

  // ---------------------------------------------------------------
  //  Reusable Widgets
  // ---------------------------------------------------------------
  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: const Color(0xFF4E45B8)),
        const SizedBox(width: 8),
        Text(
          title,
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1A1A2E),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int? maxLength,
  }) {
    return TextField(
      controller: controller,
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          borderSide: const BorderSide(color: Color(0xFF4E45B8), width: 1.5),
        ),
      ),
    );
  }

  Widget _buildDropdown<T>({
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
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
          borderSide: const BorderSide(color: Color(0xFF4E45B8), width: 1.5),
        ),
      ),
    );
  }
}
