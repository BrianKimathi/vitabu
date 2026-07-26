import 'dart:async';

import 'package:yourappname/provider/bookdetailsprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/utils/web_fullscreen.dart';
import 'package:yourappname/webpages/webpdfsearch.dart';
import 'package:yourappname/webwidget/webappbar.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:http/http.dart' as http;

class WebPdfReadingPage extends StatefulWidget {
  final int issubscription;
  final String? autherid, contentType;
  final String? pdfUrl;
  final String? bookID;
  final String? chapterID;
  final String? name;

  const WebPdfReadingPage(
      {super.key,
      required this.pdfUrl,
      required this.name,
      this.chapterID,
      required this.bookID,
      required this.issubscription,
      required this.autherid,
      required this.contentType});

  @override
  State<WebPdfReadingPage> createState() => _WebPdfReadingPageState();
}

class _WebPdfReadingPageState extends State<WebPdfReadingPage>
    with WidgetsBindingObserver {
  final GlobalKey<SfPdfViewerState> _pdfViewerKey = GlobalKey();
  final GlobalKey<WebSearchToolbarState> _textSearchKey = GlobalKey();
  PdfViewerController? _pdfViewerController;
  PdfTextSearchResult? searchResult;
  bool showToolbar = false;

  PdfBookmark? pdfBookmark;
  Uint8List? documentBytes;
  OverlayEntry? _overlayEntry;
  /// Shown when [SfPdfViewer.network] cannot parse the response (wrong URL / HTML / CORS).
  String? _networkPdfError;
  bool _isPdfPrecheckLoading = true;
  late BookDetailsProvider bookDetailsProvider;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _pdfViewerController = PdfViewerController();
    
    // Default to fullscreen immersive mode
    _isFullscreen = true;
    setWebFullscreen(true);
    _startHideControlsTimer();
    searchResult = PdfTextSearchResult();
    bookDetailsProvider =
        Provider.of<BookDetailsProvider>(context, listen: false);
    webReadBookLog(
      'PDF_VIEWER_INIT',
      'kIsWeb=$kIsWeb bookID=${widget.bookID} chapterID=${widget.chapterID} '
      'name=${widget.name} contentType=${widget.contentType} '
      'pdfUrl=${webReadBookFormatPdfUrl(widget.pdfUrl)}',
    );
    _loadPdfBytes();
    printLog(
        "📘 PDF OPENED ===================>>>> Waiting 1 minute before starting history");
    _delayTimer = Timer(const Duration(minutes: 1), () {
      printLog(
          "⏱ 1 MINUTE COMPLETED ===================>>>> Start history tracking");
      _startHistory();
    });
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

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && !_isFullscreen) {
        setState(() => _isFullscreen = true);
        setWebFullscreen(true);
      }
    });
  }

  void _toggleUI() {
    if (showToolbar) return;
    setState(() => _isFullscreen = !_isFullscreen);
    setWebFullscreen(_isFullscreen);
    if (!_isFullscreen) {
      _startHideControlsTimer();
    } else {
      _hideControlsTimer?.cancel();
    }
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

    WidgetsBinding.instance.removeObserver(this);

    super.dispose();
  }

  Future<void> _loadPdfBytes() async {
    final raw = widget.pdfUrl?.trim() ?? '';
    if (raw.isEmpty) {
      webReadBookLog('PDF_PREFETCH_SKIP', 'reason=empty_pdfUrl');
      _networkPdfError =
          'No PDF URL from API for this book. Re-upload the file in admin panel.';
      _isPdfPrecheckLoading = false;
      if (mounted) setState(() {});
      return;
    }
    webReadBookLog('PDF_PREFETCH_START', webReadBookFormatPdfUrl(raw));
    try {
      final uri = Uri.parse(raw);
      webReadBookLog('PDF_PREFETCH_URI', 'host=${uri.host} scheme=${uri.scheme} pathLen=${uri.path.length}');
      final response = await http.get(uri);
      final len = response.bodyBytes.length;
      final head = len >= 5
          ? String.fromCharCodes(response.bodyBytes.sublist(0, 5))
          : '(short)';
      webReadBookLog(
        'PDF_PREFETCH_RESPONSE',
        'status=${response.statusCode} bytes=$len first5=$head contentType=${response.headers['content-type']}',
      );
      if (response.statusCode == 200 &&
          len >= 5 &&
          head == '%PDF-') {
        documentBytes = response.bodyBytes;
        _networkPdfError = null;
        webReadBookLog('PDF_PREFETCH_OK', 'cachedBytes=$len (for annotations)');
      } else if (response.statusCode == 404) {
        _networkPdfError =
            'PDF file not found (404). The saved file path exists in DB, but file is missing on server.';
        webReadBookLog('PDF_PREFETCH_404', webReadBookFormatPdfUrl(raw));
      } else if (response.statusCode == 200 && head != '%PDF-') {
        final preview = len > 80
            ? String.fromCharCodes(response.bodyBytes.sublist(0, 80))
            : String.fromCharCodes(response.bodyBytes);
        _networkPdfError =
            'URL did not return a PDF file. It may be an HTML error page.';
        webReadBookLog(
          'PDF_PREFETCH_NOT_PDF',
          'bodyPreview=${preview.replaceAll(RegExp(r'\s+'), ' ')}',
        );
      } else {
        _networkPdfError = 'Could not load PDF (HTTP ${response.statusCode}).';
      }
    } catch (e, st) {
      webReadBookLog('PDF_PREFETCH_ERROR', '$e');
      printLog('PDF_PREFETCH stack: $st');
      _networkPdfError = 'Failed to load PDF URL: $e';
    }
    _isPdfPrecheckLoading = false;
    if (mounted) setState(() {});
  }

  void _ensureHistoryEntry() {
    final ModalRoute<dynamic>? route = ModalRoute.of(context);
    if (route != null && _textSearchKey.currentState != null) {
      route.addLocalHistoryEntry(
        LocalHistoryEntry(onRemove: () {
          _textSearchKey.currentState?.clearSearch();
          if (mounted) setState(() {});
        }),
      );
    }
  }

  void _checkAndCloseContextMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _showContextMenu(
      BuildContext context, PdfTextSelectionChangedDetails? details) {
    if (details == null || _overlayEntry != null) return;

    final RenderBox renderBoxContainer =
        context.findRenderObject()! as RenderBox;
    const double kHeight = 18;
    renderBoxContainer.localToGlobal(
      renderBoxContainer.paintBounds.topLeft,
    );

    final Rect globalSelectedRect = details.globalSelectedRegion!;
    double top = globalSelectedRect.topLeft.dy + kHeight;
    double left = globalSelectedRect.bottomLeft.dx;

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
              _buildContextButton('copy', details),
              _buildContextButton('highlight', details),
              _buildContextButton('underline', details),
              _buildContextButton('strikethrough', details),
            ],
          ),
        ),
      ),
    );
    overlayState.insert(_overlayEntry!);
  }

  Widget _buildContextButton(
      String type, PdfTextSelectionChangedDetails details) {
    return SizedBox(
      height: 30,
      width: 100,
      child: RawMaterialButton(
        onPressed: () {
          _checkAndCloseContextMenu();
          if (type == 'copy' && details.selectedText != null) {
            Clipboard.setData(ClipboardData(text: details.selectedText!));
          } else {
            _drawAnnotation(type, details.selectedText);
          }
        },
        child: MyText(
          color: black,
          text: type,
          multilanguage: true,
          fontsize: Dimens.medium12TextSize,
          fontwaight: FontWeight.w500,
        ),
      ),
    );
  }

  void _drawAnnotation(String? type, String? selectedText) {
    if (documentBytes == null) return;
    PdfDocument document = PdfDocument(inputBytes: documentBytes);

    _pdfViewerKey.currentState?.getSelectedTextLines().forEach((pdfTextLine) {
      final PdfPage page = document.pages[pdfTextLine.pageNumber];
      switch (type) {
        case 'highlight':
          page.annotations.add(PdfRectangleAnnotation(
            pdfTextLine.bounds,
            'Highlight',
            author: 'Syncfusion',
            color: PdfColor.fromCMYK(0, 0, 255, 0),
            innerColor: PdfColor.fromCMYK(0, 0, 255, 0),
            opacity: 0.5,
          ));
          break;
        case 'underline':
          page.annotations.add(PdfLineAnnotation([
            pdfTextLine.bounds.left.toInt(),
            (page.size.height - pdfTextLine.bounds.bottom).toInt(),
            pdfTextLine.bounds.right.toInt(),
            (page.size.height - pdfTextLine.bounds.bottom).toInt()
          ], 'Underline', author: 'Syncfusion', color: PdfColor(0, 255, 0)));
          break;
        case 'strikethrough':
          page.annotations.add(PdfLineAnnotation([
            pdfTextLine.bounds.left.toInt(),
            ((page.size.height - pdfTextLine.bounds.bottom) +
                    pdfTextLine.bounds.height / 2)
                .toInt(),
            pdfTextLine.bounds.right.toInt(),
            ((page.size.height - pdfTextLine.bounds.bottom) +
                    pdfTextLine.bounds.height / 2)
                .toInt()
          ], 'Strikethrough',
              author: 'Syncfusion', color: PdfColor(255, 0, 0)));
          break;
      }
      page.annotations.flattenAllAnnotations();
    });

    final bytes = document.saveSync();
    setState(() => documentBytes = Uint8List.fromList(bytes));
  }

  double _zoomLevel = 1.0; // 1.0 = 100%
  bool _isFullscreen = true;
  bool _isHorizontalSwipe = false;
  Timer? _hideControlsTimer;

  bool showToast = false;
  void setToast(bool value) {
    setState(() {
      showToast = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectivePdfUrl = widget.pdfUrl?.trim() ?? '';
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    const double maxContentWidth = 1400;
    final contentWidth =
        screenWidth > maxContentWidth ? maxContentWidth : screenWidth - 20;
    return WebAppBar(
      hideAppBar: _isFullscreen,
      widget: Consumer<BookDetailsProvider>(
        builder: (context, provider, child) {
          return SizedBox(
            width: _isFullscreen ? screenWidth : null,
            height: _isFullscreen ? screenHeight : null,
            child: Center(
              child: Container(
              width: _isFullscreen ? screenWidth : contentWidth,
              height: _isFullscreen ? screenHeight : null,
              padding: _isFullscreen
                  ? EdgeInsets.zero
                  : EdgeInsets.symmetric(horizontal: screenWidth <= 1000 ? 10 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!_isFullscreen)
                    Utils.buildWebDetailsAppBar(
                        context: context,
                        title2: widget.name,
                        isHome: false,
                        multilanguage: false),

                  // Search Toolbar
                  if (showToolbar && !_isFullscreen)
                    WebSearchToolbar(
                      key: _textSearchKey,
                      showTooltip: true,
                      controller: _pdfViewerController,
                      onTap: (Object toolbarItem) async {
                        if (toolbarItem.toString() == 'Cancel Search') {
                          showToolbar = false;
                          _textSearchKey.currentState?.clearSearch();
                          if (mounted) setState(() {});
                        }
                        if (toolbarItem.toString() == 'noResultFound') {
                          _textSearchKey.currentState?.showToast = true;
                          await Future.delayed(const Duration(seconds: 1));
                          _textSearchKey.currentState?.showToast = false;
                        }
                      },
                    ),

                  // Zoom Buttons
                  if (!_isFullscreen)
                    Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          if (_zoomLevel > 1.0) {
                            _zoomLevel -= 0.1;
                            _pdfViewerController?.zoomLevel = _zoomLevel;
                            setState(() {});
                          }
                        },
                      ),
                      Text("${(_zoomLevel * 100).toInt()}%"),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          if (_zoomLevel < 3.0) {
                            _zoomLevel += 0.1;
                            _pdfViewerController?.zoomLevel = _zoomLevel;
                            setState(() {});
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.search),
                        tooltip: 'Search',
                        onPressed: () {
                          showToolbar = true;
                          _ensureHistoryEntry();
                          if (mounted) setState(() {});
                        },
                      ),
                    ],
                  ),

                  // PDF Viewer
                  Expanded(
                    child: GestureDetector(
                      onTap: _toggleUI,
                      child: Container(
                        padding: _isFullscreen ? EdgeInsets.zero : const EdgeInsets.all(20),
                        child: Stack(
                          children: [
                            Positioned.fill(
                            child: _isPdfPrecheckLoading
                                ? const Center(child: CircularProgressIndicator())
                                : effectivePdfUrl.isEmpty
                                    ? const Center(
                                        child: Text(
                                            "No PDF URL (empty). Re-upload the file or fix API image_url."))
                                    : _networkPdfError != null
                                        ? Center(
                                            child: Padding(
                                              padding: const EdgeInsets.all(24),
                                              child: Text(
                                                _networkPdfError!,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          )
                                        : SfPdfViewer.network(
                                            effectivePdfUrl,
                                            controller: _pdfViewerController,
                                            key: _pdfViewerKey,
                                            pageLayoutMode:
                                                PdfPageLayoutMode.single,
                                            scrollDirection: _isHorizontalSwipe
                                                ? PdfScrollDirection.horizontal
                                                : PdfScrollDirection.vertical,
                                            canShowScrollHead: !_isFullscreen,
                                            canShowScrollStatus: !_isFullscreen,
                                            enableDoubleTapZooming: true,
                                            enableTextSelection: true,
                                            initialZoomLevel: _zoomLevel,
                                            maxZoomLevel: 3.0,
                                            onDocumentLoadFailed: (details) {
                                              try {
                                                webReadBookLog(
                                                  'PDF_VIEWER_LOAD_FAILED',
                                                  'description=${details.description} error=${details.error}',
                                                );
                                              } catch (e, st) {
                                                printLog(
                                                    'PDF_VIEWER_LOAD_FAILED log error: $e\n$st');
                                              }
                                              if (!mounted) return;
                                              setState(() {
                                                _networkPdfError =
                                                    'Could not open PDF. Often the file URL returns HTML (404) or APP_URL is wrong.\n'
                                                    'Server should expose files at .../storage/novels/... (run: php artisan storage:link).\n'
                                                    '${details.description}';
                                              });
                                            },
                                            onTextSelectionChanged: (details) {
                                              if (details.selectedText == null) {
                                                _checkAndCloseContextMenu();
                                              } else {
                                                _showContextMenu(
                                                    context, details);
                                              }
                                            },
                                            onDocumentLoaded: (details) {
                                              // Web / wasm: avoid throwing inside callbacks (shows as minified main.dart.js errors).
                                              try {
                                                final doc = details.document;
                                                int pageCount = -1;
                                                int bookmarkCount = -1;
                                                try {
                                                  pageCount = doc.pages.count;
                                                } catch (_) {}
                                                try {
                                                  bookmarkCount =
                                                      doc.bookmarks.count;
                                                } catch (_) {}
                                                webReadBookLog(
                                                  'PDF_VIEWER_LOAD_OK',
                                                  'pageCount=$pageCount bookmarks=$bookmarkCount',
                                                );
                                                if (bookmarkCount > 0) {
                                                  try {
                                                    pdfBookmark =
                                                        doc.bookmarks[0];
                                                  } catch (e) {
                                                    printLog(
                                                        'PDF bookmark[0] skip: $e');
                                                  }
                                                }
                                              } catch (e, st) {
                                                printLog(
                                                    'PDF_VIEWER onDocumentLoaded error: $e\n$st');
                                                webReadBookLog(
                                                  'PDF_VIEWER_LOAD_OK',
                                                  'loaded (metadata skipped: $e)',
                                                );
                                              }
                                            },
                                            onPageChanged: (details) {
                                              _lastPage = details
                                                  .newPageNumber; // ===== ADD HISTORY LOGIC =====

                                              printLog(
                                                  "📄 PAGE CHANGED ===================>>>> Current Page: <<<<=================== $_lastPage");
                                            },
                                          ),
                          ),
                          if (!_isFullscreen)
                            Positioned(
                              top: 8,
                              right: 8,
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
                                          _isHorizontalSwipe =
                                              !_isHorizontalSwipe;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 6),
                                  Card(
                                    child: IconButton(
                                      tooltip: _isFullscreen
                                          ? "Exit fullscreen"
                                          : "Fullscreen",
                                      icon: Icon(_isFullscreen
                                          ? Icons.fullscreen_exit
                                          : Icons.fullscreen),
                                      onPressed: () {
                                        final next = !_isFullscreen;
                                        setState(() => _isFullscreen = next);
                                        setWebFullscreen(next);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                        ),
                      ),
                    ),
                  ),

                  // Page Navigation + Bookmark
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
                                icon: const Icon(Icons.keyboard_double_arrow_up),
                                tooltip: 'First Page',
                                onPressed: () {
                                  _pdfViewerController?.firstPage();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.keyboard_arrow_up),
                                tooltip: 'Previous Page',
                                onPressed: () {
                                  _pdfViewerController?.previousPage();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.keyboard_arrow_down),
                                tooltip: 'Next Page',
                                onPressed: () {
                                  _pdfViewerController?.nextPage();
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.keyboard_double_arrow_down),
                                tooltip: 'Last Page',
                                onPressed: () {
                                  _pdfViewerController?.lastPage();
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.bookmark),
                                tooltip: 'Bookmarks',
                                onPressed: () {
                                  _pdfViewerKey.currentState?.openBookmarkView();
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                  if (provider.loadMore)
                    Utils.pageLoader(context)
                  else
                    const SizedBox.shrink(),
                ],
              ),
            ),
          ),
        );
        },
      ),
    );
  }
}
