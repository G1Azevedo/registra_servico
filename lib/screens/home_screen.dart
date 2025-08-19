import 'package:flutter/material.dart';
import '../models/servico.dart';
import '../database/database_helper.dart';
import 'add_edit_servico_screen.dart';
import 'relatorio_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Servico> servicos = [];
  DatabaseHelper dbHelper = DatabaseHelper();

  @override
  void initState() {
    super.initState();
    _loadServicos();
  }

  Future<void> _loadServicos() async {
    List<Servico> servicosFromDb = await dbHelper.getServicos();
    setState(() {
      servicos = servicosFromDb;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Registra Serviço'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.assessment),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => RelatorioScreen()),
              );
            },
          ),
        ],
      ),
      body: servicos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.work_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Nenhum serviço registrado',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Toque no botão + para adicionar um novo serviço',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: servicos.length,
              itemBuilder: (context, index) {
                Servico servico = servicos[index];
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    title: Text(
                      servico.nomeCliente,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 4),
                        Text(
                          servico.descricaoServico,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${servico.dataServico.day.toString().padLeft(2, '0')}/${servico.dataServico.month.toString().padLeft(2, '0')}/${servico.dataServico.year}',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                            Text(
                              'R\$ ${servico.valorTotal.toStringAsFixed(2)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[700],
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddEditServicoScreen(servico: servico),
                        ),
                      ).then((_) => _loadServicos());
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEditServicoScreen()),
          ).then((_) => _loadServicos());
        },
        icon: Icon(Icons.add),
        label: Text('Novo Serviço'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
    );
  }
}

