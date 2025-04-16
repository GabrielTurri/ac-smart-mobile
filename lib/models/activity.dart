import 'package:ac_smart/viewmodels/atividades_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

var uuid = const Uuid();

class Activity {
  final String id = uuid.v4();
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
  Activity novaAtividade = Activity(
    descricao: descricao,
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
