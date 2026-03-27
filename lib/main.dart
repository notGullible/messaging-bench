import 'package:flutter/material.dart';
import 'package:ng_messaging_bench/pages/sms_page.dart';
import 'package:flutter_embedder/flutter_embedder.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFlutterEmbedder();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  

  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {    
    return const MaterialApp(
      title: 'messaging_bench',
      home: ClassificationScreen(),
    );
  }
}



