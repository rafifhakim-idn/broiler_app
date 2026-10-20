import 'package:flutter/material';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'config/supabase_config.dart';
import 'providers/auth_provider.dart';
import 'screens/auth/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkCurrentUser()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Usaha Ayam Broiler',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1B5E20),
          primary: const Color(0xFF1B5E20),
          secondary: const Color(0xFFE65100),
        ),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.currentUser == null) {
            return const LoginScreen();
          }

          final profile = auth.userProfile;
          if (profile == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // Jika user mendaftar tapi belum di-approve oleh Super Admin
          if (!profile.isApproved) {
            return Scaffold(
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.hourglass_top, size: 64, color: Colors.orange),
                      const SizedBox(height: 16),
                      const Text(
                        'Menunggu Persetujuan Super Admin',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Akun (${profile.fullName}) ber-role ${profile.role} telah terdaftar. Hubungi Pemilik Usaha untuk menyetujui akun Anda.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () => auth.signOut(),
                        child: const Text('Keluar / Logout'),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          // Jika sudah approved, masuk ke Dashboard
          return Scaffold(
            appBar: AppBar(
              title: Text('Selamat Datang, ${profile.fullName}'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.logout),
                  onPressed: () => auth.signOut(),
                ),
              ],
            ),
            body: Center(
              child: Text(
                'Dashboard Utama (${profile.role.toUpperCase()})',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }
}