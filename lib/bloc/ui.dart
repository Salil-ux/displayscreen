import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'bloc_bloc.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late HomeBloc _homeBloc;

  @override
  void initState() {
    super.initState();
    _homeBloc = HomeBloc();
  }

  @override
  void dispose() {
    _homeBloc.dispose();
    super.dispose();
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
                        controller: _homeBloc.searchController,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (value) {
                          _homeBloc.search(value);
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search, color: Colors.grey),
                      onPressed: () {
                        _homeBloc.search(_homeBloc.searchController.text);
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
                    Expanded(child: Text("CALL", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20,), textAlign: TextAlign.center,)),
                    Expanded(child: Text("Strike Price", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700), textAlign: TextAlign.center)),
                    Expanded(child: Text("PUT", style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 20), textAlign: TextAlign.center)),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      controller: HomeBloc.scrollController, // ✅ Pass Bloc's ScrollController
                      child: Row(
                        children: [
                          _call(screenWidth),
                          _strikePrice(screenWidth),
                          _put(screenWidth),
                        ],
                      ),
                    ),
                    StreamBuilder<double?>(
                      stream: _homeBloc.foundIndexStream,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return _buildFloatingSpotIndicator(screenHeight, screenWidth, snapshot.data!);
                        }
                        return SizedBox.shrink();
                      },
                    ),
                  ],
                ),
              ),

            ],
          ),
        );
      },
    );
  }

  Widget _buildFloatingSpotIndicator(double screenHeight, double screenWidth, double foundIndex) {
    double offset = foundIndex * 56.0;
    double bottomPadding = MediaQuery.of(context).padding.bottom;
    double scrollOffset = HomeBloc.scrollController.offset;
    double topPadding = MediaQuery.of(context).padding.top;
    double appBarHeight = kToolbarHeight;

    double indicatorPosition = offset - scrollOffset + 10;
    double minPosition = 10;
    double maxPosition = screenHeight - bottomPadding - appBarHeight - topPadding - 50 - 10;

    return Positioned(
      left: MediaQuery.of(context).size.width / 2 - 78,
      top: indicatorPosition.clamp(minPosition, maxPosition),
      child: AnimatedOpacity(
        duration: Duration(milliseconds: 300),
        opacity: 1.0,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(20)),
          child: StreamBuilder<double?>(
            stream: _homeBloc.searchValueStream,
            builder: (context, snapshot) {
              return Text("Spot Price: ${snapshot.data}", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
            },
          ),
        ),
      ),
    );
  }

  Widget _strikePrice(double screenWidth) {
    return Container(
      color: Colors.green,
      width: screenWidth - (2 * screenWidth / 2.7),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: _homeBloc.strikePrices.length,
        itemBuilder: (context, index) {
          return SizedBox(
            height: 56,
            child: ListTile(
              title: Center(
                child: StreamBuilder<double?>(
                  stream: _homeBloc.searchValueStream,
                  builder: (context, snapshot) {
                    return Text(
                      _homeBloc.strikePrices[index].toString(),
                      style: TextStyle(
                        color: (snapshot.data != null && _homeBloc.strikePrices[index] == snapshot.data) ? Colors.yellow : Colors.white,
                      ),
                    );
                  },
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _call(double screenWidth) {
    return Container(
      color: Colors.black87,
      width: screenWidth / 2.7,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(3, (index) {
            return SizedBox(
              width: kIsWeb ? MediaQuery.of(context).size.width / 2.7 / 3 : 70,
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _homeBloc.strikePrices.length,
                itemBuilder: (context, index) {
                  int number = index - 20;
                  Color textColor = number < 0 ? Colors.red : Colors.green;
                  return SizedBox(
                    height: 56,
                    child: ListTile(
                      visualDensity: VisualDensity(vertical: 3),
                      title: Text(number.toString(), style: TextStyle(color: textColor), textAlign: TextAlign.center),
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
    return Container(
      color: Colors.black87,
      width: screenWidth / 2.7 ,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(3, (index) {
            return SizedBox(
              width: kIsWeb ? MediaQuery.of(context).size.width / 2.7 / 3 : 70,
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _homeBloc.strikePrices.length,
                itemBuilder: (context, index) {
                  int number = index - 20;
                  Color textColor = number < 0 ? Colors.red : Colors.green;
                  return SizedBox(
                    height: 56,
                    child: ListTile(
                      visualDensity: VisualDensity(vertical: 3),
                      title: Text(number.toString(), style: TextStyle(color: textColor), textAlign: TextAlign.center),
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