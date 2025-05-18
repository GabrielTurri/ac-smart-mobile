from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity, get_jwt
from models.atividade import Atividade
from models.aluno import Aluno
import os
from datetime import datetime
from utils.json_utils import serialize_mongo_doc
from utils.mongo_utils import json_response

atividades_blueprint = Blueprint('atividades', __name__)

@atividades_blueprint.route('/', methods=['GET'])
@jwt_required()
def listar_atividades():
    """
    Lista todas as atividades complementares com filtros opcionais
    
    Query params:
        - pagina: Número da página (padrão: 1)
        - limite: Número de itens por página (padrão: 20)
        - status: Filtrar pelo status das atividades
        - aluno_id: Filtrar pelo ID do aluno
    
    Returns:
        - atividades: Lista de atividades
        - total: Total de atividades
        - pagina: Página atual
        - total_paginas: Total de páginas
    """
    # O identity é o ID do usuário como string
    usuario_id = get_jwt_identity()
    
    # Obter claims adicionais do token
    claims = get_jwt()
    role = claims.get('role')
    
    # Parâmetros de paginação
    pagina = int(request.args.get('pagina', 1))
    limite = int(request.args.get('limite', 20))
    
    # Filtros
    filtros = {}
    
    # Aplicar filtro de status se fornecido
    if 'status' in request.args:
        filtros['status'] = request.args.get('status')
    
    # Se for um aluno, mostrar apenas as atividades dele
    if role == 'student':
        filtros['aluno_id'] = usuario_id
    # Se for coordenador e especificou um aluno, mostrar as atividades daquele aluno
    elif role == 'coordinator' and 'aluno_id' in request.args:
        filtros['aluno_id'] = request.args.get('aluno_id')
    
    # Buscar atividades
    atividade_model = Atividade()
    atividades = atividade_model.buscar_todas(filtros, limite, pagina)
    
    # Contar total para paginação
    total = len(atividade_model.buscar_todas(filtros, 0, 0))
    total_paginas = (total + limite - 1) // limite if limite > 0 else 1
    
    return jsonify({
        'atividades': atividades,
        'total': total,
        'pagina': pagina,
        'total_paginas': total_paginas
    }), 200

@atividades_blueprint.route('/<atividade_id>', methods=['GET'])
@jwt_required()
def buscar_atividade(atividade_id):
    """
    Busca uma atividade complementar pelo ID
    
    Args:
        atividade_id (str): ID da atividade
    
    Returns:
        - atividade: Dados da atividade
    """
    # O identity é o ID do usuário como string
    usuario_id = get_jwt_identity()
    
    # Obter claims adicionais do token
    claims = get_jwt()
    role = claims.get('role')
    
    # Buscar atividade
    atividade_model = Atividade()
    atividade = atividade_model.buscar_por_id(atividade_id)
    
    if not atividade:
        return jsonify({'erro': 'Atividade não encontrada'}), 404
    
    # Verificar permissões
    if role == 'student' and atividade.get('aluno_id') != usuario_id:
        return jsonify({'erro': 'Permissão negada. Você só pode visualizar suas próprias atividades'}), 403
    
    return jsonify({'atividade': atividade}), 200

