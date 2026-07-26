import 'package:yourappname/utils/color.dart';
import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

/// Signature for the [SearchToolbar.onTap] callback.
typedef SearchTapCallback = void Function(Object item);

/// SearchToolbar widget
class SearchToolbar extends StatefulWidget {
  ///it describe the search toolbar constructor
  const SearchToolbar({
    this.controller,
    this.onTap,
    this.showTooltip = true,
    super.key,
  });

  /// Indicates whether the tooltip for the search toolbar items need to be shown or not.
  final bool showTooltip;

  /// An object that is used to control the [SfPdfViewer].
  final PdfViewerController? controller;

  /// Called when the search toolbar item is selected.
  final SearchTapCallback? onTap;

  @override
  SearchToolbarState createState() => SearchToolbarState();
}

/// State for the SearchToolbar widget
class SearchToolbarState extends State<SearchToolbar> {
  /// Indicates whether search is initiated or not.
  bool _isSearchInitiated = false;

  /// Indicates whether search toast need to be shown or not.
  bool showToast = false;

  ///An object that is used to retrieve the current value of the TextField.
  final TextEditingController _editingController = TextEditingController();

  /// An object that is used to retrieve the text search result.
  PdfTextSearchResult _pdfTextSearchResult = PdfTextSearchResult();

  ///An object that is used to obtain keyboard focus and to handle keyboard events.
  FocusNode? focusNode;

  @override
  void initState() {
    super.initState();
    focusNode = FocusNode();
    focusNode?.requestFocus();
  }

  @override
  void dispose() {
    // Clean up the focus node when the Form is disposed.
    focusNode?.dispose();
    _pdfTextSearchResult.removeListener(() {});
    super.dispose();
  }

  ///Clear the text search result
  void clearSearch() {
    _isSearchInitiated = false;
    _pdfTextSearchResult.clear();
  }

  ///Display the Alert dialog to search from the beginning
  void _showSearchAlertDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          insetPadding: const EdgeInsets.all(0),
          title: const Text('Search Result'),
          content: const SizedBox(
              width: 328.0,
              child: Text(
                  'No more occurrences found. Would you like to continue to search from the beginning?')),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                setState(() {
                  _pdfTextSearchResult.nextInstance();
                });
                Navigator.of(context).pop();
              },
              child: Text(
                'YES',
                style: TextStyle(
                    color: black.withOpacity( 0.87),
                    fontFamily: 'Roboto',
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none),
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _pdfTextSearchResult.clear();
                  _editingController.clear();
                  _isSearchInitiated = false;
                  focusNode?.requestFocus();
                });
                Navigator.of(context).pop();
              },
              child: Text(
                'NO',
                style: TextStyle(
                    color: black.withOpacity( 0.87),
                    fontFamily: 'Roboto',
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w500,
                    decoration: TextDecoration.none),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Row(
        children: <Widget>[
          Material(
            color: const Color.fromRGBO(0, 0, 0, 0),
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back,
                color: black,
                size: 24,
              ),
              onPressed: () {
                widget.onTap?.call('Cancel Search');
                _isSearchInitiated = false;
                _editingController.clear();
                _pdfTextSearchResult.clear();
              },
            ),
          ),
          Flexible(
            child: TextFormField(
              style: GoogleFonts.roboto(
                  fontSize: 18, color: black, fontWeight: FontWeight.w400),
              enableInteractiveSelection: false,
              focusNode: focusNode,
              keyboardType: TextInputType.text,
              textInputAction: TextInputAction.search,
              cursorColor: black,
              controller: _editingController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Find...',
                hintStyle: GoogleFonts.roboto(
                    fontSize: 18, color: black, fontWeight: FontWeight.w400),
              ),
              onChanged: (text) {
                if (_editingController.text.isNotEmpty) {
                  setState(() {});
                }
              },
              onFieldSubmitted: (String value) {
                if (kIsWeb) {
                  _pdfTextSearchResult =
                      widget.controller!.searchText(_editingController.text);
                  if (_pdfTextSearchResult.totalInstanceCount == 0) {
                    widget.onTap?.call('noResultFound');
                  }
                  setState(() {});
                } else {
                  _isSearchInitiated = true;
                  _pdfTextSearchResult =
                      widget.controller!.searchText(_editingController.text);
                  _pdfTextSearchResult.addListener(() {
                    if (super.mounted) {
                      setState(() {});
                    }
                    if (!_pdfTextSearchResult.hasResult &&
                        _pdfTextSearchResult.isSearchCompleted) {
                      widget.onTap?.call('noResultFound');
                    }
                  });
                }
              },
            ),
          ),
          Visibility(
            visible: _editingController.text.isNotEmpty,
            child: Material(
              color: transparent,
              child: IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: black,
                  size: 24,
                ),
                onPressed: () {
                  setState(() {
                    _editingController.clear();
                    _pdfTextSearchResult.clear();
                    widget.controller!.clearSelection();
                    _isSearchInitiated = false;
                    focusNode!.requestFocus();
                  });
                  widget.onTap!.call('Clear Text');
                },
                tooltip: widget.showTooltip ? 'Clear Text' : null,
              ),
            ),
          ),
          Visibility(
            visible:
                !_pdfTextSearchResult.isSearchCompleted && _isSearchInitiated,
            child: const Padding(
              padding: EdgeInsets.only(right: 10),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: black,
                ),
              ),
            ),
          ),
          Visibility(
            visible: _pdfTextSearchResult.hasResult,
            child: Row(
              children: [
                MyText(
                  color: black,
                  text: '${_pdfTextSearchResult.currentInstanceIndex}',
                  fontsize: Dimens.medium16TextSize,
                  fontwaight: FontWeight.w600,
                ),
                const MyText(
                  color: black,
                  text: 'of',
                  multilanguage: true,
                  fontsize: Dimens.medium16TextSize,
                  fontwaight: FontWeight.w600,
                ),
                MyText(
                  color: black,
                  text: '${_pdfTextSearchResult.totalInstanceCount}',
                  fontsize: Dimens.medium16TextSize,
                  fontwaight: FontWeight.w600,
                ),
                Material(
                  color: transparent,
                  child: IconButton(
                    icon: const Icon(
                      Icons.navigate_before,
                      color: black,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        _pdfTextSearchResult.previousInstance();
                      });
                      widget.onTap!.call('Previous Instance');
                    },
                    tooltip: widget.showTooltip ? 'Previous' : null,
                  ),
                ),
                Material(
                  color: transparent,
                  child: IconButton(
                    icon: const Icon(
                      Icons.navigate_next,
                      color: black,
                      size: 24,
                    ),
                    onPressed: () {
                      setState(() {
                        if (_pdfTextSearchResult.currentInstanceIndex ==
                                _pdfTextSearchResult.totalInstanceCount &&
                            _pdfTextSearchResult.currentInstanceIndex != 0 &&
                            _pdfTextSearchResult.totalInstanceCount != 0 &&
                            _pdfTextSearchResult.isSearchCompleted) {
                          _showSearchAlertDialog(context);
                        } else {
                          widget.controller!.clearSelection();
                          _pdfTextSearchResult.nextInstance();
                        }
                      });
                      widget.onTap!.call('Next Instance');
                    },
                    tooltip: widget.showTooltip ? 'Next' : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
