import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/mynetworkimg.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:yourappname/widget/nodata.dart';
import 'package:yourappname/provider/notificationprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/widget/customwidget.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => NotificationPageState();
}

class NotificationPageState extends State<NotificationPage> {
  late NotificationProvider notificationprovider;
  late ScrollController _scrollController;
  @override
  void initState() {
    notificationprovider =
        Provider.of<NotificationProvider>(context, listen: false);
    _scrollController = ScrollController();
    _scrollController.addListener(_scrollListener);
    getApi(0);
    super.initState();
  }

  _scrollListener() async {
    if (!_scrollController.hasClients) return;
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange &&
        (notificationprovider.isMorePage ?? false) &&
        (notificationprovider.currentPage ?? 0) <
            (notificationprovider.totalPage ?? 0)) {
      await notificationprovider.setLoadMore(true);
      getApi(notificationprovider.currentPage ?? 0);
    }
  }

  getApi(int? nextPage) {
    notificationprovider.getNotification((nextPage ?? 0) + 1);
  }

  @override
  void dispose() {
    notificationprovider.clearProvider();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Scaffold(
        backgroundColor: Constant.isDarkMode ? appbarcolor : white,
        appBar: appBar(),
        body: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              notificationlist(),
              Consumer<NotificationProvider>(
                builder: (context, notificationProvider, child) {
                  if (notificationProvider.loadMore) {
                    return notificationlistShimmer();
                  } else {
                    return const SizedBox.shrink();
                  }
                },
              ),
            ],
          ),
        ),
      ),
    ]);
  }

  AppBar appBar() {
    return AppBar(
        backgroundColor: Constant.isDarkMode ? appbarcolor : white,
        surfaceTintColor: transparent,
        elevation: 0,
        leading: Utils.backButton(context),
        centerTitle: false,
        title: MyText(
          text: 'notification',
          fontsize: Dimens.medium16TextSize,
          color: Constant.isDarkMode ? white : black,
          isfont: 2,
          fontstyle: FontStyle.normal,
          multilanguage: true,
          maxline: 1,
          fontwaight: FontWeight.w600,
        ));
  }

  Widget notificationlist() {
    return Consumer<NotificationProvider>(
        builder: (context, notificationprovider, child) {
      if (notificationprovider.loading &&
          notificationprovider.loadMore == false) {
        return notificationlistShimmer();
      } else {
        if (notificationprovider.notificationModel.status == 200 &&
            notificationprovider.notificationList!.isNotEmpty &&
            notificationprovider.notificationList != null) {
          return AlignedGridView.count(
            shrinkWrap: true,
            crossAxisCount: 1,
            padding: EdgeInsets.only(bottom: 50),
            crossAxisSpacing: 0,
            mainAxisSpacing: 15,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: notificationprovider.notificationList?.length ?? 0,
            itemBuilder: (context, index) {
              final imageUrl = notificationprovider
                      .notificationList?[index].image
                      ?.toString() ??
                  "";

              return Slidable(
                key: ValueKey(
                  notificationprovider.notificationList?[index],
                ),
                direction: Axis.horizontal,
                closeOnScroll: true,
                endActionPane: ActionPane(
                  motion: const ScrollMotion(),
                  children: [
                    // delete Button
                    SlidableAction(
                      onPressed: (BuildContext context) async {
                        await notificationprovider.getReadNotification(
                            index,
                            notificationprovider.notificationList?[index].id
                                    .toString() ??
                                "");
                        if (notificationprovider.readNotificationloading) {
                          if (!mounted) return;
                          // Utils.showProgress(context);
                        } else {
                          if (notificationprovider
                                  .readnotificationModel.status ==
                              200) {
                            notificationprovider.notificationList
                                ?.removeAt(index);
                            getApi(0);
                            setState(() {});
                          }
                        }
                      },
                      backgroundColor: Theme.of(context).primaryColor,
                      icon: Icons.delete,
                      autoClose: true,
                      foregroundColor: white,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            height: 42,
                            width: 42,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6C4DF7),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: imageUrl.isNotEmpty
                                ? MyNetworkImage(
                                    imagePath: imageUrl,
                                    height: 20,
                                    width: 20,
                                    fit: BoxFit.cover,
                                  )
                                : const Icon(
                                    Icons.notifications_none_rounded,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                MyText(
                                  text: notificationprovider
                                          .notificationList?[index].title
                                          .toString() ??
                                      "",
                                  fontsize: Dimens.medium15TextSize,
                                  fontwaight: FontWeight.w500,
                                  maxline: 1,
                                  color: Constant.isDarkMode
                                      ? white
                                      : const Color(0xFF240046),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                MyText(
                                  text: notificationprovider
                                          .notificationList?[index].message
                                          .toString() ??
                                      "",
                                  fontsize: Dimens.medium13TextSize,
                                  fontwaight: FontWeight.w400,
                                  maxline: 2,
                                  overflow: TextOverflow.ellipsis,
                                  color: Constant.isDarkMode ? white : gray,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 8),

                          // 🔹 TIME (RIGHT)
                          MyText(
                            text: formateDate(
                              notificationprovider
                                      .notificationList?[index].createdAt
                                      .toString() ??
                                  "",
                            ),
                            fontsize: Dimens.medium11TextSize,
                            fontwaight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
                    Divider(
                      thickness: 1.2,
                      color: gray.withOpacity( 0.6),
                    )
                  ],
                ),
              );
            },
          );
        } else {
          return const NoData();
        }
      }
    });
  }

  formateDate(String time) {
    DateTime a = DateTime.parse(time);
    String format = DateFormat.yMMMd().format(a);
    printLog(format);
    return format;
  }

  Widget notificationlistShimmer() {
    return AlignedGridView.count(
      shrinkWrap: true,
      crossAxisCount: 1,
      crossAxisSpacing: 0,
      mainAxisSpacing: 15,
      physics: const BouncingScrollPhysics(),
      itemCount: 10,
      itemBuilder: (context, index) {
        return Row(
          children: [
            const CustomWidget.circular(
              height: 55,
              width: 55,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomWidget.roundcorner(
                    height: 12,
                    width: MediaQuery.sizeOf(context).width * 0.45,
                  ),
                  const SizedBox(height: 10),
                  const CustomWidget.roundcorner(height: 6),
                  const SizedBox(height: 10),
                  const CustomWidget.roundcorner(height: 6),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
