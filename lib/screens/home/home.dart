import 'package:fan_carousel_image_slider/fan_carousel_image_slider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:lb_tour/screens/discover/booking.dart';
import 'package:lb_tour/screens/discover/discover.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<TouristSpot> touristSpots = [];
  List<TouristSpot> filteredTouristSpots = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchTouristSpots();
    searchController.addListener(() {
      filterResults();
    });
  }

  Future<void> fetchTouristSpots() async {
    DatabaseReference databaseRef =
        FirebaseDatabase.instance.ref().child('TouristSpot');

    databaseRef.once().then((DatabaseEvent event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>;
      setState(() {
        touristSpots = data.values
            .map((e) => TouristSpot.fromMap(e as Map<dynamic, dynamic>))
            .toList(); // Ensure correct type casting to TouristSpot
        filteredTouristSpots = touristSpots;
      });
    }).catchError((error) {
      print("Error fetching data: $error");
    });
  }

  // Filter results based on search query
  void filterResults() {
    String query = searchController.text.toLowerCase();
    setState(() {
      filteredTouristSpots = touristSpots
          .where((spot) =>
              spot.name.toLowerCase().contains(query))
          .toList();
    });
  }

  // Open the booking screen with a given tourist spot
  void openBookingScreen(TouristSpot spot) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingScreen(spot: spot),
      ),
    );
  }

  // Open the web view screen with a given URL
  void openWebView(String url) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => InAppWebViewScreen(url: url),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: <Widget>[
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Image.asset(
                        'assets/images/header.jpg',
                        width: MediaQuery.of(context).size.width,
                        fit: BoxFit.cover,
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: 260,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.white.withOpacity(0.5),
                              Colors.white.withOpacity(0.1),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Column(
                          children: [
                            Text(
                              'Where do you want to go?',
                              style: GoogleFonts.comfortaa(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              child: Card(
                                elevation: 6,
                                child: Column(
                                  children: [
                                    TextField(
                                      controller: searchController,
                                      decoration: InputDecoration(
                                        hintText: 'Search here',
                                        hintStyle: GoogleFonts.comfortaa(),
                                        prefixIcon: const HugeIcon(
                                          icon:
                                              HugeIcons.strokeRoundedLocation04,
                                          color: Colors.grey,
                                          size: 24.0,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        enabledBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        focusedBorder: OutlineInputBorder(
                                          borderRadius:
                                              BorderRadius.circular(8),
                                          borderSide: BorderSide.none,
                                        ),
                                        suffixIcon: const HugeIcon(
                                          icon: HugeIcons.strokeRoundedSearch02,
                                          color: Colors.grey,
                                          size: 24.0,
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                    ),
                                    if (filteredTouristSpots.isNotEmpty &&
                                        searchController.text.isNotEmpty)
                                      ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: filteredTouristSpots.length,
                                        itemBuilder: (context, index) {
                                          final spot =
                                              filteredTouristSpots[index];
                                          return ListTile(
                                            title: Text(spot.name),
                                            onTap: () =>
                                                openWebView(spot.address),
                                          );
                                        },
                                      ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  touristSpots.isNotEmpty
                      ? SizedBox(
                          height: 430,
                          width: MediaQuery.of(context).size.width,
                          child: Stack(
                            children: [
                              FanCarouselImageSlider.sliderType1(
                                imagesLink: touristSpots
                                    .map((spot) => spot.imageUrl)
                                    .toList(),
                                isAssets: false,
                                sliderHeight: 410,
                                showIndicator: true,
                                initalPageIndex:
                                    touristSpots.isNotEmpty ? 0 : 0,
                                indicatorActiveColor:
                                    const Color.fromARGB(255, 14, 86, 170),
                                autoPlay: true,
                                currentItemShadow: const [
                                  BoxShadow(
                                    offset: Offset(1, 1),
                                    color: Color.fromARGB(78, 158, 158, 158),
                                    blurRadius: 10,
                                  ),
                                  BoxShadow(
                                    offset: Offset(-1, -1),
                                    color: Color.fromARGB(78, 158, 158, 158),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              GestureDetector(
                                onTap: () {
                                  if (touristSpots.isNotEmpty) {
                                    openBookingScreen(touristSpots[0]); // Example to open the first tourist spot
                                  }
                                },
                              ),
                            ],
                          ),
                        )
                      : const Center(
                          child: CircularProgressIndicator(
                              color: Color.fromARGB(255, 14, 86, 170)),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InAppWebViewScreen extends StatelessWidget {
  final String url;

  const InAppWebViewScreen({super.key, required this.url});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const HugeIcon(
                icon: HugeIcons.strokeRoundedLocation04,
                color: Color.fromARGB(255, 14, 86, 170),
                size: 24.0),
            const SizedBox(width: 10),
            Text(
              "Tourist Spot",
              style: GoogleFonts.comfortaa(
                fontSize: 14,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.transparent,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft02,
              color: Colors.black,
              size: 24.0),
        ),
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri(url)),
      ),
    );
  }
}