@atividades_blueprint.route('/', methods=['POST'])
@jwt_required()
def criar_atividade():
    """
    Cria uma nova atividade complementar
    
    Request:
        - titulo: Título da atividade
        - descricao: Descrição da atividade
        - horas_solicitadas: Horas solicitadas
        - data: Data da atividade (formato: YYYY-MM-DD)
        - anexo_base64: Arquivo anexo em formato base64 (opcional)
    
    Returns:
        - id: ID da atividade criada
        - mensagem: Mensagem de sucesso
    """
    # O identity é o ID do usuário como string
    usuario_id = get_jwt_identity()
    
    # Obter claims adicionais do token
    claims = get_jwt()
    role = claims.get('role')
    
    if role != 'student':
        return jsonify({'erro': 'Apenas alunos podem criar atividades complementares'}), 403
    
    dados = request.get_json()
    
    # Mapear campos em inglês para português
    field_mapping = {
        'title': 'titulo',
        'description': 'descricao',
        'requested_hours': 'horas_solicitadas',
        'completion_date': 'data',
        'student_id': 'aluno_id'
    }
    
    # Criar um dicionário normalizado com os campos em português
    dados_normalizados = {}
    for eng_field, pt_field in field_mapping.items():
        if eng_field in dados:
            dados_normalizados[pt_field] = dados[eng_field]
    
    # Adicionar campos que já estão em português
    for campo in ['titulo', 'descricao', 'horas_solicitadas', 'data', 'aluno_id']:
        if campo in dados:
            dados_normalizados[campo] = dados[campo]
    
    # Validar dados
    campos_obrigatorios = ['titulo', 'descricao', 'horas_solicitadas', 'data']
    for campo in campos_obrigatorios:
        if campo not in dados_normalizados:
            return jsonify({'erro': f'Campo obrigatório ausente: {campo}'}), 400
    
    # Preparar dados para criação
    atividade_dados = {
        'titulo': dados_normalizados.get('titulo'),
        'descricao': dados_normalizados.get('descricao'),
        'horas_solicitadas': int(dados_normalizados.get('horas_solicitadas')),
        'data': datetime.strptime(dados_normalizados.get('data'), '%Y-%m-%d'),
        'status': 'Pendente',
        'horas_aprovadas': 0,
        'aluno_id': usuario_id
    }
    
    # Se tiver anexo, salvar em base64
    if 'anexo_base64' in dados and dados.get('anexo_base64'):
        atividade_dados['anexo'] = dados.get('anexo_base64')
    
    # Criar atividade
    atividade_model = Atividade()
    atividade_id = atividade_model.criar(atividade_dados)
    
    if not atividade_id:
        return jsonify({'erro': 'Erro ao criar atividade'}), 500
    
    return jsonify({
        'id': atividade_id,
        'mensagem': 'Atividade criada com sucesso'
    }), 201

@atividades_blueprint.route('/<atividade_id>', methods=['PUT'])
@jwt_required()
def atualizar_atividade(atividade_id):
    """
    Atualiza uma atividade complementar
    
    Args:
        atividade_id (str): ID da atividade
    
    Request:
        - titulo: Título da atividade
        - descricao: Descrição da atividade
        - horas_solicitadas: Horas solicitadas
        - data: Data da atividade (formato: YYYY-MM-DD)
        - anexo_base64: Arquivo anexo em formato base64 (opcional)
    
    Returns:
        - mensagem: Mensagem de sucesso
    """
    # O identity é o ID do usuário como string
    usuario_id = get_jwt_identity()
    
    # Obter claims adicionais do token
    claims = get_jwt()
    role = claims.get('role')
    
    # Buscar atividade
    atividade_model = Atividade()
    atividade = atividade_model.buscar_por_id(atividade_id)
    
    if not atividade:
        return jsonify({'erro': 'Atividade não encontrada'}), 404
    
    # Verificar permissões
    if role == 'student':
        # Aluno só pode editar atividades dele e que estejam pendentes
        if atividade.get('aluno_id') != usuario_id:
            return jsonify({'erro': 'Permissão negada. Você só pode editar suas próprias atividades'}), 403
        if atividade.get('status') != 'Pendente':
            return jsonify({'erro': 'Apenas atividades pendentes podem ser editadas'}), 400
    
    dados = request.get_json()
    
    # Mapear campos em inglês para português
    field_mapping = {
        'title': 'titulo',
        'description': 'descricao',
        'requested_hours': 'horas_solicitadas',
        'completion_date': 'data',
        'attachment': 'anexo_base64'
    }
    
    # Criar um dicionário normalizado com os campos em português
    dados_normalizados = {}
    for eng_field, pt_field in field_mapping.items():
        if eng_field in dados:
            dados_normalizados[pt_field] = dados[eng_field]
    
    # Adicionar campos que já estão em português
    for campo in ['titulo', 'descricao', 'horas_solicitadas', 'data', 'anexo_base64']:
        if campo in dados:
            dados_normalizados[campo] = dados[campo]
    
    # Preparar dados para atualização
    atividade_dados = {}
    
    if 'titulo' in dados_normalizados:
        atividade_dados['titulo'] = dados_normalizados.get('titulo')
    
    if 'descricao' in dados_normalizados:
        atividade_dados['descricao'] = dados_normalizados.get('descricao')
    
    if 'horas_solicitadas' in dados_normalizados:
        atividade_dados['horas_solicitadas'] = int(dados_normalizados.get('horas_solicitadas'))
    
    if 'data' in dados_normalizados:
        atividade_dados['data'] = datetime.strptime(dados_normalizados.get('data'), '%Y-%m-%d')
    
    # Se tiver anexo, atualizar em base64
    if 'anexo_base64' in dados_normalizados and dados_normalizados.get('anexo_base64'):
        atividade_dados['anexo'] = dados.get('anexo_base64')
    
    # Atualizar atividade
    sucesso = atividade_model.atualizar(atividade_id, atividade_dados)
    
    if not sucesso:
        return jsonify({'erro': 'Erro ao atualizar atividade'}), 500
    
    return jsonify({
        'mensagem': 'Atividade atualizada com sucesso'
    }), 200

