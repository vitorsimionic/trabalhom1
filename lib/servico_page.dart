import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'database.dart';

class ServicoPage extends StatefulWidget {
  const ServicoPage({super.key});

  @override
  State<ServicoPage> createState() => _ServicoPageState();
}

class _ServicoPageState extends State<ServicoPage> {
  final _formKey = GlobalKey<FormState>();
  final _descricaoController = TextEditingController();
  final _horasController = TextEditingController();
  final _valorUnitarioController = TextEditingController();
  final _valorTotalController = TextEditingController(text: '0.00');
  
  DateTime _dataSelecionada = DateTime.now();
  String? _clienteSelecionado;
  List<String> _clientes = [];
  final DatabaseHelper _dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _carregarClientes();
  }

  Future<void> _carregarClientes() async {
    final lista = await _dbHelper.getNomesClientes();
    setState(() => _clientes = lista);
  }

  void _calcularTotal() {
    if (_horasController.text.isNotEmpty && _valorUnitarioController.text.isNotEmpty) {
      final horas = double.tryParse(_horasController.text) ?? 0;
      final valorUnitario = double.tryParse(_valorUnitarioController.text) ?? 0;
      final total = horas * valorUnitario;
      
      setState(() {
        _valorTotalController.text = total.toStringAsFixed(2);
      });
    }
  }

  Future<void> _selecionarData(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _dataSelecionada,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && picked != _dataSelecionada) {
      setState(() => _dataSelecionada = picked);
    }
  }

  Future<void> _salvarServico() async {
    if (_formKey.currentState!.validate() && _clienteSelecionado != null) {
      try {
        await _dbHelper.insertServico({
          'cliente': _clienteSelecionado!,
          'descricao': _descricaoController.text,
          'data': DateFormat('yyyy-MM-dd').format(_dataSelecionada),
          'horas': double.parse(_horasController.text),
          'valor_unitario': double.parse(_valorUnitarioController.text),
          'valor_total': double.parse(_valorTotalController.text),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Serviço salvo com sucesso!')),
        );

        // Limpa os campos após salvar
        _descricaoController.clear();
        _horasController.clear();
        _valorUnitarioController.clear();
        _valorTotalController.text = '0.00';
        setState(() => _clienteSelecionado = null);
        
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao salvar: $e')),
        );
      }
    } else if (_clienteSelecionado == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecione um cliente!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadastro de Serviço'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _carregarClientes,
            tooltip: 'Recarregar clientes',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Cliente*',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _clienteSelecionado,
                    hint: const Text('Selecione um cliente'),
                    isExpanded: true,
                    items: _clientes.map((cliente) {
                      return DropdownMenuItem(
                        value: cliente,
                        child: Text(cliente),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _clienteSelecionado = value);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _descricaoController,
                decoration: const InputDecoration(
                  labelText: 'Descrição do Serviço*',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe a descrição';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              InkWell(
                onTap: () => _selecionarData(context),
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Data*',
                    border: OutlineInputBorder(),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(DateFormat('dd/MM/yyyy').format(_dataSelecionada)),
                      const Icon(Icons.calendar_today),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _horasController,
                decoration: const InputDecoration(
                  labelText: 'Horas Trabalhadas*',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _calcularTotal(),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe as horas';
                  if (double.tryParse(value) == null) return 'Valor inválido';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _valorUnitarioController,
                decoration: const InputDecoration(
                  labelText: 'Valor por Hora (R\$)*',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                onChanged: (_) => _calcularTotal(),
                validator: (value) {
                  if (value == null || value.isEmpty) return 'Informe o valor';
                  if (double.tryParse(value) == null) return 'Valor inválido';
                  return null;
                },
              ),

              const SizedBox(height: 16),

              TextFormField(
                controller: _valorTotalController,
                decoration: const InputDecoration(
                  labelText: 'Valor Total (R\$)',
                  border: OutlineInputBorder(),
                  filled: true,
                ),
                readOnly: true,
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _salvarServico,
                  child: const Text('SALVAR SERVIÇO', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _descricaoController.dispose();
    _horasController.dispose();
    _valorUnitarioController.dispose();
    _valorTotalController.dispose();
    super.dispose();
  }
}