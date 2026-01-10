import 'package:flutter/material.dart';
import 'dart:async';
import '../models/dining_table.dart';
import '../services/table_service.dart';
import 'home_screen.dart' as home;
import 'database_settings_screen.dart';

class TableSelectionScreen extends StatefulWidget {
  final bool returnSelection; // when true, pop with selected table

  const TableSelectionScreen({Key? key, this.returnSelection = false})
      : super(key: key);

  @override
  State<TableSelectionScreen> createState() => _TableSelectionScreenState();
}


class _TableSelectionScreenState extends State<TableSelectionScreen> {
  // Manual state management for background sync
  bool _isLoading = true;
  String? _error;
  TableData? _cachedData;
  Timer? _refreshTimer;
  
  String? _selectedFloorId;
  DiningTable? _selectedTable;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _statusFilter; // 'available' | 'occupied' | 'reserved'

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    
    // Poll for updates every 3 seconds to keep sync
    _refreshTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      _refreshTablesSilent();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final data = await TableService.fetchTablesAndFloors();
      if (mounted) {
        setState(() {
          _cachedData = data;
          _isLoading = false;
           // Set default floor if needed
          if (_selectedFloorId == null) {
            if (data.floors.isNotEmpty) {
              _selectedFloorId = data.floors.first.id;
            } else if (data.tables.isNotEmpty) {
              _selectedFloorId = data.tables.first.floorId ?? 'default';
            }
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // Silent refresh that doesn't show loading spinner but updates data
  Future<void> _refreshTablesSilent() async {
    if (!mounted) return;
    try {
      final data = await TableService.fetchTablesAndFloors();
      if (mounted) {
        setState(() {
          _cachedData = data;
          // Note: we do NOT reset _selectedFloorId here to avoid jumping floors while user IS browsing
        });
      }
    } catch (e) {
      // Create a silent error log if needed, but don't disrupt UI
      debugPrint('Silent refresh failed: $e');
    }
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'busy':
      case 'occupied':
        return const Color(0xFFFFA000);
      case 'reserved':
      case 'unavailable':
        return const Color(0xFFE11D48);
      default:
        return const Color(0xFF10B981);
    }
  }

  String _statusLabel(String? status) {
    if (status == null || status.isEmpty) return 'Available';
    final s = status.toLowerCase();
    if (s == 'busy') return 'Occupied';
    return status[0].toUpperCase() + status.substring(1);
  }

  // Natural numeric sorting to ensure order like 1, 2, 3, 10
  int? _extractNumber(String? s) {
    if (s == null) return null;
    final m = RegExp(r"\d+").firstMatch(s);
    if (m == null) return null;
    return int.tryParse(m.group(0)!);
  }

  int _compareNumericThenAlpha(String? a, String? b) {
    final ai = _extractNumber(a);
    final bi = _extractNumber(b);
    if (ai != null && bi != null) return ai.compareTo(bi);
    return (a ?? '').toLowerCase().compareTo((b ?? '').toLowerCase());
  }

  List<DiningTable> _applyFilters(List<DiningTable> tables) {
    Iterable<DiningTable> filtered = tables;
    // Floor filter
    if (_selectedFloorId != null) {
      filtered = filtered.where((t) =>
          t.floorId == _selectedFloorId ||
          (t.floorId == null && t.floorName == _selectedFloorId));
    }
    // Status filter (only if a value is set)
    if (_statusFilter != null && _statusFilter!.isNotEmpty) {
      final target = _statusFilter!.toLowerCase();
      filtered = filtered.where((t) {
        final s = t.status?.toLowerCase();
        if (target == 'available') {
          // Treat null/empty as available when status data exists
          return s == null || s.isEmpty || s == 'available';
        }
        return s == target;
      });
    }
    // Search filter
    final q = _searchQuery.trim().toLowerCase();
    if (q.isNotEmpty) {
      filtered = filtered.where((t) =>
          (t.name.toLowerCase().contains(q)) ||
          ((t.floorName ?? '').toLowerCase().contains(q)));
    }
    final list = filtered.toList();
    list.sort((a, b) {
      final fc = _compareNumericThenAlpha(a.floorId, b.floorId);
      if (fc != 0) return fc;
      return _compareNumericThenAlpha(a.name, b.name);
    });
    return list;
  }

  void _onTableTap(DiningTable table) {
    setState(() {
      _selectedTable = table;
      _selectedFloorId = table.floorId ?? _selectedFloorId;
    });

    // Automatically navigate to home screen when table is tapped
    if (widget.returnSelection) {
      Navigator.pop(context, table);
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => home.HomeScreen(selectedTable: table),
        ),
      );
    }
  }

  void _continueToHome() {
    if (_selectedTable == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a table to continue'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    if (widget.returnSelection) {
      Navigator.pop(context, _selectedTable);
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => home.HomeScreen(selectedTable: _selectedTable!),
      ),
    );
  }



