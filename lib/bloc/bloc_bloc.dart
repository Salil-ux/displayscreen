import 'dart:async';
import 'package:flutter/material.dart';

class HomeBloc {
  final TextEditingController searchController = TextEditingController();
  final List<double> strikePrices = List.generate(100, (index) => (index * 10) + 100.00);
  static final ScrollController scrollController = ScrollController();

  final _foundIndexController = StreamController<double?>.broadcast();
  final _searchValueController = StreamController<double?>.broadcast();

  Stream<double?> get foundIndexStream => _foundIndexController.stream;
  Stream<double?> get searchValueStream => _searchValueController.stream;

  void search(String query) {
    double? searchValue = double.tryParse(query);
    double minValue = strikePrices.first;
    double maxValue = strikePrices.last;

    if (searchValue == null || searchValue < minValue || searchValue > maxValue) {
      _foundIndexController.sink.add(null);
      _searchValueController.sink.add(null);
      return;
    }

    int lowerIndex = strikePrices.indexWhere((price) => price >= searchValue);
    if (lowerIndex == -1) {
      _foundIndexController.sink.add(null);
      _searchValueController.sink.add(null);
      return;
    }

    int upperIndex = (lowerIndex == 0) ? 0 : lowerIndex - 1;
    double lowerValue = strikePrices[upperIndex];
    double upperValue = strikePrices[lowerIndex];

    double foundIndex = lowerIndex + (searchValue - lowerValue) / (upperValue - lowerValue);

    // Emit values
    _foundIndexController.sink.add(foundIndex);
    _searchValueController.sink.add(searchValue);

    // Scroll to the found index
    scrollToIndex(foundIndex);
  }

  void scrollToIndex(double index) {
    double scrollPosition = index * 56.0; // Adjust based on item height
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollPosition,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  void dispose() {
    _foundIndexController.close();
    _searchValueController.close();
    scrollController.dispose();
  }
}
