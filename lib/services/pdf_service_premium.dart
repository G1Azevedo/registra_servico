import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import '../models/servico.dart';
import '../database/database_helper.dart';

class PdfServicePremium {
  static Future<String> gerarRelatorioPdfPremium(DateTime dataInicio, DateTime dataFim) async {
    DatabaseHelper dbHelper = DatabaseHelper();
    
    // Buscar todos os serviços
    List<Servico> todosServicos = await dbHelper.getServicos();
    
    // Filtrar serviços por período
    List<Servico> servicosFiltrados = todosServicos.where((servico) {
      return servico.dataServico.isAfter(dataInicio.subtract(Duration(days: 1))) &&
             servico.dataServico.isBefore(dataFim.add(Duration(days: 1)));
    }).toList();

    // Ordenar por data
    servicosFiltrados.sort((a, b) => a.dataServico.compareTo(b.dataServico));

    // Calcular estatísticas
    double valorTotal = servicosFiltrados.fold(0.0, (total, servico) => total + servico.valorTotal);
    int totalServicos = servicosFiltrados.length;
    double valorMedio = totalServicos > 0 ? valorTotal / totalServicos : 0.0;

    // Criar o documento PDF
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            // Cabeçalho Principal
            pw.Container(
              width: double.infinity,
              child: pw.Column(
                children: [
                  // Logo/Título Principal
                  pw.Container(
                    width: double.infinity,
                    padding: pw.EdgeInsets.symmetric(vertical: 30, horizontal: 40),
                    decoration: pw.BoxDecoration(
                      gradient: pw.LinearGradient(
                        colors: [PdfColors.blue800, PdfColors.blue600],
                        begin: pw.Alignment.topLeft,
                        end: pw.Alignment.bottomRight,
                      ),
                      borderRadius: pw.BorderRadius.circular(15),
                    ),
                    child: pw.Column(
                      children: [
                        pw.Text(
                          'RELATÓRIO DE SERVIÇOS ELÉTRICOS',
                          style: pw.TextStyle(
                            fontSize: 28,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.white,
                            letterSpacing: 1.2,
                          ),
                          textAlign: pw.TextAlign.center,
                        ),
                        pw.SizedBox(height: 15),
                        pw.Container(
                          width: 100,
                          height: 3,
                          decoration: pw.BoxDecoration(
                            color: PdfColors.amber,
                            borderRadius: pw.BorderRadius.circular(2),
                          ),
                        ),
                        pw.SizedBox(height: 15),
                        pw.Text(
                          'Período: ${_formatarDataCompleta(dataInicio)} a ${_formatarDataCompleta(dataFim)}',
                          style: pw.TextStyle(
                            fontSize: 16,
                            color: PdfColors.white,
                            fontWeight: pw.FontWeight.normal,
                          ),
                        ),
                        pw.SizedBox(height: 8),
                        pw.Text(
                          'Relatório gerado em ${_formatarDataCompleta(DateTime.now())} às ${_formatarHora(DateTime.now())}',
                          style: pw.TextStyle(
                            fontSize: 12,
                            color: PdfColors.blue100,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  pw.SizedBox(height: 30),

                  // Resumo Executivo
                  pw.Container(
                    width: double.infinity,
                    padding: pw.EdgeInsets.all(25),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.grey50,
                      borderRadius: pw.BorderRadius.circular(12),
                      border: pw.Border.all(color: PdfColors.grey200, width: 1),
                    ),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'RESUMO EXECUTIVO',
                          style: pw.TextStyle(
                            fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800,
                          ),
                        ),
                        pw.SizedBox(height: 15),
                        pw.Row(
                          mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatCard('Total de Serviços', totalServicos.toString(), PdfColors.blue600),
                            _buildStatCard('Valor Total', 'R\$ ${valorTotal.toStringAsFixed(2)}', PdfColors.green600),
                            _buildStatCard('Valor Médio', 'R\$ ${valorMedio.toStringAsFixed(2)}', PdfColors.orange600),
                          ],
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(height: 30),

                  // Título da Lista de Serviços
                  pw.Container(
                    width: double.infinity,
                    padding: pw.EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                    decoration: pw.BoxDecoration(
                      color: PdfColors.blue700,
                      borderRadius: pw.BorderRadius.circular(8),
                    ),
                    child: pw.Text(
                      'DETALHAMENTO DOS SERVIÇOS REALIZADOS',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.white,
                      ),
                      textAlign: pw.TextAlign.center,
                    ),
                  ),

                  pw.SizedBox(height: 20),
                ],
              ),
            ),

            // Lista de serviços
            ...servicosFiltrados.asMap().entries.map((entry) {
              int index = entry.key;
              Servico servico = entry.value;
              
              return pw.Container(
                margin: pw.EdgeInsets.only(bottom: 20),
                decoration: pw.BoxDecoration(
                  color: PdfColors.white,
                  borderRadius: pw.BorderRadius.circular(12),
                  border: pw.Border.all(color: PdfColors.grey300, width: 1),
                ),
                child: pw.Column(
                  children: [
                    // Cabeçalho do serviço
                    pw.Container(
                      width: double.infinity,
                      padding: pw.EdgeInsets.all(20),
                      decoration: pw.BoxDecoration(
                        color: index % 2 == 0 ? PdfColors.blue50 : PdfColors.green50,
                        borderRadius: pw.BorderRadius.only(
                          topLeft: pw.Radius.circular(12),
                          topRight: pw.Radius.circular(12),
                        ),
                      ),
                      child: pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Expanded(
                            child: pw.Column(
                              crossAxisAlignment: pw.CrossAxisAlignment.start,
                              children: [
                                pw.Text(
                                  '${(index + 1).toString().padLeft(2, '0')}. ${servico.nomeCliente.toUpperCase()}',
                                  style: pw.TextStyle(
                                    fontSize: 16,
                                    fontWeight: pw.FontWeight.bold,
                                    color: PdfColors.blue800,
                                  ),
                                ),
                                pw.SizedBox(height: 5),
                                pw.Text(
                                  'Data: ${_formatarDataCompleta(servico.dataServico)}',
                                  style: pw.TextStyle(
                                    fontSize: 12,
                                    color: PdfColors.grey700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          pw.Container(
                            padding: pw.EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                            decoration: pw.BoxDecoration(
                              color: PdfColors.green600,
                              borderRadius: pw.BorderRadius.circular(20),
                            ),
                            child: pw.Text(
                              'R\$ ${servico.valorTotal.toStringAsFixed(2)}',
                              style: pw.TextStyle(
                                fontSize: 14,
                                fontWeight: pw.FontWeight.bold,
                                color: PdfColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Descrição do serviço
                    pw.Container(
                      width: double.infinity,
                      padding: pw.EdgeInsets.all(20),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                            'Descrição do Serviço:',
                            style: pw.TextStyle(
                              fontSize: 12,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.grey700,
                            ),
                          ),
                          pw.SizedBox(height: 8),
                          pw.Text(
                            servico.descricaoServico,
                            style: pw.TextStyle(
                              fontSize: 13,
                              color: PdfColors.grey800,
                              lineSpacing: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),

            pw.SizedBox(height: 30),

            // Total Final
            pw.Container(
              width: double.infinity,
              padding: pw.EdgeInsets.all(30),
              decoration: pw.BoxDecoration(
                gradient: pw.LinearGradient(
                  colors: [PdfColors.green600, PdfColors.green700],
                  begin: pw.Alignment.topLeft,
                  end: pw.Alignment.bottomRight,
                ),
                borderRadius: pw.BorderRadius.circular(15),
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    'VALOR TOTAL DOS SERVIÇOS',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  pw.Text(
                    'R\$ ${valorTotal.toStringAsFixed(2)}',
                    style: pw.TextStyle(
                      fontSize: 32,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    '${totalServicos} serviços realizados',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.green100,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 40),

            // Rodapé
            pw.Container(
              width: double.infinity,
              padding: pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                border: pw.Border(
                  top: pw.BorderSide(color: PdfColors.grey300, width: 2),
                ),
              ),
              child: pw.Column(
                children: [
                  pw.Text(
                    'Relatório gerado automaticamente pelo aplicativo Registra Serviço',
                    style: pw.TextStyle(
                      fontSize: 11,
                      color: PdfColors.grey600,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                  pw.SizedBox(height: 5),
                  pw.Text(
                    'Sistema de Gestão de Serviços Elétricos - Versão 1.0',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey500,
                    ),
                    textAlign: pw.TextAlign.center,
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    // Salvar o arquivo
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/relatorio_premium_${DateTime.now().millisecondsSinceEpoch}.pdf');
    await file.writeAsBytes(await pdf.save());

    return file.path;
  }

  static pw.Widget _buildStatCard(String titulo, String valor, PdfColor cor) {
    return pw.Container(
      padding: pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.white,
        borderRadius: pw.BorderRadius.circular(8),
        border: pw.Border.all(color: cor, width: 2),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            titulo,
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey600,
              fontWeight: pw.FontWeight.bold,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            valor,
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: cor,
            ),
            textAlign: pw.TextAlign.center,
          ),
        ],
      ),
    );
  }

  static String _formatarDataCompleta(DateTime data) {
    List<String> meses = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return '${data.day} de ${meses[data.month - 1]} de ${data.year}';
  }

  static String _formatarHora(DateTime data) {
    return '${data.hour.toString().padLeft(2, '0')}:${data.minute.toString().padLeft(2, '0')}';
  }
}

