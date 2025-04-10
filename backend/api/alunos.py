from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models.aluno import Aluno
import hashlib

alunos_blueprint = Blueprint('alunos', __name__)

@alunos_blueprint.route('/', methods=['GET'])
@jwt_required()
def listar_alunos():
    """
    Lista todos os alunos
    
    Query params:
        - pagina: Número da página (padrão: 1)
        - limite: Número de itens por página (padrão: 20)
        - nome: Filtrar pelo nome do aluno
        - curso_id: Filtrar pelo ID do curso
    
    Returns:
        - alunos: Lista de alunos
        - total: Total de alunos
        - pagina: Página atual
        - total_paginas: Total de páginas
    """
    # Verificar se o usuário logado é coordenador
    identidade = get_jwt_identity()
    if identidade.get('tipo') != 'coordenador':
        return jsonify({'erro': 'Permissão negada. Apenas coordenadores podem acessar esta funcionalidade'}), 403
    
    # Parâmetros de paginação
    pagina = int(request.args.get('pagina', 1))
    limite = int(request.args.get('limite', 20))
    
    # Filtros
    filtros = {}
    
    if 'nome' in request.args:
        nome = request.args.get('nome')
        # Filtro de busca por nome usando regex
        filtros['nome_aluno'] = {'$regex': nome, '$options': 'i'}
    
    if 'curso_id' in request.args:
        filtros['curso_id'] = request.args.get('curso_id')
    
    # Buscar alunos
    aluno_model = Aluno()
    alunos = aluno_model.buscar_todos(filtros, limite, pagina)
    
    # Remover senhas dos resultados
    for aluno in alunos:
        if 'senha_aluno' in aluno:
            del aluno['senha_aluno']
    
    # Contar total para paginação
    total = len(aluno_model.buscar_todos(filtros, 0, 0))
    total_paginas = (total + limite - 1) // limite
    
    return jsonify({
        'alunos': alunos,
        'total': total,
        'pagina': pagina,
        'total_paginas': total_paginas
    }), 200

@alunos_blueprint.route('/<aluno_id>', methods=['GET'])
@jwt_required()
def buscar_aluno(aluno_id):
    """
    Busca um aluno pelo ID
    
    Args:
        aluno_id (str): ID do aluno
    
    Returns:
        - aluno: Dados do aluno
    """
    # Verificar se o usuário logado é o próprio aluno ou um coordenador
    identidade = get_jwt_identity()
    if identidade.get('tipo') == 'aluno' and identidade.get('id') != aluno_id:
        return jsonify({'erro': 'Permissão negada. Você só pode acessar seus próprios dados'}), 403
    
    # Buscar aluno
    aluno_model = Aluno()
    aluno = aluno_model.buscar_por_id(aluno_id)
    
    if not aluno:
        return jsonify({'erro': 'Aluno não encontrado'}), 404
    
    # Remover senha do resultado
    if 'senha_aluno' in aluno:
        del aluno['senha_aluno']
    
    return jsonify({'aluno': aluno}), 200

@alunos_blueprint.route('/', methods=['POST'])
def criar_aluno():
    """
    Cria um novo aluno
    
    Request:
        - nome_aluno: Nome do aluno
        - sobrenome_aluno: Sobrenome do aluno
        - email_aluno: Email do aluno
        - senha_aluno: Senha do aluno
        - curso_id: ID do curso
    
    Returns:
        - id: ID do aluno criado
        - mensagem: Mensagem de sucesso
    """
    dados = request.get_json()
    
    # Validar dados
    campos_obrigatorios = ['nome_aluno', 'sobrenome_aluno', 'email_aluno', 'senha_aluno', 'curso_id']
    for campo in campos_obrigatorios:
        if campo not in dados:
            return jsonify({'erro': f'Campo obrigatório ausente: {campo}'}), 400
    
    # Verificar se o email já está em uso
    aluno_model = Aluno()
    if aluno_model.buscar_por_email(dados['email_aluno']):
        return jsonify({'erro': 'Este email já está em uso'}), 400
    
    # Hash da senha
    dados['senha_aluno'] = hashlib.sha256(dados['senha_aluno'].encode()).hexdigest()
    
    # Criar aluno
    aluno_id = aluno_model.criar(dados)
    
    if not aluno_id:
        return jsonify({'erro': 'Erro ao criar aluno'}), 500
    
    return jsonify({
        'id': aluno_id,
        'mensagem': 'Aluno criado com sucesso'
    }), 201

@alunos_blueprint.route('/<aluno_id>', methods=['PUT'])
@jwt_required()
def atualizar_aluno(aluno_id):
    """
    Atualiza os dados de um aluno
    
    Args:
        aluno_id (str): ID do aluno
    
    Request:
        - nome_aluno: Nome do aluno
        - sobrenome_aluno: Sobrenome do aluno
        - email_aluno: Email do aluno
        - senha_aluno: Senha do aluno (opcional)
        - curso_id: ID do curso
    
    Returns:
        - mensagem: Mensagem de sucesso
    """
    # Verificar se o usuário logado é o próprio aluno ou um coordenador
    identidade = get_jwt_identity()
    if identidade.get('tipo') == 'aluno' and identidade.get('id') != aluno_id:
        return jsonify({'erro': 'Permissão negada. Você só pode atualizar seus próprios dados'}), 403
    
    dados = request.get_json()
    
    # Buscar aluno
    aluno_model = Aluno()
    aluno = aluno_model.buscar_por_id(aluno_id)
    
    if not aluno:
        return jsonify({'erro': 'Aluno não encontrado'}), 404
    
    # Se a senha foi informada, criar hash
    if 'senha_aluno' in dados:
        dados['senha_aluno'] = hashlib.sha256(dados['senha_aluno'].encode()).hexdigest()
    
    # Atualizar aluno
    sucesso = aluno_model.atualizar(aluno_id, dados)
    
    if not sucesso:
        return jsonify({'erro': 'Erro ao atualizar aluno'}), 500
    
    return jsonify({
        'mensagem': 'Aluno atualizado com sucesso'
    }), 200

@alunos_blueprint.route('/<aluno_id>', methods=['DELETE'])
@jwt_required()
def deletar_aluno(aluno_id):
    """
    Remove um aluno do sistema
    
    Args:
        aluno_id (str): ID do aluno
    
    Returns:
        - mensagem: Mensagem de sucesso
    """
    # Verificar se o usuário logado é um coordenador
    identidade = get_jwt_identity()
    if identidade.get('tipo') != 'coordenador':
        return jsonify({'erro': 'Permissão negada. Apenas coordenadores podem remover alunos'}), 403
    
    # Buscar aluno
    aluno_model = Aluno()
    aluno = aluno_model.buscar_por_id(aluno_id)
    
    if not aluno:
        return jsonify({'erro': 'Aluno não encontrado'}), 404
    
    # Deletar aluno
    sucesso = aluno_model.deletar(aluno_id)
    
    if not sucesso:
        return jsonify({'erro': 'Erro ao deletar aluno'}), 500
    
    return jsonify({
        'mensagem': 'Aluno removido com sucesso'
    }), 200
