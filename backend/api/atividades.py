from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models.atividade import Atividade
from models.aluno import Aluno
import os
from datetime import datetime

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
    identidade = get_jwt_identity()
    
    # Parâmetros de paginação
    pagina = int(request.args.get('pagina', 1))
    limite = int(request.args.get('limite', 20))
    
    # Filtros
    filtros = {}
    
    # Aplicar filtro de status se fornecido
    if 'status' in request.args:
        filtros['status'] = request.args.get('status')
    
    # Se for um aluno, mostrar apenas as atividades dele
    if identidade.get('tipo') == 'aluno':
        filtros['aluno_id'] = identidade.get('id')
    # Se for coordenador e especificou um aluno, mostrar as atividades daquele aluno
    elif identidade.get('tipo') == 'coordenador' and 'aluno_id' in request.args:
        filtros['aluno_id'] = request.args.get('aluno_id')
    
    # Buscar atividades
    atividade_model = Atividade()
    atividades = atividade_model.buscar_todas(filtros, limite, pagina)
    
    # Contar total para paginação
    total = len(atividade_model.buscar_todas(filtros, 0, 0))
    total_paginas = (total + limite - 1) // limite
    
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
    identidade = get_jwt_identity()
    
    # Buscar atividade
    atividade_model = Atividade()
    atividade = atividade_model.buscar_por_id(atividade_id)
    
    if not atividade:
        return jsonify({'erro': 'Atividade não encontrada'}), 404
    
    # Verificar permissões
    if identidade.get('tipo') == 'aluno' and atividade.get('aluno_id') != identidade.get('id'):
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
    identidade = get_jwt_identity()
    if identidade.get('tipo') != 'aluno':
        return jsonify({'erro': 'Apenas alunos podem criar atividades complementares'}), 403
    
    dados = request.get_json()
    
    # Validar dados
    campos_obrigatorios = ['titulo', 'descricao', 'horas_solicitadas', 'data']
    for campo in campos_obrigatorios:
        if campo not in dados:
            return jsonify({'erro': f'Campo obrigatório ausente: {campo}'}), 400
    
    # Preparar dados para criação
    atividade_dados = {
        'titulo': dados.get('titulo'),
        'descricao': dados.get('descricao'),
        'horas_solicitadas': int(dados.get('horas_solicitadas')),
        'data': datetime.strptime(dados.get('data'), '%Y-%m-%d'),
        'status': 'Pendente',
        'horas_aprovadas': 0,
        'aluno_id': identidade.get('id')
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
    identidade = get_jwt_identity()
    
    # Buscar atividade
    atividade_model = Atividade()
    atividade = atividade_model.buscar_por_id(atividade_id)
    
    if not atividade:
        return jsonify({'erro': 'Atividade não encontrada'}), 404
    
    # Verificar permissões
    if identidade.get('tipo') == 'aluno':
        # Aluno só pode editar atividades dele e que estejam pendentes
        if atividade.get('aluno_id') != identidade.get('id'):
            return jsonify({'erro': 'Permissão negada. Você só pode editar suas próprias atividades'}), 403
        if atividade.get('status') != 'Pendente':
            return jsonify({'erro': 'Apenas atividades pendentes podem ser editadas'}), 400
    
    dados = request.get_json()
    
    # Preparar dados para atualização
    atividade_dados = {}
    
    if 'titulo' in dados:
        atividade_dados['titulo'] = dados.get('titulo')
    
    if 'descricao' in dados:
        atividade_dados['descricao'] = dados.get('descricao')
    
    if 'horas_solicitadas' in dados:
        atividade_dados['horas_solicitadas'] = int(dados.get('horas_solicitadas'))
    
    if 'data' in dados:
        atividade_dados['data'] = datetime.strptime(dados.get('data'), '%Y-%m-%d')
    
    # Se tiver anexo, atualizar em base64
    if 'anexo_base64' in dados and dados.get('anexo_base64'):
        atividade_dados['anexo'] = dados.get('anexo_base64')
    
    # Atualizar atividade
    sucesso = atividade_model.atualizar(atividade_id, atividade_dados)
    
    if not sucesso:
        return jsonify({'erro': 'Erro ao atualizar atividade'}), 500
    
    return jsonify({
        'mensagem': 'Atividade atualizada com sucesso'
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
    identidade = get_jwt_identity()
    
    # Verificar se o usuário é coordenador
    if identidade.get('tipo') != 'coordenador':
        return jsonify({'erro': 'Permissão negada. Apenas coordenadores podem alterar o status das atividades'}), 403
    
    dados = request.get_json()
    
    # Validar dados
    if 'status' not in dados:
        return jsonify({'erro': 'O status é obrigatório'}), 400
    
    status = dados.get('status')
    if status not in ['Aprovado', 'Reprovado', 'Pendente', 'Arquivado']:
        return jsonify({'erro': 'Status inválido'}), 400
    
    # Se for aprovar, as horas aprovadas são obrigatórias
    if status == 'Aprovado' and 'horas_aprovadas' not in dados:
        return jsonify({'erro': 'Horas aprovadas são obrigatórias para atividades aprovadas'}), 400
    
    # Buscar atividade
    atividade_model = Atividade()
    atividade = atividade_model.buscar_por_id(atividade_id)
    
    if not atividade:
        return jsonify({'erro': 'Atividade não encontrada'}), 404
    
    # Preparar dados para alteração de status
    horas_aprovadas = int(dados.get('horas_aprovadas', 0)) if status == 'Aprovado' else 0
    observacao = dados.get('observacao')
    
    # Alterar status da atividade
    sucesso = atividade_model.alterar_status(
        atividade_id, 
        status, 
        horas_aprovadas, 
        observacao
    )
    
    if not sucesso:
        return jsonify({'erro': 'Erro ao alterar status da atividade'}), 500
    
    return jsonify({
        'mensagem': f'Status da atividade alterado para {status} com sucesso'
    }), 200

@atividades_blueprint.route('/<atividade_id>', methods=['DELETE'])
@jwt_required()
def deletar_atividade(atividade_id):
    """
    Remove uma atividade complementar
    
    Args:
        atividade_id (str): ID da atividade
    
    Returns:
        - mensagem: Mensagem de sucesso
    """
    identidade = get_jwt_identity()
    
    # Buscar atividade
    atividade_model = Atividade()
    atividade = atividade_model.buscar_por_id(atividade_id)
    
    if not atividade:
        return jsonify({'erro': 'Atividade não encontrada'}), 404
    
    # Verificar permissões
    if identidade.get('tipo') == 'aluno':
        # Aluno só pode remover atividades dele e que estejam pendentes
        if atividade.get('aluno_id') != identidade.get('id'):
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
