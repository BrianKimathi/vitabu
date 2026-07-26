import 'dart:async';

import 'package:yourappname/pages/pdf/padfsearch.dart';
import 'package:yourappname/provider/bookdetailsprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:http/http.dart' as http;
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfReadingPage extends StatefulWidget {
  final int issubscription;
  final String? autherid, contentType;
  final String? pdfUrl;
  final String? bookID;
  final String? chapterID;

  final String? name;
  const PdfReadingPage(
      {super.key,
      required this.pdfUrl,
      required this.name,
      this.chapterID,
      required this.bookID,
      required this.issubscription,
      required this.autherid,
      required this.contentType});

  @override
  State<PdfReadingPage> createState() => _PdfReadingPageState();
}

class _PdfReadingPageState extends State<PdfReadingPage>
    with WidgetsBindingObserver {
  OverlayEntry? _overlayEntry;

  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final GlobalKey<SearchToolbarState> _textSearchKey = GlobalKey();
  PdfViewerController? _pdfViewerController;
  PdfTextSearchResult? searchResult;
  bool _showToolbar = false;
  bool _isFullscreen = true; // Immersive by default
  bool _isHorizontalSwipe = false;

  Timer? _hideControlsTimer;
  bool? showScrollHead;
  PdfBookmark? pdfBookmark;
  LocalHistoryEntry? _historyEntry;
  Uint8List? documentBytes;
  /// Set when download fails or body is not a PDF (e.g. HTML 404 from wrong file URL).
  String? _pdfLoadError;
  double? xOffset;
  double? yOffset;
  late BookDetailsProvider bookDetailsProvider;

  @override
  void initState() {
    _showToolbar = false;
    showScrollHead = true;
    _pdfViewerController = PdfViewerController();
    searchResult = PdfTextSearchResult();
    bookDetailsProvider =
        Provider.of<BookDetailsProvider>(context, listen: false);
    
    // Set to immersive by default
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _startHideControlsTimer();

    getPdfBytes();
    printLog(
        "📘 PDF OPENED ===================>>>> Waiting 1 minute before starting history");
    _delayTimer = Timer(const Duration(minutes: 1), () {
      printLog(
          "⏱ 1 MINUTE COMPLETED ===================>>>> Start history tracking");
      _startHistory();
    });
    super.initState();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && !_isFullscreen) {
        _setFullscreen(true);
      }
    });
  }

  void _toggleUI() {
    if (_showToolbar) return; // Don't toggle if search is active
    _setFullscreen(!_isFullscreen);
    if (!_isFullscreen) {
      _startHideControlsTimer();
    } else {
      _hideControlsTimer?.cancel();
    }
  }

  Future<void> _setFullscreen(bool fullscreen) async {
    try {
      if (fullscreen) {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() => _isFullscreen = fullscreen);
  }

  void getPdfBytes() async {
    _pdfLoadError = null;
    final url = widget.pdfUrl?.trim() ?? '';
    if (url.isEmpty) {
      _pdfLoadError =
          'No PDF URL from server. Re-save the novel in admin with a PDF file.';
      if (mounted) setState(() {});
      return;
    }
    try {
      final uri = Uri.parse(url);
      final response = await http.get(uri);
      if (response.statusCode != 200) {
        _pdfLoadError =
            'Could not download PDF (HTTP ${response.statusCode}). Check that files are reachable at APP_URL/storage/... and storage:link exists.';
        documentBytes = null;
      } else {
        final bytes = response.bodyBytes;
        if (bytes.length < 5 ||
            String.fromCharCodes(bytes.sublist(0, 5)) != '%PDF-') {
          _pdfLoadError =
              'The URL did not return a valid PDF (often an HTML error page). Fix IMAGE_URL / APP_URL in .env so links use .../storage/novels/... not .../storage/app/public/...';
          documentBytes = null;
        } else {
          documentBytes = bytes;
        }
      }
    } catch (e, st) {
      printLog('PDF load error: $e\n$st');
      _pdfLoadError = 'Failed to load PDF: $e';
      documentBytes = null;
    }
    if (mounted) setState(() {});
  }

  /// Ensure the entry history of text search.
  void _ensureHistoryEntry() {
    if (_historyEntry == null) {
      final ModalRoute<dynamic>? route = ModalRoute.of(context);
      if (route != null) {
        _historyEntry = LocalHistoryEntry(onRemove: _handleHistoryEntryRemoved);
        route.addLocalHistoryEntry(_historyEntry!);
      }
    }
  }

  /// Remove history entry for text search.
  void _handleHistoryEntryRemoved() {
    _textSearchKey.currentState?.clearSearch();
    _showToolbar = false;
    if (mounted) {
      setState(() {});
    }
    _historyEntry = null;
  }

  // ================= ADD HISTORY LOGIC =================
  Timer? _delayTimer; // 1 minute delay
  Timer? _readTimer; // reading timer

  int _timeSpend = 0;
  int _lastPage = 1;

  bool _apiStarted = false;
  // ====================================================

  // ================= ADD HISTORY FUNCTIONS =================

  void _startHistory() {
    if (_apiStarted) return;

    _apiStarted = true;

    printLog("▶️ ===>>>> HISTORY STARTED <<<<===");
    printLog("📊 ===>>>> Initial Page: <<<<=== $_lastPage");
    printLog("⏱ ===>>>> Initial Time: <<<<=== $_timeSpend seconds");

    _readTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timeSpend++;

      if (_timeSpend % 5 == 0) {
        printLog("⏱ ===>>>> Time Spent: <<<<=== $_timeSpend sec");
      }
    });
  }

  void _callHistoryApi() {
    if (!_apiStarted) {
      printLog(" ===>>>> API NOT CALLED (History not started)<<<<=== ");
      return;
    }
    printLog("🌐 CALLING ADD HISTORY API");
    printLog("➡️ author_id      ===>>>>: ${widget.autherid}");
    printLog("➡️ content_type   ===>>>>: ${widget.contentType}");
    printLog("➡️ book_id        ===>>>>: ${widget.bookID}");
    printLog("➡️ chapter_id     ===>>>>: ${widget.chapterID}");
    printLog("➡️ is_subscription===>>>>: ${widget.issubscription}");
    printLog("➡️ last_page      ===>>>>: $_lastPage");
    printLog("➡️ time_spend(sec)===>>>>: $_timeSpend");

    bookDetailsProvider.addhistorydata(
      widget.autherid,
      widget.contentType,
      widget.bookID,
      widget.chapterID,
      _timeSpend,
      widget.issubscription,
      _lastPage,
    );
  }

  void _pauseAndSave() {
    printLog("<<<<<============== Pause And save =>>>>>");

    printLog("<<<<<=== APP PAUSED / PAGE LEFT =======>>>>>");
    printLog("⏱ <<<<<=== Final Time Spent: $_timeSpend sec ===>>>>>");
    printLog("📄 <<<<<===Final Page Read:===>>>>> $_lastPage");
    _readTimer?.cancel();
    _readTimer = null;
    if (_timeSpend >= 60) {
      printLog("✅ Calling API (time >= 60s)");
      _callHistoryApi();
    } else {
      printLog("🚫 Time < 60s → API NOT CALLED");
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    printLog("<<<<<==== APP STATE CHANGED  ===>>>>> $state");
    if (!_apiStarted) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      printLog("🏠<<<<<=== APP TO HOME → END SESSION ===>>>>>");
      _pauseAndSave();
    }
  }

  @override
  void dispose() {
    printLog("❌ <<<<< PDF PAGE DISPOSED ===>>>>>");

    _delayTimer?.cancel();
    _readTimer?.cancel();
    _hideControlsTimer?.cancel();

    printLog("✅ <<<<=== FINAL API CALL ON DISPOSE ===>>>>>");
    printLog("⏱ <<<<<=== Total Time Spent: $_timeSpend sec ===>>>>>");
    printLog("📄 <<<<<==== Total Pages Read: $_lastPage ===>>>>>");
    _callHistoryApi();

    // Restore system UI if user leaves while fullscreen.
    if (_isFullscreen) {
      try {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      } catch (_) {}
    }

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  // ===============
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: _isFullscreen,
        appBar: _isFullscreen
            ? null
            : _showToolbar
            ? AppBar(
                elevation: 1,
                leading: Utils.backButton(context),
                flexibleSpace: SafeArea(
                  child: SearchToolbar(
                    key: _textSearchKey,
                    showTooltip: true,
                    controller: _pdfViewerController,
                    onTap: (Object toolbarItem) async {
                      if (toolbarItem.toString() == 'Cancel Search') {
                        _showToolbar = false;
                        showScrollHead = true;
                        if (Navigator.canPop(context)) {
                          Navigator.maybePop(context);
                        }
                      }
                      if (toolbarItem.toString() == 'noResultFound') {
                        _textSearchKey.currentState?.showToast = true;

                        await Future.delayed(const Duration(seconds: 1));
                        _textSearchKey.currentState?.showToast = false;
                      }
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),
                ),
                automaticallyImplyLeading: false,
              )
            : AppBar(
                elevation: 1,
                title: Row(
                  children: [
                    InkWell(
                        onTap: () async {
                          if (_pdfViewerController?.pageNumber !=
                              _pdfViewerController?.pageCount) {
                            // bookDetailsProvider.continuereadbook(
                            //     bookDetailsProvider
                            //         .bookDetailModel.result?.id);
                            if (!context.mounted) return;
                            if (Navigator.canPop(context)) {
                              Navigator.maybePop(context);
                            }
                          }
                        },
                        child: Utils.backButton(context)),
                    const SizedBox(width: 15),
                    Expanded(
                      child: MyText(
                        text: widget.name ?? "",
                        fontsize: Dimens.largeTextSize,
                        fontwaight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_drop_down_circle,
                    ),
                    onPressed: () {
                      _pdfViewerController?.jumpToBookmark(pdfBookmark!);
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.bookmark,
                    ),
                    onPressed: () {
                      _pdfViewerKey.currentState?.openBookmarkView();
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.search,
                    ),
                    onPressed: () {
                      showScrollHead = false;
                      _showToolbar = true;
                      _ensureHistoryEntry();
                      if (mounted) {
                        setState(() {});
                      }
                    },
                  ),
                ],
                automaticallyImplyLeading: false,
              ),
        body: GestureDetector(
          onTap: _toggleUI,
          child: Stack(
            children: [
              _pdfLoadError != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        _pdfLoadError!,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                : documentBytes == null
                    ? const Center(child: CircularProgressIndicator())
                    : SfPdfViewer.memory(
                    documentBytes ?? Uint8List(0),
                    pageSpacing: 0,
                    pageLayoutMode: PdfPageLayoutMode.single,
                    scrollDirection: _isHorizontalSwipe
                        ? PdfScrollDirection.horizontal
                        : PdfScrollDirection.vertical,
                    canShowScrollHead: !_isFullscreen && (showScrollHead ?? true),
                    canShowScrollStatus: !_isFullscreen,
                    enableDoubleTapZooming: true,
                    enableTextSelection: true,
                    currentSearchTextHighlightColor: colorAccent,
                    otherSearchTextHighlightColor: colorAccent,
                    onHyperlinkClicked: (value) {},
                    onDocumentLoaded: (PdfDocumentLoadedDetails details) {
                      printLog(
                          "bookmarks.count -----??${details.document.bookmarks.count}");
                      if (details.document.bookmarks.count > 0) {
                        pdfBookmark = details.document.bookmarks[0];
                      }
                    },
                    onTextSelectionChanged:
                        (PdfTextSelectionChangedDetails details) {
                      if (details.selectedText == null &&
                          _overlayEntry != null) {
                        _checkAndCloseContextMenu();
                      } else if (details.selectedText != null &&
                          _overlayEntry == null) {
                        _showContextMenu(context, details);
                      }
                    },
                    key: _pdfViewerKey,
                    controller: _pdfViewerController,
                    onDocumentLoadFailed: (value) {},
                    onPageChanged: (details) {
                      _lastPage = details
                          .newPageNumber; // ===== ADD HISTORY LOGIC =====

                      printLog(
                          "📄 PAGE CHANGED ===================>>>> Current Page: <<<<=================== $_lastPage");
                    },
                    onZoomLevelChanged: (details) {},
                    initialZoomLevel: 1,
                  ),
            Visibility(
              visible: _textSearchKey.currentState?.showToast ?? false,
              child: Align(
                alignment: Alignment.center,
                child: Flex(
                  direction: Axis.horizontal,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.only(
                          left: 15, top: 7, right: 15, bottom: 7),
                      decoration: BoxDecoration(
                        color: gray.withOpacity( 0.6),
                        borderRadius: const BorderRadius.all(
                          Radius.circular(16.0),
                        ),
                      ),
                      child: const MyText(
                        color: white,
                        text: "no_result",
                        multilanguage: true,
                        fontsize: Dimens.largeTextSize,
                        fontwaight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (!_isFullscreen)
              Positioned(
                top: 12,
                right: 12,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Card(
                      child: IconButton(
                        tooltip: _isHorizontalSwipe
                            ? "Vertical scroll"
                            : "Horizontal swipe",
                        icon: Icon(_isHorizontalSwipe
                            ? Icons.swap_vert
                            : Icons.swipe_left_alt),
                        onPressed: () {
                          setState(() {
                            _isHorizontalSwipe = !_isHorizontalSwipe;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 6),
                    Card(
                      child: IconButton(
                        tooltip: _isFullscreen ? "Exit fullscreen" : "Fullscreen",
                        icon: Icon(_isFullscreen
                            ? Icons.fullscreen_exit
                            : Icons.fullscreen),
                        onPressed: () {
                          _setFullscreen(!_isFullscreen);
                        },
                      ),
                    ),
                  ],
                ),
              ),
            if (!_isFullscreen)
              Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8.0, 20, 30),
                child: Card(
                  elevation: 2,
                  color: Theme.of(context).cardColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(
                          Icons.keyboard_double_arrow_up_sharp,
                        ),
                        onPressed: () {
                          _pdfViewerController?.firstPage();
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.keyboard_arrow_up,
                        ),
                        onPressed: () {
                          _pdfViewerController?.previousPage();
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.keyboard_arrow_down,
                        ),
                        onPressed: () {
                          _pdfViewerController?.nextPage();
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.keyboard_double_arrow_down_sharp,
                        ),
                        onPressed: () {
                          _pdfViewerController?.lastPage();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        )));
  }

  void _showContextMenu(
    BuildContext context,
    PdfTextSelectionChangedDetails? details,
  ) {
    final RenderBox renderBoxContainer =
        context.findRenderObject()! as RenderBox;
    const double kContextMenuHeight = 90;
    const double kContextMenuWidth = 100;
    const double kHeight = 18;
    final Offset containerOffset = renderBoxContainer.localToGlobal(
      renderBoxContainer.paintBounds.topLeft,
    );
    if (details != null &&
            containerOffset.dy < details.globalSelectedRegion!.topLeft.dy ||
        (containerOffset.dy <
                details!.globalSelectedRegion!.center.dy -
                    (kContextMenuHeight / 2) &&
            details.globalSelectedRegion!.height > kContextMenuWidth)) {
      double top = 0.0;
      double left = 0.0;
      final Rect globalSelectedRect = details.globalSelectedRegion!;
      if ((globalSelectedRect.top) > MediaQuery.of(context).size.height / 2) {
        top = globalSelectedRect.topLeft.dy +
            details.globalSelectedRegion!.height +
            kHeight;
        left = globalSelectedRect.bottomLeft.dx;
      } else {
        top = globalSelectedRect.height > kContextMenuWidth
            ? globalSelectedRect.center.dy - (kContextMenuHeight / 2)
            : globalSelectedRect.topLeft.dy +
                details.globalSelectedRegion!.height +
                kHeight;
        left = globalSelectedRect.height > kContextMenuWidth
            ? globalSelectedRect.center.dx - (kContextMenuWidth / 2)
            : globalSelectedRect.bottomLeft.dx;
      }
      final OverlayState overlayState = Overlay.of(context, rootOverlay: true);
      _overlayEntry = OverlayEntry(
        builder: (context) => Positioned(
          top: top,
          left: left,
          child: Card(
            elevation: 10,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  height: 30,
                  width: 100,
                  child: RawMaterialButton(
                    onPressed: () async {
                      _checkAndCloseContextMenu();
                      if (details.selectedText != null) {
                        Clipboard.setData(
                            ClipboardData(text: details.selectedText!));
                        printLog(
                            'Text copied to clipboard: ${details.selectedText}');
                        // _pdfViewerController.clearSelection();
                      }
                    },
                    child: const MyText(
                      color: black,
                      text: "copy",
                      multilanguage: true,
                      fontsize: Dimens.medium12TextSize,
                      fontwaight: FontWeight.w500,
                    ),
                  ),
                ),
                _addAnnotation('highlight', details.selectedText),
                _addAnnotation('underline', details.selectedText),
                _addAnnotation('strikethrough', details.selectedText),
              ],
            ),
          ),
        ),
      );
      overlayState.insert(_overlayEntry!);
    }
  }

  /// Check and close the context menu.
  void _checkAndCloseContextMenu() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
  }

  Widget _addAnnotation(String? annotationType, String? selectedText) {
    return SizedBox(
      height: 30,
      width: 100,
      child: RawMaterialButton(
        onPressed: () async {
          _checkAndCloseContextMenu();
          _drawAnnotation(annotationType);
        },
        child: MyText(
          color: black,
          text: annotationType!,
          multilanguage: true,
          fontsize: Dimens.medium12TextSize,
          fontwaight: FontWeight.w500,
        ),
      ),
    );
  }

  void _drawAnnotation(String? annotationType) {
    PdfDocument document = PdfDocument(inputBytes: documentBytes);
    switch (annotationType) {
      case 'highlight':
        {
          _pdfViewerKey.currentState!
              .getSelectedTextLines()
              .forEach((pdfTextLine) {
            final PdfPage page = document.pages[pdfTextLine.pageNumber];
            final PdfRectangleAnnotation rectangleAnnotation =
                PdfRectangleAnnotation(
                    pdfTextLine.bounds, 'Highlight Annotation',
                    author: 'Syncfusion',
                    color: PdfColor.fromCMYK(0, 0, 255, 0),
                    innerColor: PdfColor.fromCMYK(0, 0, 255, 0),
                    opacity: 0.5);
            page.annotations.add(rectangleAnnotation);
            page.annotations.flattenAllAnnotations();
            xOffset = _pdfViewerController?.scrollOffset.dx;
            yOffset = _pdfViewerController?.scrollOffset.dy;
          });
          final List<int> bytes = document.saveSync();
          setState(() {
            documentBytes = Uint8List.fromList(bytes);
            printLog("Highlight documentBytes -----??$documentBytes");
          });
        }
        break;
      case 'underline':
        {
          _pdfViewerKey.currentState!
              .getSelectedTextLines()
              .forEach((pdfTextLine) {
            final PdfPage page = document.pages[pdfTextLine.pageNumber];
            final PdfLineAnnotation lineAnnotation = PdfLineAnnotation(
              [
                pdfTextLine.bounds.left.toInt(),
                (document.pages[pdfTextLine.pageNumber].size.height -
                        pdfTextLine.bounds.bottom)
                    .toInt(),
                pdfTextLine.bounds.right.toInt(),
                (document.pages[pdfTextLine.pageNumber].size.height -
                        pdfTextLine.bounds.bottom)
                    .toInt()
              ],
              'Underline Annotation',
              author: 'Syncfusion',
              innerColor: PdfColor(0, 255, 0),
              color: PdfColor(0, 255, 0),
            );
            page.annotations.add(lineAnnotation);
            page.annotations.flattenAllAnnotations();
            xOffset = _pdfViewerController?.scrollOffset.dx;
            yOffset = _pdfViewerController?.scrollOffset.dy;
          });
          final List<int> bytes = document.saveSync();
          setState(() {
            documentBytes = Uint8List.fromList(bytes);
            printLog("Underline documentBytes -----??$documentBytes");
          });
        }
        break;
      case 'strikethrough':
        {
          _pdfViewerKey.currentState!
              .getSelectedTextLines()
              .forEach((pdfTextLine) {
            final PdfPage page = document.pages[pdfTextLine.pageNumber];
            final PdfLineAnnotation lineAnnotation = PdfLineAnnotation(
              [
                pdfTextLine.bounds.left.toInt(),
                ((document.pages[pdfTextLine.pageNumber].size.height -
                            pdfTextLine.bounds.bottom) +
                        (pdfTextLine.bounds.height / 2))
                    .toInt(),
                pdfTextLine.bounds.right.toInt(),
                ((document.pages[pdfTextLine.pageNumber].size.height -
                            pdfTextLine.bounds.bottom) +
                        (pdfTextLine.bounds.height / 2))
                    .toInt()
              ],
              'Strikethrough Annotation',
              author: 'Syncfusion',
              innerColor: PdfColor(255, 0, 0),
              color: PdfColor(255, 0, 0),
            );
            page.annotations.add(lineAnnotation);
            page.annotations.flattenAllAnnotations();
            xOffset = _pdfViewerController?.scrollOffset.dx;
            yOffset = _pdfViewerController?.scrollOffset.dy;
          });
          final List<int> bytes = document.saveSync();
          setState(() {
            documentBytes = Uint8List.fromList(bytes);
            printLog("Strikethrough documentBytes -----??$documentBytes");
          });
        }
        break;
    }
  }
}