@atividades_blueprint.route('/<atividade_id>/approve', methods=['PUT'])
@jwt_required()
def aprovar_atividade(atividade_id):
    """
    Aprova uma atividade complementar (apenas coordenadores)
    
    Args:
        atividade_id (str): ID da atividade
    
    Request:
        - approved_hours: Horas aprovadas
        - observation: Observação sobre a aprovação (opcional)
    
    Returns:
        - mensagem: Mensagem de sucesso
    """
    # O identity é o ID do usuário como string
    usuario_id = get_jwt_identity()
    
    # Obter claims adicionais do token
    claims = get_jwt()
    role = claims.get('role')
    
    # Verificar se é coordenador
    if role != 'coordinator':
        return jsonify({'erro': 'Apenas coordenadores podem aprovar atividades'}), 403
    
    # Buscar atividade
    atividade_model = Atividade()
    atividade = atividade_model.buscar_por_id(atividade_id)
    
    if not atividade:
        return jsonify({'erro': 'Atividade não encontrada'}), 404
    
    dados = request.get_json()
    
    # Validar dados
    if 'approved_hours' not in dados:
        return jsonify({'erro': 'Campo obrigatório ausente: approved_hours'}), 400
    
    # Preparar dados para atualização
    atividade_dados = {
        'status': 'Aprovado',
        'horas_aprovadas': int(dados.get('approved_hours'))
    }
    
    # Adicionar observação se fornecida
    if 'observation' in dados:
        atividade_dados['observacao'] = dados.get('observation')
    
    # Atualizar atividade
    sucesso = atividade_model.atualizar(atividade_id, atividade_dados)
    
    if not sucesso:
        return jsonify({'erro': 'Erro ao aprovar atividade'}), 500
    
    return jsonify({
        'mensagem': 'Atividade aprovada com sucesso'
    }), 200

@atividades_blueprint.route('/<atividade_id>/reject', methods=['PUT'])
@jwt_required()
def rejeitar_atividade(atividade_id):
    """
    Rejeita uma atividade complementar (apenas coordenadores)
    
    Args:
        atividade_id (str): ID da atividade
    
    Request:
        - observation: Observação sobre a rejeição (opcional)
    
    Returns:
        - mensagem: Mensagem de sucesso
    """
    # O identity é o ID do usuário como string
    usuario_id = get_jwt_identity()
    
    # Obter claims adicionais do token
    claims = get_jwt()
    role = claims.get('role')
    
    # Verificar se é coordenador
    if role != 'coordinator':
        return jsonify({'erro': 'Apenas coordenadores podem rejeitar atividades'}), 403
    
    # Buscar atividade
    atividade_model = Atividade()
    atividade = atividade_model.buscar_por_id(atividade_id)
    
    if not atividade:
        return jsonify({'erro': 'Atividade não encontrada'}), 404
    
    dados = request.get_json()
    
    # Preparar dados para atualização
    atividade_dados = {
        'status': 'Reprovado',
        'horas_aprovadas': 0
    }
    
    # Adicionar observação se fornecida
    if 'observation' in dados:
        atividade_dados['observacao'] = dados.get('observation')
    
    # Atualizar atividade
    sucesso = atividade_model.atualizar(atividade_id, atividade_dados)
    
    if not sucesso:
        return jsonify({'erro': 'Erro ao rejeitar atividade'}), 500
    
    return jsonify({
        'mensagem': 'Atividade rejeitada com sucesso'
    }), 200

