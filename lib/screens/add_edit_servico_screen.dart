import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/servico.dart';
import '../models/item_servico.dart';
import '../database/database_helper.dart';

class AddEditServicoScreen extends StatefulWidget {
  final Servico? servico;

  AddEditServicoScreen({this.servico});

  @override
  _AddEditServicoScreenState createState() => _AddEditServicoScreenState();
}

class _AddEditServicoScreenState extends State<AddEditServicoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeClienteController = TextEditingController();
  final _descricaoServicoController = TextEditingController();
  DateTime _dataServico = DateTime.now();
  List<ItemServicoTemp> _itens = [];
  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    if (widget.servico != null) {
      _nomeClienteController.text = widget.servico!.nomeCliente;
      _descricaoServicoController.text = widget.servico!.descricaoServico;
      _dataServico = widget.servico!.dataServico;
      _loadItens();
    } else {
      _adicionarItem();
    }
  }

  Future<void> _loadItens() async {
    if (widget.servico != null) {
      List<ItemServico> itensFromDb = await dbHelper.getItemServicos(widget.servico!.id!);
      setState(() {
        _itens = itensFromDb.map((item) => ItemServicoTemp(
          quantidade: item.quantidade,
          valorUnitario: item.valorUnitario,
        )).toList();
      });
    }
  }

  void _adicionarItem() {
    setState(() {
      _itens.add(ItemServicoTemp(quantidade: 1, valorUnitario: 20.0));
    });
  }

  void _removerItem(int index) {
    setState(() {
      _itens.removeAt(index);
    });
  }

  double _calcularValorTotal() {
    return _itens.fold(0.0, (total, item) => total + (item.quantidade * item.valorUnitario));
  }

  Future<void> _salvarServico() async {
    if (_formKey.currentState!.validate() && _itens.isNotEmpty) {
      double valorTotal = _calcularValorTotal();
      
      Servico servico = Servico(
        id: widget.servico?.id,
        nomeCliente: _nomeClienteController.text,
        dataServico: _dataServico,
        descricaoServico: _descricaoServicoController.text,
        valorTotal: valorTotal,
      );

      int servicoId;
      if (widget.servico == null) {
        servicoId = await dbHelper.insertServico(servico);
      } else {
        await dbHelper.updateServico(servico);
        servicoId = widget.servico!.id!;
        // Remove itens antigos
        await dbHelper.deleteServico(servicoId);
        servicoId = await dbHelper.insertServico(servico);
      }

      // Salva os itens
      for (ItemServicoTemp item in _itens) {
        ItemServico itemServico = ItemServico(
          servicoId: servicoId,
          quantidade: item.quantidade,
          valorUnitario: item.valorUnitario,
        );
        await dbHelper.insertItemServico(itemServico);
      }

      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.servico == null ? 'Novo Serviço' : 'Editar Serviço'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _salvarServico,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _nomeClienteController,
                decoration: InputDecoration(
                  labelText: 'Nome do Cliente *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira o nome do cliente';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              InkWell(
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: _dataServico,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (picked != null) {
                    setState(() {
                      _dataServico = picked;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Data do Serviço',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    '${_dataServico.day.toString().padLeft(2, '0')}/${_dataServico.month.toString().padLeft(2, '0')}/${_dataServico.year}',
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descricaoServicoController,
                decoration: InputDecoration(
                  labelText: 'Descrição do Serviço',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Itens do Serviço',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _adicionarItem,
                    icon: Icon(Icons.add),
                    label: Text('Adicionar Item'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16),
              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _itens.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: TextFormField(
                                  initialValue: _itens[index].quantidade.toString(),
                                  decoration: InputDecoration(
                                    labelText: 'Quantidade',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.number,
                                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                  onChanged: (value) {
                                    setState(() {
                                      _itens[index].quantidade = int.tryParse(value) ?? 1;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                flex: 3,
                                child: TextFormField(
                                  initialValue: _itens[index].valorUnitario.toStringAsFixed(2),
                                  decoration: InputDecoration(
                                    labelText: 'Valor Unitário (R\$)',
                                    border: OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                                  onChanged: (value) {
                                    setState(() {
                                      _itens[index].valorUnitario = double.tryParse(value) ?? 20.0;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 12),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: _itens.length > 1 ? () => _removerItem(index) : null,
                              ),
                            ],
                          ),
                          SizedBox(height: 8),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                'Subtotal: R\$ ${(_itens[index].quantidade * _itens[index].valorUnitario).toStringAsFixed(2)}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[700],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Text(
                  'Valor Total: R\$ ${_calcularValorTotal().toStringAsFixed(2)}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _salvarServico,
                  child: Text(
                    'Salvar Serviço',
                    style: TextStyle(fontSize: 18),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ItemServicoTemp {
  int quantidade;
  double valorUnitario;

  ItemServicoTemp({required this.quantidade, required this.valorUnitario});
}

