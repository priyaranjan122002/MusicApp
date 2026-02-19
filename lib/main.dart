
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/di/injection_container.dart' as di;
import 'presentation/screens/library_screen.dart';
import 'presentation/screens/main_screen.dart';
import 'logic/blocs/library_bloc.dart';
import 'core/bloc_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.init();
  Bloc.observer = SimpleBlocObserver();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.sl<LibraryBloc>()..add(LoadTracks())),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Music Library',
        theme: ThemeData(
          brightness: Brightness.dark,
          primarySwatch: Colors.blue,
          scaffoldBackgroundColor: Colors.black,
          useMaterial3: true,
        ),
        home: const MainScreen(),
      ),
    );
  }
}
