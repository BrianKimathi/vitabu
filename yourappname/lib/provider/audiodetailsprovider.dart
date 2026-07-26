import 'package:yourappname/model/audiobookmodel.dart';
import 'package:yourappname/model/audiodetailmodel.dart';
import 'package:yourappname/model/episodemodel.dart' as episode;
import 'package:yourappname/model/reviewmodel.dart' as comment;
import 'package:yourappname/model/audiobookmodel.dart' as audio;
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webservice/apiservice.dart';
import 'package:flutter/material.dart';

class AudioDetailsProvider extends ChangeNotifier {
  AudioDetailModel audioDetailModel = AudioDetailModel();
  SuccessModel successModel = SuccessModel();
  AudioBookModel bookModel = AudioBookModel();
  episode.EpisodeModel chapterModel = episode.EpisodeModel();
  comment.ReviewModel reviewModel = comment.ReviewModel();

  List<episode.Result>? chaptersList = [];
  List<audio.Result>? audioList = [];

  bool loading = false;
  bool bookChapterLoading = false;
  bool releteditemsloading = false;

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

  setLoading(isLoading) {
    loading = isLoading;
    bookChapterLoading = isLoading;
    commentloading = isLoading;
    releteditemsloading = isLoading;
    notifyListeners();
  }

  Future<void> getBookDetails(contentType, contentId) async {
    loading = true;
    audioDetailModel =
        await ApiService().contentDetailsResponse(contentType, contentId);
    loading = false;
    notifyListeners();
  }

  Set<String> locallyUnlockedEpisodes = {};

  void markEpisodeUnlocked(String episodeId) {
    locallyUnlockedEpisodes.add(episodeId);
    notifyListeners();
  }

  bool isEpisodeUnlocked(String episodeId, bool isPaid, bool isBuy) {
    // If free, already bought, or locally unlocked
    return !isPaid || isBuy || locallyUnlockedEpisodes.contains(episodeId);
  }

/* Bookmark api Stared */
  Future<void> getBookMark(contentType, contentId) async {
    if ((audioDetailModel.result?.isBookmark ?? 0) == 1) {
      audioDetailModel.result?.isBookmark = 0;
    } else {
      audioDetailModel.result?.isBookmark = 1;
    }

    notifyListeners();
    successModel = await ApiService().bookmarkResponse(contentType, contentId);
  }

