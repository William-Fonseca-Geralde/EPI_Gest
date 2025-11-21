abstract class AppWriteModel {
  String? id;
  String? collectionId;
  String? databaseId;
  String? createdAt;
  String? updatedAt;

  AppWriteModel({
    this.id,
    this.collectionId,
    this.databaseId,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toMap();
}