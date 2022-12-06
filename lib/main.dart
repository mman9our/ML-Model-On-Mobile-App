import 'dart:convert';
import 'package:flutter_localizations/flutter_localizations.dart';
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
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('ar', 'AE'),
      ],
      theme: ThemeData(
        fontFamily: 'Cairo',
        textTheme: ThemeData.light().textTheme.copyWith(
              headline5: TextStyle(
                color: Colors.black87,
                fontSize: 22,
                fontFamily: 'Cario',
              ),
              headline6: TextStyle(
                color: Colors.black87,
                fontSize: 26,
                fontFamily: 'Cario',
                fontWeight: FontWeight.bold,
              ),
            ),
      ),
      title: "Sentiment Analysis for Shoppy App",
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String text = "";
  String sentimentReuslt = "";
  // String sentimentScore = "";

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shoppy App"),
        centerTitle: true,
        backgroundColor: Color.fromARGB(0xFF, 43, 45, 57),
      ),
      body: Container(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 100),
              Container(
                width: MediaQuery.of(context).size.width,
                child: Form(
                  key: _formKey,
                  child: TextField(
                    style: Theme.of(context).textTheme.headline5,
                    onChanged: (value) {
                      setState(() {
                        text = value;
                      });
                    },
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Color.fromARGB(0xFF, 230, 230, 240),
                      hintText: "أدخل النص",
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.black87, width: 2),
                          borderRadius: BorderRadius.all(Radius.circular(30))),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black87, width: 2),
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              TextButton.icon(
                style: TextButton.styleFrom(
                  foregroundColor: Color.fromARGB(0xFF, 230, 230, 240),
                  backgroundColor: Color.fromARGB(0xFF, 43, 45, 57),
                ),
                onPressed: () async {
                  final url = Uri.http("10.0.2.2:5000", "/");

                  final response = await http.post(url,
                      body: json.encode(
                        {'text': text},
                      ),
                      headers: {
                        'Content-Type': "application/json; charset=utf-8"
                      });
                  print('StatusCode ${response.statusCode}');
                  print('Return Data: ${response.body}');

                  if (response.statusCode == 200) {
                    final jsonResponse =
                        jsonDecode(response.body) as Map<String, dynamic>;

                    sentimentReuslt = jsonResponse['sentiment'];
                    // sentimentScore = jsonResponse['score'];

                    print(sentimentReuslt);

                    // print(sentimentScore);

                    setState(() {
                      sentimentReuslt = sentimentReuslt;
                      // sentimentScore = sentimentScore;
                    });
                  } else {
                    print("Request field with status: ${response.statusCode}");
                  }
                },
                icon: Icon(
                  Icons.sentiment_neutral,
                  color: Color.fromARGB(0xFF, 230, 230, 240),
                  size: 30,
                ),
                label: Text(
                  "توقع المشاعر",
                  style: Theme.of(context)
                      .textTheme
                      .headline6
                      ?.apply(color: Color.fromARGB(0xFF, 230, 230, 240)),
                ),
              ),
              SizedBox(height: 10),
              Text(
                "النص : $text",
                style: TextStyle(
                  color: Color.fromARGB(0xFF, 43, 45, 57),
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 5),
              Text(
                "التوقع : $sentimentReuslt",
                style: TextStyle(
                  color: Color.fromARGB(0xFF, 43, 45, 57),
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 5),
              // Text(
              //   "النسبة: $sentimentScore",
              //   style: TextStyle(
              //     color: Color.fromARGB(0xFF, 43, 45, 57),
              //     fontSize: 18,
              //     fontWeight: FontWeight.w400,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
