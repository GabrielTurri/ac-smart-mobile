class Activity {
  final int id;
  final int raAluno = 123456;
  final String descricao;
  final String anexo;
  final int horasSolicitadas;
  final int horasAprovadas = 0;
  final DateTime dataEntrega = DateTime.now();
  final String status = 'Pendente';

  int pageIndex = 0;
  Activity({
    required this.id,
    this.descricao = 'Certificado: HTML Básico',
    this.anexo = 'teste.png',
    this.horasSolicitadas = 4,
  });

  // cadastrarAtividade() {

  // }
}
