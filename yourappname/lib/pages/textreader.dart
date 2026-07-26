import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:yourappname/provider/bookdetailsprovider.dart';
import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/constant.dart';

class TextReader extends StatefulWidget {
  final String content;
  final String title;
  final String bookId;
  final String? chapterId;
  final String? authorId;
  final String? contentType;
  final int isSubscription;

  const TextReader({
    super.key,
    required this.content,
    required this.title,
    required this.bookId,
    this.chapterId,
    this.authorId,
    this.contentType,
    required this.isSubscription,
  });

  @override
  State<TextReader> createState() => _TextReaderState();
}

class _TextReaderState extends State<TextReader> {
  // Theme options
  static const List<Color> bgColors = [Colors.white, Color(0xFFF4ECD8), Color(0xFF121212)];
  static const List<Color> textColors = [Colors.black, Color(0xFF5B4636), Colors.white70];
  
  int _themeIndex = 0; // 0: White, 1: Sepia, 2: Dark
  double _fontSize = 18.0;
  
  late PageController _pageController;
  int _currentPage = 0;
  List<String> _pages = [];
  bool _isUIVisible = false;
  bool _isPaginating = true;

  // Auto-hide UI Timer
  Timer? _hideControlsTimer;

  // History tracking
  Timer? _delayTimer;
  Timer? _readTimer;
  int _timeSpend = 0;
  bool _apiStarted = false;
  late BookDetailsProvider bookDetailsProvider;

  @override
  void initState() {
    super.initState();
    _loadSettings();
    bookDetailsProvider = Provider.of<BookDetailsProvider>(context, listen: false);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // History tracking logic
    _delayTimer = Timer(const Duration(minutes: 1), () {
      _startHistory();
    });
  }

