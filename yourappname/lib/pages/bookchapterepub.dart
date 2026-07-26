import 'package:dio/dio.dart';
import 'package:yourappname/provider/generalprovider.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
// import 'package:vocsy_epub_viewer/epub_viewer.dart';

class BookChapterEpub extends StatefulWidget {
  final String? ePubTitle, ePubUrl;
  final String? chapterID;
  const BookChapterEpub(
      {super.key,
      required this.ePubTitle,
      this.chapterID,
      required this.ePubUrl});

  @override
  State<BookChapterEpub> createState() => _BookChapterEpubState();
}

class _BookChapterEpubState extends State<BookChapterEpub> {
  late GeneralProvider generalProvider;
  bool loading = false;
  Dio dio = Dio();
  String filePath = "";

  Future<void> openEpub() async {
    final url = widget.ePubUrl ?? "";
    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/temp.epub';

    setState(() {
      loading = true;
    });

    await dio.download(url, filePath, deleteOnError: true);

    setState(() {
      loading = false;
    });
    if (!mounted) return;

    //   VocsyEpub.setConfig(
    //     themeColor: Theme.of(context).primaryColor,
    //     identifier: "iosBook",
    //     scrollDirection: EpubScrollDirection.ALLDIRECTIONS,
    //     allowSharing: true,
    //     enableTts: true,
    //     nightMode: true,
    //   );

    //   // get current locator
    //   VocsyEpub.locatorStream.listen((locator) {
    //     printLog('LOCATOR: $locator');
    //   });
    //   if (!mounted) return;
    //   Navigator.pop(context);
    //   VocsyEpub.open(
    //     filePath,
    //     lastLocation: EpubLocator.fromJson({
    //       "bookId": "2239",
    //       "href": "/OEBPS/ch06.xhtml",
    //       "created": 1539934158390,
    //       "locations": {"cfi": "epubcfi(/0!/4/4[simple_book]/2/2/6)"}
    //     }),
    //   );
    // }
  }

  @override
  void initState() {
    generalProvider = Provider.of<GeneralProvider>(context, listen: false);
    _future = openEpub();
    super.initState();
  }

  late Future<void> _future;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: FutureBuilder(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return Text(
                  'E-pub opened'); // Display a message when the EPUB is opened
            } else {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  CircularProgressIndicator(),
                  Text('Opening E-pub...'),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}
