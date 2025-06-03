# CI/CD Setup para AC Smart Mobile

## Visão Geral

Este documento explica como funciona o pipeline de CI/CD do AC Smart Mobile e como configurá-lo corretamente.

## Funcionalidades do Pipeline

O pipeline de CI/CD implementa:

1. **Testes automáticos** para cada Pull Request
2. **Versionamento Semântico** baseado nas mensagens de commit
3. **Build de APK** para Android
4. **Armazenamento de APKs** em um bucket Hetzner
5. **Criação de releases** no GitHub

## Configuração de Secrets no GitHub

Para que o pipeline funcione corretamente, é necessário configurar os seguintes secrets no repositório GitHub:

### Secrets do Hetzner Storage (obrigatórios para armazenar APKs)

| Nome do Secret | Descrição |
|----------------|-----------|
| `HETZNER_ENDPOINT` | URL do endpoint S3-compatível do Hetzner Storage Box |
| `HETZNER_ACCESS_KEY` | Chave de acesso para o Hetzner Storage |
| `HETZNER_SECRET_KEY` | Chave secreta para o Hetzner Storage |
| `HETZNER_BUCKET` | Nome do bucket no Hetzner Storage |

### Secrets para Assinatura de APK (opcionais para builds de release)

| Nome do Secret | Descrição |
|----------------|-----------|
| `KEY_PROPERTIES` | Conteúdo do arquivo `key.properties` para assinatura do APK |
| `KEYSTORE_JKS_BASE64` | Arquivo keystore codificado em base64 |

## Como configurar o Keystore para Android

1. Gere um keystore para assinatura:
```bash
keytool -genkey -v -keystore keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

2. Crie um arquivo `key.properties` com o seguinte conteúdo:
```
storePassword=<senha do keystore>
keyPassword=<senha da chave>
keyAlias=upload
storeFile=keystore.jks
```

3. Converta o arquivo keystore para base64:
```bash
base64 -w 0 keystore.jks
```

4. Adicione o conteúdo dos arquivos como secrets no GitHub:
   - Conteúdo do `key.properties` → `KEY_PROPERTIES`
   - Output do comando base64 → `KEYSTORE_JKS_BASE64`

## Trabalhando com Versionamento Semântico

Para que o pipeline incremente corretamente a versão do app, siga o padrão de mensagens de commit conforme descrito no arquivo [VERSIONING.md](../VERSIONING.md).

## Execução Manual do Pipeline

Você pode executar manualmente o pipeline de CI/CD através da interface do GitHub:

1. Acesse a aba "Actions" no repositório
2. Selecione o workflow "Flutter CI/CD"
3. Clique em "Run workflow"
4. Selecione a branch (geralmente `main`)
5. Clique em "Run workflow"

## Troubleshooting

Se o pipeline falhar:

1. **Erro de build**: Verifique se a versão do Flutter no workflow é compatível com o SDK requerido no `pubspec.yaml`
2. **Erro de upload**: Verifique se os secrets do Hetzner estão configurados corretamente
3. **Erro de keystore**: Verifique se os secrets de assinatura estão configurados corretamente
