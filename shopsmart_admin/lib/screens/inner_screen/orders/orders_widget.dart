import 'package:fancy_shimmer_image/fancy_shimmer_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_admin/models/order_model.dart';
import 'package:shopsmart_admin/providers/orders_provider.dart';
import 'package:shopsmart_admin/screens/inner_screen/orders/order_details_screen.dart';
import '../../../consts/app_constants.dart';
import '../../../widgets/subtitle_text.dart';
import '../../../widgets/title_text.dart';

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
    final orderProvider = Provider.of<OrderProvider>(context);

    final size = MediaQuery.of(context).size;

    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OrderDetailsScreen(
              order: widget.ordersModelAdvanced,
            ),
          ),
        );
      },
      title: TitlesTextWidget(
        label: "Ordered by: ${widget.ordersModelAdvanced.userName}",
        fontSize: 16,
      ),
      subtitle: SubtitleTextWidget(
        label: "Order ID: ${widget.ordersModelAdvanced.orderId}",
        fontSize: 14,
        color: Colors.grey,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.red),
            onPressed: () async {
              bool? confirmDelete = await showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text("Confirm Delete"),
                  content:
                      const Text("Are you sure you want to delete this order?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(false),
                      child: const Text("Cancel"),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(ctx).pop(true),
                      child: const Text("Delete",
                          style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );

              if (confirmDelete == true) {
                await orderProvider
                    .deleteOrder(widget.ordersModelAdvanced.orderId);
              }
            },
          ),
          const Icon(Icons.arrow_forward_ios, size: 18, color: Colors.blue),
        ],
      ),
    );
    // return GestureDetector(
    //   onTap: () {
    //     // Navigacija na OrderDetailsScreen
    //     Navigator.push(
    //       context,
    //       MaterialPageRoute(
    //         builder: (context) => OrderDetailsScreen(
    //           order: widget.ordersModelAdvanced,
    //         ),
    //       ),
    //     );
    //   },
    //   child: Padding(
    //     padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    //     child: Row(
    //       children: [
    //         ClipRRect(
    //           borderRadius: BorderRadius.circular(12),
    //           child: FancyShimmerImage(
    //             height: size.width * 0.25,
    //             width: size.width * 0.25,
    //             imageUrl: widget.ordersModelAdvanced.imageUrl,
    //           ),
    //         ),
    //         Flexible(
    //           child: Padding(
    //             padding: const EdgeInsets.all(12.0),
    //             child: Column(
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Row(
    //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
    //                   children: [
    //                     Flexible(
    //                       child: TitlesTextWidget(
    //                         label: widget.ordersModelAdvanced.productTitle,
    //                         maxLines: 2,
    //                         fontSize: 15,
    //                       ),
    //                     ),
    //                     IconButton(
    //                         onPressed: () async {
    //                           String? userId =
    //                               await orderProvider.getUserIdByOrderId(
    //                                   widget.ordersModelAdvanced.orderId);
    //                           // omoguciti brisanje
    //                           orderProvider.deleteOrder(orderId);
    //                         },
    //                         icon: const Icon(
    //                           Icons.clear,
    //                           color: Colors.red,
    //                           size: 22,
    //                         )),
    //                   ],
    //                 ),
    //                 Row(
    //                   children: [
    //                     TitlesTextWidget(
    //                       label: 'Price:  ',
    //                       fontSize: 15,
    //                     ),
    //                     Flexible(
    //                       child: SubtitleTextWidget(
    //                         label: "${widget.ordersModelAdvanced.price}\$",
    //                         fontSize: 15,
    //                         color: Colors.blue,
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //                 const SizedBox(
    //                   height: 5,
    //                 ),
    //                 SubtitleTextWidget(
    //                   label: "Qty: ${widget.ordersModelAdvanced.quantity}",
    //                   fontSize: 15,
    //                 ),
    //                 SizedBox(height: 5),
    //                 // 🔹 Prikaz korisnika koji je napravio porudžbinu
    //                 SubtitleTextWidget(
    //                   label:
    //                       "Ordered by: ${widget.ordersModelAdvanced.userName}",
    //                   fontSize: 15,
    //                   color: Colors.green,
    //                 ),
    //                 SubtitleTextWidget(
    //                   label: "User ID: ${widget.ordersModelAdvanced.userId}",
    //                   fontSize: 12,
    //                   color: Colors.grey,
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }
}
