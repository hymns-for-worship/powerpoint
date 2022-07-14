import 'package:flutter/material.dart';
import 'package:powerpoint/slide_viewer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter PowerPoint',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const PowerPointExample(),
    );
  }
}

class PowerPointExample extends StatelessWidget {
  const PowerPointExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SlidesView(
      title: const Text('Presentation Example'),
      slides: [
        TextSlide(
          name: '1',
          text: 'Slide 1',
          color: Colors.black,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white.withOpacity(0.67),
          ),
        ),
        TextSlide(
          name: '2',
          text: 'Slide 2',
          color: Colors.black,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white.withOpacity(0.67),
          ),
        ),
        TextSlide(
          name: '3',
          text: 'Slide 3',
          color: Colors.black,
          style: TextStyle(
            fontSize: 18,
            color: Colors.white.withOpacity(0.67),
          ),
        ),
      ],
      onEnd: () {},
    );
  }
}
