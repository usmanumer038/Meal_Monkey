import 'package:flutter/material.dart';
import 'package:food_delivery/common_widget/round_button.dart';
import '../../common/color_extension.dart';

class CheckoutMessageView extends StatefulWidget {
  const CheckoutMessageView({super.key});

  @override
  State<CheckoutMessageView> createState() => _CheckoutMessageViewState();
}

class _CheckoutMessageViewState extends State<CheckoutMessageView> {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      // Prevent system insets from causing overflow
      child: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive hero image height (max ~40% of available height)
          final heroHeight = constraints.maxHeight * 0.4;

          return SingleChildScrollView(
            padding: EdgeInsets.only(
              // respect bottom insets for keyboard/gesture areas
              bottom: MediaQuery.of(context).padding.bottom + 12,
            ),
            child: Center(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                padding:
                const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                decoration: BoxDecoration(
                  color: TColor.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Close button row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: Icon(Icons.close,
                              color: TColor.primaryText, size: 22),
                        )
                      ],
                    ),
                    // Hero image
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: heroHeight,
                        minHeight: 180,
                      ),
                      child: Image.asset(
                        "assets/img/thank_you.png",
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "Thank You!",
                      style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "for your order",
                      style: TextStyle(
                        color: TColor.primaryText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Text(
                        "Your Order is now being processed. We will let you know once the order is picked from the outlet. Check the status of your Order",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    RoundButton(
                      title: "Track My Order",
                      onPressed: () {
                        // TODO: wire to tracking screen
                      },
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        "Back To Home",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: TColor.primaryText,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}