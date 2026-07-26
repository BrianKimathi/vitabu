import 'package:yourappname/model/reviewmodel.dart' as comment;
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/webservice/apiservice.dart';
import 'package:flutter/material.dart';

class ReviewViewProvider extends ChangeNotifier {
  comment.ReviewModel reviewModel = comment.ReviewModel();
  SuccessModel successModel = SuccessModel();
  bool commentloadmore = false, commentloading = false;
  List<comment.Result>? commentList = []; // Comment List Field Pagination
  int? totalRowsComment, totalPageComment, currentPageComment;
  bool? morePageComment;

  setLoading(isLoading) {
    commentloading = isLoading;
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

    setDeleteCommentLoding(false);
  }

  setDeleteCommentLoding(isSending) {
    debugPrint("isSending ==> $isSending");
    deletecommentLoading = isSending;
    notifyListeners();
  }

  clearProvider() {
    reviewModel = comment.ReviewModel();

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
