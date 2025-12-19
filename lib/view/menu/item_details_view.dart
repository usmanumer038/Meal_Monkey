import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:food_delivery/common/cart_service.dart';
import 'package:food_delivery/common/supabase_service.dart';
import 'package:food_delivery/common_widget/round_icon_button.dart';
import 'package:food_delivery/common/price_service.dart';
import '../../common/color_extension.dart';
import '../more/my_order_view.dart';

class ItemDetailsView extends StatefulWidget {
  final Map<String, dynamic> meal;
  const ItemDetailsView({super.key, required this.meal});

  @override
  State<ItemDetailsView> createState() => _ItemDetailsViewState();
}

class _ItemDetailsViewState extends State<ItemDetailsView> {
  late double price; // generated from meal ID
  int qty = 1;
  bool isFav = false;
  final cart = CartService();

  @override
  void initState() {
    super.initState();
    price = PriceService.priceForMeal(widget.meal["idMeal"]?.toString() ?? "");
    checkFavorite();
  }

  Future<void> checkFavorite() async {
    final favIds = await SupabaseService.fetchFavoriteIds();
    if (mounted) {
      setState(() {
        isFav = favIds.contains(widget.meal["idMeal"]);
      });
    }
  }

  Future<void> toggleFavorite() async {
    await SupabaseService.toggleFavorite(
        widget.meal["idMeal"]?.toString() ?? "", isFav);
    if (mounted) setState(() => isFav = !isFav);
  }

  void addToCart() {
    cart.addItem(CartItem(
      id: widget.meal["idMeal"]?.toString() ?? "",
      name: widget.meal["strMeal"] ?? "",
      image: widget.meal["strMealThumb"] ?? "",
      price: price,
      qty: qty,
    ));

    final snackBar = SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      backgroundColor: Colors.black87,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      content: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: TColor.primary.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check, color: TColor.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Added to Cart",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.meal["strMeal"] ?? "",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
      duration: const Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;
    final meal = widget.meal;

    return Scaffold(
      backgroundColor: TColor.white,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          SizedBox(
            width: media.width,
            height: media.width,
            child: Image.network(
              meal["strMealThumb"] ?? "",
              width: media.width,
              height: media.width,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  Container(width: media.width, height: media.width, color: TColor.placeholder),
            ),
          ),
          Container(
            width: media.width,
            height: media.width,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [Colors.black, Colors.transparent, Colors.black],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  Column(
                    children: [
                      SizedBox(height: media.width - 60),
                      Container(
                        decoration: BoxDecoration(
                            color: TColor.white,
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(30),
                                topRight: Radius.circular(30))),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 35),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 25),
                                child: Text(
                                  meal["strMeal"] ?? "Food Item",
                                  style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 25),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        IgnorePointer(
                                          ignoring: true,
                                          child: RatingBar.builder(
                                            initialRating: 4,
                                            minRating: 1,
                                            direction: Axis.horizontal,
                                            allowHalfRating: true,
                                            itemCount: 5,
                                            itemSize: 20,
                                            itemPadding: const EdgeInsets.symmetric(horizontal: 1.0),
                                            itemBuilder: (context, _) => Icon(
                                              Icons.star,
                                              color: TColor.primary,
                                            ),
                                            onRatingUpdate: (rating) {},
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "4 Star Ratings",
                                          style: TextStyle(
                                              color: TColor.primary,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          "\$${price.toStringAsFixed(2)}",
                                          style: TextStyle(
                                              color: TColor.primaryText,
                                              fontSize: 31,
                                              fontWeight: FontWeight.w700),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          "/per Portion",
                                          style: TextStyle(
                                              color: TColor.primaryText,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w500),
                                        ),
                                      ],
                                    )
                                  ],
                                ),
                              ),
                              const SizedBox(height: 15),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 25),
                                child: Text(
                                  "Description",
                                  style: TextStyle(
                                      color: TColor.primaryText,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 25),
                                child: Text(
                                  (meal["strInstructions"]?.toString() ?? "")
                                      .substring(
                                      0,
                                      ((meal["strInstructions"]?.toString().length ?? 0) > 200)
                                          ? 200
                                          : (meal["strInstructions"]?.toString().length ?? 0)) ??
                                      "Delicious meal prepared with fresh ingredients.",
                                  style: TextStyle(color: TColor.secondaryText, fontSize: 12),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 25),
                                child: Row(
                                  children: [
                                    Text(
                                      "Number of Portions",
                                      style: TextStyle(
                                          color: TColor.primaryText,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w700),
                                    ),
                                    const Spacer(),
                                    InkWell(
                                      onTap: () {
                                        if (qty > 1) {
                                          setState(() => qty--);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 15),
                                        height: 25,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: TColor.primary,
                                            borderRadius: BorderRadius.circular(12.5)),
                                        child: Text(
                                          "-",
                                          style: TextStyle(
                                              color: TColor.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 15),
                                      height: 25,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                          border: Border.all(color: TColor.primary),
                                          borderRadius: BorderRadius.circular(12.5)),
                                      child: Text(
                                        qty.toString(),
                                        style: TextStyle(
                                            color: TColor.primary,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    InkWell(
                                      onTap: () {
                                        setState(() => qty++);
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 15),
                                        height: 25,
                                        alignment: Alignment.center,
                                        decoration: BoxDecoration(
                                            color: TColor.primary,
                                            borderRadius: BorderRadius.circular(12.5)),
                                        child: Text(
                                          "+",
                                          style: TextStyle(
                                              color: TColor.white,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 25),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Total Price",
                                          style: TextStyle(
                                              color: TColor.primaryText,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w500),
                                        ),
                                        Text(
                                          "\$${(price * qty).toStringAsFixed(2)}",
                                          style: TextStyle(
                                              color: TColor.primaryText,
                                              fontSize: 21,
                                              fontWeight: FontWeight.w700),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: 180,
                                      height: 45,
                                      child: RoundIconButton(
                                          title: "Add to Cart",
                                          icon: "assets/img/shopping_add.png",
                                          color: TColor.primary,
                                          onPressed: addToCart),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 20),
                            ]),
                      ),
                    ],
                  ),
                  Container(
                    height: media.width - 20,
                    alignment: Alignment.bottomRight,
                    margin: const EdgeInsets.only(right: 4),
                    child: InkWell(
                        onTap: toggleFavorite,
                        child: Image.asset(
                            isFav
                                ? "assets/img/favorites_btn.png"
                                : "assets/img/favorites_btn_2.png",
                            width: 70,
                            height: 70)),
                  ),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                const SizedBox(height: 35),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: Image.asset(
                          "assets/img/btn_back.png",
                          width: 20,
                          height: 20,
                          color: TColor.white,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const MyOrderView()));
                        },
                        icon: Image.asset(
                          "assets/img/shopping_cart.png",
                          width: 25,
                          height: 25,
                          color: TColor.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}