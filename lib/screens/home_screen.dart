import 'package:flutter/material.dart';
import '../models/menu_item.dart';
import '../models/cart_item.dart';
import '../models/menu_category.dart';
import '../models/dining_table.dart';
import '../services/menu_service.dart';
import '../widgets/menu_item_cart.dart';
import '../widgets/category_chip.dart';
import 'cart_screen.dart';
import 'login_screen.dart';
import 'table_selection_screen.dart';
import '../services/table_service.dart';
import '../services/shared_ticket_service.dart';
import '../services/database_service.dart';
import 'database_settings_screen.dart';
import 'config_screen.dart';
import '../utils/responsive_utils.dart';

class HomeScreen extends StatefulWidget {
  final DiningTable selectedTable;

  const HomeScreen({super.key, required this.selectedTable});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController searchController = TextEditingController();
  String searchQuery = '';

  List<MenuCategory> categories = [];
  List<MenuItem> menuItems = [];

  String selectedCategoryId = 'all';

  bool _loading = true;
  String? _error;

  final List<CartItem> cart = [];

  // Overlay for search suggestions
  final LayerLink _searchFieldLink = LayerLink();
  final GlobalKey _searchFieldKey = GlobalKey();
  OverlayEntry? _searchOverlay;
  Size? _searchFieldSize;
  String? _ticketId;

  @override
  void initState() {
    super.initState();
    _loadMenu().then((_) => _initializeTicket());
  }

