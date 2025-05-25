import 'dart:io';

class Activity {
  String? id;
  String alunoId;
  DateTime dataEntrega;
  DateTime dataAtividade;
  String titulo;
  String descricao;
  // String arquivoPath;
  int horasSolicitadas;
  int horasAprovadas;
  String status;

  Activity({
    this.id,
    required this.alunoId,
    required this.dataAtividade,
    required this.titulo,
    required this.descricao,
    required this.horasSolicitadas,
    this.horasAprovadas = 0,
    DateTime? dataEntrega,
    this.status = '',
  }) : dataEntrega = dataEntrega ?? DateTime.now();

  factory Activity.fromJson(Map<String, dynamic> json) {
    return Activity(
      id: json['_id'],
      alunoId: json['aluno_id'],
      dataAtividade: HttpDate.parse(json['data']),
      dataEntrega: HttpDate.parse(json['data_criacao']),
      descricao: json['descricao'],
      horasAprovadas: json['horas_aprovadas'],
      horasSolicitadas: json['horas_solicitadas'],
      status: json['status'],
      titulo: json['titulo'],
    );
  }
}
