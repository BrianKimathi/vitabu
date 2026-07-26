import 'package:yourappname/model/profilemodel.dart';
import 'package:yourappname/model/sectionmodel.dart' as sectiondata;
import 'package:yourappname/model/successmodel.dart';
import 'package:yourappname/utils/constant.dart';
import 'package:yourappname/utils/sharedpref.dart';
import 'package:yourappname/utils/utils.dart';
import 'package:yourappname/webservice/apiservice.dart';
import 'package:flutter/foundation.dart';

class AudioBookProvider extends ChangeNotifier {
  ProfileModel profileModel = ProfileModel();
  sectiondata.SectionModel sectionListModel = sectiondata.SectionModel();
  SuccessModel successModel = SuccessModel();
  List<sectiondata.Result>? sectionListData = [];

  bool loading = false;

  setLoading(bool isLoading) {
    loading = isLoading;

    notifyListeners();
  }

  SharedPref sharedPre = SharedPref();

    getProfile(userId) async {
    if (userId == null || userId.toString().trim().isEmpty || userId.toString() == "0") {
      loading = false;
      notifyListeners();
      return;
    }
    loading = true;
    profileModel = await ApiService().profileResponse(userId);

    if (profileModel.status == 200 &&
        profileModel.result != null &&
        profileModel.result!.isNotEmpty) {
      final result = profileModel.result!.first;

      await sharedPre.save(
        "is_subscription",
        (result.isSubscription ?? 0).toString(),
      );

      Constant.isSubscription = result.isSubscription ?? 0;
    }

    loading = false;
    notifyListeners();
  }

  int? currentIndex = 0;
  String? audioBookId = "",
      categoryId = "",
      authorId = "",
      bookImage = "",
      authorName = "",
      contentName = "",
      audioUrl = "",
      isPaid = "",
      isBuy = "",
      price = "";

  setIndexChange({index}) {
    currentIndex = index;

    notifyListeners();
  }
/* Paid Banner Content */

  int currentPaidIndex = 0;
  String? paidaudioBookId = "",
      paidcategoryId = "",
      paidauthorId = "",
      paidbookImage = "",
      paidauthorName = "",
      paidcontentName = "",
      paidaudioUrl = "",
      paidBook = "",
      paidisBuy = "",
      paidprice = "";
  setAudioPaidIndexChange({
    index,
    ids,
    catIds,
    authorIds,
    image,
    auName,
    conName,
    url,
    paid,
    buy,
    priceBook,
  }) {
    currentPaidIndex = index;
    paidauthorId = authorIds;
    paidaudioBookId = ids;
    paidcategoryId = catIds;
    paidbookImage = image;
    paidauthorName = auName;
    paidcontentName = conName;
    paidaudioUrl = url;
    paidBook = paid;
    paidisBuy = buy;
    paidprice = priceBook;

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

  /* Audio Book Section Data Started */
  Future<void> getSectionList(sectionType, userCategoryId, pageno) async {
    loading = true;
    sectionListModel =
        await ApiService().sectionList(sectionType, userCategoryId, pageno);
    printLog("section_list status :==> ${sectionListModel.status}");
    printLog("section_list message :==> ${sectionListModel.message}");
    if (sectionListModel.status == 200) {
      setPagination(sectionListModel.totalRows, sectionListModel.totalPage,
          sectionListModel.currentPage, sectionListModel.morePage);
      if (sectionListModel.result != null &&
          (sectionListModel.result?.length ?? 0) > 0) {
        if (sectionListModel.result != null &&
            (sectionListModel.result?.length ?? 0) > 0) {
          for (var i = 0; i < (sectionListModel.result?.length ?? 0); i++) {
            sectionListData
                ?.add(sectionListModel.result?[i] ?? sectiondata.Result());
          }
          final Map<int, sectiondata.Result> postMap = {};
          sectionListData?.forEach((item) {
            postMap[item.id ?? 0] = item;
          });
          sectionListData = postMap.values.toList();
          setLoadMore(false);
        }
      }
    }
    loading = false;
    notifyListeners();
  }
  /*  Pagination start */

  int? totalRows, totalPage, currentPage;
  bool loadMore = false;
  bool? isMorePage;

  setLoadMore(loadMore) {
    printLog("setLoadMore loadMore :=> $loadMore");
    this.loadMore = loadMore;
    notifyListeners();
  }

  setPagination(
      int? totalRows, int? totalPage, int? currentPage, bool? morePage) {
    this.currentPage = currentPage;
    this.totalRows = totalRows;
    this.totalPage = totalPage;
    isMorePage = morePage;
    notifyListeners();
  }

  Future<void> setView(contentType, contentId, subContentId) async {
    debugPrint("addPostView postId :==> $contentId");
    // loaded = true;
    successModel = await ApiService()
        .contentViewResponse(contentType, contentId, subContentId);
    debugPrint("addPostView status :==> ${successModel.status}");
    debugPrint("addPostView message :==> ${successModel.message}");
    // loaded = false;
  } /* Web Data Started */

  String? name;
  DateTime? id;
  setBanner(ids, names) {
    id = ids;
    name = names;
    notifyListeners();
  }

  clearProvider() {
    printLog("================== ClearProvider ==================");
    currentIndex = 0;
    audioBookId = "";
    categoryId = "";
    authorId = "";
    bookImage = "";
    authorName = "";
    contentName = "";
    audioUrl = "";
    isPaid = "";
    isBuy = "";
    price = "";
/* Paid Content Data */
    currentPaidIndex = 0;
    paidaudioBookId = "";
    paidcategoryId = "";
    paidauthorId = "";
    paidbookImage = "";
    paidauthorName = "";
    paidcontentName = "";
    paidaudioUrl = "";
    paidBook = "";
    paidisBuy = "";
    paidprice = "";
    profileModel = ProfileModel();
    sectionListModel = sectiondata.SectionModel();
    sectionListData = [];
    sectionListData?.clear();
    loading = false;

    loadMore = false;
    totalRows;
    totalPage;
    currentPage;
    isMorePage = false;
    id = DateTime.now();
    name = "";
  }
}

