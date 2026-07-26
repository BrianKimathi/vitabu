import 'package:yourappname/model/addhistorymodel.dart';
import 'package:flutter/material.dart';
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webservice/apiservice.dart';
import 'package:yourappname/model/episodemodel.dart' as episode;

class AudioPlayProvider extends ChangeNotifier {
  episode.EpisodeModel chapterModel = episode.EpisodeModel();
  SuccessModel successModel = SuccessModel();
  List<episode.Result>? chaptersList = [];
  bool bookChapterLoading = false;
/* New Book Details page Api */

  Future<void> setView(contentType, contentId, subContentId) async {
    debugPrint("addPostView postId :==> $contentId");
    // loaded = true;
    successModel = await ApiService()
        .contentViewResponse(contentType, contentId, subContentId);
    debugPrint("addPostView status :==> ${successModel.status}");
    debugPrint("addPostView message :==> ${successModel.message}");
    // loaded = false;
  }

  setLoding(isLoding) {
    bookChapterLoading = isLoding;
    notifyListeners();
  }

  Future<void> getChapterbyBook(audioBookId, pageno) async {
    bookChapterLoading = true;
    chapterModel =
        await ApiService().audioBookEpisodeResponse(audioBookId, pageno);
    if (chapterModel.status == 200) {
      setPagination(chapterModel.totalRows, chapterModel.totalPage,
          chapterModel.currentPage, chapterModel.morePage);
      if (chapterModel.result != null &&
          (chapterModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (chapterModel.result?.length ?? 0); i++) {
          chaptersList?.add(chapterModel.result?[i] ?? episode.Result());
        }
        final Map<int, episode.Result> chapterMap = {};
        chaptersList?.forEach((item) {
          chapterMap[item.id ?? 0] = item;
        });
        chaptersList = chapterMap.values.toList();
        setLoadMore(false);
      }
    }
    bookChapterLoading = false;
    notifyListeners();
  }

  setLoadMore(loadMore) {
    printLog("setLoadMore loadMore :=> $loadMore");
    this.loadMore = loadMore;
    notifyListeners();
  }

/* =========================== ADD History ======================== */

  Addhistorymodel addhistorymodel = Addhistorymodel();
  bool historyloading = false;
  Future<void> addhistorydata(authorid, contenttype, contentid, subcontentid,
      timespend, isSubscription, lastposition) async {
    historyloading = true;
    addhistorymodel = await ApiService().addhistoryapi(authorid, contenttype,
        contentid, subcontentid, timespend, isSubscription, lastposition);
    historyloading = false;
    notifyListeners();
  }

  /*  Pagination start */
  int? totalRows, totalPage, currentPage;
  bool? isMorePage;
  bool loadMore = false;
  setPagination(
      int? totalRows, int? totalPage, int? currentPage, bool? isMorePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    this.isMorePage = isMorePage;
    notifyListeners();
  }

  notifyListener() {
    notifyListeners();
  }

  clearProvider() {
    printLog("-----??clearProvider BookDetailsProvider-----??");
    successModel = SuccessModel();
    chapterModel = episode.EpisodeModel();
    chaptersList = [];
    chaptersList?.clear();
    bookChapterLoading = false;

    /*  Pagination start */
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
    loadMore = false;
  }
}
