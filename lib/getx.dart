import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  final TextEditingController searchController = TextEditingController();
  var foundIndex = Rx<double?>(null);
  var searchValue = Rx<double?>(null);
  var scrollOffset = 0.0.obs;

  final List<double> strikePrices = List.generate(
    100,
        (index) => (index * 10) + 100.00,
  );
  final ScrollController mainScrollController = ScrollController();

  @override
  void onInit() {
    super.onInit();
    mainScrollController.addListener(() {
      scrollOffset.value = mainScrollController.offset;
    });
  }

  void search(String query) {
    double? value = double.tryParse(query);
    double minValue = strikePrices.first;
    double maxValue = strikePrices.last;

    if (value == null || value < minValue || value > maxValue) {
      foundIndex.value = null;
      searchValue.value = null;
      return;
    }

    int lowerIndex = strikePrices.indexWhere((price) => price >= value);
    if (lowerIndex == -1) {
      foundIndex.value = null;
      searchValue.value = null;
      return;
    }

    int upperIndex = (lowerIndex == 0) ? 0 : lowerIndex - 1;
    double lowerValue = strikePrices[upperIndex];
    double upperValue = strikePrices[lowerIndex];

    double index =
        upperIndex + (value - lowerValue) / (upperValue - lowerValue);

    searchValue.value = value;

    scrollToIndex(index);
  }

  void scrollToIndex(double index) async {
    double targetOffset = index * 56.0;

    await mainScrollController.animateTo(
      targetOffset,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    foundIndex.value = index;
    update();
  }
}


class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final HomeController controller = Get.put(HomeController());

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        double screenHeight = constraints.maxHeight;
        double screenWidth = constraints.maxWidth;

        return Scaffold(
          appBar: AppBar(
            backgroundColor: Theme
                .of(context)
                .colorScheme
                .inversePrimary,
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
                        controller: controller.searchController,
                        decoration: InputDecoration(
                          hintText: 'Search',
                          border: InputBorder.none,
                        ),
                        onSubmitted: (value) {
                          controller.search(value);
                        },
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.search, color: Colors.grey),
                      onPressed: () {
                        controller.search(controller.searchController.text);
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
                    Expanded(
                      child: Text(
                        "CALL",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Strike Price",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "PUT",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Stack(
                  children: [
                    SingleChildScrollView(
                      controller: controller.mainScrollController,
                      child: Row(
                        children: [
                          _call(screenWidth, context),
                          _strikePrice(screenWidth, controller),
                          _put(screenWidth, context),
                        ],
                      ),
                    ),
                    Obx(
                          () =>
                      controller.foundIndex.value != null
                          ? _buildFloatingSpotIndicator(
                        screenHeight,
                        screenWidth,
                        controller,
                        context,
                      )
                          : SizedBox.shrink(),
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

  Widget _strikePrice(double screenWidth, HomeController controller) {
    return Container(
      color: Colors.green,
      width: screenWidth - (2 * screenWidth / 2.7),
      child: ListView.builder(
        shrinkWrap: true,
        physics: NeverScrollableScrollPhysics(),
        itemCount: controller.strikePrices.length,
        itemBuilder: (context, index) {
          return SizedBox(
            height: 56,
            child: ListTile(
              title: Center(
                child: Obx(
                      () =>
                      Text(
                        controller.strikePrices[index].toString(),
                        style: TextStyle(
                          color:
                          (controller.searchValue.value != null &&
                              controller.strikePrices[index] ==
                                  controller.searchValue.value)
                              ? Colors.yellow
                              : Colors.white,
                        ),
                      ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _call(double screenWidth, BuildContext context) {
    return Container(
      color: Colors.black87,
      width: screenWidth / 2.7,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(3, (index) {
            return SizedBox(
              width: kIsWeb ? MediaQuery
                  .of(context)
                  .size
                  .width / 2.7 / 3 : 70,
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 100,
                itemBuilder: (context, index) {
                  int number = index - 20;
                  Color textColor = number < 0 ? Colors.red : Colors.green;
                  return SizedBox(
                    height: 56,
                    child: ListTile(
                      visualDensity: VisualDensity(vertical: 3),
                      title: Text(
                        number.toString(),
                        style: TextStyle(color: textColor),
                        textAlign: TextAlign.center,
                      ),
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

  Widget _put(double screenWidth, BuildContext context) {
    return Container(
      color: Colors.black87,
      width: screenWidth / 2.7,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: List.generate(3, (index) {
            return SizedBox(
              width: kIsWeb ? MediaQuery
                  .of(context)
                  .size
                  .width / 2.7 / 3 : 70,
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: 100,
                itemBuilder: (context, index) {
                  int number = index - 20;
                  Color textColor = number < 0 ? Colors.red : Colors.green;
                  return SizedBox(
                    height: 56,
                    child: ListTile(
                      visualDensity: VisualDensity(vertical: 3),
                      title: Text(
                        number.toString(),
                        style: TextStyle(color: textColor),
                        textAlign: TextAlign.center,
                      ),
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

  Widget _buildFloatingSpotIndicator(double screenHeight,
      double screenWidth,
      HomeController controller,
      BuildContext context,) {
    return Obx(() {
      if (controller.foundIndex.value == null) return SizedBox.shrink();

      double offset = controller.foundIndex.value! * 56.0;
      double scrollOffset = controller.scrollOffset.value;
      double topPadding = MediaQuery
          .of(context)
          .padding
          .top;
      double bottomPadding = MediaQuery
          .of(context)
          .padding
          .bottom;
      double appBarHeight = kToolbarHeight;

      double indicatorPosition = offset - scrollOffset + 10;
      double minPosition = 10;
      double maxPosition = screenHeight - bottomPadding - appBarHeight -
          topPadding - 60;

      double finalPosition = indicatorPosition.clamp(minPosition, maxPosition);

      return Positioned(
        left: MediaQuery
            .of(context)
            .size
            .width / 2 - 78,
        top: finalPosition,
        child: AnimatedOpacity(
          duration: Duration(milliseconds: 300),
          opacity: 1.0,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              "Spot Price: ${controller.searchValue.value}",
              style: TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    });
  }
}