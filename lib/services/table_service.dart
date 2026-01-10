import 'package:mysql_client/mysql_client.dart';
import '../models/dining_table.dart';
import 'database_service.dart';

class TableService {
  static Future<TableData> fetchTablesAndFloors() async {
    final conn = await DatabaseService.openConfiguredConnection();

    try {
      final floors = await _loadFloors(conn);
      final tables = await _loadTables(conn, floors);

      // If floors table is empty but tables have floor ids/names, derive floors
      if (floors.isEmpty && tables.isNotEmpty) {
        final derived = <String, FloorInfo>{};
        for (final table in tables) {
          final key = table.floorId ?? table.floorName ?? 'default';
          final name = table.floorName ?? 'Floor ${table.floorId ?? '1'}';
          derived[key] = FloorInfo(id: key, name: name);
        }
        return TableData(floors: derived.values.toList(), tables: tables);
      }

      return TableData(floors: floors, tables: tables);
    } finally {
      await conn.close();
    }
  }

  static Future<List<FloorInfo>> _loadFloors(MySQLConnection conn) async {
    try {
      final result = await conn.execute(
        'SELECT id, name FROM floors ORDER BY name',
      );

      return result.rows
          .map(
            (row) => FloorInfo(
              id: row.colByName('id') ?? '',
              name: row.colByName('name') ?? 'Unnamed floor',
            ),
          )
          .toList();
    } catch (_) {
      // Fallback: derive floors directly from places table if floors table doesn't exist
      try {
        final fallback = await conn.execute(
          'SELECT DISTINCT floor AS id FROM places ORDER BY floor',
        );

        return fallback.rows
            .map(
              (row) => FloorInfo(
                id: row.colByName('id') ?? '',
                name: 'Floor ${row.colByName('id') ?? ''}',
              ),
            )
            .where((floor) => floor.id.isNotEmpty)
            .toList();
      } catch (_) {
        final fallback = await conn.execute(
          'SELECT DISTINCT floor AS id FROM places ORDER BY floor',
        );

        return fallback.rows
            .map(
              (row) => FloorInfo(
                id: row.colByName('id') ?? '',
                name: 'Floor ${row.colByName('id') ?? ''}',
              ),
            )
            .where((floor) => floor.id.isNotEmpty)
            .toList();
      }
    }
  }

  static Future<List<DiningTable>> _loadTables(
    MySQLConnection conn,
    List<FloorInfo> floors,
  ) async {
    try {
      final result = await conn.execute('''
        SELECT
          t.id AS id,
          t.name AS name,
          t.floor AS floorId,
          f.name AS floorName,
          CASE
            WHEN st.locked IS NOT NULL THEN 'reserved' -- Priority: Locked means Reserved
            WHEN t.occupied IS NOT NULL THEN 'occupied'
            WHEN st.id IS NOT NULL THEN 'occupied' -- Shared ticket exists but not locked (maybe legacy?)
            ELSE NULL
          END AS status,
          t.seats AS seats
        FROM places t
        LEFT JOIN floors f ON t.floor = f.id
        LEFT JOIN sharedtickets st ON st.id = t.id
        ORDER BY t.floor, t.name
      ''');

      final floorById = {for (final f in floors) f.id: f};

      return result.rows.map((row) {
        final floorId = row.colByName('floorId');
        final floor = floorId != null ? floorById[floorId] : null;
        return DiningTable(
          id: row.colByName('id') ?? '',
          name: row.colByName('name') ?? 'Table',
          floorId: floorId,
          floorName: row.colByName('floorName') ?? floor?.name,
          status: row.colByName('status'),
          seats: int.tryParse(row.colByName('seats') ?? ''),
        );
      }).toList();
    } catch (_) {
      // Fallback query if the join fails due to schema differences
      try {
        final result = await conn.execute('''
          SELECT
            id,
            name,
            floor AS floorId,
            CASE WHEN occupied IS NOT NULL THEN 'occupied' ELSE NULL END AS status
          FROM places
          ORDER BY floor, name
        ''');

        return result.rows.map((row) {
          return DiningTable(
            id: row.colByName('id') ?? '',
            name: row.colByName('name') ?? 'Table',
            floorId: row.colByName('floorId'),
            floorName: row.colByName('floorId'),
            status: row.colByName('status'),
          );
        }).toList();
      } catch (_) {
        final result = await conn.execute(
          '''
          SELECT id, name,
                 CASE WHEN occupied IS NOT NULL THEN 'occupied' ELSE NULL END AS status
          FROM places
          ORDER BY name
          ''',
        );

        return result.rows.map((row) {
          return DiningTable(
            id: row.colByName('id') ?? '',
            name: row.colByName('name') ?? 'Table',
            status: row.colByName('status'),
          );
        }).toList();
      }
    }
  }

