import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Result extends StatefulWidget {
  final String place;
  const Result({super.key, required this.place});

  @override
  State<Result> createState() => _ResultState();
}

class _ResultState extends State<Result> {
  Future<Map<String, dynamic>> getDatafromApi() async {
    final apiKey = dotenv.env['API_KEY'];
    final baseUrl = dotenv.env['API_URL'];
    final apiUrl = "$baseUrl?q=${widget.place}&appid=$apiKey&units=metric";
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception("Error!!");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Hasil track",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: Container(
        padding: const EdgeInsets.only(left: 70, right: 70),
        child: FutureBuilder<Map<String, dynamic>>(
          future: getDatafromApi(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasData) {
              final data = snapshot.data!;
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data["name"],
                    style: const TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  Image.network(
                      'https://flagsapi.com/${data["sys"]["country"]}/shiny/64.png'),
                  Text(
                    data["weather"][0]["main"],
                    style: const TextStyle(
                      fontSize: 30,
                    ),
                  ),
                  Image.network(
                      'https://openweathermap.org/img/wn/${data["weather"][0]["icon"]}@2x.png'),
                  Text(
                    'Terasa seperti: ${data["main"]["feels_like"]} °C',
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                  Text(
                    'Kecepatan Angin: ${data["wind"]["speed"]} m/s',
                    style: const TextStyle(
                      fontSize: 20,
                    ),
                  ),
                ],
              );
            } else {
              return const Center(
                child: Text("Data tidak ditemukan"),
              );
            }
          },
        ),
      ),
    );
  }
}
