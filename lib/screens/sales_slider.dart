import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/inventory_provider.dart';

class SalesSlider extends StatefulWidget {
  final int currentMonth;
  final int currentYear;
  const SalesSlider({super.key, required this.currentMonth, required this.currentYear});

  @override
  _SalesSliderState createState() => _SalesSliderState();
}

class _SalesSliderState extends State<SalesSlider> {
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(viewportFraction: 0.85, initialPage: 0);
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 4), (Timer timer) {
      if (!mounted) return;
      final provider = Provider.of<InventoryProvider>(context, listen: false);
      final sales = provider.getFilteredSliderSales(widget.currentMonth, widget.currentYear);

      if (sales.isNotEmpty) {
        if (_currentPage < sales.length - 1) {
          _currentPage++;
        } else {
          _currentPage = 0;
        }

        if (_pageController.hasClients) {
          _pageController.animateToPage(
            _currentPage,
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeInOutQuart,
          );
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  final List<List<Color>> gradients = [
    [const Color(0xFF0F2027), const Color(0xFF203A43)],
    [const Color(0xFF373331), const Color(0xFF4b4431)],
    [const Color(0xFF1e130c), const Color(0xFF9a8478)],
    [const Color(0xFF000428), const Color(0xFF004e92)],
  ];

  @override
  Widget build(BuildContext context) {
    return Selector<InventoryProvider, List<dynamic>>(
      selector: (_, provider) => provider.getFilteredSliderSales(widget.currentMonth, widget.currentYear),
      builder: (context, sales, child) {
        if (sales.isEmpty) {
          return const Center(
            child: Text("No sales this month", style: TextStyle(color: Colors.white54, fontSize: 12)),
          );
        }

        return Column(
          children: [
            SizedBox(
              height: 120,
              child: RepaintBoundary(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: sales.length,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    _currentPage = index;
                  },
                  itemBuilder: (context, index) {
                    return SalesCardItem(
                      sale: sales[index],
                      gradient: gradients[index % gradients.length],
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class SalesCardItem extends StatelessWidget {
  final dynamic sale;
  final List<Color> gradient;

  const SalesCardItem({super.key, required this.sale, required this.gradient});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white10,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.sell_rounded, color: Colors.amberAccent, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    sale['name'] ?? 'Fabric Item',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15),
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Qty: ${sale['qty']} ${sale['unit']}",
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                  Text(
                    "Color: ${sale['colorName'] ?? 'No Color'}",
                    style: const TextStyle(
                        color: Colors.amberAccent,
                        fontSize: 12,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  "Rs. ${sale['totalPrice']}",
                  style: const TextStyle(
                      color: Colors.greenAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 16),
                ),
                const Text("Paid",
                    style: TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
