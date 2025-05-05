import 'package:ac_smart/viewmodels/atividades_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class Activity {
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