  Widget _buildFloorChips(List<FloorInfo> floors) {
    if (floors.isEmpty) {
      return const SizedBox.shrink();
    }
    final sortedFloors = [...floors]
      ..sort((a, b) => _compareNumericThenAlpha(a.name, b.name));
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: sortedFloors.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final floor = sortedFloors[index];
          final selected = floor.id == _selectedFloorId;
          return ChoiceChip(
            label: Text(
              floor.name,
              style: TextStyle(
                color: selected ? Colors.white : const Color(0xFF1F2937),
                fontWeight: FontWeight.w600,
              ),
            ),
            selected: selected,
            onSelected: (_) {
              setState(() {
                _selectedFloorId = floor.id;
                _selectedTable = null;
              });
            },
            selectedColor: const Color(0xFF6366F1),
            backgroundColor: const Color(0xFFF3F4F6),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(
                color: selected
                    ? const Color(0xFF6366F1)
                    : const Color(0xFFE5E7EB),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTableCard(DiningTable table) {
    final isSelected = _selectedTable?.id == table.id;
    final statusColor = _statusColor(table.status);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEEF2FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF6366F1) : const Color(0xFFE5E7EB),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          if (table.status == 'reserved') {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Table ${table.name} is reserved/locked.'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }
          _onTableTap(table);
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.circle, size: 10, color: statusColor),
                        const SizedBox(width: 6),
                        Text(
                          _statusLabel(table.status),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: statusColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (table.seats != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.chair_alt_rounded,
                              size: 16, color: Color(0xFF6366F1)),
                          const SizedBox(width: 6),
                          Text(
                            '${table.seats} seats',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF6366F1),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                table.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                table.floorName ?? 'Floor ${table.floorId ?? '-'}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Builder(
        builder: (context) {
          // 1. Initial Loading State (only if no data yet)
          if (_isLoading && _cachedData == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Error State (only if no data yet)
          if (_error != null && _cachedData == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 48, color: Colors.amber),
                    const SizedBox(height: 16),
                    Text(
                      'Unable to load tables',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton.icon(
                      onPressed: _loadInitialData,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Retry'),
                    ),
                    const SizedBox(height: 16),
                    OutlinedButton.icon(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  const DatabaseSettingsScreen()),
                        );
                        if (result == true) {
                          _loadInitialData();
                        }
                      },
                      icon: const Icon(Icons.settings_rounded),
                      label: const Text('Settings'),
                    ),
                  ],
                ),
              ),
            );
          }

          // 3. Main Data View
          // We force unwrap _cachedData here because logically we must have data if the above checks passed
          // (or we are in a transitory state where we have old data but might be loading/erroring in background)
          final data = _cachedData!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Gradient
              Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Please select a table',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Pick a floor and choose the table to start the order.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.refresh_rounded,
                            color: Colors.white, size: 26),
                        onPressed: () {
                          _loadInitialData();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.refresh_rounded,
                                      color: Colors.white),
                                  SizedBox(width: 12),
                                  Text('Refreshing tables...',
                                      style: TextStyle(
                                          fontWeight: FontWeight.w500)),
                                ],
                              ),
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              margin: const EdgeInsets.all(16),
                              duration: const Duration(milliseconds: 1500),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Floor Chips
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _buildFloorChips(data.floors),
              ),
              const SizedBox(height: 12),
              
              // Filters & Search
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search tables...',
                          hintStyle: TextStyle(color: Colors.grey[400]),
                          prefixIcon: Icon(Icons.search,
                              color: Colors.grey[400], size: 22),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: Icon(Icons.clear,
                                      color: Colors.grey[400], size: 20),
                                  onPressed: () {
                                    setState(() {
                                      _searchController.clear();
                                      _searchQuery = '';
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
                            _searchQuery = value.trim();
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 10),
                    Builder(builder: (context) {
                      final hasStatusData = data.tables.any(
                          (t) => (t.status != null && t.status!.isNotEmpty));
                      if (!hasStatusData) return const SizedBox.shrink();
                      final chips = [
                        {'label': 'All', 'value': null},
                        {'label': 'Available', 'value': 'available'},
                        {'label': 'Occupied', 'value': 'occupied'},
                        {'label': 'Reserved', 'value': 'reserved'},
                      ];
                      return SizedBox(
                        height: 40,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: chips.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(width: 8),
                          itemBuilder: (context, index) {
                            final chip = chips[index];
                            final selected = _statusFilter == chip['value'];
                            return ChoiceChip(
                              label: Text(
                                chip['label'] as String,
                                style: TextStyle(
                                  color: selected
                                      ? Colors.white
                                      : const Color(0xFF1F2937),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              selected: selected,
                              onSelected: (_) {
                                setState(() {
                                  _statusFilter = chip['value'];
                                });
                              },
                              selectedColor: const Color(0xFF6366F1),
                              backgroundColor: const Color(0xFFF3F4F6),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(
                                  color: selected
                                      ? const Color(0xFF6366F1)
                                      : const Color(0xFFE5E7EB),
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    }),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              
              // Grid View
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadInitialData,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _applyFilters(data.tables).isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 100),
                              Center(
                                child: Text(
                                  'No tables available for this floor.',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Color(0xFF6B7280),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          )
                        : GridView.builder(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding:
                                const EdgeInsets.only(bottom: 24, top: 8),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              childAspectRatio: 1,
                            ),
                            itemCount: _applyFilters(data.tables).length,
                            itemBuilder: (context, index) {
                              final table = _applyFilters(data.tables)[index];
                              return _buildTableCard(table);
                            },
                          ),
                  ),
                ),
              ),
              

            ],
          );
        },
      ),
    );
  }
}
