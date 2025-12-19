import 'package:flutter/material.dart';
import '../common/color_extension.dart';

class MenuItemRow extends StatelessWidget {
  final Map mObj;
  final VoidCallback onTap;
  const MenuItemRow({super.key, required this.mObj, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = (mObj["image"] ?? "").toString();
    final isNetwork = imageUrl.startsWith("http");

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: InkWell(
        onTap: onTap,
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: double.maxFinite,
                height: 160,
                child: isNetwork
                    ? Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  width: double.maxFinite,
                  height: 160,
                  errorBuilder: (_, __, ___) =>
                      Container(color: TColor.placeholder),
                )
                    : Image.asset(
                  imageUrl.isNotEmpty ? imageUrl : "assets/img/dess_1.png",
                  fit: BoxFit.cover,
                  width: double.maxFinite,
                  height: 160,
                ),
              ),
            ),
            Container(
              width: double.maxFinite,
              height: 160,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black
                ], begin: Alignment.topCenter, end: Alignment.bottomCenter),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mObj["name"] ?? "",
                    style: TextStyle(
                        color: TColor.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Image.asset(
                        "assets/img/rate.png",
                        width: 10,
                        height: 10,
                        fit: BoxFit.cover,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        mObj["rate"]?.toString() ?? "",
                        style: TextStyle(color: TColor.primary, fontSize: 11),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          mObj["type"] ?? "",
                          style: TextStyle(color: TColor.white, fontSize: 11),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(" . ", style: TextStyle(color: TColor.primary)),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          mObj["food_type"] ?? "",
                          style: TextStyle(color: TColor.white, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
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
  }
}