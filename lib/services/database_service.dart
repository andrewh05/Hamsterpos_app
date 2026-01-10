import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'package:mysql_client/mysql_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DatabaseService {
  /// Quick TCP reachability probe before attempting MySQL handshake
  static Future<void> probeReachability({
    required String host,
    required int port,
    Duration timeout = const Duration(seconds: 4),
  }) async {
    try {
      final socket = await Socket.connect(host, port, timeout: timeout);
      await socket.close();
      socket.destroy();
    } on SocketException catch (e) {
      // Map common network errors to clearer messages
      if (e.osError?.message.toLowerCase().contains('no route to host') ==
          true) {
        throw Exception(
          'Host unreachable. Ensure your device and the server are on the same network, '
          'the MySQL port ($port) is open, and the server IP ($host) is correct.',
        );
      }
      if (e.osError?.message.toLowerCase().contains('connection refused') ==
          true) {
        throw Exception(
          'Connection refused. The MySQL service may not be listening on port $port, '
          'or a firewall is blocking it.',
        );
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      rethrow;
    }
  }

  /// Create a fresh MySQL connection
  /// Load connection config from saved preferences
  static Future<Map<String, String>> _loadConfig({String? database}) async {
    final prefs = await SharedPreferences.getInstance();
    final host = prefs.getString('server_ip');
    final portStr = prefs.getString('server_port');
    final user = prefs.getString('mysql_user');
    final password = prefs.getString('mysql_password');
    final db = database ?? prefs.getString('selected_database');

    if (host == null || portStr == null || user == null || db == null) {
      throw Exception(
          'Database configuration is incomplete. Please set server, port, user, and database.');
    }

    return {
      'host': host,
      'port': portStr,
      'user': user,
      'password': password ?? '',
      'db': db,
    };
  }

  /// Open a MySQL connection using saved preferences
  static Future<MySQLConnection> openConfiguredConnection(
      {String? database}) async {
    final cfg = await _loadConfig(database: database);
    final port = int.tryParse(cfg['port']!) ?? 3306;

    await probeReachability(host: cfg['host']!, port: port);

    final conn = await MySQLConnection.createConnection(
      host: cfg['host']!,
      port: port,
      userName: cfg['user']!,
      password: cfg['password']!,
      databaseName: cfg['db'],
      secure: false, // Disable SSL to avoid handshake issues on non-SSL servers
    );

    await conn.connect();
    return conn;
  }

  static Future<MySQLConnection> _createConnection({
    required String host,
    required int port,
    required String user,
    required String password,
    String? databaseName,
  }) async {
    return await MySQLConnection.createConnection(
      host: host,
      port: port,
      userName: user,
      password: password,
      databaseName: databaseName,
      secure: false, // Set to true if using SSL
    ).timeout(const Duration(seconds: 10));
  }

  /// Connect to MySQL server and return list of databases
  static Future<List<String>> getAvailableDatabases({
    required String host,
    required int port,
    required String user,
    required String password,
  }) async {
    MySQLConnection? conn;

    try {
      // Preflight reachability to provide clearer feedback
      await probeReachability(host: host, port: port);

      // Create connection
      conn = await _createConnection(
        host: host,
        port: port,
        user: user,
        password: password,
      );

      // Connect to the server
      await conn.connect();

      // Query to get all databases
      final result = await conn.execute('SHOW DATABASES');
      final databases = <String>[];

      for (var row in result.rows) {
        databases.add(row.colAt(0) ?? '');
      }

      return databases;
    } on TimeoutException {
      throw Exception(
          'Connection timed out. Check network and firewall settings.');
    } on SocketException catch (e) {
      final msg = e.osError?.message.toLowerCase() ?? e.message.toLowerCase();
      if (msg.contains('broken pipe')) {
        throw Exception(
            'Connection dropped by server (broken pipe). Verify MySQL is reachable and not closing connections due to firewall or auth issues.');
      }
      if (msg.contains('connection reset')) {
        throw Exception(
            'Connection reset by peer. Server closed the connection unexpectedly—check credentials and server SSL/auth settings.');
      }
      throw Exception('Network error: ${e.message}');
    } catch (e) {
      throw Exception('Failed to connect to database: $e');
    } finally {
      // Always close the connection
      if (conn != null) {
        try {
          await conn.close();
        } catch (_) {
          // Ignore cleanup errors
        }
      }
    }
  }

  /// Close the database connection (kept for compatibility)
  static Future<void> closeConnection() async {
    // No-op: connections are now always closed after use
  }

  /// Test the connection
  static Future<bool> testConnection({
    required String host,
    required int port,
    required String user,
    required String password,
  }) async {
    MySQLConnection? conn;

    try {
      await probeReachability(host: host, port: port);

      conn = await _createConnection(
        host: host,
        port: port,
        user: user,
        password: password,
      );

      await conn.connect();

      // Perform a simple query to verify the connection works
      await conn.execute('SELECT 1');

      return true;
    } catch (e) {
      return false;
    } finally {
      if (conn != null) {
        try {
          await conn.close();
        } catch (_) {}
      }
    }
  }

  /// Save cart items to ticketlines table
  /// This matches the SQL schema: ticket, line, product, attributesetinstance_id,
  /// units, price, taxid, attributes, sku, price_level
  static Future<void> saveTicketLines({
    required String ticketId,
    required List<dynamic> cartItems,
    required String defaultTaxId,
  }) async {
    final conn = await openConfiguredConnection();
    try {
      String esc(String s) => s.replaceAll("'", "\\'");

      for (int i = 0; i < cartItems.length; i++) {
        final item = cartItems[i];
        final lineNumber = i;

        // Extract cart item properties
        final productId = item['menuItem']['id'] ?? item['id'];
        final units = item['quantity'] ?? 1;
        final price = item['menuItem']['price'] ?? item['price'] ?? 0.0;
        final sku = item['sku'] ?? '';
        final priceLevel = item['priceLevel'] ?? 0;
        final notes = item['notes'];
        final attributeSetInstanceId = item['attributeSetInstanceId'];

        // Build attributes blob (can include notes/modifiers)
        final attributesBlob = notes != null ? "'${esc(notes)}'" : 'NULL';
        final attrSetId = attributeSetInstanceId != null
            ? "'${esc(attributeSetInstanceId)}'"
            : 'NULL';

        final sql = """
          INSERT INTO ticketlines (
            TICKET, LINE, PRODUCT, ATTRIBUTESETINSTANCE_ID,
            UNITS, PRICE, TAXID, ATTRIBUTES, sku, PRICE_LEVEL
          ) VALUES (
            '${esc(ticketId)}',
            $lineNumber,
            '${esc(productId)}',
            $attrSetId,
            $units,
            $price,
            '${esc(defaultTaxId)}',
            $attributesBlob,
            '${esc(sku)}',
            $priceLevel
          )
        """;

        await conn.execute(sql);
      }
    } finally {
      await conn.close();
    }
  }

  /// Delete ticket lines for a given ticket
  static Future<void> deleteTicketLines(String ticketId) async {
    final conn = await openConfiguredConnection();
    try {
      String esc(String s) => s.replaceAll("'", "\\'");
      await conn
          .execute("DELETE FROM ticketlines WHERE TICKET='${esc(ticketId)}'");
    } finally {
      await conn.close();
    }
  }

  /// Get or create an open cash session
  static Future<String> getOrCreateOpenCashSession({
    String? host,
  }) async {
    final conn = await openConfiguredConnection();
    try {
      String esc(String s) => s.replaceAll("'", "\\'");
      final hostname = host ?? 'POS-${DateTime.now().millisecondsSinceEpoch}';

      // Try to find an open cash session (dateend is NULL)
      final openSession = await conn.execute(
          "SELECT money FROM closedcash WHERE dateend IS NULL ORDER BY datestart DESC LIMIT 1");

      if (openSession.rows.isNotEmpty) {
        return openSession.rows.first.colAt(0) ?? '';
      }

      // If no open session, try to get the most recent closed session
      final lastSession = await conn.execute(
          "SELECT money FROM closedcash ORDER BY datestart DESC LIMIT 1");

      if (lastSession.rows.isNotEmpty) {
        return lastSession.rows.first.colAt(0) ?? '';
      }

      // If no session exists at all, create a new one
      final now =
          DateTime.now().toIso8601String().split('.')[0].replaceAll('T', ' ');
      final moneyId = 'CASH-${DateTime.now().millisecondsSinceEpoch}';

      // Get next hostsequence
      final seqResult = await conn.execute(
          "SELECT COALESCE(MAX(hostsequence), 0) + 1 as nextseq FROM closedcash WHERE host='${esc(hostname)}'");
      final hostsequence = seqResult.rows.first.colAt(0) ?? 1;

      await conn.execute("""
        INSERT INTO closedcash (money, host, hostsequence, datestart, nosales)
        VALUES (
          '${esc(moneyId)}',
          '${esc(hostname)}',
          $hostsequence,
          '$now',
          0
        )
      """);

      return moneyId;
    } finally {
      await conn.close();
    }
  }

  /// Create or update a receipt record
  static Future<void> createReceipt({
    required String receiptId,
    String? personId,
  }) async {
    final conn = await openConfiguredConnection();
    try {
      String esc(String s) => s.replaceAll("'", "\\'");
      final now =
          DateTime.now().toIso8601String().split('.')[0].replaceAll('T', ' ');

      // Check if receipt exists
      final check = await conn.execute(
          "SELECT id FROM receipts WHERE id='${esc(receiptId)}' LIMIT 1");

      if (check.rows.isEmpty) {
        // Get or create a valid money (closedcash) session
        final moneyId = await getOrCreateOpenCashSession();

        // Create new receipt
        await conn.execute("""
          INSERT INTO receipts (id, money, datenew, person)
          VALUES (
            '${esc(receiptId)}',
            '${esc(moneyId)}',
            '$now',
            ${personId != null ? "'${esc(personId)}'" : 'NULL'}
          )
        """);
      }
    } finally {
      await conn.close();
    }
  }

  /// Get a valid person ID from the people table (returns first active user)
  static Future<String?> getValidPersonId() async {
    final conn = await openConfiguredConnection();
    try {
      // Try to get any active person
      final result =
          await conn.execute("SELECT id FROM people WHERE visible=1 LIMIT 1");
      if (result.rows.isNotEmpty) {
        return result.rows.first.colAt(0) as String?;
      }

      // If no active person, get any person
      final anyPerson = await conn.execute("SELECT id FROM people LIMIT 1");
      if (anyPerson.rows.isNotEmpty) {
        return anyPerson.rows.first.colAt(0) as String?;
      }

      return null;
    } finally {
      await conn.close();
    }
  }

  /// Get next ticket number for a given ticket type
  static Future<int> getNextTicketNumber(int ticketType) async {
    final conn = await openConfiguredConnection();
    try {
      // Get the maximum ticketid for this tickettype and add 1
      final result = await conn.execute(
          "SELECT COALESCE(MAX(ticketid), 0) + 1 as nextid FROM tickets WHERE tickettype=$ticketType");
      final value = result.rows.first.colAt(0);
      if (value is int) {
        return value as int;
      }
      if (value is String) {
        return int.tryParse(value) ?? 1;
      }
      return 1;
    } finally {
      await conn.close();
    }
  }

  /// Create or update a ticket record
  static Future<void> createTicket({
    required String ticketId,
    required String personId,
    String? customerId,
    String? placeId,
    int ticketType = 0,
    int? ticketNumber,
  }) async {
    final conn = await openConfiguredConnection();
    try {
      String esc(String s) => s.replaceAll("'", "\\'");

      // Check if ticket exists
      final check = await conn.execute(
          "SELECT id FROM tickets WHERE id='${esc(ticketId)}' LIMIT 1");

      if (check.rows.isEmpty) {
        // Get next ticket number if not provided
        final ticketNum = ticketNumber ?? await getNextTicketNumber(ticketType);

        // Create new ticket
        await conn.execute("""
          INSERT INTO tickets (
            id, tickettype, ticketid, person, customer, status, place_id
          ) VALUES (
            '${esc(ticketId)}',
            $ticketType,
            $ticketNum,
            '${esc(personId)}',
            ${customerId != null ? "'${esc(customerId)}'" : 'NULL'},
            0,
            ${placeId != null ? "'${esc(placeId)}'" : 'NULL'}
          )
        """);
      }
    } finally {
      await conn.close();
    }
  }

  /// Save a single cart item to ticketlines (for incremental saves)
  static Future<void> saveCartItem({
    required String ticketId,
    required String productId,
    required int line,
    required double units,
    required double price,
    required String taxId,
    String? sku,
    String? notes,
    String? attributeSetInstanceId,
    int priceLevel = 0,
  }) async {
    final conn = await openConfiguredConnection();
    try {
      String esc(String s) => s.replaceAll("'", "\\'");

      // Delete existing line if it exists
      await conn.execute(
          "DELETE FROM ticketlines WHERE TICKET='${esc(ticketId)}' AND LINE=$line");

      final attributesBlob = notes != null ? "'${esc(notes)}'" : 'NULL';
      final attrSetId = attributeSetInstanceId != null
          ? "'${esc(attributeSetInstanceId)}'"
          : 'NULL';

      final sql = """
        INSERT INTO ticketlines (
          TICKET, LINE, PRODUCT, ATTRIBUTESETINSTANCE_ID,
          UNITS, PRICE, TAXID, ATTRIBUTES, sku, PRICE_LEVEL
        ) VALUES (
          '${esc(ticketId)}',
          $line,
          '${esc(productId)}',
          $attrSetId,
          $units,
          $price,
          '${esc(taxId)}',
          $attributesBlob,
          '${esc(sku ?? '')}',
          $priceLevel
        )
      """;

      await conn.execute(sql);
    } finally {
      await conn.close();
    }
  }

  /// Get existing ticket ID for a table
  static Future<String?> getExistingTicketForTable(String placeId) async {
    final conn = await openConfiguredConnection();
    try {
      String esc(String s) => s.replaceAll("'", "\\'");

      // Check if table has an active ticket (status = 0 means open)
      final result = await conn.execute("""
        SELECT t.id 
        FROM tickets t
        WHERE t.place_id = '${esc(placeId)}' 
        AND t.status = 0
        ORDER BY t.ticketid DESC
        LIMIT 1
      """);

      if (result.rows.isNotEmpty) {
        return result.rows.first.colAt(0) as String?;
      }

      return null;
    } finally {
      await conn.close();
    }
  }

  /// Load ticket lines for a given ticket
  static Future<List<Map<String, dynamic>>> loadTicketLines(
      String ticketId) async {
    final conn = await openConfiguredConnection();
    try {
      String esc(String s) => s.replaceAll("'", "\\'");

      final result = await conn.execute("""
        SELECT 
          tl.TICKET,
          tl.LINE,
          tl.PRODUCT,
          tl.UNITS,
          tl.PRICE,
          tl.TAXID,
          tl.ATTRIBUTES,
          tl.sku,
          tl.PRICE_LEVEL,
          p.name as product_name,
          p.code as product_code
        FROM ticketlines tl
        LEFT JOIN products p ON tl.PRODUCT = p.id
        WHERE tl.TICKET = '${esc(ticketId)}'
        ORDER BY tl.LINE
      """);

      return result.rows.map((row) {
        return {
          'ticket': row.colByName('TICKET'),
          'line': row.colByName('LINE'),
          'productId': row.colByName('PRODUCT'),
          'productName': row.colByName('product_name'),
          'productCode': row.colByName('product_code'),
          'units': row.colByName('UNITS'),
          'price': row.colByName('PRICE'),
          'taxId': row.colByName('TAXID'),
          'attributes': row.colByName('ATTRIBUTES'),
          'sku': row.colByName('sku'),
          'priceLevel': row.colByName('PRICE_LEVEL'),
        };
      }).toList();
    } finally {
      await conn.close();
    }
  }

  /// Debug method to inspect sharedtickets content for a table
  static Future<void> debugShowSharedTicketContent(String tableId) async {
    MySQLConnection? conn;
    try {
      conn = await openConfiguredConnection();
      final rs = await conn.execute(
        "SELECT id, name, content FROM sharedtickets WHERE id=:id LIMIT 1",
        {'id': tableId},
      );

      if (rs.rows.isEmpty) {
        print('❌ No shared ticket found for table: $tableId');
        return;
      }

      final row = rs.rows.first;
      final id = row.colAt(0);
      final name = row.colAt(1);
      final Object? content = row.colAt(2);

      print('\n✅ Found shared ticket for table: $id');
      print('📝 Name: $name');
      print('📦 Content type: ${content.runtimeType}');

      if (content is List<int>) {
        print('📊 Content length: ${content.length} bytes');

        // Show first 64 bytes as preview
        final preview = content.length > 64 ? content.sublist(0, 64) : content;
        print('🔍 First bytes: $preview');

        // Try to decode as UTF-8
        try {
          final jsonStr = utf8.decode(content);
          print('📄 UTF-8 decoded successfully (${jsonStr.length} chars)');

          final data = jsonDecode(jsonStr);
          print('\n🛒 Parsed JSON (type=${data.runtimeType}):');

          if (data is Map) {
            print('   Total: \$${data['total']}');
            print('   Items count: ${(data['items'] as List?)?.length ?? 0}');
            if (data['items'] is List) {
              for (int i = 0; i < (data['items'] as List).length; i++) {
                final item = (data['items'] as List)[i];
                print(
                    '   [$i] ${item['name']} x${item['qty']} @ \$${item['price']}');
              }
            }
          } else if (data is List) {
            print('   Items count: ${data.length}');
            for (int i = 0; i < data.length; i++) {
              final item = data[i];
              if (item is Map) {
                print(
                    '   [$i] ${item['name']} x${item['qty']} @ \$${item['price']}');
              } else {
                print('   [$i] Product ID: $item');
              }
            }
          }
        } catch (e) {
          print('❌ UTF-8 decode failed: $e');

          // Try base64
          try {
            final base64Str = utf8.decode(content);
            final decodedBytes = base64.decode(base64Str);
            final jsonStr = utf8.decode(decodedBytes);
            final data = jsonDecode(jsonStr);
            print(
                '✅ Decoded as base64! Parsed JSON (type=${data.runtimeType})');
          } catch (e2) {
            print('❌ Base64 decode also failed: $e2');
          }
        }
      } else if (content is String) {
        print('📊 Content length: ${content.length} chars');
        print(
            '� First 100 chars: ${content.length > 100 ? content.substring(0, 100) : content}');

        try {
          final data = jsonDecode(content);
          print('\n🛒 Parsed JSON (type=${data.runtimeType}):');

          if (data is Map) {
            print('   Total: \$${data['total']}');
            print('   Items count: ${(data['items'] as List?)?.length ?? 0}');
            if (data['items'] is List) {
              for (int i = 0; i < (data['items'] as List).length; i++) {
                final item = (data['items'] as List)[i];
                if (item is Map) {
                  print(
                      '   [$i] ${item['name']} x${item['qty']} @ \$${item['price']}');
                } else {
                  print('   [$i] Product ID: $item');
                }
              }
            }
          } else if (data is List) {
            print('   Items count: ${data.length}');
            for (int i = 0; i < data.length; i++) {
              final item = data[i];
              if (item is Map) {
                print(
                    '   [$i] ${item['name']} x${item['qty']} @ \$${item['price']}');
              } else {
                print('   [$i] Product ID: $item');
              }
            }
          }
        } catch (e) {
          print('❌ Direct JSON parse failed: $e');

          // Try base64
          try {
            final decodedBytes = base64.decode(content);
            final jsonStr = utf8.decode(decodedBytes);
            final data = jsonDecode(jsonStr);
            print(
                '✅ Decoded as base64! Parsed JSON (type=${data.runtimeType})');
          } catch (e2) {
            print('❌ Base64 decode also failed: $e2');
          }
        }
      } else {
        print('⚠️  Unexpected content type, cannot parse');
      }
    } catch (e) {
      print('❌ Error reading sharedtickets: $e');
    } finally {
      if (conn != null) {
        try {
          await conn.close();
        } catch (_) {}
      }
    }
  }

  /// Create a new cart
  static Future<void> createCart({
    required String cartId,
    String? userId,
    String? customerId,
    String? customerName,
  }) async {
    final conn = await openConfiguredConnection();
    try {
      String esc(String s) => s.replaceAll("'", "\\'");
      final now = DateTime.now().toIso8601String().split('.')[0].replaceAll('T', ' ');

      await conn.execute("""
        INSERT IGNORE INTO cart (
          id, user_id, customer_id, customer_name, 
          created_date, updated_date, modified_date,
          status, total, subtotal, tax, discount
        ) VALUES (
          '${esc(cartId)}',
          ${userId != null ? "'${esc(userId)}'" : 'NULL'},
          ${customerId != null ? "'${esc(customerId)}'" : 'NULL'},
          ${customerName != null ? "'${esc(customerName)}'" : 'NULL'},
          '$now', '$now', '$now',
          'open', 0, 0, 0, 0
        )
      """);
      print('DB: Created cart $cartId (if not existed)');
      print('DB: Created cart $cartId');
    } catch (e) {
      print('DB: Error creating cart: $e');
      rethrow;
    } finally {
      await conn.close();
    }
  }

  /// Save a cart line (upsert based on cart_id and line_number)
  static Future<void> saveCartLine({
    required String cartId,
    required int lineNumber, // This is the unique line index (0, 1, 2...)
    required String productId,
    required String productName,
    required double quantity,
    required double price,
    double unitPrice = 0.0,
    double taxRate = 0.0,
    double discount = 0.0,
    String? taxId,
    String? attributes,
    String? productRef, // Added productRef
  }) async {
    final conn = await openConfiguredConnection();
    try {
      String esc(String s) => s.replaceAll("'", "\\'");
      final lineId = "${cartId}_$lineNumber";
      final now = DateTime.now().toIso8601String().split('.')[0].replaceAll('T', ' ');

      // Calculate totals
      final subtotal = (price * quantity);
      final taxAmount = subtotal * (taxRate / 100);
      final total = subtotal + taxAmount;

      final attrBlob = attributes != null ? "'${esc(attributes)}'" : 'NULL';
      final prodRef = productRef != null ? "'${esc(productRef)}'" : 'NULL';

      // Lazy creation: Ensure cart exists before inserting line
      try {
        print('DB: Ensuring cart $cartId exists before saving line $lineNumber');
        await conn.execute("""
          INSERT INTO cart (id, status, created_date, updated_date, modified_date, total, subtotal, tax, discount)
          VALUES ('${esc(cartId)}', 'open', '$now', '$now', '$now', 0, 0, 0, 0)
          ON DUPLICATE KEY UPDATE updated_date = '$now'
        """);
      } catch (e) {
        print('DB: Error ensuring parent cart exists: $e');
        // If this fails, the next insert will likely fail with FK error, but we want to know WHY this failed
      }

      // Use upsert pattern

      // Use upsert pattern
      // Use upsert pattern
      try {
        await conn.execute("""
          INSERT INTO cartlines (
            id, cart_id, line_number, line_num,
            product_id, product_name, product_ref,
            quantity, price, unit_price,
            tax_rate, tax_amount, discount,
            subtotal, total, attributes,
            created_date, updated_date
          ) VALUES (
            '${esc(lineId)}', '${esc(cartId)}', $lineNumber, $lineNumber,
            '${esc(productId)}', '${esc(productName)}', $prodRef,
            $quantity, $price, ${unitPrice == 0 ? price : unitPrice},
            $taxRate, $taxAmount, $discount,
            $subtotal, $total, $attrBlob,
            '$now', '$now'
          ) AS new_values
          ON DUPLICATE KEY UPDATE
            quantity = new_values.quantity,
            price = new_values.price,
            subtotal = new_values.subtotal,
            total = new_values.total,
            attributes = new_values.attributes,
            updated_date = new_values.updated_date,
            product_ref = new_values.product_ref
        """);
      } catch (e) {
        print('DB: Critical error saving cartline $lineId: $e');
        rethrow;
      }
      
      // Update cart totals
      await conn.execute("""
        UPDATE cart c 
        SET 
          c.subtotal = (SELECT COALESCE(SUM(cl.subtotal), 0) FROM cartlines cl WHERE cl.cart_id = c.id),
          c.tax = (SELECT COALESCE(SUM(cl.tax_amount), 0) FROM cartlines cl WHERE cl.cart_id = c.id),
          c.total = (SELECT COALESCE(SUM(cl.total), 0) FROM cartlines cl WHERE cl.cart_id = c.id),
          c.updated_date = '$now'
        WHERE c.id = '${esc(cartId)}'
      """);

    } finally {
      await conn.close();
    }
  }

  /// Load cart lines for a given cart ID
  static Future<List<Map<String, dynamic>>> loadCartLines(String cartId) async {
    final conn = await openConfiguredConnection();
    try {
      String esc(String s) => s.replaceAll("'", "\\'");

      final result = await conn.execute("""
        SELECT 
          cl.line_number,
          cl.product_id,
          cl.product_name,
          cl.quantity,
          cl.price,
          cl.attributes
        FROM cartlines cl
        WHERE cl.cart_id = '${esc(cartId)}'
        ORDER BY cl.line_number
      """);

      return result.rows.map((row) {
        return {
          'lineNumber': row.colByName('line_number'),
          'productId': row.colByName('product_id'),
          'productName': row.colByName('product_name'),
          'quantity': row.colByName('quantity'),
          'price': row.colByName('price'),
          'attributes': row.colByName('attributes'),
        };
      }).toList();
    } finally {
      await conn.close();
    }
  }

  /// Get active cart ID for a table (checking sharedtickets table)
  static Future<String?> getOpenCartForTable(String tableId) async {
    final conn = await openConfiguredConnection();
    try {
      String esc(String s) => s.replaceAll("'", "\\'");

      // Check sharedtickets for this table
      final result = await conn.execute("""
        SELECT cart_id 
        FROM sharedtickets 
        WHERE id = '${esc(tableId)}'
      """);

      if (result.rows.isNotEmpty) {
        final cartId = result.rows.first.colByName('cart_id');
        print('DB: Found sharedticket for table $tableId, cart_id: $cartId');
        
        if (cartId != null && cartId.toString().isNotEmpty) {
           return cartId.toString();
        }
      } else {
        print('DB: No sharedticket found for table $tableId');
      }
      return null;
    } catch (e) {
      print('DB: Error in getOpenCartForTable: $e');
      return null;
    } finally {
      await conn.close();
    }
  }

  /// Link a cart to a table using sharedtickets
  static Future<void> linkCartToTable({
    required String tableId,
    required String tableName,
    required String cartId,
  }) async {
    final conn = await openConfiguredConnection();
    try {
      String esc(String s) => s.replaceAll("'", "\\'");
      
      // Upsert into sharedtickets
      // We use ticket_type = 'general' as default
      await conn.execute("""
        INSERT INTO sharedtickets (
          id, name, cart_id, ticket_type, locked
        ) VALUES (
          '${esc(tableId)}', 
          '${esc(tableName)}', 
          '${esc(cartId)}', 
          'general',
          'locked'
        )
        ON DUPLICATE KEY UPDATE
          cart_id = '${esc(cartId)}',
          name = '${esc(tableName)}',
          locked = 'locked'
      """);
      
      print('DB: Linked cart $cartId to table $tableId in sharedtickets');
  } catch (e) {
    print('DB: Error linking cart to table: $e');
    rethrow;
  } finally {
    await conn.close();
  }
}

/// Lock a table (set sharedtickets.locked = 'locked')
static Future<void> lockTable(String tableId) async {
  final conn = await openConfiguredConnection();
  try {
    String esc(String s) => s.replaceAll("'", "\\'");
    await conn.execute("UPDATE sharedtickets SET locked = 'locked' WHERE id = '${esc(tableId)}'");
    print('DB: Locked table $tableId');
  } catch (e) {
    print('DB: Error locking table: $e');
  } finally {
    await conn.close();
  }
}

/// Unlock a table (set sharedtickets.locked = NULL)
  static Future<void> unlockTable(String tableId) async {
    final conn = await openConfiguredConnection();
    try {
      String esc(String s) => s.replaceAll("'", "\\'");
      final result = await conn.execute("UPDATE sharedtickets SET locked = NULL WHERE id = '${esc(tableId)}'");
      print('DB: Unlocked table $tableId. Affected rows: ${result.affectedRows}');
    } catch (e) {
      print('DB: Error unlocking table: $e');
    } finally {
      await conn.close();
    }
  }
}
