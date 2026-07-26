import 'package:yourappname/model/magazinedetailsmodel.dart';
import 'package:yourappname/model/magazinemodel.dart';
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/model/reviewmodel.dart' as comment;
import 'package:yourappname/webservice/apiservice.dart';
import 'package:flutter/material.dart';

class MagazineDetailsProvider extends ChangeNotifier {
  MagazineDetailModel magazineDetailModel = MagazineDetailModel();
  SuccessModel successModel = SuccessModel();
  MagazineModel bookModel = MagazineModel();
  comment.ReviewModel reviewModel = comment.ReviewModel();

  bool loading = false;
  bool releteditemsloading = false;

  setLoading(isLoading) {
    loading = isLoading;
    commentloading = isLoading;
    releteditemsloading = isLoading;
    notifyListeners();
  }

  Future<void> getMagazineDetails(contentType, contentId) async {
    loading = true;
    magazineDetailModel =
        await ApiService().contentDetailsResponse(contentType, contentId);
    loading = false;
    notifyListeners();
  }

/* Bookmark api Stared */
  Future<void> getBookMark(contentType, contentId) async {
    if ((magazineDetailModel.result?.isBookmark ?? 0) == 1) {
      magazineDetailModel.result?.isBookmark = 0;
    } else {
      magazineDetailModel.result?.isBookmark = 1;
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
    clearCommentData();
    await getComment(contentType, contentId, 1);
    // Update the total comment count for the corresponding feed item
    magazineDetailModel.result?.totalReviews = commentList?.length ?? 0;
    setSendingComment(false);
  }

  setSendingComment(isSending) {
    debugPrint("isSending ==> $isSending");
    addcommentloading = isSending;
    notifyListeners();
  }

  /* get Comment */
  Future<void> getComment(contentType, contentId, pageNo) async {
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
    magazineDetailModel.result?.totalReviews = commentList?.length ?? 0;
    setDeleteCommentLoding(false);
  }

  setDeleteCommentLoding(isSending) {
    debugPrint("isSending ==> $isSending");
    deletecommentLoading = isSending;
    notifyListeners();
  }

  clearMagazineContnt() {
    magazineDetailModel = MagazineDetailModel();
    loading = false;
  }

  clearCommentData() {
    commentList = [];
    commentList?.clear();
    reviewModel = comment.ReviewModel();
    commentloading = false;
    commentloadmore = false;
    totalRowsComment;
    totalPageComment;
    currentPageComment;
    morePageComment;
  }

  /* Web  */

  String? tabDetails = "1";

  setDetailsTab(value) {
    tabDetails = value;
    notifyListeners();
  }

  clearProvider() {
    printLog("-----??clearProvider MagazineDetailsProvider-----??");
    magazineDetailModel = MagazineDetailModel();
    successModel = SuccessModel();
    reviewModel = comment.ReviewModel();
    loading = false;
    releteditemsloading = false;

    deleteItemIndex = 0;
    tabDetails = "1";
    commentList = [];
    commentList?.clear();
    commentloading = false;
    commentloadmore = false;
    totalRowsComment;
    totalPageComment;
    currentPageComment;
    morePageComment;
    deletecommentLoading = false;
  }
}
