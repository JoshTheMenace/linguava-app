import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Set to fullscreen immersive mode
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

  // Request permissions
  await _requestPermissions();

  runApp(const MyApp());
}

Future<void> _requestPermissions() async {
  // Request microphone permission for voice interaction
  final microphoneStatus = await Permission.microphone.request();

  if (microphoneStatus.isDenied) {
    print('Microphone permission denied. Voice interaction will not work.');
  }

  if (microphoneStatus.isPermanentlyDenied) {
    print('Microphone permission permanently denied. Please enable it in settings.');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Linguava',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: Colors.black,
        primaryColor: Colors.purpleAccent,
        colorScheme: ColorScheme.dark(
          primary: Colors.purpleAccent,
          secondary: Colors.deepPurpleAccent,
          surface: Colors.black,
        ),
        useMaterial3: true,
      ),
      home: HomeScreen(
        apiKey: dotenv.env['GEMINI_API_KEY'] ?? '',
      ),
    );
  }
}
