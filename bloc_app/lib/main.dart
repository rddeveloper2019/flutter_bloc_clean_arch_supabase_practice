import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/di/di.dart';
import 'features/auth/presentation/blocs/authentication/authentication_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL'] ?? '',
    anonKey: dotenv.env['SUPABASE_ANON_KEY'] ?? '',
  );

  configureDependencies();
  print('(**) => SUPABASE_URL  :  ${dotenv.env['SUPABASE_URL']}');
  print('(**) => SUPABASE_ANON_KEY  :  ${dotenv.env['SUPABASE_ANON_KEY']}');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider.value(value: getIt<AuthenticationBloc>())],
      child: MaterialApp(
        title: 'Community Board Bloc',
        theme: ThemeData(colorScheme: .fromSeed(seedColor: Colors.deepPurple)),
        home: const Scaffold(
          body: Center(child: Text('Project setup complete')),
        ),
      ),
    );
  }
}