@atividades_blueprint.route('/<atividade_id>/status', methods=['PUT'])
@jwt_required()
def alterar_status_atividade(atividade_id):
    """
    Altera o status de uma atividade complementar (apenas coordenadores)
    
    Args:
        atividade_id (str): ID da atividade
    
    Request:
        - status: Novo status da atividade (Aprovado, Reprovado, Pendente, Arquivado)
        - horas_aprovadas: Horas aprovadas (obrigatório se status for 'Aprovado')
        - observacao: Observação sobre a alteração de status (opcional)
    
    Returns:
        - mensagem: Mensagem de sucesso
    """
    # O identity é o ID do usuário como string
    usuario_id = get_jwt_identity()
    
    # Obter claims adicionais do token
    claims = get_jwt()
    role = claims.get('role')
    
    # Verificar se é coordenador
    if role != 'coordinator':
        return jsonify({'erro': 'Apenas coordenadores podem alterar o status de atividades'}), 403
    
    # Buscar atividade
    atividade_model = Atividade()
    atividade = atividade_model.buscar_por_id(atividade_id)
    
    if not atividade:
        return jsonify({'erro': 'Atividade não encontrada'}), 404
    
    dados = request.get_json()
    
    # Mapear campos em inglês para português
    field_mapping = {
        'status': 'status',
        'approved_hours': 'horas_aprovadas',
        'observation': 'observacao',
        'comments': 'observacao'
    }
    
    # Criar um dicionário normalizado com os campos em português
    dados_normalizados = {}
    for eng_field, pt_field in field_mapping.items():
        if eng_field in dados:
            dados_normalizados[pt_field] = dados[eng_field]
    
    # Adicionar campos que já estão em português
    for campo in ['status', 'horas_aprovadas', 'observacao']:
        if campo in dados:
            dados_normalizados[campo] = dados[campo]
    
    # Mapear status em inglês para português
    status_mapping = {
        'Approved': 'Aprovado',
        'Rejected': 'Reprovado',
        'Pending': 'Pendente',
        'Archived': 'Arquivado'
    }
    
    # Validar dados
    if 'status' not in dados_normalizados:
        return jsonify({'erro': 'Campo obrigatório ausente: status'}), 400
    
    status = dados_normalizados.get('status')
    # Converter status em inglês para português se necessário
    if status in status_mapping:
        status = status_mapping[status]
    
    status_validos = ['Aprovado', 'Reprovado', 'Pendente', 'Arquivado']
    
    if status not in status_validos:
        return jsonify({'erro': f'Status inválido. Valores permitidos: {", ".join(status_validos)}'}), 400
    
    # Se status for 'Aprovado', horas_aprovadas é obrigatório
    if status == 'Aprovado' and ('horas_aprovadas' not in dados_normalizados or not dados_normalizados.get('horas_aprovadas')):
        return jsonify({'erro': 'Campo obrigatório ausente: horas_aprovadas (obrigatório para status Aprovado)'}), 400
    
    # Preparar dados para atualização
    atividade_dados = {
        'status': status
    }
    
    # Adicionar horas aprovadas se fornecido
    if 'horas_aprovadas' in dados_normalizados:
        atividade_dados['horas_aprovadas'] = int(dados_normalizados.get('horas_aprovadas'))
    
    # Adicionar observação se fornecida
    if 'observacao' in dados_normalizados:
        atividade_dados['observacao'] = dados_normalizados.get('observacao')
    
    # Atualizar atividade
    sucesso = atividade_model.atualizar(atividade_id, atividade_dados)
    
    if not sucesso:
        return jsonify({'erro': 'Erro ao atualizar status da atividade'}), 500
    
    return jsonify({
        'mensagem': f'Status da atividade alterado para {status} com sucesso'
    }), 200

