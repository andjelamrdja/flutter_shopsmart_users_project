import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';

class ProductGallery extends StatefulWidget {
  final List<String> imageUrls;

  const ProductGallery({Key? key, required this.imageUrls}) : super(key: key);

  @override
  _ProductGalleryState createState() => _ProductGalleryState();
}

class _ProductGalleryState extends State<ProductGallery> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CarouselSlider(
          options: CarouselOptions(
            height: 100.0, // Smanjena visina slika
            enlargeCenterPage: true,
            autoPlay: true,
            autoPlayInterval: Duration(seconds: 3),
            viewportFraction: 0.4, // Smanjuje širinu slika
            onPageChanged: (index, reason) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          items: widget.imageUrls.map((url) {
            return GestureDetector(
              onTap: () {
                _openFullScreen(context, widget.imageUrls, _currentIndex);
              },
              child: ClipRRect(
                borderRadius:
                    BorderRadius.circular(10), // Blago zaobljeni uglovi
                child: Image.network(
                  url,
                  fit: BoxFit.cover,
                  width: 100, // Širina jednaka visini za kvadratni oblik
                  height: 100,
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: widget.imageUrls.asMap().entries.map((entry) {
            return GestureDetector(
              onTap: () => setState(() {
                _currentIndex = entry.key;
              }),
              child: Container(
                width: 6.0,
                height: 6.0,
                margin: EdgeInsets.symmetric(horizontal: 3.0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentIndex == entry.key ? Colors.blue : Colors.grey,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _openFullScreen(
      BuildContext context, List<String> imageUrls, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            FullScreenImageGallery(imageUrls: imageUrls, initialIndex: index),
      ),
    );
  }
}

class FullScreenImageGallery extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const FullScreenImageGallery(
      {Key? key, required this.imageUrls, required this.initialIndex})
      : super(key: key);

  @override
  _FullScreenImageGalleryState createState() => _FullScreenImageGalleryState();
}

class _FullScreenImageGalleryState extends State<FullScreenImageGallery> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: PageView.builder(
              itemCount: widget.imageUrls.length,
              controller: PageController(initialPage: _currentIndex),
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return InteractiveViewer(
                  child: Image.network(widget.imageUrls[index],
                      fit: BoxFit.contain),
                );
              },
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 30),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }
}
