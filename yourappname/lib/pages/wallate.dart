import 'package:yourappname/model/transactionhistorymodel.dart';
import 'package:yourappname/provider/walletprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:responsive_grid_list/responsive_grid_list.dart';

class Wallet extends StatefulWidget {
  const Wallet({super.key});

  @override
  State<Wallet> createState() => _WalletState();
}

class _WalletState extends State<Wallet> with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late WalletProvider walletProvider;

  @override
  void initState() {
    walletProvider = Provider.of<WalletProvider>(context, listen: false);
    _scrollController.addListener(_scrollListener);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getApi();
    });
    super.initState();
  }

  getApi() {
    walletProvider.setLoading(true);
    fetchTransactionthistory("1", 0);
    walletProvider.setTab("1");
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

  @override
  void dispose() {
    walletProvider.clearProvider();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Utils.cusstomAppBar(
          name: "transaction_history", multilanguage: true, context: context),
      body: Consumer<WalletProvider>(builder: (context, walletProvider, child) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 00, 20, 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 20,
            children: [_buildTab(), Expanded(child: _buildMain())],
          ),
        );
      }),
    );
  }

// New Tab bar Started
  Widget _buildTab() {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _titleBuild("1", Icons.audio_file_rounded, "audio_book", () {
              walletProvider.setTab("1");
              walletProvider.clearData();
              fetchTransactionthistory(walletProvider.currentIndex, 0);
            }),
            _titleBuild("2", FontAwesomeIcons.book, "books", () {
              walletProvider.setTab("2");
              walletProvider.clearData();
              fetchTransactionthistory(walletProvider.currentIndex, 0);
            }),
            _titleBuild("3", FontAwesomeIcons.newspaper, "magazines", () {
              walletProvider.setTab("3");
              walletProvider.clearData();
              fetchTransactionthistory(walletProvider.currentIndex, 0);
            }),
          ],
        ));
  }

  Widget _titleBuild(index, iconData, title, onTap) {
    return InkWell(
      splashColor: transparent,
      hoverColor: transparent,
      focusColor: transparent,
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(right: 10),
        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
            color: Constant.isDarkMode
                ? walletProvider.currentIndex == index
                    ? colorPrimaryDark
                    : transparent
                : walletProvider.currentIndex == index
                    ? colorPrimary
                    : transparent,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              width: 1,
              style: BorderStyle.solid,
              color: Constant.isDarkMode
                  ? walletProvider.currentIndex == index
                      ? colorPrimary
                      : gray
                  : colorPrimary,
            )),
        child: Row(
          children: [
            Icon(
              color: Constant.isDarkMode
                  ? walletProvider.currentIndex == index
                      ? colorPrimary
                      : white
                  : walletProvider.currentIndex == index
                      ? white
                      : black,
              iconData,
              size: 16,
            ),
            SizedBox(width: 6),
            MyText(
              color: Constant.isDarkMode
                  ? walletProvider.currentIndex == index
                      ? colorPrimary
                      : white
                  : walletProvider.currentIndex == index
                      ? white
                      : black,
              text: title,
              multilanguage: true,
              fontwaight: FontWeight.w500,
              fontsize: Dimens.medium14TextSize,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMain() {
    if (walletProvider.loading && !walletProvider.loadMore) {
      return shimmer();
    } else {
      if (walletProvider.transactionHistory != null &&
          (walletProvider.transactionHistory?.length ?? 0) > 0) {
        return SingleChildScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _buildData(),
                const SizedBox(height: 10),
                if (walletProvider.loadMore)
                  Utils.pageLoader(context)
                else
                  const SizedBox.shrink(),
                const SizedBox(height: 30),
              ],
            ));
      } else {
        return const NoData();
      }
    }
  }

  Widget _buildData() {
    final transactions = walletProvider.transactionHistory ?? [];
    final groupedTransactions = _groupTransactionsByMonth(transactions);

    return ResponsiveGridList(
        minItemWidth: 400,
        maxItemsPerRow: 2,
        minItemsPerRow: 1,
        verticalGridMargin: 0,
        horizontalGridMargin: 0,
        verticalGridSpacing: 0,
        listViewBuilderOptions: ListViewBuilderOptions(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics()),
        children: List.generate(
          groupedTransactions.keys.length,
          (index) {
            final monthYear = groupedTransactions.keys.toList()[index];
            final transactionsInMonth = groupedTransactions[monthYear] ?? [];

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Month Header
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: MyText(
                    text: monthYear, // Display month and year
                    multilanguage: false,
                    fontsize: Dimens.medium18TextSize,
                    fontwaight: FontWeight.w600,
                    color: colorAccent,
                  ),
                ),
                // Transactions for the Month
                ...transactionsInMonth.map((trans) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: MyText(
                          text: trans.id.toString(),
                          multilanguage: false,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontsize: Dimens.medium14TextSize,
                          fontwaight: FontWeight.w400,
                        ),
                        title: MyText(
                          text: (trans.contentName ?? "").isEmpty
                              ? (trans.subContentName ?? "")
                              : trans.contentName ?? "",
                          multilanguage: false,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontsize: Dimens.medium12TextSize,
                          fontwaight: FontWeight.w600,
                        ),
                        subtitle: MyText(
                          text: "Trans_Id : ${trans.transactionId}",
                          multilanguage: false,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontsize: Dimens.medium12TextSize,
                          fontwaight: FontWeight.w400,
                        ),
                        trailing: MyText(
                          text: "\$ ${trans.price}",
                          multilanguage: false,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontsize: Dimens.medium16TextSize,
                          fontwaight: FontWeight.w400,
                        ),
                      ),
                      Align(
                        alignment: Alignment.topRight,
                        child: MyText(
                          text: Utils.dateConvert(
                              trans.createdAt ?? "", 'd MMM yyyy, h:mm a'),
                          multilanguage: false,
                          maxline: 1,
                          overflow: TextOverflow.ellipsis,
                          fontsize: Dimens.medium12TextSize,
                          fontwaight: FontWeight.w400,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            );
          },
        ));
  }

// Helper method to group transactions by month and year
  Map<String, List<Result>> _groupTransactionsByMonth(
      List<Result> transactions) {
    final Map<String, List<Result>> groupedTransactions = {};

    for (int i = 0; i < (transactions.length); i++) {
      final date = DateTime.parse(transactions[i].createdAt ?? "");
      final monthYear = DateFormat('MMMM yyyy').format(date);

      if (groupedTransactions.containsKey(monthYear)) {
        groupedTransactions[monthYear]!.add(transactions[i]);
      } else {
        groupedTransactions[monthYear] = [transactions[i]];
      }
    }

    return groupedTransactions;
  }

  /* Shimmer Data */

  Widget shimmer() {
    return ResponsiveGridList(
        minItemWidth: 400,
        maxItemsPerRow: 2,
        minItemsPerRow: 1,
        verticalGridMargin: 0,
        horizontalGridMargin: 0,
        verticalGridSpacing: 20,
        listViewBuilderOptions: ListViewBuilderOptions(
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics()),
        children: List.generate(10, (index) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              spacing: 6,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 20,
                  children: [
                    CustomWidget.circular(height: 30, width: 30),
                    Expanded(
                      child: CustomWidget.roundcorner(
                          height: 14, width: MediaQuery.sizeOf(context).width),
                    ),
                    const CustomWidget.roundcorner(height: 14, width: 60),
                  ],
                ),
                Align(
                    alignment: Alignment.topRight,
                    child: CustomWidget.roundcorner(height: 16, width: 200))
              ]);
        }));
  }
}
