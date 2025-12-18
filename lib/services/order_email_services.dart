import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Data model for an item in the order.
/// Map your food API product fields to this model.
class CartItem {
  final String id;
  final String name;
  final int quantity;
  final double price;
  final String imageUrl; // HTTPS URL to the product image

  CartItem({
    required this.id,
    required this.name,
    required this.quantity,
    required this.price,
    required this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "qty": quantity,
    "price": price,
    "imageUrl": imageUrl,
  };
}

/// Service to send the order details and item images to Supabase Edge Function.
/// - If Verify JWT is OFF on the function, no Authorization header is needed.
/// - If Verify JWT is ON, set [authorizationBearer] to a valid token.
class OrderEmailService {
  OrderEmailService({
    required this.functionUrl,
    this.authorizationBearer,
    this.timeout = const Duration(seconds: 20),
  });

  /// Your Supabase Edge Function URL (e.g., https://<project-ref>.functions.supabase.co/send-order-email)
  final String functionUrl;

  /// Optional: Provide "Bearer <TOKEN>" if you enabled Verify JWT on the function.
  final String? authorizationBearer;

  /// HTTP timeout
  final Duration timeout;

  /// Sends the order email with full details and item images.
  ///
  /// Throws [OrderEmailException] with details on failure.
  Future<void> sendOrder({
    required String orderId,
    required String customerName,
    required String customerEmail,
    String? customerPhone,
    required String address,
    required List<CartItem> items,
    required double subtotal,
    required double delivery,
    required double discount,
    required double total,
    String payment = "Cash on Delivery",
    String notes = "",
  }) async {
    if (!functionUrl.startsWith("https://")) {
      throw OrderEmailException("Invalid function URL: must be https.");
    }

    // Basic validation to avoid 400 Bad Request
    if (orderId.isEmpty) {
      throw OrderEmailException("orderId cannot be empty.");
    }
    if (customerName.isEmpty || customerEmail.isEmpty) {
      throw OrderEmailException("customerName and customerEmail are required.");
    }
    if (items.isEmpty) {
      throw OrderEmailException("items cannot be empty.");
    }

    final url = Uri.parse(functionUrl);
    final body = {
      "orderId": orderId,
      "customer": {
        "name": customerName,
        "email": customerEmail,
        "phone": customerPhone ?? ""
      },
      "address": address,
      "items": items.map((it) => it.toJson()).toList(),
      "totals": {
        "subtotal": subtotal,
        "delivery": delivery,
        "discount": discount,
        "total": total,
      },
      "payment": payment,
      "notes": notes,
    };

    final headers = <String, String>{
      "Content-Type": "application/json",
      if (authorizationBearer != null && authorizationBearer!.isNotEmpty)
        "Authorization": authorizationBearer!,
    };

    http.Response res;
    try {
      res = await http
          .post(
        url,
        headers: headers,
        body: jsonEncode(body),
      )
          .timeout(timeout);
    } on SocketException catch (e) {
      throw OrderEmailException("Network error: ${e.message}");
    } on HttpException catch (e) {
      throw OrderEmailException("HTTP error: ${e.message}");
    } on FormatException catch (e) {
      throw OrderEmailException("Bad response format: ${e.message}");
    } on Exception catch (e) {
      throw OrderEmailException("Unexpected error: $e");
    }

    // Helpful diagnostics
    if (res.statusCode != 200) {
      final reason = "status=${res.statusCode} body=${res.body}";
      // Common causes:
      // 400: Your JSON is invalid or missing fields; or function throws "bad request".
      // 500: Mailjet error (invalid FROM_EMAIL, bad API key, deliverability block).
      throw OrderEmailException("Email send failed: $reason");
    }
  }
}

class OrderEmailException implements Exception {
  final String message;
  OrderEmailException(this.message);

  @override
  String toString() => "OrderEmailException: $message";
}