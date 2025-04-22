import 'package:flutter/material.dart';
import 'database.dart';

class ListaCadastroPage extends StatelessWidget {
  const ListaCadastroPage({super.key});

  @override
  Widget build(BuildContext context) {
    final DatabaseHelper dbHelper = DatabaseHelper();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Lista de Cadastros'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: dbHelper.getAllCadastros(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Nenhum cadastro encontrado.'));
          } else {
            final cadastros = snapshot.data!;
            return ListView.builder(
              itemCount: cadastros.length,
              itemBuilder: (context, index) {
                final cadastro = cadastros[index];
                return ListTile(
                  title: Text(cadastro['nome']),
                  subtitle: Text(
                      '${cadastro['telefone']} - ${cadastro['endereco']}'),
                  trailing: const Icon(Icons.arrow_forward),
                );
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pop(context), 
        child: const Icon(Icons.add),
      ),
    );
  }
}