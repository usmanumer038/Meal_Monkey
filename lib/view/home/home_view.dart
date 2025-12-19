import 'dart:async';
import 'package:flutter/material.dart';
import 'package:food_delivery/common/api_service.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_textfield.dart';
import 'package:food_delivery/view/menu/item_details_view.dart';
import 'package:food_delivery/view/more/my_order_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final TextEditingController txtSearch = TextEditingController();
  final PageController carouselController = PageController(viewportFraction: 0.88);

  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> popularMeals = [];
  List<Map<String, dynamic>> searchResults = [];

  bool isLoading = true;
  bool isSearching = false;
  int carouselPage = 0;
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  @override
  void dispose() {
    txtSearch.dispose();
    carouselController.dispose();
    _searchDebounce?.cancel();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    setState(() => isLoading = true);
    try {
      final cats = await ApiService.getCategories();
      final meals = await ApiService.getPopularMeals();
      setState(() {
        categories = cats;
        popularMeals = meals;
        isLoading = false;
      });
    } catch (_) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _onRefresh() async => _loadInitialData();

  void _onSearchChanged(String q) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 350), () async {
      if (q.trim().isEmpty) {
        setState(() {
          searchResults = [];
          isSearching = false;
        });
        return;
      }
      setState(() {
        isSearching = true;
        searchResults = [];
      });
      final results = await ApiService.searchMeals(q.trim());
      setState(() {
        searchResults = results;
        isSearching = false;
      });
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

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 10),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Good morning!",
                    style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 24,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 4),
                Text("Find food you love — fast delivery",
                    style: TextStyle(
                        color: TColor.secondaryText,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          InkWell(
            onTap: () => Navigator.push(
                context, MaterialPageRoute(builder: (_) => const MyOrderView())),
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
          )
        ],
      ),
    );
  }

  Widget _searchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: RoundTextfield(
        hintText: "Search meals, cuisines, restaurants",
        controller: txtSearch,
        left: Container(
          alignment: Alignment.center,
          width: 36,
          child: Image.asset("assets/img/search.png", width: 20, height: 20),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _categories() {
    if (categories.isEmpty) return const SizedBox(height: 120);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: TColor.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: SizedBox(
        height: 100,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final cat = categories[index];
            final img = cat["strCategoryThumb"] ?? "";
            final name = cat["strCategory"] ?? "";
            return GestureDetector(
              onTap: () async {
                final meals =
                await ApiService.getMealsByCategory(name);
                setState(() {
                  searchResults = meals;
                  txtSearch.clear();
                });
              },
              child: Container(
                width: 80,
                margin: const EdgeInsets.symmetric(horizontal: 6),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(40),
                      child: _netImg(img, width: 60, height: 60),
                    ),
                    const SizedBox(height: 6),
                    Text(name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            color: TColor.primaryText,
                            fontSize: 12,
                            fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _carousel() {
    if (popularMeals.isEmpty) {
      return const SizedBox(height: 220, child: Center(child: CircularProgressIndicator()));
    }
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text("Popular Meals",
                style: TextStyle(
                    color: TColor.primaryText,
                    fontSize: 20,
                    fontWeight: FontWeight.w800)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: PageView.builder(
            controller: carouselController,
            itemCount: popularMeals.length,
            onPageChanged: (p) => setState(() => carouselPage = p),
            itemBuilder: (context, index) {
              final meal = popularMeals[index];
              final img = (meal["strMealThumb"] ?? "").toString();
              final title = meal["strMeal"] ?? "";
              final subtitle =
                  "${meal["strCategory"] ?? ""} • ${meal["strArea"] ?? ""}";

              return GestureDetector(
                onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => ItemDetailsView(meal: meal))),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: Offset(0, 4))
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        _netImg(img),
                        Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.transparent, Colors.black54],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                        Positioned(
                          left: 14,
                          right: 14,
                          bottom: 14,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                      color: TColor.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700)),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.star,
                                      color: TColor.primary, size: 14),
                                  const SizedBox(width: 4),
                                  Text("4.5",
                                      style: TextStyle(
                                          color: TColor.primary, fontSize: 12)),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(subtitle,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                            color: TColor.white, fontSize: 12)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(popularMeals.length, (i) {
            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: i == carouselPage ? 18 : 6,
              decoration: BoxDecoration(
                color: i == carouselPage ? TColor.primary : TColor.placeholder,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _mostPopular() {
    if (popularMeals.isEmpty) return const SizedBox();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text("Most Popular",
              style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 14),
            itemCount: popularMeals.length,
            itemBuilder: (context, index) {
              final meal = popularMeals[index];
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
                  width: 170,
                  margin: const EdgeInsets.symmetric(horizontal: 6),
                  decoration: BoxDecoration(
                    color: TColor.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                          color: Colors.black12,
                          blurRadius: 6,
                          offset: Offset(0, 3))
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                        child: _netImg(img, width: 170, height: 100),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: TColor.primaryText,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: Text("$type • $area",
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                          color: TColor.secondaryText,
                                          fontSize: 11)),
                                ),
                                Icon(Icons.star,
                                    color: TColor.primary, size: 12),
                                const SizedBox(width: 2),
                                Text("4.5",
                                    style: TextStyle(
                                        color: TColor.primary, fontSize: 11)),
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
        ),
      ],
    );
  }

  Widget _listSection() {
    if (isSearching) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final list = searchResults.isNotEmpty ? searchResults : popularMeals;
    final title = searchResults.isNotEmpty ? "Search Results" : "Recent Items";

    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 32),
        child: Center(child: Text("No items found")),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(title,
              style: TextStyle(
                  color: TColor.primaryText,
                  fontSize: 20,
                  fontWeight: FontWeight.w800)),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: list.length,
          itemBuilder: (context, index) {
            final meal = list[index];
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
                margin: const EdgeInsets.symmetric(vertical: 6),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: TColor.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, 2))
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: _netImg(img, width: 70, height: 70),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: TColor.primaryText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text("$type • $area",
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  color: TColor.secondaryText, fontSize: 12)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(Icons.star,
                                  color: TColor.primary, size: 14),
                              const SizedBox(width: 4),
                              Text("4.5",
                                  style: TextStyle(
                                      color: TColor.primary, fontSize: 12)),
                              const SizedBox(width: 8),
                              Text("(100 Ratings)",
                                  style: TextStyle(
                                      color: TColor.secondaryText,
                                      fontSize: 11)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios,
                        color: TColor.placeholder, size: 16),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f5f8),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _onRefresh,
          child: isLoading
              ? ListView(
            children: const [
              SizedBox(height: 160),
              Center(child: CircularProgressIndicator()),
            ],
          )
              : ListView(
            padding: const EdgeInsets.only(bottom: 100),
            children: [
              _header(),
              _searchBar(),
              _categories(),
              _carousel(),
              const SizedBox(height: 20),
              _mostPopular(),
              const SizedBox(height: 20),
              _listSection(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}