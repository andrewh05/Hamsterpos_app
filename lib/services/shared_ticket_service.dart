import 'dart:convert';
import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:mysql_client/mysql_client.dart';
import '../models/dining_table.dart';
import '../models/cart_item.dart';
import 'database_service.dart';
import 'table_service.dart';

String _bytesAsciiPreview(Uint8List bytes) {
  final len = math.min(64, bytes.length);
  final sub = bytes.sublist(0, len);
  final sb = StringBuffer();
  for (final b in sub) {
    if (b >= 32 && b <= 126) {
      sb.write(String.fromCharCode(b));
    } else {
      sb.write('.');
    }
  }
  return sb.toString();
}

/// Normalizes JSON structure to always be a Map.
/// If root is a List (Java POS items array), wraps as {'items': data}.
/// If already a Map, returns as-is.
Map<String, dynamic>? _normalizeJsonStructure(dynamic parsed) {
  if (parsed is Map<String, dynamic>) {
    return parsed;
  } else if (parsed is List) {
    debugPrint(
        '[sharedtickets] Root is List, wrapping as items array (len=${parsed.length})');
    // Inspect first item to understand structure
    if (parsed.isNotEmpty) {
      final first = parsed[0];
      debugPrint(
          '[sharedtickets] First item type=${first.runtimeType}, value=$first');
    }
    return {'items': parsed};
  }
  debugPrint('[sharedtickets] Unexpected root type: ${parsed.runtimeType}');
  return null;
}

class SharedTicketService {
  
  /// Deletes any shared ticket for a given table id.
  static Future<void> deleteSharedTicket(String tableId) async {
    MySQLConnection? conn;
    try {
      conn = await DatabaseService.openConfiguredConnection();
      print('DB: Deleting shared ticket for $tableId');
      print('DB: Stack trace: ${StackTrace.current}');
      await conn.execute(
        "DELETE FROM sharedtickets WHERE id=:id",
        {'id': tableId},
      );
    } catch (e) {
      // rethrow; // logging is enough
      print('Error deleting shared ticket: $e');
    } finally {
      if (conn != null) {
        try {
          await conn.close();
        } catch (e) {
          // Ignore close errors
        }
      }
    }
  }
}
