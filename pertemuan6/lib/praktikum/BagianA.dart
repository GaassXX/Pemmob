
import 'package:flutter/material.dart';

final themeMode = ValueNotifier<ThemeMode>(ThemeMode.light);
final seedColor = ValueNotifier<Color>(Colors.indigo);

const pilihanWarna = [
  Colors.indigo,
  Colors.teal,
  Colors.deepOrange,
  Colors.pink,
];

ThemeData buatTema(Color seed, Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    colorSchemeSeed: seed,
    brightness: brightness,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
    ),
  );
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        themeMode,
        seedColor,
      ]),
      builder: (context, _) {
        return MaterialApp(
          title: 'Praktikum 6',
          debugShowCheckedModeBanner: false,
          theme: buatTema(
            seedColor.value,
            Brightness.light,
          ),
          darkTheme: buatTema(
            seedColor.value,
            Brightness.dark,
          ),
          themeMode: themeMode.value,
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Pengaturan Tema'),
            ),
            body: const PengaturanTab(),
          ),
        );
      },
    );
  }
}

class PengaturanTab extends StatelessWidget {
  const PengaturanTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        themeMode,
        seedColor,
      ]),
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pengaturan Tampilan',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Ubah tema dan warna aplikasi '
                      'sesuai keinginan.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Mode gelap'),
              subtitle: const Text(
                'Aktifkan tema gelap aplikasi',
              ),
              secondary: const Icon(Icons.dark_mode),
              value: themeMode.value == ThemeMode.dark,
              onChanged: (v) {
                themeMode.value = v
                    ? ThemeMode.dark
                    : ThemeMode.light;
              },
            ),
            const SizedBox(height: 16),
            Text(
              'Warna tema',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final warna in pilihanWarna)
                  GestureDetector(
                    onTap: () {
                      seedColor.value = warna;
                    },
                    child: CircleAvatar(
                      radius: 28,
                      backgroundColor: warna,
                      child: seedColor.value == warna
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Card(
              color: Theme.of(context)
                  .colorScheme
                  .primaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    Icon(
                      Icons.palette,
                      size: 36,
                      color: Theme.of(context)
                          .colorScheme
                          .onPrimaryContainer,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        'Contoh tampilan tema',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
