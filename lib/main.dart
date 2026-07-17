import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'providers/chat_provider.dart';
import 'screens/chat_screen.dart';
import 'services/beacon_service.dart';

const String KIWIZ_COPYRIGHT = 
  "@ 2026 rexoe43 - Todos los derechos reservados. "
  "Kiwiz es un asistente de estudio inteligente. "
  "Prohibido la copia, modificación o distribución sin autorización. ";

const String KIWIZ_VERSION = "1.0.0";
void main() async {

  print("==================================");
  print(KIWIZ_COPYRIGHT);
  print("Kiwiz v$KIWIZ_VERSION - Asistente de Estudio Inteligente");
  
  WidgetsFlutterBinding.ensureInitialized();
  
  
  
  await dotenv.load();
  
  
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];
  
  
  if (supabaseUrl == null || supabaseAnonKey == null) {
    throw Exception(
      'Faltan variables de entorno: SUPABASE_URL y SUPABASE_ANON_KEY '
      'deben estar definidas en el archivo .env'
    );
  }
  
  
  await Supabase.initialize(
    url: supabaseUrl,
    publishableKey: supabaseAnonKey,
  );
  
  BeaconService().reportUsage();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: MaterialApp(
        title: 'Kiwiz - Asistente de Estudio',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.green,
            brightness: Brightness.light,
          ),
        ),
        home: const ChatScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
