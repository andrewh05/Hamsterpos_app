import 'package:flutter/foundation.dart';
import 'database_service.dart';
import '../models/menu_item.dart';
import '../models/menu_category.dart';

class MenuLoadResult {
  final List<MenuCategory> categories;
  final List<MenuItem> items;

  const MenuLoadResult({required this.categories, required this.items});
}

class MenuService {
  static Future<MenuLoadResult> fetchMenu() async {
    final conn = await DatabaseService.openConfiguredConnection();

    try {
      // Fetch all categories (needed to resolve parent/child relationships)
      // Only show categories where catshowname = 1, ordered by catorder
      final catsResult = await conn.execute(
        'SELECT id, name, parentid FROM categories WHERE catshowname = 1 ORDER BY catorder',
      );

      final categories = <MenuCategory>[];
      final categoryMap = <String, MenuCategory>{};

      for (final row in catsResult.rows) {
        final cat = MenuCategory(
          id: row.colByName('id') ?? '',
          name: row.colByName('name') ?? '',
          parentId: row.colByName('parentid'),
        );
        categoryMap[cat.id] = cat;
        categories.add(cat);
      }

      // Fetch products with their category info
      // Changed to LEFT JOIN to include active products even if category links are broken
      final productsResult = await conn.execute('''
        SELECT
          p.id,
          p.name,
          p.pricesell,
          p.category AS categoryId, -- Use product's category column as fallback
          c.id   AS joinedCategoryId,
          c.name AS categoryName,
          c.parentid AS parentCategoryId
        FROM products p
        LEFT JOIN categories c ON p.category = c.id
        WHERE (p.ACTIVE IS NULL OR p.ACTIVE = 1)
        ORDER BY c.catorder
      ''');

      debugPrint('DEBUG: Fetching menu...');
      final items = <MenuItem>[];

      for (final row in productsResult.rows) {
        final categoryId = row.colByName('categoryId') ?? '';
        final joinedCatId = row.colByName('joinedCategoryId');
        
        // If category join failed, use the raw ID
        final finalCatId = joinedCatId ?? categoryId;
        
        // Debug missing categories
        if (joinedCatId == null) {
           debugPrint('WARNING: Product ${row.colByName('name')} has invalid category ID: $categoryId');
        }

        final category = categoryMap[finalCatId];

        items.add(
          MenuItem(
            id: row.colByName('id') ?? '',
            name: row.colByName('name') ?? '',
            price: double.tryParse(row.colByName('pricesell') ?? '0') ?? 0,
            categoryId: finalCatId,
            categoryName: category?.name ?? (row.colByName('categoryName') ?? 'Uncategorized'),
            parentCategoryId: category?.parentId, // Use object's parent if available
            subCategoryName: null, // Simplified for robustness
          ),
        );
      }

      return MenuLoadResult(categories: categories, items: items);
    } finally {
      await conn.close();
    }
  }

  /// Fetch a single product by ID
  static Future<MenuItem?> getProductById(String productId) async {
    final conn = await DatabaseService.openConfiguredConnection();

    try {
      final result = await conn.execute(
        '''
        SELECT
          p.id,
          p.name,
          p.pricesell,
          c.id   AS categoryId,
          c.name AS categoryName,
          c.parentid AS parentCategoryId
        FROM products p
        JOIN categories c ON p.category = c.id
        WHERE p.id = :id
          AND (p.ACTIVE IS NULL OR p.ACTIVE = 1)
        LIMIT 1
        ''',
        {'id': productId},
      );

      if (result.rows.isEmpty) return null;

      final row = result.rows.first;
      final categoryId = row.colByName('categoryId') ?? '';
      final parentCategoryId = row.colByName('parentCategoryId');

      return MenuItem(
        id: row.colByName('id') ?? '',
        name: row.colByName('name') ?? '',
        price: double.tryParse(row.colByName('pricesell') ?? '0') ?? 0,
        categoryId: categoryId,
        categoryName: row.colByName('categoryName') ?? '',
        parentCategoryId: parentCategoryId,
        subCategoryName: parentCategoryId != null
            ? (row.colByName('categoryName') ?? '')
            : null,
      );
    } finally {
      await conn.close();
    }
  }
}
