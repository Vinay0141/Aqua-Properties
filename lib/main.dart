import 'package:aqua_properties/features/nav_bar/nav_bar_bloc/tab_bloc.dart';
import 'package:aqua_properties/features/nav_view/home/home_screen.dart';
import 'package:aqua_properties/print_screen.dart';
import 'package:aqua_properties/view/pdf_download_screen.dart';
import 'package:aqua_properties/view/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_downloader/flutter_downloader.dart';

Future<void> main() async {

  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Flutter Downloader
  await FlutterDownloader.initialize(debug: true);



  runApp(const MyApp());
}




class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TabBloc()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
          useMaterial3: true,
        ),
        home: SplashScreen(),
      ),
    );
  }
}

