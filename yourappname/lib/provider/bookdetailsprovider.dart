import 'package:yourappname/model/addhistorymodel.dart';
import 'package:yourappname/model/bookdetailmodel.dart';
import 'package:yourappname/model/bookmodel.dart';
import 'package:yourappname/model/chaptermodel.dart' as chapter;
import 'package:yourappname/model/reviewmodel.dart' as comment;
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webservice/apiservice.dart';
import 'package:flutter/material.dart';

class BookDetailsProvider extends ChangeNotifier {
  BookDetailModel bookDetailModel = BookDetailModel();
  SuccessModel successModel = SuccessModel();
  BookModel bookModel = BookModel();
  chapter.ChapterModel chapterModel = chapter.ChapterModel();
  comment.ReviewModel reviewModel = comment.ReviewModel();

  List<chapter.Result>? chaptersList = [];

  bool loading = false;
  bool bookChapterLoading = false;
  bool releteditemsloading = false;

/* New Book Details page Api */

  setLoading(isLoading) {
    loading = isLoading;
    bookChapterLoading = isLoading;
    commentloading = isLoading;
    releteditemsloading = isLoading;
    notifyListeners();
  }

  setbookloading(loading) {
    bookChapterLoading = loading;
  }

  Future<void> getBookDetails(contentType, contentId) async {
    webReadBookLog('API_book_detail_START',
        'contentType=$contentType contentId=$contentId');
    loading = true;
    bookDetailModel =
        await ApiService().contentDetailsResponse(contentType, contentId);
    loading = false;
    printLog("ISpaid check ====>> ${bookDetailModel.result?.accessType == 1} ");
    printLog("isbuy check ====>> ${bookDetailModel.result?.isBuy} ");
    printLog("API response after purchase: ${bookDetailModel.toJson()}");

    final r = bookDetailModel.result;
    webReadBookLog('API_book_detail_DONE',
        'httpStatus=${bookDetailModel.status} message=${bookDetailModel.message} bookId=${r?.id} accessType=${r?.accessType} isBuy=${r?.isBuy} isSub=${r?.isSubscription} fullNovel=${webReadBookFormatPdfUrl(r?.fullNovel)}');

    notifyListeners();
  }

/* Bookmark api Stared */
  Future<void> getBookMark(contentType, contentId) async {
    if ((bookDetailModel.result?.isBookmark ?? 0) == 1) {
      bookDetailModel.result?.isBookmark = 0;
    } else {
      bookDetailModel.result?.isBookmark = 1;
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
    releteditemsloading = false;
    notifyListeners();
  }

  Future<void> getChapterbyBook(novelId, pageno) async {
    if (pageno == 1) {
      bookChapterLoading = true;
    }

    chapterModel = await ApiService().bookChapterResponse(novelId, pageno);

    if (chapterModel.status == 200) {
      setPagination(chapterModel.totalRows, chapterModel.totalPage, pageno,
          chapterModel.morePage);

      if (chapterModel.result != null &&
          (chapterModel.result?.length ?? 0) > 0) {
        if (pageno == 1) {
          chaptersList = chapterModel.result;
        } else {
          chaptersList?.addAll(chapterModel.result!);
        }

        final Map<int, chapter.Result> chapterMap = {};
        chaptersList?.forEach((item) {
          chapterMap[item.id ?? 0] = item;
        });
        chaptersList = chapterMap.values.toList();

        setLoadMore(false);
      } else {
        if (pageno == 1) chaptersList?.clear();
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
// Add Comment & Add Replay Comment
  bool addcommentloading = false, addreplaycommentloading = false;
  // Comment List Field Pagination
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
    // Update the total comment count for the corresponding feed item
    bookDetailModel.result?.totalReviews = commentList?.length ?? 0;
    setSendingComment(false);
  }

  setSendingComment(bool isSending) {
    debugPrint("isSending ==> $isSending");
    addcommentloading = isSending;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });
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
        if (pageNo == 0) {
          commentList = reviewModel.result; // fresh list
        } else {
          commentList?.addAll(reviewModel.result ?? []);
        }

        // Duplicate avoid karva (optional)
        final Map<int, comment.Result> postMap = {};
        for (var item in commentList!) {
          postMap[item.id ?? 0] = item;
        }
        commentList = postMap.values.toList();

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
    bookDetailModel.result?.totalReviews = commentList?.length ?? 0;
    setDeleteCommentLoding(false);
  }

  setDeleteCommentLoding(isSending) {
    debugPrint("isSending ==> $isSending");
    deletecommentLoading = isSending;
    notifyListeners();
  }

  String? tabDetails = "1";

  setDetailsTab(value) {
    tabDetails = value;
    notifyListeners();
  }

// BookDetailsProvider Class
// ... (existing code)

  clearChapterData() {
    // Only clear the list, do not reset loading flags
    chaptersList?.clear();
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

// ... (rest of the provider)

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

  clearProvider() {
    printLog("-----??clearProvider BookDetailsProvider-----??");
    bookDetailModel = BookDetailModel();
    successModel = SuccessModel();
    bookModel = BookModel();
    chapterModel = chapter.ChapterModel();
    reviewModel = comment.ReviewModel();
    chaptersList = [];
    chaptersList?.clear();
    loading = false;
    bookChapterLoading = false;
    releteditemsloading = false;
    tabDetails = "1";
    /*  Pagination start */
    totalRows;
    totalPage;
    currentPage;
    isMorePage = false;
    loadMore = false;
    deleteItemIndex = 0;

    commentList = [];
    commentList?.clear();
    commentloading = false;
    commentloadmore = false;
    totalRowsComment = 0;
    totalPageComment = 0;
    currentPageComment = 0;
    morePageComment = false;
    deletecommentLoading = false;
  }
}
