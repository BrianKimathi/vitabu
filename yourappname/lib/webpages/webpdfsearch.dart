import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// Signature for the [SearchToolbar.onTap] callback.
typedef SearchTapCallback = void Function(Object item);

/// Web-optimized SearchToolbar widget
class WebSearchToolbar extends StatefulWidget {
  const WebSearchToolbar({
    this.controller,
    this.onTap,
    this.showTooltip = true,
    super.key,
  });

  final PdfViewerController? controller;
  final SearchTapCallback? onTap;
  final bool showTooltip;

  @override
  State<WebSearchToolbar> createState() => WebSearchToolbarState();
}

class WebSearchToolbarState extends State<WebSearchToolbar> {
  final TextEditingController _editingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  late PdfTextSearchResult _searchResult;
  int currentIndex = 0;
  bool showToast = false;

  @override
  void initState() {
    super.initState();
    _focusNode.requestFocus();
    _searchResult = PdfTextSearchResult();
  }

  @override
  void dispose() {
    _editingController.dispose();
    _focusNode.dispose();
    _searchResult.clear();
    super.dispose();
  }

  void clearSearch() {
    _editingController.clear();
    _searchResult.clear();
    currentIndex = 0;
    widget.controller?.clearSelection();
    widget.onTap?.call('Clear Text');
    setState(() {});
    _focusNode.requestFocus();
  }

  void _searchText(String value) {
    if (value.isEmpty) return;
    _searchResult = widget.controller!.searchText(value);
    currentIndex = _searchResult.hasResult ? 1 : 0;

    if (_searchResult.totalInstanceCount == 0) {
      widget.onTap?.call('noResultFound');
    }
    setState(() {});
  }

  void _nextInstance() {
    if (currentIndex < _searchResult.totalInstanceCount) {
      _searchResult.nextInstance();
      currentIndex++;
    } else if (currentIndex == _searchResult.totalInstanceCount &&
        currentIndex != 0) {
      _showSearchAlertDialog();
    }
    setState(() {});
    widget.onTap?.call('Next Instance');
  }

  void _previousInstance() {
    if (currentIndex > 1) {
      _searchResult.previousInstance();
      currentIndex--;
    }
    setState(() {});
    widget.onTap?.call('Previous Instance');
  }

  void _showSearchAlertDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Search Result'),
        content: const SizedBox(
          width: 328.0,
          child: Text(
              'No more occurrences found. Would you like to continue to search from the beginning?'),
        ),
        actions: [
          TextButton(
            onPressed: () {
              _searchResult.nextInstance();
              currentIndex = 1;
              Navigator.of(context).pop();
              setState(() {});
            },
            child: const Text('YES'),
          ),
          TextButton(
            onPressed: () {
              clearSearch();
              Navigator.of(context).pop();
            },
            child: const Text('NO'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Back button
        IconButton(
          icon: const Icon(Icons.arrow_back, color: black),
          onPressed: () {
            clearSearch();
            widget.onTap?.call('Cancel Search');
          },
        ),

        // Search TextField
        Expanded(
          child: TextFormField(
            controller: _editingController,
            focusNode: _focusNode,
            style: GoogleFonts.roboto(fontSize: 18, color: black),
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Find...',
              hintStyle: GoogleFonts.roboto(
                  fontSize: 18, color: black, fontWeight: FontWeight.w400),
            ),
            textInputAction: TextInputAction.search,
            onFieldSubmitted: _searchText,
          ),
        ),

        // Clear text button
        if (_editingController.text.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear, color: black),
            tooltip: widget.showTooltip ? 'Clear Text' : null,
            onPressed: clearSearch,
          ),

        // Search navigation & count
        if (_searchResult.hasResult)
          Row(
            children: [
              MyText(
                text: '$currentIndex',
                color: black,
                fontsize: Dimens.medium16TextSize,
                fontwaight: FontWeight.w600,
              ),
              const MyText(
                text: 'of',
                color: black,
                fontsize: Dimens.medium16TextSize,
                fontwaight: FontWeight.w600,
              ),
              MyText(
                text: '${_searchResult.totalInstanceCount}',
                color: black,
                fontsize: Dimens.medium16TextSize,
                fontwaight: FontWeight.w600,
              ),
              IconButton(
                icon: const Icon(Icons.navigate_before, color: black),
                tooltip: widget.showTooltip ? 'Previous' : null,
                onPressed: _previousInstance,
              ),
              IconButton(
                icon: const Icon(Icons.navigate_next, color: black),
                tooltip: widget.showTooltip ? 'Next' : null,
                onPressed: _nextInstance,
              ),
            ],
          ),
      ],
    );
  }
}
