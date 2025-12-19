import 'package:flutter/material.dart';
import 'package:food_delivery/common/color_extension.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import 'package:food_delivery/view/main_tabview/main_tabview.dart';

class OnBoardingView extends StatefulWidget {
  const OnBoardingView({super.key});

  @override
  State<OnBoardingView> createState() => _OnBoardingViewState();
}

class _OnBoardingViewState extends State<OnBoardingView> {
  int selectPage = 0;
  final PageController controller = PageController();

  final List<Map<String, String>> pageArr = const [
    {
      "title": "Find Food You Love",
      "subtitle":
      "Discover the best foods from over 1,000\nrestaurants and fast delivery to your\ndoorstep",
      "image": "assets/img/on_boarding_1.png",
    },
    {
      "title": "Fast Delivery",
      "subtitle": "Fast food delivery to your home, office\n wherever you are",
      "image": "assets/img/on_boarding_2.png",
    },
    {
      "title": "Live Tracking",
      "subtitle":
      "Real time tracking of your food on the app\nonce you placed the order",
      "image": "assets/img/on_boarding_3.png",
    },
  ];

  @override
  void initState() {
    super.initState();
    controller.addListener(() {
      final p = controller.page?.round() ?? 0;
      if (p != selectPage && mounted) {
        setState(() => selectPage = p);
      }
    });
  }

  void _next() {
    if (selectPage >= pageArr.length - 1) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const MainTabView()),
      );
    } else {
      controller.animateToPage(
        selectPage + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              // Pager area
              Expanded(
                child: PageView.builder(
                  controller: controller,
                  itemCount: pageArr.length,
                  itemBuilder: (context, index) {
                    final pObj = pageArr[index];
                    return LayoutBuilder(
                      builder: (context, constraints) {
                        final imageHeight = constraints.maxHeight * 0.45;
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              height: imageHeight,
                              child: Image.asset(
                                pObj["image"]!,
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              pObj["title"]!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: TColor.primaryText,
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              pObj["subtitle"]!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: TColor.secondaryText,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Dots
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(pageArr.length, (i) {
                  final selected = i == selectPage;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    height: 6,
                    width: selected ? 18 : 6,
                    decoration: BoxDecoration(
                      color: selected ? TColor.primary : TColor.placeholder,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 24),
              // CTA
              RoundButton(title: "Next", onPressed: _next),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}