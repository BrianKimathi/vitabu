import 'package:yourappname/provider/packageprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:iconify_flutter/iconify_flutter.dart';
import 'package:iconify_flutter/icons/bi.dart';
import 'package:iconify_flutter/icons/material_symbols.dart';
import 'package:provider/provider.dart';

class Subscriptionhistory extends StatefulWidget {
  const Subscriptionhistory({super.key});

  @override
  State<Subscriptionhistory> createState() => _SubscriptionhistoryState();
}

class _SubscriptionhistoryState extends State<Subscriptionhistory> {
  late ScrollController _scrollController;
  late PackageProvider provider;

  String selectedFilterLabel = "all";
  int? selectedStatus; // null = all

  @override
  void initState() {
    super.initState();
    provider = context.read<PackageProvider>();
    _scrollController = ScrollController()..addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      provider.changeHistoryFilter(null);
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 100 &&
        provider.loadmore == false &&
        (provider.historycurrentPage ?? 0) < (provider.historytotalPage ?? 0)) {
      provider.loadMoreHistory(selectedStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Constant.isDarkMode ? appbarcolor : white,
      appBar: AppBar(
        backgroundColor: Constant.isDarkMode ? appbarcolor : white,
        leading: Utils.backButton(context),
        centerTitle: false,
        title: MyText(
          text: "mytransaction",
          fontsize: Dimens.medium16TextSize,
          fontwaight: FontWeight.w600,
          isfont: 3,
          multilanguage: true,
        ),
      ),
      body: Consumer<PackageProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Row(
                        children: [
                          MyText(
                            text: selectedFilterLabel,
                            fontsize: Dimens.medium15TextSize,
                            fontwaight: FontWeight.w600,
                            isfont: 3,
                            multilanguage: true,
                            color: Constant.isDarkMode ? white : black,
                          ),
                          const SizedBox(width: 4),
                          Iconify(
                            Bi.arrow_down,
                            size: 12,
                            color: Constant.isDarkMode ? white : black,
                          ) // widget
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        _showFilterSheet();
                      },
                      child: Iconify(
                        MaterialSymbols.filter_alt_sharp,
                        color: Constant.isDarkMode ? white : black,
                        size: 20,
                      ),
                    ) // widget
                  ],
                ),
              ),
              Expanded(
                child: Builder(
                  builder: (_) {
                    /// 1️⃣ LOADING
                    if (provider.historyloading &&
                        (provider.historyList == null ||
                            provider.historyList!.isEmpty)) {
                      return transactionShimmer();
                    }

                    /// 2️⃣ NO DATA
                    if (!provider.historyloading &&
                        (provider.historyList == null ||
                            provider.historyList!.isEmpty)) {
                      return NoData();
                    }

                    /// 3️⃣ DATA AVAILABLE
                    return ListView.separated(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: provider.historyList!.length +
                          (provider.loadmore ? 1 : 0),
                      separatorBuilder: (_, __) => const Divider(height: 24),
                      itemBuilder: (context, index) {
                        /// LOAD MORE INDICATOR
                        if (index >= provider.historyList!.length) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 16),
                            child: Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        }

                        final item = provider.historyList![index];
                        final status = item.status ?? 0;
                        final bgColor = getBgColor(status);
                        final textColor = getTextColor(status);
                        final debit = isDebit(status);

                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: bgColor,
                              child: MyText(
                                text: item.planName
                                        ?.substring(0, 1)
                                        .toUpperCase() ??
                                    "",
                                fontsize: Dimens.medium14TextSize,
                                fontwaight: FontWeight.w600,
                                isfont: 3,
                                multilanguage: false,
                                color: textColor,
                              ),
                            ),
                            const SizedBox(width: 12),

                            /// CENTER
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  MyText(
                                    text: item.planName ?? "",
                                    fontsize: Dimens.medium15TextSize,
                                    fontwaight: FontWeight.w600,
                                    isfont: 3,
                                    multilanguage: false,
                                    color: Constant.isDarkMode ? white : black,
                                  ),
                                  const SizedBox(height: 4),
                                  MyText(
                                    text: Utils.formatTransactionDate(
                                        item.buyDate ?? ""),
                                    fontsize: Dimens.medium13TextSize,
                                    fontwaight: FontWeight.w400,
                                    isfont: 3,
                                    multilanguage: false,
                                    color: gray,
                                  ),
                                ],
                              ),
                            ),

                            /// AMOUNT
                            MyText(
                              text: "${debit ? "-" : "+"}\$${item.price ?? 0}",
                              fontsize: Dimens.medium15TextSize,
                              fontwaight: FontWeight.w600,
                              isfont: 3,
                              multilanguage: false,
                              color: textColor,
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
      ),
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

  bool isDebit(int status) => status == 0 || status == 3;

  /// 🔽 FILTER BOTTOM SHEET
  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _filterItem("all", null),
            _filterItem("expired", 0),
            _filterItem("active", 1),
            _filterItem("upcoming", 2),
          ],
        );
      },
    );
  }

  Widget _filterItem(String label, int? status) {
    return ListTile(
      title: MyText(
        text: label,
        fontsize: Dimens.medium15TextSize,
        fontwaight: FontWeight.w500,
        isfont: 3,
        multilanguage: true,
        color: Constant.isDarkMode ? white : black,
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

  Widget transactionShimmer() {
    return ListView.builder(
      itemCount: 5,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, __) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
          child: Row(
            children: [
              const CustomWidget.circular(height: 40, width: 40),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    CustomWidget.roundrectborder(height: 14, width: 120),
                    SizedBox(height: 6),
                    CustomWidget.roundrectborder(height: 12, width: 160),
                  ],
                ),
              ),
              const CustomWidget.roundrectborder(height: 14, width: 50),
            ],
          ),
        );
      },
    );
  }
}
