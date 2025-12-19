import 'package:flutter/material.dart';
import '../services/order_email_services.dart';

/// Replace this with your actual project-ref edge function URL.
/// Ensure Verify JWT is OFF (simple) OR pass a valid bearer token below.
const kFunctionUrl =
    "https://bnjsobwbolnytncquuif.functions.supabase.co/send-order-email";

// If you enable Verify JWT, set:
// const kAuthorizationBearer = "Bearer <YOUR_VALID_TOKEN>";
const String? kAuthorizationBearer = null;

// Demo items (replace with your real cart data mapped to CartItem).
final demoItems = <CartItem>[
  CartItem(
    id: "p1",
    name: "Margherita Pizza",
    quantity: 2,
    price: 12.5,
    imageUrl:
    "https://images.unsplash.com/photo-1601924582971-b4976e4f9f6d?w=800&q=80",
  ),
  CartItem(
    id: "p2",
    name: "Cheeseburger",
    quantity: 1,
    price: 8.0,
    imageUrl:
    "https://images.unsplash.com/photo-1550547660-d9450f859349?w=800&q=80",
  ),
];

class CheckoutPage extends StatefulWidget {
  const CheckoutPage({super.key});

  @override
  State<CheckoutPage> createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  bool _sending = false;

  late final service = OrderEmailService(
    functionUrl: kFunctionUrl,
    authorizationBearer: kAuthorizationBearer,
  );

  // Compute totals from demo items. Replace with your cart logic.
  double get subtotal =>
      demoItems.fold(0.0, (sum, it) => sum + (it.price * it.quantity));
  double get delivery => 2.0;
  double get discount => 0.0;
  double get total => subtotal + delivery - discount;

  Future<void> _sendOrder() async {
    setState(() => _sending = true);
    try {
      await service.sendOrder(
        orderId: DateTime.now().millisecondsSinceEpoch.toString(),
        customerName: "John Doe", // replace with actual user name
        customerEmail: "john@example.com", // replace with actual user email
        customerPhone: "1234567890",
        address: "123 Main St, City",
        items: demoItems, // map your real cart items here
        subtotal: subtotal,
        delivery: delivery,
        discount: discount,
        total: total,
        payment: "Cash on Delivery",
        notes: "Leave at the door.",
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Order email sent successfully")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Failed to send order: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s1 = Theme.of(context).textTheme.bodyMedium!;
    final s2 =
    Theme.of(context).textTheme.titleMedium!.copyWith(fontWeight: FontWeight.bold);

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: demoItems.length,
                itemBuilder: (context, i) {
                  final it = demoItems[i];
                  return ListTile(
                    leading: Image.network(
                      it.imageUrl,
                      width: 56,
                      height: 56,
                      fit: BoxFit.cover,
                    ),
                    title: Text("${it.name} x${it.quantity}"),
                    subtitle: Text("\$${it.price.toStringAsFixed(2)} each"),
                  );
                },
              ),
            ),
            const SizedBox(height: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("Subtotal", style: s1), Text("\$${subtotal.toStringAsFixed(2)}", style: s1)],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("Delivery", style: s1), Text("\$${delivery.toStringAsFixed(2)}", style: s1)],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("Discount", style: s1), Text("-\$${discount.toStringAsFixed(2)}", style: s1)],
                ),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Text("Total", style: s2), Text("\$${total.toStringAsFixed(2)}", style: s2)],
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _sending ? null : _sendOrder,
                icon: _sending
                    ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Icon(Icons.send),
                label: Text(_sending ? "Sending..." : "Send Order"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}