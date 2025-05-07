import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shopsmart_users/providers/review_provider.dart';

class AddReviewForm extends StatefulWidget {
  final String productId;
  final String userId;

  const AddReviewForm({
    Key? key,
    required this.productId,
    required this.userId,
  }) : super(key: key);

  @override
  _AddReviewFormState createState() => _AddReviewFormState();
}

class _AddReviewFormState extends State<AddReviewForm> {
  final TextEditingController _commentController = TextEditingController();
  double _selectedRating = 0;

  void _submitReview() async {
    if (_selectedRating == 0 || _commentController.text.isEmpty) {
      // ScaffoldMessenger.of(context).showSnackBar(
      //   SnackBar(
      //       content: Text(
      //     "Add comment and rating: ",
      //   )),
      // );
      Fluttertoast.showToast(msg: "Add comment and rating:");

      return;
    }

    try {
      final reviewProvider =
          Provider.of<ReviewProvider>(context, listen: false);

      await reviewProvider.addReview(
        productId: widget.productId,
        userId: widget.userId,
        rating: _selectedRating,
        comment: _commentController.text,
      );

      // Čišćenje forme nakon dodavanja
      _commentController.clear();
      setState(() {
        _selectedRating = 0;
      });
      await reviewProvider.fetchReviews(widget.productId);
      // Osvjezi UI
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Review successfully added!")),
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error while adding review.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: Colors.white,
        color: Theme.of(context).canvasColor,
        borderRadius: BorderRadius.circular(12), // Zaobljene ivice
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            // color: Colors.grey.withOpacity(0.2),
            spreadRadius: 7,
            blurRadius: 6,
            offset: Offset(0, 6), // Blagi efekat senke
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Rate this product:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(
            height: 5,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                iconSize: 32,
                icon: Icon(
                  index < _selectedRating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                ),
                onPressed: () {
                  setState(() {
                    _selectedRating = index + 1.0;
                  });
                },
              );
            }),
          ),
          TextField(
            controller: _commentController,
            decoration: InputDecoration(labelText: "Your comment"),
            maxLines: 1,
          ),
          SizedBox(height: 10),
          SizedBox(
            height: 5,
          ),
          Align(
            alignment: Alignment.center,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: _submitReview,
              child: Text("Add review",
                  style: TextStyle(
                    color: Colors.white,
                  )),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }
}
