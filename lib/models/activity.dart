import 'package:flutter/material.dart';

class Activity {
  final int id;
  final int raAluno = 123456;
  final String descricao;
  final String arquivoPath;
  final int horasSolicitadas;
  final int horasAprovadas = 0;
  final DateTime dataEntrega = DateTime.now();
  DateTime dataAtividade = DateTime.utc(2025, 04, 01);
  final String status;

  int pageIndex = 0;
  Activity({
    required this.id,
    this.descricao = 'Certificado: HTML Básico',
    this.arquivoPath = 'teste.png',
    required this.dataAtividade,
    this.horasSolicitadas = 4,
    this.status = 'Pendente',
  });
}

void incluirAtividade({
  required descricao,
  required statusSelecionado,
  required dataAtividade,
  required arquivoPath,
}) {
  int novoId = atividades.last.id + 1;
  Activity novaAtividade = Activity(
    id: novoId,
    descricao: descricao,
    status: statusSelecionado,
    dataAtividade: dataAtividade,
    arquivoPath: arquivoPath,
  );
  // atividades.add(novaAtividade);
  return debugPrint('Nova atividade cadastrada: \n$novaAtividade');
  // Retornar uma mensagem de sucesso
}

List<Activity> get atividades => _atividades;

final List<Activity> _atividades = [
  Activity(
      id: 0,
      descricao: 'Palestra Python',
      horasSolicitadas: 4,
      dataAtividade: DateTime(2025, 04)),
  Activity(
    id: 1,
    descricao: 'Palestra Machine Learning',
    horasSolicitadas: 8,
    status: 'Reprovada',
    dataAtividade: DateTime(2025, 04),
  ),
  Activity(
    id: 2,
    descricao: 'Certificado: HTML Básico',
    horasSolicitadas: 4,
    status: 'Aprovada',
    dataAtividade: DateTime(2025, 04),
  ),
];
Activity consultarAtividade(index) {
  return atividades[index];
}
