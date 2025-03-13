import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_admin/models/order_model.dart';
import 'package:shopsmart_admin/providers/orders_provider.dart';
import '../../../../widgets/empty_bag.dart';
import '../../../services/assets_manager.dart';
import '../../../widgets/title_text.dart';
import 'orders_widget.dart';

class OrdersScreenFree extends StatefulWidget {
  static const routeName = '/OrderScreen';

  const OrdersScreenFree({Key? key}) : super(key: key);

  @override
  State<OrdersScreenFree> createState() => _OrdersScreenFreeState();
}

class _OrdersScreenFreeState extends State<OrdersScreenFree> {
  late Future<List<OrdersModelAdvanced>> _ordersFuture;
  bool isEmptyOrders = false;

  @override
  void initState() {
    super.initState();
    _ordersFuture =
        Provider.of<OrderProvider>(context, listen: false).fetchOrders();
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
        appBar: AppBar(
          title: const TitlesTextWidget(
            label: 'Placed orders',
          ),
        ),
        body: FutureBuilder<List<OrdersModelAdvanced>>(
            future: _ordersFuture, // Koristimo učitane podatke
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: SelectableText(snapshot.error.toString()));
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return EmptyBagWidget(
                  imagePath: AssetsManager.order,
                  title: "No orders have been placed yet",
                  subtitle: "",
                );
              }
              return ListView.separated(
                itemCount: ordersProvider.getOrders.length,
                itemBuilder: (ctx, index) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
                    child: OrdersWidgetFree(
                        ordersModelAdvanced: ordersProvider.getOrders[index]),
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return const Divider(thickness: 1, color: Colors.grey);
                },
              );
            }));

    // return Scaffold(
    //     appBar: AppBar(
    //       title: const TitlesTextWidget(
    //         label: 'Placed orders',
    //       ),
    //     ),
    //     body: FutureBuilder<List<OrdersModelAdvanced>>(
    //         future: ordersProvider.fetchOrders(),
    //         builder: (context, snapshot) {
    //           if (snapshot.connectionState == ConnectionState.waiting) {
    //             return Center(
    //               child: CircularProgressIndicator(),
    //             );
    //           }
    //           if (snapshot.hasError) {
    //             return Center(
    //               child: SelectableText(snapshot.error.toString()),
    //             );
    //           } else if (!snapshot.hasData ||
    //               ordersProvider.getOrders.isEmpty) {
    //             return EmptyBagWidget(
    //               imagePath: AssetsManager.order,
    //               title: "No orders has been placed yet",
    //               subtitle: "",
    //             );
    //           }
    //           return ListView.separated(
    //             itemCount: snapshot.data!.length,
    //             itemBuilder: (ctx, index) {
    //               return Padding(
    //                 padding:
    //                     const EdgeInsets.symmetric(horizontal: 2, vertical: 6),
    //                 child: OrdersWidgetFree(
    //                     ordersModelAdvanced: ordersProvider.getOrders[index]),
    //               );
    //             },
    //             separatorBuilder: (BuildContext context, int index) {
    //               return const Divider(
    //                 thickness: 1,
    //                 color: Colors.grey,
    //               );
    //             },
    //           );
    //         }));
  }
}
