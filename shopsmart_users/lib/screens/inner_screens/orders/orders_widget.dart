import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:shopsmart_users/consts/app_consts.dart';
import 'package:shopsmart_users/models/order_model.dart';
import 'package:shopsmart_users/screens/inner_screens/orders/order_details_screen.dart';
import '../../../../widgets/subtitle_text.dart';
import '../../../../widgets/title_text.dart';

class OrdersWidgetFree extends StatefulWidget {
  const OrdersWidgetFree({super.key, required this.ordersModelAdvanced});
  final OrdersModelAdvanced ordersModelAdvanced;

  @override
  State<OrdersWidgetFree> createState() => _OrdersWidgetFreeState();
}

class _OrdersWidgetFreeState extends State<OrdersWidgetFree> {
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        // Navigacija na OrderDetailsScreen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(
              order: widget.ordersModelAdvanced,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: FancyShimmerImage(
                height: size.width * 0.25,
                width: size.width * 0.25,
                imageUrl: widget.ordersModelAdvanced.imageUrl,
              ),
            ),
            Flexible(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: TitlesTextWidget(
                            label: widget.ordersModelAdvanced.productTitle,
                            maxLines: 2,
                            fontSize: 15,
                          ),
                        ),
                        // da li mi treba funkcionalost da user brise svoje ordere?
                        // IconButton(
                        //     onPressed: () {},
                        //     icon: const Icon(
                        //       Icons.clear,
                        //       color: Colors.red,
                        //       size: 22,
                        //     )),
                      ],
                    ),
                    Row(
                      children: [
                        TitlesTextWidget(
                          label: 'Price:  ',
                          fontSize: 15,
                        ),
                        Flexible(
                          child: SubtitleTextWidget(
                            label: "${widget.ordersModelAdvanced.price}\$",
                            fontSize: 15,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    SubtitleTextWidget(
                      label: "Qty: ${widget.ordersModelAdvanced.quantity}",
                      fontSize: 15,
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
