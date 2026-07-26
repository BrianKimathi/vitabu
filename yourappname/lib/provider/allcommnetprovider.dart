import 'package:yourappname/model/commentmodel.dart' as comment;
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webservice/apiservice.dart';
import 'package:flutter/material.dart';

class AllCommentProvider extends ChangeNotifier {
  comment.CommentModel commentModel = comment.CommentModel();
  List<comment.Result>? commentList = [];
  SuccessModel editcommnetSuccessModel = SuccessModel();

  bool commentloading = false, editcommentloading = false;
  bool loadMore = false;

  setLoadMore(loadMore) {
    printLog("setLoadMore loadMore :=> $loadMore");
    this.loadMore = loadMore;
    notifyListeners();
  }

  setLoading(bool isLoading) {
    commentloading = isLoading;
  }

  /*  Pagination start */
  int? totalRows, totalPage, currentPage;
  bool? morePage;
  setPagination(
      int? totalRows, int? totalPage, int? currentPage, bool? morePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    this.morePage = morePage;
    notifyListeners();
  }
  /*  Pagination end */

  Future<void> getComments(type, bookid, magazineid, pageno) async {
    commentloading = true;
    // commentModel = comment.CommentModel();
    commentModel = await ApiService()
        .viewCommentPagination(type, bookid, magazineid, pageno);
    if (commentModel.status == 200) {
      setPagination(commentModel.totalRows, commentModel.totalPage,
          commentModel.currentPage, commentModel.morePage);
      if (commentModel.result != null &&
          (commentModel.result?.length ?? 0) > 0) {
        for (var i = 0; i < (commentModel.result?.length ?? 0); i++) {
          commentList?.add(commentModel.result?[i] ?? comment.Result());
        }
        final Map<int, comment.Result> commentMap = {};
        commentList?.forEach((item) {
          commentMap[item.id ?? 0] = item;
        });
        commentList = commentMap.values.toList();
        setLoadMore(false);
        printLog("commentList length :==> ${(commentList?.length ?? 0)}");
      }
    }
    commentloading = false;
    notifyListeners();
  }

  clearProvider() {
    commentModel = comment.CommentModel();

    commentList = [];

    commentloading = false;
    loadMore = false;
  }

  Future<void> editComment(
      type, bookid, comment, commentId, rating, magazineID, pageno) async {
    editcommentloading = true;
    editcommnetSuccessModel = await ApiService()
        .editComment(type, comment, commentId, rating, bookid, magazineID);
    editcommentloading = false;
    notifyListeners();
  }
}
