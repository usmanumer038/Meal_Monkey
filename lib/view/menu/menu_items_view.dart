import 'package:flutter/material.dart';
import 'package:food_delivery/common/api_service.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/view/menu/item_details_view.dart';
import 'package:food_delivery/view/more/my_order_view.dart';

class MenuItemsView extends StatefulWidget {
  final Map mObj;
  const MenuItemsView({super.key, required this.mObj});

  @override
  State<MenuItemsView> createState() => _MenuItemsViewState();
}

class _MenuItemsViewState extends State<MenuItemsView> {
  final TextEditingController _search = TextEditingController();
  List<Map<String, dynamic>> allItems = [];
  List<Map<String, dynamic>> filtered = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _loadItems() async {
    final category = widget.mObj['strCategory'] ?? widget.mObj['name'] ?? '';
    final meals = await ApiService.getMealsByCategory(category);
    setState(() {
      allItems = meals;
      filtered = meals;
      isLoading = false;
    });
  }

  void _filter(String q) {
    if (q.isEmpty) {
      setState(() => filtered = allItems);
      return;
    }
    final lower = q.toLowerCase();
    setState(() {
      filtered = allItems
          .where((m) =>
          (m["strMeal"] ?? "").toString().toLowerCase().contains(lower))
          .toList();
    });
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
    final title =
        widget.mObj["strCategory"]?.toString() ?? widget.mObj["name"]?.toString() ?? "Items";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
          children: [
            // Top bar
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 20, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon:
                    const Icon(Icons.arrow_back, color: Colors.black87),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const MyOrderView())),
                    icon: const Icon(Icons.shopping_cart_outlined,
                        color: Colors.black87),
                  ),
                ],
              ),
            ),
            // Search bar
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xfff1f1f1),
                  borderRadius: BorderRadius.circular(22),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Row(
                  children: [
                    Icon(Icons.search,
                        color: TColor.secondaryText, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _search,
                        onChanged: _filter,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          hintText: "Search Food",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 24),
                itemCount: filtered.length,
                itemBuilder: (context, index) {
                  final meal = filtered[index];
                  final img = (meal["strMealThumb"] ?? "").toString();
                  final name = meal["strMeal"] ?? "";
                  final cat = meal["strCategory"] ?? "";
                  final area = meal["strArea"] ?? "";
                  const rating = "4.5";

                  return GestureDetector(
                    onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ItemDetailsView(meal: meal))),
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      height: 190,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4))
                        ],
                      ),
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: _netImg(img,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.05),
                                    Colors.black.withOpacity(0.55)
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter),
                            ),
                          ),
                          Positioned(
                            left: 14,
                            right: 14,
                            bottom: 14,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    const Icon(Icons.star,
                                        color: Colors.orange, size: 14),
                                    const SizedBox(width: 4),
                                    Text(rating,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12)),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        "$cat • $area",
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}