@atividades_blueprint.route('/aluno/<aluno_id>', methods=['GET'])
@jwt_required()
def listar_atividades_aluno(aluno_id):
    """
    Lista todas as atividades complementares de um aluno específico
    
    Args:
        aluno_id (str): ID do aluno
    
    Query params:
        - pagina: Número da página (padrão: 1)
        - limite: Número de itens por página (padrão: 10)
        - status: Filtrar pelo status das atividades (opcional)
    
    Returns:
        - atividades: Lista de atividades
        - total: Total de atividades
        - pagina: Página atual
        - total_paginas: Total de páginas
    """
    # O identity é o ID do usuário como string
    usuario_id = get_jwt_identity()
    
    # Obter claims adicionais do token
    claims = get_jwt()
    role = claims.get('role')
    
    # Verificar permissões
    if role == 'student' and usuario_id != aluno_id:
        return jsonify({'erro': 'Permissão negada. Você só pode visualizar suas próprias atividades'}), 403
    
    # Parâmetros de paginação
    pagina = int(request.args.get('pagina', 1))
    limite = int(request.args.get('limite', 10))
    
    # Filtros
    filtros = {'aluno_id': aluno_id}
    
    # Aplicar filtro de status se fornecido
    if 'status' in request.args and request.args.get('status') != 'all':
        filtros['status'] = request.args.get('status')
    
    # Buscar atividades
    atividade_model = Atividade()
    atividades = atividade_model.buscar_todas(filtros, limite, pagina)
    
    # Contar total para paginação
    total = len(atividade_model.buscar_todas(filtros, 0, 0))
    total_paginas = (total + limite - 1) // limite if limite > 0 else 1
    
    return jsonify({
        'atividades': atividades,
        'total': total,
        'pagina': pagina,
        'total_paginas': total_paginas
    }), 200

@atividades_blueprint.route('/<path:atividade_id>', methods=['DELETE'])
@jwt_required()
def deletar_atividade(atividade_id):
    """
    Remove uma atividade complementar
    
    Args:
        atividade_id (str): ID da atividade (pode conter uma URL malformada)
    
    Returns:
        - mensagem: Mensagem de sucesso
    """
    # Corrigir atividade_id se contiver baseUrl
    if 'http://' in atividade_id or 'https://' in atividade_id:
        # Extrair o ID real da atividade (último componente do path)
        atividade_id = atividade_id.split('/')[-1]
    
    # O identity é o ID do usuário como string
    usuario_id = get_jwt_identity()
    
    # Obter claims adicionais do token
    claims = get_jwt()
    role = claims.get('role')
    
    # Buscar atividade
    atividade_model = Atividade()
    atividade = atividade_model.buscar_por_id(atividade_id)
    
    if not atividade:
        return jsonify({'erro': 'Atividade não encontrada'}), 404
    
    # Verificar permissões
    if role == 'student':
        # Aluno só pode remover atividades dele e que estejam pendentes
        if atividade.get('aluno_id') != usuario_id:
            return jsonify({'erro': 'Permissão negada. Você só pode remover suas próprias atividades'}), 403
        if atividade.get('status') != 'Pendente':
            return jsonify({'erro': 'Apenas atividades pendentes podem ser removidas'}), 400
    
    # Deletar atividade
    sucesso = atividade_model.deletar(atividade_id)
    
    if not sucesso:
        return jsonify({'erro': 'Erro ao deletar atividade'}), 500
    
    return jsonify({
        'mensagem': 'Atividade removida com sucesso'
    }), 200
