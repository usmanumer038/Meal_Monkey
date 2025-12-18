import 'package:flutter/material.dart';
import 'package:food_delivery/common/cart_service.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'checkout_view.dart';

class MyOrderView extends StatefulWidget {
  const MyOrderView({super.key});

  @override
  State<MyOrderView> createState() => _MyOrderViewState();
}

class _MyOrderViewState extends State<MyOrderView> {
  final cart = CartService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor. white,
      body: ListenableBuilder(
        listenable: cart,
        builder: (context, _) {
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets. symmetric(vertical: 20),
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
                          child: Text("My Order",
                              style: TextStyle(
                                  color: TColor. primaryText,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (cart.items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.all(40),
                      child: Center(child: Text("Your cart is empty")),
                    )
                  else
                    Container(
                      decoration: BoxDecoration(color: TColor.textfield),
                      child: ListView.separated(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        padding: EdgeInsets. zero,
                        itemCount: cart. items.length,
                        separatorBuilder: (_, __) => Divider(
                          indent: 25,
                          endIndent: 25,
                          color: TColor. secondaryText. withOpacity(0.5),
                          height: 1,
                        ),
                        itemBuilder: (context, index) {
                          final item = cart.items[index];
                          return Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 15, horizontal: 25),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item. image,
                                    width: 50,
                                    height: 50,
                                    fit: BoxFit. cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      width: 50,
                                      height: 50,
                                      color: TColor.placeholder,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item. name,
                                        style: TextStyle(
                                            color: TColor. primaryText,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              cart.decreaseQty(item.id);
                                            },
                                            child: Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: TColor.primary,
                                                borderRadius:
                                                BorderRadius.circular(12),
                                              ),
                                              child: Icon(Icons.remove,
                                                  size: 16,
                                                  color: TColor.white),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text("${item.qty}"),
                                          ),
                                          InkWell(
                                            onTap: () {
                                              cart. increaseQty(item.id);
                                            },
                                            child: Container(
                                              width: 24,
                                              height: 24,
                                              decoration: BoxDecoration(
                                                color: TColor.primary,
                                                borderRadius:
                                                BorderRadius.circular(12),
                                              ),
                                              child: Icon(Icons. add,
                                                  size: 16,
                                                  color: TColor.white),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  "\$${(item.price * item. qty).toStringAsFixed(2)}",
                                  style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
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
                                    fontWeight: FontWeight.w700)),
                            Text("\$${cart.subtotal.toStringAsFixed(2)}",
                                style: TextStyle(
                                    color: TColor.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight. w700)),
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
                                    fontWeight: FontWeight. w700)),
                            Text("\$${cart.deliveryCost.toStringAsFixed(2)}",
                                style: TextStyle(
                                    color: TColor.primary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                        if (cart.discount > 0) ...[
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Discount",
                                  style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700)),
                              Text("-\$${cart. discount.toStringAsFixed(2)}",
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 13,
                                      fontWeight: FontWeight. w700)),
                            ],
                          ),
                        ],
                        const SizedBox(height: 15),
                        Divider(
                          color: TColor. secondaryText.withOpacity(0.5),
                          height: 1,
                        ),
                        const SizedBox(height: 15),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total",
                                style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700)),
                            Text("\$${cart.total.toStringAsFixed(2)}",
                                style: TextStyle(
                                    color: TColor.primary,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                        const SizedBox(height: 25),
                        RoundButton(
                            title: "Checkout",
                            onPressed: cart.items.isEmpty
                                ? () {}
                                : () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const CheckoutView(),
                                ),
                              );
                            }),
                        const SizedBox(height: 20),
                      ],
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