  void _startHistory() {
    if (_apiStarted) return;
    _apiStarted = true;
    _readTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _timeSpend++;
    });
  }

  void _callHistoryApi() {
    if (!_apiStarted) return;
    bookDetailsProvider.addhistorydata(
      widget.authorId,
      widget.contentType ?? "2",
      widget.bookId,
      widget.chapterId,
      _timeSpend,
      widget.isSubscription,
      _currentPage + 1,
    );
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _delayTimer?.cancel();
    _readTimer?.cancel();
    _callHistoryApi();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _themeIndex = prefs.getInt('reader_theme') ?? 0;
      _fontSize = prefs.getDouble('reader_font_size') ?? 18.0;
      _currentPage = prefs.getInt('progress_${widget.bookId}') ?? 0;
    });
    _pageController = PageController(initialPage: _currentPage);
  }

  Future<void> _saveProgress(int page) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('progress_${widget.bookId}', page);
  }

  Future<void> _saveTheme(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reader_theme', index);
  }

  Future<void> _saveFontSize(double size) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('reader_font_size', size);
  }

  /// Professional pagination logic using TextPainter
  void _paginate(BoxConstraints constraints) {
    final textStyle = GoogleFonts.merriweather(
      fontSize: _fontSize,
      height: 1.6,
    );

    final maxWidth = constraints.maxWidth - 40; // 20 horizontal padding on each side
    final maxHeight = constraints.maxHeight - 80; // Approximate vertical padding + UI space

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.justify,
    );

    List<String> pages = [];
    int start = 0;

    while (start < widget.content.length) {
      int end = start + 1000; // Start with a chunk
      if (end > widget.content.length) end = widget.content.length;

      // Binary search for the perfect cut-off point
      int low = start;
      int high = end;
      
      // If we are at the end, just add the rest
      if (high == widget.content.length) {
          textPainter.text = TextSpan(text: widget.content.substring(start), style: textStyle);
          textPainter.layout(maxWidth: maxWidth);
          if (textPainter.height <= maxHeight) {
              pages.add(widget.content.substring(start));
              break;
          }
      }

      // Find how much fits
      while (low <= high) {
        int mid = (low + high) ~/ 2;
        textPainter.text = TextSpan(text: widget.content.substring(start, mid), style: textStyle);
        textPainter.layout(maxWidth: maxWidth);

        if (textPainter.height <= maxHeight) {
          low = mid + 1;
        } else {
          high = mid - 1;
        }
      }

      int cutoff = high;
      // Try to cut at a space or newline for better experience
      if (cutoff < widget.content.length) {
          int lastSpace = widget.content.substring(start, cutoff).lastIndexOf(RegExp(r'\s'));
          if (lastSpace != -1 && lastSpace > (cutoff - start) * 0.8) {
              cutoff = start + lastSpace + 1;
          }
      }

      pages.add(widget.content.substring(start, cutoff));
      start = cutoff;
    }

    if (mounted) {
      setState(() {
        _pages = pages;
        _isPaginating = false;
        // Ensure current page is within bounds
        if (_currentPage >= _pages.length) {
          _currentPage = max(0, _pages.length - 1);
        }
      });
    }
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted && _isUIVisible) {
        setState(() => _isUIVisible = false);
      }
    });
  }

  void _toggleUI() {
    setState(() {
      _isUIVisible = !_isUIVisible;
      if (_isUIVisible) {
        _startHideControlsTimer();
      } else {
        _hideControlsTimer?.cancel();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColors[_themeIndex],
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (_isPaginating) {
            // Trigger pagination after layout is available
            WidgetsBinding.instance.addPostFrameCallback((_) => _paginate(constraints));
            return const Center(child: CircularProgressIndicator(color: colorAccent));
          }

          return GestureDetector(
            onTap: _toggleUI,
            child: Stack(
              children: [
                // Reading Area
                PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                    _saveProgress(index);
                  },
                  itemBuilder: (context, index) {
                    return Container(
                      padding: const EdgeInsets.fromLTRB(20, 60, 20, 60),
                      child: SelectableText(
                        _pages[index],
                        textAlign: TextAlign.justify,
                        style: GoogleFonts.merriweather(
                          fontSize: _fontSize,
                          height: 1.6,
                          color: textColors[_themeIndex],
                        ),
                      ),
                    );
                  },
                ),

                // Overlay UI - Top Bar
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  top: _isUIVisible ? 0 : -100,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    padding: const EdgeInsets.only(top: 40, left: 10, right: 10),
                    decoration: BoxDecoration(
                      color: bgColors[_themeIndex].withOpacity( 0.9),
                    ),
                    child: Row(
                      children: [
                        // Close Button (X)
                        IconButton(
                          icon: Icon(Icons.close, color: textColors[_themeIndex], size: 28),
                          onPressed: () => Navigator.pop(context),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            widget.title,
                            style: GoogleFonts.merriweather(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: textColors[_themeIndex],
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.settings, color: textColors[_themeIndex]),
                          onPressed: _showSettings,
                        ),
                      ],
                    ),
                  ),
                ),

                // Floating Close Button (visible when UI is hidden)
                if (!_isUIVisible)
                  Positioned(
                    top: 20,
                    left: 20,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context), // Directly close
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity( 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close, color: Colors.white70, size: 20),
                      ),
                    ),
                  ),

                // Overlay UI - Bottom Progress
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 250),
                  bottom: _isUIVisible ? 0 : -80,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: bgColors[_themeIndex].withOpacity( 0.95),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        LinearProgressIndicator(
                          value: _pages.isEmpty ? 0 : (_currentPage + 1) / _pages.length,
                          backgroundColor: textColors[_themeIndex].withOpacity( 0.1),
                          valueColor: const AlwaysStoppedAnimation<Color>(colorAccent),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Page ${_currentPage + 1} of ${_pages.length}",
                          style: TextStyle(
                            color: textColors[_themeIndex].withOpacity( 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: bgColors[_themeIndex],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Settings", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 24),
                const Text("Theme"),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: List.generate(bgColors.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() => _themeIndex = index);
                        _saveTheme(index);
                        setModalState(() {});
                      },
                      child: Container(
                        width: 60,
                        height: 40,
                        decoration: BoxDecoration(
                          color: bgColors[index],
                          border: Border.all(
                            color: _themeIndex == index ? colorAccent : Colors.grey,
                            width: 2,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: index == 1 ? const Center(child: Text("Sepia", style: TextStyle(fontSize: 10))) : null,
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                const Text("Font Size"),
                Slider(
                  value: _fontSize,
                  min: 12,
                  max: 30,
                  activeColor: colorAccent,
                  onChanged: (value) {
                    setState(() {
                      _fontSize = value;
                      _isPaginating = true; // Retrigger pagination
                    });
                    _saveFontSize(value);
                    setModalState(() {});
                  },
                ),
              ],
            ),
          );
        });
      },
    );
  }
}
