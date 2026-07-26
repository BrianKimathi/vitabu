class DownloadModel {
  int? id;
  String? title;
  String? type; // pdf or epub
  String? url;
  String? categoryName;
  String? image;
  String? urlType;
  String? filePath;
  String? userID;

  DownloadModel(
      {this.id,
      this.title,
      this.type,
      this.url,
      this.categoryName,
      this.image,
      this.urlType,
      this.filePath,
      this.userID});

  factory DownloadModel.fromJson(Map<String, dynamic> json) {
    return DownloadModel(
        id: json['id'],
        title: json['title'],
        type: json['type'],
        url: json['url'],
        categoryName: json['category_name'],
        image: json['image'],
        urlType: json['url_type'],
        filePath: json["filePath"],
        userID: json["userId"]);
  }
}
