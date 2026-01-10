class MenuCategory {
  final String id;
  final String name;
  final String? parentId;

  const MenuCategory({
    required this.id,
    required this.name,
    this.parentId,
  });
}
