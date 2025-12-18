import 'package:flutter/material.dart';
import 'package:food_delivery/common/api_service.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/view/menu/menu_items_view.dart';
import 'package:food_delivery/view/more/my_order_view.dart';

class MenuView extends StatefulWidget {
  const MenuView({super.key});

  @override
  State<MenuView> createState() => _MenuViewState();
}

class _MenuViewState extends State<MenuView> {
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> filtered = [];
  bool isLoading = true;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => isLoading = true);
    try {
      final cats = await ApiService.getCategories();
      setState(() {
        categories = cats;
        filtered = cats;
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  void _filter(String q) {
    if (q.isEmpty) {
      setState(() => filtered = categories);
      return;
    }
    final lower = q.toLowerCase();
    setState(() {
      filtered = categories
          .where((c) =>
          (c['strCategory'] ?? '').toString().toLowerCase().contains(lower))
          .toList();
    });
  }

  Widget _netImg(String url,
      {double? w, double? h, BoxFit fit = BoxFit.cover}) {
    if (url.startsWith('http')) {
      return Image.network(
        url,
        width: w,
        height: h,
        fit: fit,
        errorBuilder: (_, __, ___) =>
            Container(width: w, height: h, color: TColor.placeholder),
      );
    }
    return Container(width: w, height: h, color: TColor.placeholder);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f5f8),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
          onRefresh: _load,
          child: Stack(
            children: [
              // Orange strip
              Positioned.fill(
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    width: 90,
                    margin: const EdgeInsets.only(top: 80, bottom: 40),
                    decoration: const BoxDecoration(
                      color: Color(0xfff36b12),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(32),
                        bottomRight: Radius.circular(32),
                      ),
                    ),
                  ),
                ),
              ),
              ListView(
                padding: const EdgeInsets.only(bottom: 100),
                children: [
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text("Menu",
                              style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w800)),
                        ),
                        IconButton(
                          onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const MyOrderView())),
                          icon: Image.asset("assets/img/shopping_cart.png",
                              width: 22, height: 22),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: TColor.textfield,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding:
                      const EdgeInsets.symmetric(horizontal: 14),
                      child: Row(
                        children: [
                          Icon(Icons.search,
                              color: TColor.secondaryText, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _search,
                              onChanged: _filter,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Search food",
                                hintStyle: TextStyle(
                                    color: TColor.placeholder,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(filtered.length, (i) {
                    final c = filtered[i];
                    final img = c["strCategoryThumb"] ?? "";
                    final name = c["strCategory"] ?? "";
                    final count = (120 + i * 7); // placeholder

                    return Container(
                      margin: const EdgeInsets.only(
                          left: 40, right: 16, bottom: 14), // moved left
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 8,
                              offset: Offset(0, 4))
                        ],
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: _netImg(img,
                              w: 64, h: 64, fit: BoxFit.cover),
                        ),
                        title: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              color: TColor.primaryText,
                              fontSize: 18,
                              fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text("$count Items",
                            style: TextStyle(
                                color: TColor.secondaryText,
                                fontSize: 12,
                                fontWeight: FontWeight.w500)),
                        trailing: Container(
                          width: 34,
                          height: 34,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2))
                            ],
                          ),
                          child: const Icon(Icons.arrow_forward_ios,
                              color: Color(0xfff36b12), size: 16),
                        ),
                        onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => MenuItemsView(mObj: c))),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}