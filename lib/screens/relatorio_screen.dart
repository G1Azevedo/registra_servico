import 'package:flutter/material.dart';
import '../models/servico.dart';
import '../database/database_helper.dart';
import '../services/pdf_service.dart';
import '../services/pdf_service_premium.dart';

class RelatorioScreen extends StatefulWidget {
  @override
  _RelatorioScreenState createState() => _RelatorioScreenState();
}

class _RelatorioScreenState extends State<RelatorioScreen> {
  DateTime _dataInicio = DateTime.now().subtract(Duration(days: 30));
  DateTime _dataFim = DateTime.now();
  DatabaseHelper dbHelper = DatabaseHelper();
  bool _gerandoPdf = false;

  Future<void> _gerarRelatorio({bool premium = false}) async {
    setState(() {
      _gerandoPdf = true;
    });

    try {
      List<Servico> todosServicos = await dbHelper.getServicos();
      List<Servico> servicosFiltrados = todosServicos.where((servico) {
        return servico.dataServico.isAfter(_dataInicio.subtract(Duration(days: 1))) &&
               servico.dataServico.isBefore(_dataFim.add(Duration(days: 1)));
      }).toList();

      if (servicosFiltrados.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Nenhum serviço encontrado no período selecionado'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      String caminhoArquivo;
      if (premium) {
        caminhoArquivo = await PdfServicePremium.gerarRelatorioPdfPremium(_dataInicio, _dataFim);
      } else {
        caminhoArquivo = await PdfService.gerarRelatorioPdf(_dataInicio, _dataFim);
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Relatório PDF ${premium ? 'Premium ' : ''}gerado com sucesso!\nSalvo em: $caminhoArquivo'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 5),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao gerar relatório: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _gerandoPdf = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gerar Relatório'),
        backgroundColor: Colors.blue[700],
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Selecione o período para o relatório:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 24),
            InkWell(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _dataInicio,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _dataInicio = picked;
                  });
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Data de Início',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  '${_dataInicio.day.toString().padLeft(2, '0')}/${_dataInicio.month.toString().padLeft(2, '0')}/${_dataInicio.year}',
                ),
              ),
            ),
            SizedBox(height: 16),
            InkWell(
              onTap: () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: _dataFim,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (picked != null) {
                  setState(() {
                    _dataFim = picked;
                  });
                }
              },
              child: InputDecorator(
                decoration: InputDecoration(
                  labelText: 'Data de Fim',
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  '${_dataFim.day.toString().padLeft(2, '0')}/${_dataFim.month.toString().padLeft(2, '0')}/${_dataFim.year}',
                ),
              ),
            ),
            SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _gerandoPdf ? null : () => _gerarRelatorio(premium: false),
                icon: _gerandoPdf 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.picture_as_pdf),
                label: Text(
                  _gerandoPdf ? 'Gerando PDF...' : 'Gerar Relatório PDF Simples',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _gerandoPdf ? null : () => _gerarRelatorio(premium: true),
                icon: _gerandoPdf 
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : Icon(Icons.auto_awesome),
                label: Text(
                  _gerandoPdf ? 'Gerando PDF...' : 'Gerar Relatório PDF Premium',
                  style: TextStyle(fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[700],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.purple[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.purple[700], size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'O relatório Premium inclui design aprimorado, estatísticas e layout profissional.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.purple[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

