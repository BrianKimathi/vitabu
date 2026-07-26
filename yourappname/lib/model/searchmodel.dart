// To parse this JSON data, do
//
//     final searchModel = searchModelFromJson(jsonString);

// import 'dart:convert';

// SearchModel searchModelFromJson(String str) =>
//     SearchModel.fromJson(json.decode(str));

// String searchModelToJson(SearchModel data) => json.encode(data.toJson());

// class SearchModel {
//   int? status;
//   String? message;
//   List<Result>? result;

//   SearchModel({
//     this.status,
//     this.message,
//     this.result,
//   });

//   factory SearchModel.fromJson(Map<String, dynamic> json) => SearchModel(
//         status: json["status"],
//         message: json["message"],
//         result:
//             List<Result>.from(json["result"].map((x) => Result.fromJson(x))),
//       );

//   Map<String, dynamic> toJson() => {
//         "status": status,
//         "message": message,
//         "result": List<dynamic>.from(result!.map((x) => x.toJson())),
//       };
// }

// class Result {
//   int? id;
//   String? name;
//   String? categoryId;
//   String? languageId;
//   String? videoType;
//   String? url;
//   int? videoDuration;
//   int? download;
//   String? description;
//   String? isPremium;
//   String? isTitle;
//   String? thumbnail;
//   String? landscape;
//   String? createdAt;
//   String? updatedAt;
//   String? categoryName;
//   String? languageName;

//   Result({
//     this.id,
//     this.name,
//     this.categoryId,
//     this.languageId,
//     this.videoType,
//     this.url,
//     this.videoDuration,
//     this.download,
//     this.description,
//     this.isPremium,
//     this.isTitle,
//     this.thumbnail,
//     this.landscape,
//     this.createdAt,
//     this.updatedAt,
//     this.categoryName,
//     this.languageName,
//   });

//   factory Result.fromJson(Map<String, dynamic> json) => Result(
//         id: json["id"],
//         name: json["name"],
//         categoryId: json["category_id"],
//         languageId: json["language_id"],
//         videoType: json["video_type"],
//         url: json["url"],
//         videoDuration: json["video_duration"],
//         download: json["download"],
//         description: json["description"],
//         isPremium: json["is_premium"],
//         isTitle: json["is_title"],
//         thumbnail: json["thumbnail"],
//         landscape: json["landscape"],
//         createdAt: json["created_at"],
//         updatedAt: json["updated_at"],
//         categoryName: json["category_name"],
//         languageName: json["language_name"],
//       );

//   Map<String, dynamic> toJson() => {
//         "id": id,
//         "name": name,
//         "category_id": categoryId,
//         "language_id": languageId,
//         "video_type": videoType,
//         "url": url,
//         "video_duration": videoDuration,
//         "download": download,
//         "description": description,
//         "is_premium": isPremium,
//         "is_title": isTitle,
//         "thumbnail": thumbnail,
//         "landscape": landscape,
//         "created_at": createdAt,
//         "updated_at": updatedAt,
//         "category_name": categoryName,
//         "language_name": languageName,
//       };
// }