  /// Attempts to update the status of a place. If the column doesn't exist,
  /// this will silently fail without throwing.
  static Future<void> setPlaceStatus({
    required String placeId,
    required String status,
  }) async {
    final conn = await DatabaseService.openConfiguredConnection();
    try {
      final escId = placeId.replaceAll("'", "\\'");
      final escStatus = status.replaceAll("'", "\\'");
      // Attempt to set status, occupied timestamp, and reset ready; ignore if columns are missing
      try {
        await conn.execute(
            "UPDATE places SET status='$escStatus', occupied=NOW(), ready=FALSE WHERE id='$escId'");
      } catch (_) {
        try {
          await conn.execute(
              "UPDATE places SET status='$escStatus', occupied=NOW() WHERE id='$escId'");
        } catch (_) {
          await conn.execute(
              "UPDATE places SET status='$escStatus' WHERE id='$escId'");
        }
      }
    } catch (_) {
      // Ignore schema mismatch
    } finally {
      await conn.close();
    }
  }

  /// Clears status/occupied for a place (marks it free). Best-effort, ignores
  /// schema mismatches.
  static Future<void> clearPlaceStatus({required String placeId}) async {
    final conn = await DatabaseService.openConfiguredConnection();
    try {
      final escId = placeId.replaceAll("'", "\\'");
      try {
        await conn.execute(
            "UPDATE places SET status=NULL, occupied=NULL, ready=FALSE, ticketid=NULL, waiter=NULL WHERE id='$escId'");
      } catch (_) {
        try {
          await conn.execute(
              "UPDATE places SET status=NULL, occupied=NULL, ticketid=NULL, waiter=NULL WHERE id='$escId'");
        } catch (_) {
          await conn.execute(
              "UPDATE places SET status=NULL, ticketid=NULL, waiter=NULL WHERE id='$escId'");
        }
      }
    } catch (_) {
      // ignore
    } finally {
      await conn.close();
    }
  }

  /// Marks a place as occupied and stores ticket/waiter metadata directly on `places`.
  static Future<void> markPlaceOccupied({
    required String placeId,
    required String ticketId,
    String? waiterName,
  }) async {
    final conn = await DatabaseService.openConfiguredConnection();
    try {
      final escId = placeId.replaceAll("'", "\\'");
      final escTicket = ticketId.replaceAll("'", "\\'");
      final escWaiter = (waiterName ?? '').replaceAll("'", "\\'");
      final waiterValue = escWaiter.isEmpty ? 'Waiter' : escWaiter;
      try {
        await conn.execute(
            "UPDATE places SET occupied=NOW(), ready=FALSE, ticketid='$escTicket', waiter='$waiterValue' WHERE id='$escId'");
      } catch (e) {
        print('DB: Error in markPlaceOccupied: $e');
        // Fallback without ready column
        try {
           await conn.execute(
              "UPDATE places SET occupied=NOW(), ticketid='$escTicket', waiter='$waiterValue' WHERE id='$escId'");
           print('DB: markPlaceOccupied fallback success');
        } catch (e2) {
           print('DB: markPlaceOccupied fallback failed: $e2');
        }
      }
    } catch (e) {
      print('DB: Critical error in markPlaceOccupied: $e');
    } finally {
      await conn.close();
    }
  }
}
