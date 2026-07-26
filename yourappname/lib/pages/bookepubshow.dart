import 'dart:typed_data';

import 'package:yourappname/utils/dimens.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/widget/mytext.dart';
import 'package:epub_view/epub_view.dart';
import 'package:flutter/material.dart';
import 'package:internet_file/internet_file.dart';

class BookEpubShow extends StatefulWidget {
  final String? ePubUrl;

  const BookEpubShow({super.key, required this.ePubUrl});

  @override
  State<BookEpubShow> createState() => _EpubReaderState();
}

class _EpubReaderState extends State<BookEpubShow> {
  EpubController? _epubController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadEupData();
    });
  }

  Future<void> _loadEupData() async {
    try {
      final Uint8List data = await InternetFile.get(widget.ePubUrl ?? "");
      final Future<EpubBook> document = EpubDocument.openData(data);
      _epubController = EpubController(document: document);
      setState(() {}); // Update the UI
    } catch (e) {
      printLog("Not loaded error ${e.toString()}");
    }
  }

  void _showCurrentEpubCfi(BuildContext context) {
    if (_epubController != null) {
      final String? cfi = _epubController?.generateEpubCfi();
      if (cfi != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(cfi),
            action: SnackBarAction(
              label: 'GO',
              onPressed: () {
                _epubController?.gotoEpubCfi(cfi);
              },
            ),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _epubController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _epubController != null
            ? EpubViewActualChapter(
                controller: _epubController!,
                builder: (chapterValue) => MyText(
                  text: chapterValue?.chapter?.Title.toString() ?? "",
                  textalign: TextAlign.start,
                  fontsize: Dimens.medium18TextSize,
                  fontwaight: FontWeight.w500,
                ),
                animationAlignment: Alignment.centerLeft,
              )
            : const Text(''),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.save_alt),
            onPressed: () => _showCurrentEpubCfi(context),
          ),
        ],
      ),
      body: _epubController != null
          ? EpubView(
              builders: EpubViewBuilders<DefaultBuilderOptions>(
                options: const DefaultBuilderOptions(),
                chapterDividerBuilder: (_) => const Divider(),
              ),
              controller: _epubController!,
            )
          : const Center(
              child:
                  CircularProgressIndicator(), // show a loading indicator while loading
            ),
      drawer: _epubController != null
          ? InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Drawer(
                elevation: 10,
                child: EpubViewTableOfContents(
                  controller: _epubController!,
                ),
              ),
            )
          : null, // or some other widget
    );
  }
}
