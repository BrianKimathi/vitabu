import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webwidget/footerweb.dart';
import 'package:yourappname/webwidget/webappbar.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class CommonPage extends StatefulWidget {
  final String appBarTitle, loadURL;

  const CommonPage({
    super.key,
    required this.appBarTitle,
    required this.loadURL,
  });

  @override
  State<CommonPage> createState() => _CommonPageState();
}

class _CommonPageState extends State<CommonPage> {
  var loadingPercentage = 0;
  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;
  SharedPref sharedPref = SharedPref();
  final ScrollController scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    printLog("loadURL ========> ${widget.loadURL}");
    pullToRefreshController = (kIsWeb) ||
            ![TargetPlatform.iOS, TargetPlatform.android]
                .contains(defaultTargetPlatform)
        ? null
        : PullToRefreshController(
            settings: PullToRefreshSettings(color: colorAccent),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController?.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS) {
                webViewController?.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController?.getUrl()));
              }
            },
          );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        backgroundColor: colorPrimaryDark,
        body: WebAppBar(
          widget: _buildWeb(),
        ),
      );
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: Utils.backButton(context),
        title: MyText(
          color: Constant.isDarkMode ? white : black,
          text: widget.appBarTitle,
          fontsize: Dimens.medium18TextSize,
          multilanguage: false,
          fontwaight: FontWeight.w600,
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: setWebView(),
          ),
        ],
      ),
    );
  }

  Widget _buildWeb() {
    final screenWidth = MediaQuery.of(context).size.width;
    const double maxContentWidth = 1400;
    final bool isWide = screenWidth > 1000;

    return SingleChildScrollView(
      controller: scrollController,
      child: Column(
        children: [
          Center(
            child: SizedBox(
              width: isWide ? maxContentWidth : screenWidth,
              child: Utils.buildWebDetailsAppBar(
                context: context,
                isHome: true,
                title2: widget.appBarTitle,
                multilanguage: false,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: SizedBox(
              width: isWide ? maxContentWidth : screenWidth,
              height: MediaQuery.of(context).size.height * 0.8,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: setWebView(),
              ),
            ),
          ),
          const SizedBox(height: 40),
          FooterWeb(),
        ],
      ),
    );
  }

  Widget setWebView() {
    final formattedUrl = widget.loadURL;

    return Stack(
      children: [
        InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(formattedUrl)),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            clearCache: true,
            supportZoom: true,
            disableHorizontalScroll: true,
            disableVerticalScroll: false,
          ),
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          pullToRefreshController: pullToRefreshController,
          onLoadStart: (controller, url) {
            setState(() => loadingPercentage = 0);
          },
          onLoadStop: (controller, url) async {
            pullToRefreshController?.endRefreshing();
            setState(() => loadingPercentage = 100);
          },
          onReceivedError: (controller, request, error) {
            pullToRefreshController?.endRefreshing();
            setState(() => loadingPercentage = 100);
          },
          onProgressChanged: (controller, progress) {
            setState(() => loadingPercentage = progress);
            if (progress == 100) {
              pullToRefreshController?.endRefreshing();
            }
          },
          onConsoleMessage: (controller, consoleMessage) {
            printLog("consoleMessage: ${consoleMessage.message}");
          },
        ),
        if (loadingPercentage < 100)
          LinearProgressIndicator(
            color: colorAccent,
            backgroundColor: colorPrimaryDark,
            value: loadingPercentage / 100.0,
          ),
      ],
    );
  }
}