  Future<void> _initializeTicket() async {
    try {
      // 0. Ensure the table is LOCKED specifically for this session
      await DatabaseService.lockTable(widget.selectedTable.id);

      // 1. Check for existing open cart for this table in database
      String? existingCartId = await DatabaseService.getOpenCartForTable(widget.selectedTable.id);

      if (existingCartId != null) {
        _ticketId = existingCartId; // We use _ticketId variable to store the active cart ID
        debugPrint('Found existing open cart for table ${widget.selectedTable.id}: $existingCartId');
        
        await _loadExistingCart(existingCartId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Loaded existing order for ${widget.selectedTable.name}'),
              backgroundColor: Theme.of(context).primaryColor,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else {
        // 2. No open cart found, create a new one
        final newCartId = _generateCartId();
        debugPrint('Creating new cart for table ${widget.selectedTable.id}: $newCartId');
        
        // Create cart record
        await DatabaseService.createCart(
          cartId: newCartId,
          customerName: 'Guest',
        );

        // Link cart to table in sharedtickets
        await DatabaseService.linkCartToTable(
          tableId: widget.selectedTable.id,
          tableName: widget.selectedTable.name,
          cartId: newCartId,
        );

        // Mark table as occupied (visual status in places table)
        await TableService.markPlaceOccupied(
          placeId: widget.selectedTable.id,
          ticketId: newCartId,
          waiterName: 'Waiter',
        );

        _ticketId = newCartId;
      }
    } catch (e) {
      debugPrint('Error initializing ticket/cart: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading table: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _loadExistingCart(String cartId) async {
    try {
      // Load lines from cartlines table
      final lines = await DatabaseService.loadCartLines(cartId);

      final cartItems = <CartItem>[];

      for (final line in lines) {
        final productId = line['productId'] as String? ?? '';
        final quantity = _parseDouble(line['quantity']) ?? 1.0;
        final price = _parseDouble(line['price']) ?? 0.0;
        final attributes = line['attributes'] as String?;

        // Find product in loaded menu or create placeholder
        final menuItem = menuItems.firstWhere(
          (m) => m.id == productId,
          orElse: () => MenuItem(
            id: productId,
            name: line['productName'] ?? 'Unknown Item',
            price: price,
            categoryId: '',
            categoryName: '',
            emoji: '📦',
          ),
        );

        cartItems.add(CartItem(
          menuItem: menuItem,
          quantity: quantity.toInt(),
          notes: attributes,
        ));
      }

      setState(() {
        cart.clear();
        cart.addAll(cartItems);
      });
      debugPrint('Loaded ${cart.length} items from cartlines for cart $cartId');

    } catch (e) {
      debugPrint('Error loading existing cart: $e');
    }
  }



  // Helper method to safely parse int values from database
  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value);
    return null;
  }

  // Helper method to safely parse double values from database
  double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Future<void> _createTicketAndReceipt() async {
    final ticketId = _ticketId ?? _generateCartId();
    try {
      // Get a valid person ID from the database
      final personId = await DatabaseService.getValidPersonId();
      if (personId == null) {
        throw Exception(
            'No users found in the database. Please create a user first.');
      }

      // Create receipt first (tickets table has FK to receipts)
      // The receipt method will automatically get or create a valid closedcash session
      await DatabaseService.createReceipt(
        receiptId: ticketId,
        personId: personId,
      );

      // Create ticket - ticketNumber will be auto-generated
      await DatabaseService.createTicket(
        ticketId: ticketId,
        personId: personId,
        placeId: widget.selectedTable.id,
        ticketType: 0,
        // ticketNumber is now auto-generated by the database service
      );

      _ticketId = ticketId;
      debugPrint('Successfully created ticket: $ticketId');
    } catch (e) {
      debugPrint('Error creating ticket/receipt: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to create ticket: $e'),
            backgroundColor: const Color(0xFFEF4444),
            duration: const Duration(seconds: 3),
          ),
        );
      }
      rethrow;
    }
  }

  String _generateCartId() {
    final ts = DateTime.now().millisecondsSinceEpoch;
    // Create a unique cart ID (e.g., C-TableID-Timestamp)
    return 'C-${widget.selectedTable.id}-$ts';
  }

  Future<void> _markTableOccupied({bool showFeedback = false}) async {
    final ticket = _ticketId ?? _generateCartId();
    try {
      await TableService.markPlaceOccupied(
        placeId: widget.selectedTable.id,
        ticketId: ticket,
        waiterName: 'Waiter',
      );
      _ticketId = ticket;
      if (showFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Marked table as occupied (ticket $ticket)'),
            backgroundColor: const Color(0xFF10B981),
          ),
        );
      }
    } catch (e) {
      if (showFeedback) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to mark occupied: $e'),
            backgroundColor: const Color(0xFFEF4444),
          ),
        );
      }
    }
  }

  Future<void> _loadMenu() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final result = await MenuService.fetchMenu();
      setState(() {
        categories = result.categories;
        menuItems = result.items;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _removeSearchOverlay() {
    _searchOverlay?.remove();
    _searchOverlay = null;
  }

  void _showSearchOverlay() {
    final box =
        _searchFieldKey.currentContext?.findRenderObject() as RenderBox?;
    _searchFieldSize = box?.size;
    _removeSearchOverlay();
    if (searchQuery.isEmpty || searchMatches.isEmpty) return;
    _searchOverlay = _buildSearchOverlayEntry();
    Overlay.of(context).insert(_searchOverlay!);
  }

  List<MenuItem> get searchMatches {
    final q = searchQuery.trim().toLowerCase();
    if (q.isEmpty) return const [];
    return menuItems
        .where((m) => m.name.toLowerCase().contains(q))
        .take(8)
        .toList();
  }

  OverlayEntry _buildSearchOverlayEntry() {
    final size = _searchFieldSize ?? const Size(300, 48);
    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _searchFieldLink,
          offset: Offset(0, size.height + 4),
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE5E7EB)),
              ),
              constraints: const BoxConstraints(maxHeight: 260),
              child: ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                shrinkWrap: true,
                itemCount: searchMatches.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = searchMatches[index];
                  return ListTile(
                    title: Text(item.name,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(
                      item.subCategoryName ?? item.categoryName,
                      style: const TextStyle(color: Color(0xFF6B7280)),
                    ),
                    trailing: Text(
                      '\$${item.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        color: Color(0xFF1F2937),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    onTap: () {
                      addToCart(item);
                      _removeSearchOverlay();
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  List<MenuCategory> get categoriesWithAll {
    final mains = categories.where((c) => c.parentId == null).toList();
    return [const MenuCategory(id: 'all', name: 'All'), ...mains];
  }

  List<MenuItem> get filteredItems {
    final q = searchQuery.trim().toLowerCase();
    return menuItems.where((item) {
      final matchesSearch = q.isEmpty || item.name.toLowerCase().contains(q);
      if (selectedCategoryId == 'all') return matchesSearch;
      return matchesSearch && item.categoryId == selectedCategoryId;
    }).toList();
  }

  void addToCart(MenuItem item) async {
    setState(() {
      final existingIndex =
          cart.indexWhere((cartItem) => cartItem.menuItem.id == item.id);
      if (existingIndex >= 0) {
        cart[existingIndex].quantity++;
      } else {
        cart.add(CartItem(menuItem: item));
      }
    });

    // Save to database
    await _saveCartToDatabase();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                item.emoji,
                style: const TextStyle(fontSize: 20),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Added to cart',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.9),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
          ],
        ),
        backgroundColor: const Color(0xFF10B981),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  int get totalItems => cart.fold(0, (sum, item) => sum + item.quantity);
  double get totalPrice => cart.fold(0, (sum, item) => sum + item.totalPrice);

  Future<void> _saveCartToDatabase() async {
    final cartId = _ticketId;
    if (cartId == null) return;

    try {
      debugPrint('Saving cart to database (cartlines)...');
      for (int i = 0; i < cart.length; i++) {
        final item = cart[i];
        await DatabaseService.saveCartLine(
          cartId: cartId,
          lineNumber: i,
          productId: item.menuItem.id,
          productName: item.menuItem.name,
          quantity: item.quantity.toDouble(),
          price: item.menuItem.price,
          attributes: item.notes,
          productRef: item.menuItem.id, // Added productRef
        );
      }
      debugPrint('Cart saved successfully');
    } catch (e) {
      debugPrint('Error saving cart to database: $e');
    }
  }

  /// Save permanent records when payment is made (checkout)
  Future<void> _finalizeTicket() async {
    final ticketId = _ticketId;
    if (ticketId == null || cart.isEmpty) return;

    try {
      // Get a valid person ID from the database
      final personId = await DatabaseService.getValidPersonId();
      if (personId == null) {
        throw Exception(
            'No users found in the database. Please create a user first.');
      }

      // Create receipt first (tickets table has FK to receipts)
      await DatabaseService.createReceipt(
        receiptId: ticketId,
        personId: personId,
      );

      // Create ticket
      await DatabaseService.createTicket(
        ticketId: ticketId,
        personId: personId,
        placeId: widget.selectedTable.id,
        ticketType: 0,
      );

      // Save each cart item to ticketlines
      for (int i = 0; i < cart.length; i++) {
        final item = cart[i];
        await DatabaseService.saveCartItem(
          ticketId: ticketId,
          productId: item.menuItem.id,
          line: i,
          units: item.quantity.toDouble(),
          price: item.menuItem.price,
          taxId: '001',
          sku: item.sku,
          notes: item.notes,
          attributeSetInstanceId: item.attributeSetInstanceId,
          priceLevel: item.priceLevel,
        );
      }

      // Delete from sharedtickets after finalizing
      await SharedTicketService.deleteSharedTicket(widget.selectedTable.id);
      
      // Also clear visual status
      await TableService.clearPlaceStatus(placeId: widget.selectedTable.id);

      debugPrint(
          'Ticket finalized: saved to receipts/tickets/ticketlines and removed from sharedtickets');
    } catch (e) {
      debugPrint('Error finalizing ticket: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvoked: (didPop) async {
        if (didPop) {
           debugPrint('Exiting HomeScreen - Unlocking table ${widget.selectedTable.id}');
           await DatabaseService.unlockTable(widget.selectedTable.id);
        }
      },
            child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Hamster POS',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Color(0xFF10B981)),
              onPressed: () {
                _loadMenu();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Row(
                      children: [
                        Icon(Icons.refresh_rounded, color: Colors.white),
                        SizedBox(width: 12),
                        Text(
                          'Refreshing menu...',
                          style: TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    backgroundColor: const Color(0xFF10B981),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.all(16),
                    duration: const Duration(milliseconds: 1500),
                  ),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon:
                  Icon(Icons.settings_outlined, color: Theme.of(context).primaryColor),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      title: Row(
                        children: [
                          Icon(Icons.settings_rounded, 
                            color: Theme.of(context).primaryColor),
                          const SizedBox(width: 12),
                          const Text('Settings'),
                        ],
                      ),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Database Settings Option
                          ListTile(
                            leading: const Icon(Icons.storage_rounded, 
                              color: Color(0xFF6366F1)),
                            title: const Text('Database Settings'),
                            subtitle: const Text('Configure database connection'),
                            onTap: () {
                              Navigator.pop(context);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const DatabaseSettingsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Close'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.table_bar_rounded,
                              color: Theme.of(context).primaryColor,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.selectedTable.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF111827),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  widget.selectedTable.floorName ??
                                      'Floor ${widget.selectedTable.floorId ?? '-'}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Color(0xFF6B7280),
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          TextButton.icon(
                            onPressed: () async {
                              final newTable =
                                  await Navigator.push<DiningTable>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const TableSelectionScreen(
                                    returnSelection: true,
                                  ),
                                ),
                              );
                              if (newTable == null ||
                                  newTable.id == widget.selectedTable.id) {
                                return;
                              }
                              // Transfer cart snapshot to new table and move occupancy
                              try {
                                // Just save the current cart before switching
                                await _saveCartToDatabase();
                                
                                // DO NOT transfer the cart ID to the new table.
                                // The new table should have its own independent cart.
                                
                              } catch (_) {}

                              // Do NOT clear the old table's status - it is still occupied with the current order.
                              // Do NOT pre-mark the new table - HomeScreen.initState will handle initialization/loading.
                              
                              debugPrint('Attempting to unlock old table: ${widget.selectedTable.id}');
                              await DatabaseService.unlockTable(widget.selectedTable.id);

                              // Navigate to new HomeScreen for the selected table
                              if (!mounted) return;
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HomeScreen(
                                    selectedTable: newTable,
                                  ),
                                ),
                              );
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: const Color(0xFF6366F1), 
                            ),
                            icon: const Icon(Icons.swap_horiz_rounded),
                            label: const Text('Change'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    height: double.infinity,
                    width: 56,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Theme.of(context).primaryColor.withOpacity(0.35),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          await _markTableOccupied(showFeedback: true);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: const Center(
                          child: Icon(
                            Icons.add_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CompositedTransformTarget(
                    link: _searchFieldLink,
                    child: TextField(
                      key: _searchFieldKey,
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: 'Search menu items...',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        prefixIcon: Icon(Icons.search,
                            color: Colors.grey[400], size: 22),
                        suffixIcon: searchQuery.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear,
                                    color: Colors.grey[400], size: 20),
                                onPressed: () {
                                  setState(() {
                                    searchController.clear();
                                    searchQuery = '';
                                    _removeSearchOverlay();
                                  });
                                },
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                      ),
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value;
                        });
                        if (value.isEmpty || searchMatches.isEmpty) {
                          _removeSearchOverlay();
                        } else {
                          _showSearchOverlay();
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 44,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: categoriesWithAll.length,
                    itemBuilder: (context, index) {
                      final cat = categoriesWithAll[index];
                      return CategoryChip(
                        label: cat.name,
                        isSelected: selectedCategoryId == cat.id,
                        onTap: () {
                          setState(() {
                            selectedCategoryId = cat.id;
                          });
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation(Theme.of(context).primaryColor),
                    ),
                  )
                : _error != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 48, color: Color(0xFFEF4444)),
                              const SizedBox(height: 12),
                              Text(
                                'Failed to load menu',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                _error!,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadMenu,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                              )
                            ],
                          ),
                        ),
                      )
                    : Builder(builder: (context) {
                          if (selectedCategoryId == 'all') {
                          return GridView.builder(
                            padding: const EdgeInsets.all(20),
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: ResponsiveUtils.getGridColumns(
                                context,
                                mobile: 2,
                                tablet: 3,
                                desktop: 4,
                              ),
                              childAspectRatio: 0.72,
                              crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(
                                context,
                                mobile: 16.0,
                                tablet: 20.0,
                              ),
                              mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(
                                context,
                                mobile: 16.0,
                                tablet: 20.0,
                              ),
                            ),
                            itemCount: filteredItems.length,
                            itemBuilder: (context, index) {
                              return MenuItemCard(
                                item: filteredItems[index],
                                onAdd: () => addToCart(filteredItems[index]),
                              );
                            },
                          );
                        }

                        final isSubSelected = categories.any(
                          (c) =>
                              c.id == selectedCategoryId && c.parentId != null,
                        );

                        if (!isSubSelected) {
                          final mainCategoryItems = menuItems.where((item) {
                            final matchesSearch = searchQuery.isEmpty ||
                                item.name
                                    .toLowerCase()
                                    .contains(searchQuery.toLowerCase());
                            return item.parentCategoryId == null &&
                                item.categoryId == selectedCategoryId &&
                                matchesSearch;
                          }).toList();
                          final subCategoriesForActive = categories
                              .where((c) => c.parentId == selectedCategoryId)
                              .toList();

                          return SingleChildScrollView(
                            child: Column(
                              children: [
                                if (subCategoriesForActive.isNotEmpty) ...[
                                  Padding(
                                    padding: const EdgeInsets.fromLTRB(
                                        20, 12, 20, 0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Subcategories',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 20, vertical: 12),
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: ResponsiveUtils.getGridColumns(
                                          context,
                                          mobile: 3,
                                          tablet: 4,
                                          desktop: 5,
                                        ),
                                        mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(
                                          context,
                                          mobile: 12.0,
                                          tablet: 16.0,
                                        ),
                                        crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(
                                          context,
                                          mobile: 12.0,
                                          tablet: 16.0,
                                        ),
                                        childAspectRatio: 0.9,
                                      ),
                                      itemCount: subCategoriesForActive.length,
                                      itemBuilder: (context, index) {
                                        final sub =
                                            subCategoriesForActive[index];
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              selectedCategoryId = sub.id;
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(14),
                                              border: Border.all(
                                                  color:
                                                      const Color(0xFFE5E7EB)),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.04),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.folder_copy_outlined,
                                                  size: 32,
                                                  color: Color(0xFF6366F1),
                                                ),
                                                const SizedBox(height: 10),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(horizontal: 6),
                                                  child: Text(
                                                    sub.name,
                                                    textAlign: TextAlign.center,
                                                    maxLines: 2,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontSize: 13,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: Color(0xFF1F2937),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ] else ...[
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Center(
                                      child: Text(
                                        'No subcategories',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                                if (mainCategoryItems.isNotEmpty) ...[
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 8, 20, 0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Products',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: GridView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: ResponsiveUtils.getGridColumns(
                                          context,
                                          mobile: 2,
                                          tablet: 3,
                                          desktop: 4,
                                        ),
                                        childAspectRatio: 0.72,
                                        crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(
                                          context,
                                          mobile: 16.0,
                                          tablet: 20.0,
                                        ),
                                        mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(
                                          context,
                                          mobile: 16.0,
                                          tablet: 20.0,
                                        ),
                                      ),
                                      itemCount: mainCategoryItems.length,
                                      itemBuilder: (context, index) {
                                        final item = mainCategoryItems[index];
                                        return MenuItemCard(
                                          item: item,
                                          onAdd: () => addToCart(item),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        }

                        final currentSub = categories.firstWhere(
                          (c) => c.id == selectedCategoryId,
                          orElse: () => const MenuCategory(id: '', name: ''),
                        );

                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.arrow_back_rounded),
                                    onPressed: () {
                                      setState(() {
                                        selectedCategoryId =
                                            currentSub.parentId ?? 'all';
                                      });
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      'Products in ${currentSub.name}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: filteredItems.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(24),
                                            decoration: const BoxDecoration(
                                              color: Color(0xFFF3F4F6),
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.search_off_rounded,
                                              size: 64,
                                              color: Colors.grey[400],
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          const Text(
                                            'No items found',
                                            style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF6B7280),
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : GridView.builder(
                                      padding: const EdgeInsets.all(20),
                                      gridDelegate:
                                          SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: ResponsiveUtils.getGridColumns(
                                          context,
                                          mobile: 2,
                                          tablet: 3,
                                          desktop: 4,
                                        ),
                                        childAspectRatio: 0.72,
                                        crossAxisSpacing: ResponsiveUtils.getResponsiveSpacing(
                                          context,
                                          mobile: 16.0,
                                          tablet: 20.0,
                                        ),
                                        mainAxisSpacing: ResponsiveUtils.getResponsiveSpacing(
                                          context,
                                          mobile: 16.0,
                                          tablet: 20.0,
                                        ),
                                      ),
                                      itemCount: filteredItems.length,
                                      itemBuilder: (context, index) {
                                        return MenuItemCard(
                                          item: filteredItems[index],
                                          onAdd: () =>
                                              addToCart(filteredItems[index]),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        );
                      }),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
                child: Row(
                  children: [
                    if (cart.isNotEmpty) ...[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            '$totalItems ${totalItems == 1 ? 'item' : 'items'}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '\$${totalPrice.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                    ],
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: cart.isEmpty
                              ? Theme.of(context).primaryColor.withOpacity(0.5)
                              : Theme.of(context).primaryColor,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: cart.isEmpty
                              ? []
                              : [
                                  BoxShadow(
                                    color: Theme.of(context).primaryColor
                                        .withOpacity(0.4),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: cart.isEmpty
                                ? null
                                : () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => CartScreen(
                                          cart: cart,
                                          selectedTable: widget.selectedTable,
                                          cartId: _ticketId,
                                        ),
                                      ),
                                    );
                                    // Always update UI when returning from cart
                                    setState(() {
                                      if (result == true) {
                                        // Order was placed, clear cart
                                        cart.clear();
                                      }
                                      // If result is null/false, cart may have been modified
                                      // setState will refresh the counters
                                    });
                                  },
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 16,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      const Icon(
                                        Icons.shopping_cart_outlined,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                      if (totalItems > 0)
                                        Positioned(
                                          right: -8,
                                          top: -8,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              gradient: const LinearGradient(
                                                colors: [
                                                  Color(0xFFFF6B6B),
                                                  Color(0xFFEE5A6F)
                                                ],
                                              ),
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFFFF6B6B)
                                                      .withOpacity(0.4),
                                                  blurRadius: 4,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 18,
                                              minHeight: 18,
                                            ),
                                            child: Text(
                                              '$totalItems',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    cart.isEmpty
                                        ? 'Cart is empty'
                                        : 'View Cart',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (cart.isNotEmpty) ...[
                                    const SizedBox(width: 8),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      ),
    );
  }
}
