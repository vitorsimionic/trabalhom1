import 'package:flutter/material.dart';
import 'cadastro_page.dart';
import 'lista_cadastro.dart';
import 'servico_page.dart';
import 'lista_servicos.dart'; 
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Cadastros',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        ),
      ),
      home: const HomePage(), 
      routes: {
        '/cadastro': (context) => const CadastroPage(),
        '/lista-clientes': (context) => const ListaCadastroPage(),
        '/servicos': (context) => const ServicoPage(),
        '/lista-servicos': (context) => const ListaServicosPage(), 
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Menu Principal'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // cadastro de cliente
            _buildMenuButton(
              context,
              icon: Icons.person_add,
              label: 'Cadastrar Cliente',
              route: '/cadastro',
            ),
            const SizedBox(height: 20),
            
            // lista de clients
            _buildMenuButton(
              context,
              icon: Icons.people,
              label: 'Listar Clientes',
              route: '/lista-clientes',
            ),
            const SizedBox(height: 20),
            
            // cadastrasr serviço
            _buildMenuButton(
              context,
              icon: Icons.handyman,
              label: 'Cadastrar Serviço',
              route: '/servicos',
            ),
            const SizedBox(height: 20),
            
            // listar serviço
            _buildMenuButton(
              context,
              icon: Icons.list_alt,
              label: 'Serviços Realizados',
              route: '/lista-servicos',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuButton(BuildContext context, {
    required IconData icon,
    required String label,
    required String route,
  }) {
    return SizedBox(
      width: 250,
      child: ElevatedButton.icon(
        icon: Icon(icon),
        label: Text(label),
        onPressed: () => Navigator.pushNamed(context, route),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
          alignment: Alignment.centerLeft,
        ),
      ),
    );
  }
}