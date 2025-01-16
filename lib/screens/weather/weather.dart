import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

// Replace with your actual API key
const String openWeatherAPIKey = '32eaca329590d8262fac84eb5de5a30f';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Map<String, dynamic> selectedForecast; // Selected forecast data
  late String selectedType; // "hourly" or "daily"
  late String displayDateTime; // To show the selected date or hour
  bool isLoading = true; // Loading state
  int? selectedRowIndex; // Track selected row index for highlighting
  int? selectedHourlyIndex; // Track selected hourly index for highlighting

  Future<Map<String, dynamic>> getCurrentWeather() async {
    try {
      String cityName = 'Philippines';
      final res = await http.get(
        Uri.parse(
          'https://api.openweathermap.org/data/2.5/forecast?q=$cityName&APPID=$openWeatherAPIKey',
        ),
      );
      final data = jsonDecode(res.body);

      // After data is loaded, stop loading indicator
      setState(() {
        isLoading = false;
      });

      return data;
    } catch (e) {
      setState(() {
        isLoading = false; // Ensure loading stops even if there's an error
      });
      throw e.toString();
    }
  }

  @override
  void initState() {
    super.initState();
    selectedType = "daily"; // Default selected forecast type
    selectedForecast = {
      "name": "Today",
      "temp": "Loading...",
      "condition": "Loading...",
    }; // Default forecast values
    displayDateTime = DateFormat('MMM dd, yyyy').format(DateTime.now()); // Default display value
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
        future: getCurrentWeather(),
    builder: (context, snapshot) {
    if (isLoading && !snapshot.hasData) {
    // Show CircularProgressIndicator only during the initial load
    return const Center(
    child: CircularProgressIndicator(
    color: Color.fromARGB(255, 14, 86, 170),
    ),
    );
    }

    if (snapshot.hasError) {
    return Center(child: Text(snapshot.error.toString()));
    }

    final data = snapshot.data!;
    final currentWeatherData = data['list'][0];
    final currentTemp =
    (currentWeatherData['main']['temp'] - 273.15).toStringAsFixed(1);
    final currentSky = currentWeatherData['weather'][0]['main'];

    // Update "Today" forecast
    if (selectedForecast["temp"] == "Loading...") {
    selectedForecast = {
    "name": "Today",
    "temp": currentTemp,
    "condition": currentSky,
    };
    }

    // Grouping data for daily and hourly forecasts
    final dailyForecast = _groupDailyForecast(data['list']);
    final interpolatedHourlyForecast =
    _interpolateHourlyForecast(data['list']);

    return Container(
    decoration: const BoxDecoration(
    color: Colors.white,
    ),
    child: SafeArea(
    child: Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
    // Dynamic Header Section (Updates on selection)
    Column(
    children: [
    Text(
    selectedForecast["name"],
    style: GoogleFonts.roboto(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    ),
    ),
    const SizedBox(height: 8),
    Text(
    '${selectedForecast["temp"]}°C',
    style: GoogleFonts.roboto(
    fontSize: 72,
    fontWeight: FontWeight.bold,
    color: Color.fromARGB(255, 14, 86, 170),
    ),
    ),
    const SizedBox(height: 4),
    Text(
    selectedForecast["condition"],
    style: GoogleFonts.roboto(
    fontSize: 28,
    fontWeight: FontWeight.normal,
    color: Colors.black,
    ),
    ),
    const SizedBox(height: 8),
    Text(
    displayDateTime,
    style: GoogleFonts.roboto(
    fontSize: 22,
    color: Color.fromARGB(255, 14, 86, 170),
    ),
    ),
    ],
    ),
    const SizedBox(height: 20),

    // Hourly Forecast Section
    Column(
    children: [
    Align(
    alignment: Alignment.centerLeft,
    child: Text(
    "Hourly Forecast",
    style: GoogleFonts.roboto(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    ),
    ),
    ),
    const SizedBox(height: 12),
    SizedBox(
    height: 120,
    child: ListView.builder(
    scrollDirection: Axis.horizontal,
    itemCount: interpolatedHourlyForecast.length,
    itemBuilder: (context, index) {
    final forecast = interpolatedHourlyForecast[index];
    final isSelected = index == selectedHourlyIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = "hourly";
          selectedHourlyIndex = index; // Highlight the selected hour
          selectedRowIndex = null; // Clear daily selection
          selectedForecast = {
            "name": "Hourly Forecast",
            "temp": forecast['temp'],
            "condition": "${forecast['rain']}% Rain",
          };
          displayDateTime = DateFormat(
              'MMM dd, yyyy - h a')
              .format(forecast['time']);
        });
      },

      child: Container(
    margin:
    const EdgeInsets.symmetric(horizontal: 8),
    padding: const EdgeInsets.all(8),
    decoration: BoxDecoration(
    color: isSelected
    ? Colors.lightBlueAccent
        .withOpacity(0.3)
        : Colors.transparent,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(
    color: isSelected
    ? Color.fromARGB(255, 14, 86, 170)
        : Colors.grey.shade300,
    ),
    ),
    child: Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
    Text(
    DateFormat('h a')
        .format(forecast['time']),
    style: GoogleFonts.roboto(
    color: Colors.black,
    fontWeight: FontWeight.bold,
    fontSize: 18,
    ),
    ),
    const SizedBox(height: 4),
    Text(
    '${forecast['temp']}°C',
    style: GoogleFonts.comfortaa(

    color: Color.fromARGB(255, 14, 86, 170),

    fontSize: 16,
    ),
    ),
    const SizedBox(height: 4),
    Text(
    "${forecast['rain']}% Rain",
    style: GoogleFonts.roboto(
    color: Colors.black54,
    fontSize: 14,
    ),
    ),
    ],
    ),
    ),
    );
    },
    ),
    ),
    ],
    ),

    const SizedBox(height: 20),

    // Daily Forecast Section
    Column(
    children: [
    Align(
    alignment: Alignment.centerLeft,
    child: Text(
    "Daily Forecast",
    style: GoogleFonts.roboto(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: Colors.black,
    ),
    ),
    ),
    const SizedBox(height: 12),
    SizedBox(
    height: 250,
    child: ListView.builder(
    itemCount: dailyForecast.length,
    itemBuilder: (context, index) {
    final dayForecast = dailyForecast[index];
    final isSelected = index == selectedRowIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedType = "daily";
          selectedRowIndex = index; // Highlight the selected row
          selectedHourlyIndex = null; // Clear hourly selection
          selectedForecast = {
            "name": DateFormat('EEEE')
                .format(dayForecast['date']),
            "temp": dayForecast['averageTemp'],
            "condition":
            "Rain: ${dayForecast['rainPercentage']}%",
          };
          displayDateTime = DateFormat(
              'MMM dd, yyyy')
              .format(dayForecast['date']);
        });
      },

      child: Container(
    margin:
    const EdgeInsets.symmetric(vertical: 4),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
    color: isSelected
    ? Colors.lightBlueAccent
        .withOpacity(0.3)
        : Colors.transparent,
    borderRadius: BorderRadius.circular(10),
    border: Border.all(
    color: isSelected
    ? Colors.lightBlueAccent
        : Colors.grey.shade300,
    ),
    ),
    child: Row(
    mainAxisAlignment:
    MainAxisAlignment.spaceBetween,
    children: [
    Text(
    DateFormat('EEEE')
        .format(dayForecast['date']),
    style: GoogleFonts.roboto(
    color: Colors.black,
    fontSize: 18,
    ),
    ),
    Text(
    '${dayForecast['rainPercentage']}% Rain',
    style: GoogleFonts.roboto(
    color: Colors.black,
    fontSize: 18,
    ),
    ),
    Text(
    '${dayForecast['averageTemp']}°C',
    style: GoogleFonts.roboto(

    color: Color.fromARGB(255, 14, 86, 170),
    fontSize: 18,
    ),
    ),
    ],
    ),
    ),
    );
    },
    ),
    ),
    ],
    ),
    ],
    ),
    ),
    ),
    );
    },
        ),
    );
  }

  List<Map<String, dynamic>> _groupDailyForecast(List<dynamic> list) {
    Map<String, List<dynamic>> grouped = {};

    for (var item in list) {
      final date = DateTime.parse(item['dt_txt']);
      final dayKey = DateFormat('yyyy-MM-dd').format(date);
      if (grouped.containsKey(dayKey)) {
        grouped[dayKey]!.add(item);
      } else {
        grouped[dayKey] = [item];
      }
    }

    return grouped.entries.map((entry) {
      final rainPercentage = (entry.value.fold<double>(0, (sum, item) {
        return sum + (item['rain']?['3h'] ?? 0);
      }) / entry.value.length).toStringAsFixed(0);

      final averageTemp = (entry.value.fold<double>(0, (sum, item) {
        return sum + item['main']['temp'];
      }) / entry.value.length - 273.15).toStringAsFixed(1);

      return {
        'date': DateTime.parse(entry.key),
        'rainPercentage': rainPercentage,
        'averageTemp': averageTemp,
      };
    }).toList();
  }

  List<Map<String, dynamic>> _interpolateHourlyForecast(List<dynamic> list) {
    List<Map<String, dynamic>> hourlyForecast = [];

    for (int i = 0; i < list.length - 1; i++) {
      final current = list[i];
      final next = list[i + 1];

      final currentTime = DateTime.parse(current['dt_txt']);
      final nextTime = DateTime.parse(next['dt_txt']);

      final timeDifference = nextTime.difference(currentTime).inHours;
      final tempDifference =
          (next['main']['temp'] - current['main']['temp']) / timeDifference;
      final rainDifference =
          ((next['rain']?['3h'] ?? 0) - (current['rain']?['3h'] ?? 0)) /
              timeDifference;
      final sky = current['weather'][0]['main'];

      for (int j = 0; j < timeDifference; j++) {
        final interpolatedTime = currentTime.add(Duration(hours: j));
        final interpolatedTemp =
            (current['main']['temp'] + tempDifference * j) - 273.15;
        final interpolatedRain =
        ((current['rain']?['3h'] ?? 0) + rainDifference * j)
            .toStringAsFixed(0);

        hourlyForecast.add({
          'time': interpolatedTime,
          'temp': interpolatedTemp.toStringAsFixed(1),
          'sky': sky,
          'rain': interpolatedRain,
        });
      }
    }

    return hourlyForecast;
  }
}