  /* Bookmark api END */
  /* Releted Data */
  Future<void> getRelatedItems(type, categoryId, contentId, pageno) async {
    releteditemsloading = true;
    bookModel =
        await ApiService().reletedResponse(type, categoryId, contentId, pageno);
    if (bookModel.status == 200) {
      setPagination(bookModel.totalRows, bookModel.totalPage,
          bookModel.currentPage, bookModel.morePage);
      if (bookModel.result != null && (bookModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (bookModel.result?.length ?? 0); i++) {
          audioList?.add(bookModel.result?[i] ?? audio.Result());
        }
        final Map<int, audio.Result> postMap = {};
        audioList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        audioList = postMap.values.toList();
        setLoadMore(false);
        printLog("bookModel length :=2=> ${(bookModel.result?.length ?? 0)}");
      }
      printLog("getSectionDetails status :===> ${bookModel.status}");
      printLog("getSectionDetails message :==> ${bookModel.message}");
    }
    releteditemsloading = false;
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

  /*  Pagination end */
/* Add Review Started */
  bool addcommentloading = false, addreplaycommentloading = false;
  int? totalRowsComment, totalPageComment, currentPageComment;
  bool? morePageComment;
  bool commentloadmore = false, commentloading = false;
  List<comment.Result>? commentList = [];

  Future<void> getAddComment(contentType, contentId, review, rating) async {
    setSendingComment(true);
    successModel = await ApiService()
        .addReviewResponse(contentType, contentId, review, rating);
    // Backend pagination for reviews is 1-indexed (page_no=1 is first page).
    await getComment(contentType, contentId, 1);
    audioDetailModel.result?.totalReviews = commentList?.length ?? 0;
    setSendingComment(false);
  }

  setSendingComment(isSending) {
    debugPrint("isSending ==> $isSending");
    addcommentloading = isSending;
    notifyListeners();
  }

  /* get Comment */
  Future<void> getComment(contentType, contentId, pageNo) async {
    if (pageNo == 1) {
      clearCommentData();
    }
    commentloading = true;
    reviewModel =
        await ApiService().reviewResponse(contentType, contentId, pageNo);
    if (reviewModel.status == 200) {
      setCommentPaginationData(reviewModel.totalRows, reviewModel.totalPage,
          reviewModel.currentPage, reviewModel.morePage);
      if (reviewModel.result != null && (reviewModel.result?.length ?? 0) > 0) {
        debugPrint(
            "postModel length :==> ${(reviewModel.result?.length ?? 0)}");

        for (var i = 0; i < (reviewModel.result?.length ?? 0); i++) {
          commentList?.add(reviewModel.result?[i] ?? comment.Result());
        }
        final Map<int, comment.Result> postMap = {};
        commentList?.forEach((item) {
          postMap[item.id ?? 0] = item;
        });
        commentList = postMap.values.toList();
        debugPrint("shortVideoList length :==> ${(commentList?.length ?? 0)}");
        setCommentLoadMore(false);
      }
    }
    commentloading = false;
    notifyListeners();
  }

  setCommentPaginationData(int? totalRowsComment, int? totalPageComment,
      int? currentPageComment, bool? morePageComment) {
    this.currentPageComment = currentPageComment;
    this.totalRowsComment = totalRowsComment;
    this.totalPageComment = totalPageComment;
    morePageComment = morePageComment;
    notifyListeners();
  }

  setCommentLoadMore(commentloadmore) {
    this.commentloadmore = commentloadmore;
    notifyListeners();
  }

/* Delete Comment */
  int deleteItemIndex = 0;
  bool deletecommentLoading = false;
  Future<void> getDeleteComment(index, reviewId) async {
    deleteItemIndex = index;
    setDeleteCommentLoding(true);
    successModel = await ApiService().deleteReviewResponse(reviewId);
    commentList?.removeAt(index);
    audioDetailModel.result?.totalReviews = commentList?.length ?? 0;
    setDeleteCommentLoding(false);
  }

  /* Web tabs */
  String? tabDetails = "1";

  setDetailsTab(value) {
    tabDetails = value;
    notifyListeners();
  }

  setDeleteCommentLoding(isSending) {
    debugPrint("isSending ==> $isSending");
    deletecommentLoading = isSending;
    notifyListeners();
  }

  clearCommentData() {
    commentList = [];
    commentList?.clear();
    totalRowsComment = 0;
    totalPageComment = 0;
    currentPageComment = 0;
    morePageComment = false;
    notifyListeners();
  }

/* Music Related Code */
  bool isPlaying = false;
  bool isFirstClickDone = false;
  bool isCompleted = false;

  setCompleteMusic({isCom, isPla}) {
    isCompleted = isCom;
    isPlaying = isPla;
    notifyListeners();
  }

  setFirstMusicPlay({isFirst, isPla}) {
    isFirstClickDone = isFirst;
    isPlaying = isPla;
    notifyListeners();
  }

  setPlayMusic({isPla}) {
    isPlaying = isPla;
    notifyListeners();
  } /* Music Episode Related Code */

  bool isEpisodePlaying = false;
  bool isEpisodeFirstClickDone = false;
  bool isEpisodeCompleted = false;

  setEpisodeCompleteMusic({isCom, isPla}) {
    isEpisodeCompleted = isCom;
    isEpisodePlaying = isPla;
    notifyListeners();
  }

  setEpisodeFirstMusicPlay({isFirst, isPla}) {
    isEpisodeFirstClickDone = isFirst;
    isEpisodePlaying = isPla;
    notifyListeners();
  }

  setEpisodePlayMusic({isPla}) {
    isEpisodePlaying = isPla;
    notifyListeners();
  }

  clearProvider() {
    printLog("-----??clearProvider BookDetailsProvider-----??");
    successModel = SuccessModel();
    bookModel = AudioBookModel();
    chapterModel = episode.EpisodeModel();
    reviewModel = comment.ReviewModel();
    chaptersList = [];
    chaptersList?.clear();
    loading = false;
    bookChapterLoading = false;
    releteditemsloading = false;
    audioDetailModel = AudioDetailModel();
    /*  Pagination start */
    totalRows;
    totalPage;
    currentPage;
    isMorePage;
    loadMore = false;
    deleteItemIndex = 0;
    tabDetails = "1";
    commentList = [];
    audioList = [];
    audioList?.clear();
    commentList?.clear();
    commentloading = false;
    commentloadmore = false;
    totalRowsComment = 0;
    totalPageComment = 0;
    currentPageComment = 0;
    morePageComment = false;
    deletecommentLoading = false;
    isPlaying = false;
    isFirstClickDone = false;
    isCompleted = false;
    isEpisodePlaying = false;
    isEpisodeFirstClickDone = false;
    isEpisodeCompleted = false;
  }
}
