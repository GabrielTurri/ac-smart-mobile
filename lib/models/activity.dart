class Activity {
  final int id;
  final int raAluno = 123456;
  final String descricao;
  final String anexo;
  final int horasSolicitadas;
  final int horasAprovadas = 0;
  final DateTime dataEntrega = DateTime.now();
  final String status;

  int pageIndex = 0;
  Activity({
    required this.id,
    this.descricao = 'Certificado: HTML Básico',
    this.anexo = 'teste.png',
    this.horasSolicitadas = 4,
    this.status = 'Pendente',
  });

  // cadastrarAtividade() {

  // }
}

get atividades => _atividades;

final List<Activity> _atividades = [
  Activity(id: 1, descricao: 'Palestra Python', horasSolicitadas: 4),
  Activity(
      id: 2,
      descricao: 'Palestra Machine Learning',
      horasSolicitadas: 8,
      status: 'Reprovada'),
  Activity(
      id: 3,
      descricao: 'Certificado: HTML Básico',
      horasSolicitadas: 4,
      status: 'Aprovada'),
];
Activity ConsultarAtividade(index) {
  return atividades[index];
}
