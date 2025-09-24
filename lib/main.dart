import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Weather App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CityListPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CityListPage extends StatelessWidget {
  const CityListPage({super.key});

  final List<String> cities = const [
    "London",
    "Paris",
    "Tokyo",
    "Jakarta",
    "New York",
    "Sydney",
    "Berlin",
    "Moscow",
    "Toronto",
    "Dubai",
    "Singapore",
    "Bangkok",
    "Los Angeles",
    "Chicago",
    "Hong Kong",
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: const Text("Select a City")),
        body: ListView.builder(
          itemCount: cities.length,
          itemBuilder: (context, index) {
            final city = cities[index];
            return ListTile(
              title: Text(city),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => WeatherDetailPage(city: city),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class WeatherDetailPage extends StatefulWidget {
  final String city;
  const WeatherDetailPage({super.key, required this.city});

  @override
  State<WeatherDetailPage> createState() => _WeatherDetailPageState();
}

class _WeatherDetailPageState extends State<WeatherDetailPage> {
  String _temperature = "";
  String _description = "";
  String _iconUrl = "";
  bool _loading = true;
  String _error = "";

  Future<void> fetchWeather() async {
    const apiKey = "OpenWeatherAPIKey"; // Masukkan API Key disini
    final url =
        "https://api.openweathermap.org/data/2.5/weather?q=${widget.city}&appid=$apiKey&units=metric";

    try {
      debugPrint("Fetching weather for: ${widget.city}");
      final response = await http.get(Uri.parse(url));
      debugPrint("Status: ${response.statusCode}");
      debugPrint("Body: ${response.body}");

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _temperature = "${data["main"]["temp"]} °C";
          _description = data["weather"][0]["description"];
          _iconUrl =
              "http://openweathermap.org/img/wn/${data["weather"][0]["icon"]}@2x.png";
          _loading = false;
        });
      } else {
        setState(() {
          _error = "Failed to load weather (Code ${response.statusCode})";
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = "Error: $e";
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(title: Text(widget.city)),
        body: Center(
          child: _loading
              ? const CircularProgressIndicator()
              : _error.isNotEmpty
                  ? Text(
                      _error,
                      style: const TextStyle(color: Colors.red),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (_iconUrl.isNotEmpty)
                          Image.network(_iconUrl, height: 100),
                        Text(
                          widget.city,
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _temperature,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          _description,
                          style: const TextStyle(
                            fontSize: 20,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}
