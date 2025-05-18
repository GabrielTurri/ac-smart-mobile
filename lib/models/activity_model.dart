import 'package:ac_smart/viewmodels/atividades_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class Activity {
// "_id": "682924ba76b66900579f8ad3",
//       "aluno_id": "6806a78edd1190fa2b330bb7",
//       "data": "Mon, 01 May 2023 00:00:00 GMT",
//       "data_criacao": "Sat, 17 May 2025 21:07:22 GMT",
//       "descricao": "Test activity description",
//       "horas_aprovadas": 0,
//       "horas_solicitadas": 10,
//       "status": "Pendente",
//       "titulo": "Test Activity"

  final String id = uuid.v4();
  final int raAluno = 123456;
  String titulo;
  String descricao;
  String arquivoPath;
  int horasSolicitadas;
  int horasAprovadas = 0;
  DateTime dataEntrega = DateTime.now();
  DateTime dataAtividade = DateTime.utc(2025, 04, 01);
  String status;

  int pageIndex = 0;

  Activity({
    this.titulo = 'Certificado: HTML Básico',
    this.descricao = 'Certificado de curso online de HTML Básico',
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
  Activity novaAtividade = Activity(
    titulo: descricao,
    status: statusSelecionado,
    dataAtividade: dataAtividade,
    arquivoPath: arquivoPath,
  );
  AtividadeProvider().adicionarAtividade(novaAtividade);

  return debugPrint('Nova atividade cadastrada: \n$novaAtividade');

  // Retornar uma mensagem de sucesso
}

Activity consultarAtividade(index) {
  return consultarAtividade(index);
}

void alterarAtividade({
  required id,
  required descricao,
  required statusSelecionado,
  required dataAtividade,
  required arquivoPath,
}) {
  Activity novaAtividade = Activity(
    titulo: descricao,
    status: statusSelecionado,
    dataAtividade: dataAtividade,
    arquivoPath: arquivoPath,
  );
  AtividadeProvider().adicionarAtividade(novaAtividade);

  return debugPrint('Nova atividade cadastrada: \n$novaAtividade');
}
