import 'package:intl/intl.dart';

String formatDateToHttp(DateTime dateTime) {
  final DateFormat formatter = DateFormat("y-M-d");
  return formatter.format(dateTime.toUtc());
}

String formatHttpDate(String httpDate) {
  final DateFormat inputFormat =
      DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", 'en_US');
  final DateFormat outputFormat = DateFormat('yyyy-MM-dd');

  DateTime parsedDate = inputFormat.parseUtc(httpDate);
  return outputFormat.format(parsedDate);
}

class Activity {
  String? id;
  String alunoId;
  String dataEntrega;
  String dataAtividade;
  String titulo;
  String descricao;
  // String arquivoPath;
  int horasSolicitadas;
  int horasAprovadas;
  String status;
  String observacao = '';

  Activity({
    this.id,
    required this.alunoId,
    required this.dataAtividade,
    required this.titulo,
    required this.descricao,
    required this.horasSolicitadas,
    this.horasAprovadas = 0,
    String? dataEntrega,
    String? observacao,
    this.status = '',
  }) : dataEntrega = dataEntrega ?? formatDateToHttp(DateTime.now());

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['_id'],
      alunoId: json['aluno_id'],
      dataAtividade: formatHttpDate(json['data']),
      dataEntrega: formatHttpDate(json['data_criacao']),
      descricao: json['descricao'],
      horasAprovadas: json['horas_aprovadas'],
      horasSolicitadas: json['horas_solicitadas'],
      status: json['status'],
      titulo: json['titulo'],
    );
  }
}
