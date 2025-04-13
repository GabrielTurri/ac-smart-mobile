class Activity {
  final int id;
  final int raAluno = 123456;
  final String descricao;
  final String anexo;
  final int horasSolicitadas;
  final int horasAprovadas = 0;
  final DateTime dataEntrega = DateTime.now();
  final DateTime dataAtividade = DateTime.utc(2025, 04, 01);
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

List<Activity> get atividades => _atividades;

final List<Activity> _atividades = [
  Activity(id: 0, descricao: 'Palestra Python', horasSolicitadas: 4),
  Activity(
      id: 1,
      descricao: 'Palestra Machine Learning',
      horasSolicitadas: 8,
      status: 'Reprovada'),
  Activity(
      id: 2,
      descricao: 'Certificado: HTML Básico',
      horasSolicitadas: 4,
      status: 'Aprovada'),
];
Activity consultarAtividade(index) {
  return atividades[index];
}
