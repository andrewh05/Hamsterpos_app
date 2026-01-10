class FloorInfo {
  final String id;
  final String name;

  const FloorInfo({required this.id, required this.name});
}

class DiningTable {
  final String id;
  final String name;
  final String? floorId;
  final String? floorName;
  final String? status;
  final int? seats;

  const DiningTable({
    required this.id,
    required this.name,
    this.floorId,
    this.floorName,
    this.status,
    this.seats,
  });
}

class TableData {
  final List<FloorInfo> floors;
  final List<DiningTable> tables;

  const TableData({required this.floors, required this.tables});
}
