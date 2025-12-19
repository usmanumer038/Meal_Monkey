import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:food_delivery/common/cart_service.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common/supabase_service.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:http/http.dart' as http;
import '../../common/notification_service.dart';
import 'checkout_message_view.dart';
import 'change_address_view.dart';

class CheckoutView extends StatefulWidget {
  const CheckoutView({super.key});

  @override
  State<CheckoutView> createState() => _CheckoutViewState();
}

class _CheckoutViewState extends State<CheckoutView> {
  final cart = CartService();

  List paymentArr = [
    {"name": "Cash on delivery", "icon": "assets/img/cash.png"},
    {"name": "**** **** **** 2187", "icon": "assets/img/visa_icon.png"},
    {"name": "test@gmail.com", "icon": "assets/img/paypal.png"},
  ];

  int selectMethod = -1;

  // Fallback address; replaced by profile or picker.
  String deliveryAddress = "653 Nostrand Ave. Brooklyn, NY 11216";

  // Profile info to send in the email.
  String customerName = "Guest";
  String customerEmail = "guest@example.com";
  String customerPhone = "";

  // Your deployed Edge Function URL
  final emailEndpoint =
      'https://bnjsobwbolnytncquuif.functions.supabase.co/send-order-email';

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final profile = await SupabaseService.getProfile();
    final user = SupabaseService.currentUser;
    if (!mounted) return;
    setState(() {
      customerEmail = user?.email ?? customerEmail;
      customerName = (profile?['name'] as String?)?.trim().isNotEmpty == true
          ? profile!['name']
          : customerEmail;
      customerPhone = profile?['mobile'] ?? "";
      deliveryAddress = profile?['address']?.toString().trim().isNotEmpty == true
          ? profile!['address']
          : deliveryAddress;
    });
  }

  Future<void> _pickAddress() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChangeAddressView()),
    );
    if (result is Map && result["address"] != null) {
      setState(() {
        deliveryAddress = result["address"];
      });
    }
  }

  Future<void> _sendOrderEmail({
    required String orderId,
    required double subtotal,
    required double deliveryFee,
    required double discount,
    required double total,
  }) async {
    final items = cart.items
        .map((c) => {
      "name": c.name,
      "qty": c.qty,
      "price": c.price,
      "imageUrl": c.image, // include image
    })
        .toList();

    final resp = await http.post(
      Uri.parse(emailEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "orderId": orderId,
        "customer": {
          "name": customerName,
          "email": customerEmail,
          "phone": customerPhone,
        },
        "address": deliveryAddress,
        "items": items,
        "totals": {
          "subtotal": subtotal,
          "delivery": deliveryFee,
          "discount": discount,
          "total": total,
        },
        "payment": "Cash on Delivery",
      }),
    );

    debugPrint("send-order-email status=${resp.statusCode} body=${resp.body}");

    if (resp.statusCode != 200) {
      throw Exception("Email send failed: ${resp.statusCode} ${resp.body}");
    }

    // In-app notification on success
    NotificationService.instance.addNotification(
      title: "Order email sent",
      subtitle: "Order #$orderId • $deliveryAddress",
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Order #$orderId sent to email.\n$deliveryAddress",
            maxLines: 3,
          ),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _placeOrder() async {
    if (cart.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cart is empty")),
      );
      return;
    }

    try {
      final subtotal = cart.subtotal;
      final deliveryFee = cart.deliveryCost;
      final discount = cart.discount;
      final total = cart.total;

      // Create order in Supabase
      final order = await SupabaseService.createOrder(
        deliveryAddress: deliveryAddress,
        items: cart.items
            .map((e) => {
          'id': e.id,
          'name': e.name,
          'qty': e.qty,
          'price': e.price,
        })
            .toList(),
        total: total,
        restaurantId: null,
      );

      final orderId = order['id'].toString();

      // Send email with profile + item images
      await _sendOrderEmail(
        orderId: orderId,
        subtotal: subtotal,
        deliveryFee: deliveryFee,
        discount: discount,
        total: total,
      );

      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (_) => const CheckoutMessageView(),
      );
    } catch (e) {
      debugPrint("placeOrder failed: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Send order failed: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      body: ListenableBuilder(
        listenable: cart,
        builder: (_, __) {
          final subtotal = cart.subtotal;
          final deliveryFee = cart.deliveryCost;
          final discount = cart.discount;
          final total = cart.total;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 46),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Row(
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Image.asset("assets/img/btn_back.png",
                              width: 20, height: 20),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text("Checkout",
                              style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ),
                  // Address
                  Padding(
                    padding:
                    const EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Delivery Address",
                            style: TextStyle(
                                color: TColor.secondaryText, fontSize: 12)),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                deliveryAddress,
                                style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                            const SizedBox(width: 4),
                            TextButton(
                              onPressed: _pickAddress,
                              child: Text("Change",
                                  style: TextStyle(
                                      color: TColor.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700)),
                            )
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(color: TColor.textfield, height: 8),
                  // Payment method (unchanged)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Payment method",
                                style: TextStyle(
                                    color: TColor.secondaryText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                            TextButton.icon(
                              onPressed: () {},
                              icon: Icon(Icons.add, color: TColor.primary),
                              label: Text("Add Card",
                                  style: TextStyle(
                                      color: TColor.primary,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700)),
                            )
                          ],
                        ),
                        ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            itemCount: paymentArr.length,
                            itemBuilder: (context, index) {
                              var pObj = paymentArr[index] as Map? ?? {};
                              return Container(
                                margin: const EdgeInsets.symmetric(vertical: 8.0),
                                padding: const EdgeInsets.symmetric(
                                    vertical: 8.0, horizontal: 15.0),
                                decoration: BoxDecoration(
                                    color: TColor.textfield,
                                    borderRadius: BorderRadius.circular(5),
                                    border: Border.all(
                                        color:
                                        TColor.secondaryText.withOpacity(0.2))),
                                child: Row(
                                  children: [
                                    Image.asset(pObj["icon"].toString(),
                                        width: 50,
                                        height: 20,
                                        fit: BoxFit.contain),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(pObj["name"],
                                          style: TextStyle(
                                              color: TColor.primaryText,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500)),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        setState(() => selectMethod = index);
                                      },
                                      child: Icon(
                                        selectMethod == index
                                            ? Icons.radio_button_on
                                            : Icons.radio_button_off,
                                        color: TColor.primary,
                                        size: 15,
                                      ),
                                    )
                                  ],
                                ),
                              );
                            })
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(color: TColor.textfield, height: 8),
                  // Totals
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Sub Total",
                                style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                            Text("\$${subtotal.toStringAsFixed(2)}",
                                style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700))
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Delivery Cost",
                                style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                            Text("\$${deliveryFee.toStringAsFixed(2)}",
                                style: TextStyle(
                                    color: Colors.black87,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700))
                          ],
                        ),
                        if (discount > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Discount",
                                  style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500)),
                              Text("-\$${discount.toStringAsFixed(2)}",
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700))
                            ],
                          ),
                        ],
                        const SizedBox(height: 15),
                        Divider(
                            color: TColor.secondaryText.withOpacity(0.5),
                            height: 1),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total",
                                style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500)),
                            Text("\$${total.toStringAsFixed(2)}",
                                style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700))
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(color: TColor.textfield, height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
                    child: RoundButton(
                      title: "Send Order",
                      onPressed: () {
                        _placeOrder(); // non-null, guarded internally
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}