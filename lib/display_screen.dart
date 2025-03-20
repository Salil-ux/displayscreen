import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _searchController = TextEditingController();
  double? _foundIndex;
  double? _searchValue;
  final List<double> _strikePrices = List.generate(100, (index) => (index*10) + 100.00);
  final List<GlobalKey> _strikePriceKeys = List.generate(100, (index) => GlobalKey());
  final ScrollController _mainScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _mainScrollController.addListener(() {
      setState(() {

      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double screenHeight = constraints.maxHeight;
        double screenWidth = constraints.maxWidth;

      return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search',
                        border: InputBorder.none,
                      ),
                      onSubmitted: (value) {
                        _search(value);
                      },
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search, color: Colors.grey),
                    onPressed: () {
                      _search(_searchController.text);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
        body: Column(
          children: [
            Container(
              height: 50,
              color: Colors.black87,
              child: Row(
                children: [
                  Expanded(child: Text("CALL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20,),textAlign: TextAlign.center,)),
                  Expanded(child: Text("Strike Price", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),textAlign: TextAlign.center)),
                  Expanded(child: Text("PUT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20),textAlign: TextAlign.center)),
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    controller: _mainScrollController,
                    child: Row(
                      children: [
                        _call(screenWidth),
                        _strikePrice(screenWidth),
                        _put(screenWidth),
                      ],
                    ),
                  ),
                  if (_foundIndex != null) _buildFloatingSpotIndicator(screenHeight, screenWidth),
                ],
              ),
            ),
          ],
        ),
      );}
    );
  }

  void _search(String query) {
    double? searchValue = double.tryParse(query);
    double minValue = _strikePrices.first;
    double maxValue = _strikePrices.last;

    if (searchValue == null) {
      setState(() {
        _foundIndex = null;
        _searchValue = null;
      });
      return;
    }
    if (searchValue < minValue || searchValue > maxValue) {
      setState(() {
        _foundIndex = null;
        _searchValue = null;
      });
      return;
    }

    int lowerIndex = _strikePrices.indexWhere((price) => price >= searchValue);
    if (lowerIndex == -1) {
      setState(() {
        _foundIndex = null;
        _searchValue = null;
      });
      return;
    }

    int upperIndex = (lowerIndex == 0) ? 0 : lowerIndex - 1;
    double lowerValue = _strikePrices[upperIndex];
    double upperValue = _strikePrices[lowerIndex];

    double foundIndex = upperIndex + (searchValue - lowerValue) / (upperValue - lowerValue);

    setState(() {
      _foundIndex = foundIndex;
      _searchValue = searchValue;
    });

    _scrollToIndex(foundIndex);
    }


  void _scrollToIndex(double index) {
    _mainScrollController.animateTo(
      index * 56.0,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }


  Widget _buildFloatingSpotIndicator(double screenHeight,double screenWidth) {

    double offset = _foundIndex! * 56.0;
    double bottomPadding = MediaQuery.of(context).padding.bottom;
    double scrollOffset = _mainScrollController.offset;
    double topPadding = MediaQuery.of(context).padding.top;
    double appBarHeight = kToolbarHeight;

    double indicatorPosition = offset - scrollOffset + 10;
    double minPosition = 10;
    double maxPosition = screenHeight - bottomPadding - appBarHeight - topPadding - 50 - 10;
    double maxWebPosition = screenHeight - bottomPadding - appBarHeight - topPadding - 50 - 50;

      double finalWebPosition = indicatorPosition.clamp(minPosition, maxWebPosition);
      double finalPosition = indicatorPosition.clamp(minPosition, maxPosition);

    return Positioned(
      left: MediaQuery.of(context).size.width / 2 - 78,
      top: kIsWeb? finalWebPosition : finalPosition ,
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 300),
        opacity: _foundIndex != null ? 1.0 : 0.0,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
          child: Text("Spot Price: $_searchValue", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }


  Widget _strikePrice(double screenWidth) {
    return Container(
      color: Colors.green,
     width: screenWidth - (2*screenWidth/2.7),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _strikePrices.length,
        itemBuilder: (context, index) {
          return SizedBox(
            height: 56,
            child: ListTile(
              key: _strikePriceKeys[index],
              title: Center(
                child: Text(
                  _strikePrices[index].toString(),
                  style: TextStyle(
                    color: (_searchValue != null && _strikePrices[index] == _searchValue) ? Colors.yellow : Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _call(double screenWidth) {
    return  Container(
      color: Colors.black87,
      width: screenWidth/2.7,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(3, (index) {
            return SizedBox(
              width: kIsWeb? MediaQuery.of(context).size.width / 2.7/3 : 70,
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _strikePrices.length,
                itemBuilder: (context, index) {
                  int number = index - 20;
                  Color textColor = number < 0 ? Colors.red : Colors.green;
                  return SizedBox(
                    height: 56,
                    child: ListTile(
                      visualDensity: VisualDensity(vertical: 3),
                      title: Text(number.toString(), style: TextStyle(color: textColor),textAlign: TextAlign.center),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }

  Widget _put(double screenWidth) {
    return  Container(
      color: Colors.black87,
      width: screenWidth/2.7,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(3, (index) {
            return SizedBox(
              width: kIsWeb? MediaQuery.of(context).size.width / 2.7/3 : 70,
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _strikePrices.length,
                itemBuilder: (context, index) {
                  int number = index - 20;
                  Color textColor = number < 0 ? Colors.red : Colors.green;
                  return SizedBox(
                    height: 56,
                    child: ListTile(
                      visualDensity: VisualDensity(vertical: 3),
                      title: Text(number.toString(), style: TextStyle(color: textColor),textAlign: TextAlign.center),
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ),
    );
  }
}
