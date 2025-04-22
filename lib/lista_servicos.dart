import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database.dart';

class ListaServicosPage extends StatefulWidget {
  const ListaServicosPage({super.key});

  @override
  State<ListaServicosPage> createState() => _ListaServicosPageState();
}

class _ListaServicosPageState extends State<ListaServicosPage> {
  final DatabaseHelper _dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _servicos = [];
  bool _carregando = true;
  String _filtro = 'Todos';

  @override
  void initState() {
    super.initState();
    _carregarServicos();
  }

  Future<void> _carregarServicos() async {
    setState(() => _carregando = true);
    final dados = await _dbHelper.getAllServicos();
    setState(() {
      _servicos = dados;
      _carregando = false;
    });
  }

  Future<void> _filtrarServicos(String cliente) async {
    setState(() => _carregando = true);
    final dados = cliente == 'Todos'
        ? await _dbHelper.getAllServicos()
        : await _dbHelper.getServicosPorCliente(cliente);
    setState(() {
      _servicos = dados;
      _carregando = false;
    });
  }

  Future<void> _deletarServico(int id) async {
    await _dbHelper.deleteServico(id);
    _carregarServicos();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serviços Realizados'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarServicos,
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtro por cliente
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: FutureBuilder<List<String>>(
              future: _dbHelper.getNomesClientes(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox();
                final clientes = ['Todos', ...snapshot.data!];
                return DropdownButton<String>(
                  value: _filtro,
                  items: clientes.map((cliente) {
                    return DropdownMenuItem(
                      value: cliente,
                      child: Text(cliente),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _filtro = value!);
                    _filtrarServicos(value == 'Todos' ? 'Todos' : value!);
                  },
                );
              },
            ),
          ),
          Expanded(
            child: _carregando
                ? const Center(child: CircularProgressIndicator())
                : _servicos.isEmpty
                    ? const Center(child: Text('Nenhum serviço encontrado'))
                    : ListView.builder(
                        itemCount: _servicos.length,
                        itemBuilder: (context, index) {
                          final servico = _servicos[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            child: ListTile(
                              title: Text(servico['cliente']),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(servico['descricao']),
                                  Text(
                                    'Data: ${DateFormat('dd/MM/yyyy').format(DateTime.parse(servico['data']))}',
                                  ),
                                  Text(
                                    'Valor: R\$${servico['valor_total'].toStringAsFixed(2)}',
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deletarServico(servico['id']),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.pushNamed(context, '/servicos'),
        child: const Icon(Icons.add),
      ),
    );
  }
}