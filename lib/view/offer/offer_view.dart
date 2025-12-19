import 'package:flutter/material.dart';
import 'package:food_delivery/common/api_service.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:food_delivery/view/menu/item_details_view.dart';
import 'package:food_delivery/view/more/my_order_view.dart';

class OfferView extends StatefulWidget {
  const OfferView({super.key});

  @override
  State<OfferView> createState() => _OfferViewState();
}

class _OfferViewState extends State<OfferView> {
  bool isLoading = true;
  List<Map<String, dynamic>> offerMeals = [];

  @override
  void initState() {
    super.initState();
    _loadOffers();
  }

  Future<void> _loadOffers() async {
    setState(() => isLoading = true);
    try {
      final meals = await ApiService.getPopularMeals();
      setState(() {
        offerMeals = meals;
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Widget _netImg(String url,
      {double? width, double? height, BoxFit fit = BoxFit.cover}) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (_, __, ___) => Container(
          width: width,
          height: height,
          color: TColor.placeholder,
          child: Icon(Icons.image_not_supported, color: TColor.secondaryText),
        ),
      );
    }
    return Container(
      width: width,
      height: height,
      color: TColor.placeholder,
      child: Icon(Icons.image_not_supported, color: TColor.secondaryText),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f5f8),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadOffers,
          child: isLoading
              ? ListView(children: const [
            SizedBox(height: 180),
            Center(child: CircularProgressIndicator())
          ])
              : ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
                child: Row(
                  children: [
                    Expanded(
                      child: Text("Latest Offers",
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 24,
                              fontWeight: FontWeight.w800)),
                    ),
                    InkWell(
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(builder: (_) => const MyOrderView())),
                      child: Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: TColor.textfield,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: Image.asset("assets/img/shopping_cart.png",
                            width: 22, height: 22),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  "Find discounts, special meals, and tasty surprises!",
                  style: TextStyle(
                      color: TColor.secondaryText,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RoundButton(
                    title: "Check Offers",
                    fontSize: 14,
                    onPressed: _loadOffers),
              ),
              const SizedBox(height: 20),
              ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: offerMeals.length,
                itemBuilder: (context, index) {
                  final meal = offerMeals[index];
                  final img = (meal["strMealThumb"] ?? "").toString();
                  final name = meal["strMeal"] ?? "";
                  final type = meal["strCategory"] ?? "";
                  final area = meal["strArea"] ?? "";

                  return GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ItemDetailsView(meal: meal))),
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      decoration: BoxDecoration(
                        color: TColor.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 6,
                              offset: Offset(0, 3))
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(14)),
                            child: _netImg(img, height: 180),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: TColor.primaryText,
                                        fontSize: 18,
                                        fontWeight: FontWeight.w700)),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Icon(Icons.star,
                                        color: TColor.primary, size: 14),
                                    const SizedBox(width: 4),
                                    Text("4.5",
                                        style: TextStyle(
                                            color: TColor.primary,
                                            fontSize: 12)),
                                    const SizedBox(width: 8),
                                    Text("(100 Ratings)",
                                        style: TextStyle(
                                            color: TColor.secondaryText,
                                            fontSize: 11)),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text("$type • $area",
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              color: TColor.secondaryText,
                                              fontSize: 12)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}