class MenuItem {
  final String id;
  final String name;
  final double price;
  final String categoryId;
  final String categoryName;
  final String? parentCategoryId;
  final String? subCategoryName;
  final String emoji;

  bool get hasSubCategory =>
      subCategoryName != null && subCategoryName!.isNotEmpty;

  MenuItem({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
    required this.categoryName,
    this.parentCategoryId,
    this.subCategoryName,
    String? emoji,
  }) : emoji = emoji ?? '📦';
}
