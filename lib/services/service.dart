class Service {
  // URL para ambiente de desenvolvimento local (comentado):
  // final String _url = 'http://10.0.2.2:5000';

  // URL para ambiente de produção:
  final String _url = 'https://ac-smart.sanchez.dev.br';
  // final String _url = 'https://ac-smart-backup.sanchez.dev.br';
  final String _backupUrl = 'https://ac-smart-backup.sanchez.dev.br';

  String get url => _url;
  String get backupUrl => _backupUrl;
}
