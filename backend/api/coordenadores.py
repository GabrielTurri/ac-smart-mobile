from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models.coordenador import Coordenador
import hashlib

coordenadores_blueprint = Blueprint('coordenadores', __name__)

@coordenadores_blueprint.route('/', methods=['GET'])
@jwt_required()
def listar_coordenadores():
    """
    Lista todos os coordenadores (apenas para coordenadores)
    
    Query params:
        - pagina: Número da página (padrão: 1)
        - limite: Número de itens por página (padrão: 20)
        - nome: Filtrar pelo nome do coordenador
    
    Returns:
        - coordenadores: Lista de coordenadores
        - total: Total de coordenadores
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
        filtros['nome_coordenador'] = {'$regex': nome, '$options': 'i'}
    
    # Buscar coordenadores
    coordenador_model = Coordenador()
    coordenadores = coordenador_model.buscar_todos(filtros, limite, pagina)
    
    # Remover senhas dos resultados
    for coordenador in coordenadores:
        if 'senha_coordenador' in coordenador:
            del coordenador['senha_coordenador']
    
    # Contar total para paginação
    total = len(coordenador_model.buscar_todos(filtros, 0, 0))
    total_paginas = (total + limite - 1) // limite
    
    return jsonify({
        'coordenadores': coordenadores,
        'total': total,
        'pagina': pagina,
        'total_paginas': total_paginas
    }), 200

@coordenadores_blueprint.route('/<coordenador_id>', methods=['GET'])
@jwt_required()
def buscar_coordenador(coordenador_id):
    """
    Busca um coordenador pelo ID
    
    Args:
        coordenador_id (str): ID do coordenador
    
    Returns:
        - coordenador: Dados do coordenador
    """
    # Verificar se o usuário logado é o próprio coordenador ou outro coordenador
    identidade = get_jwt_identity()
    if identidade.get('tipo') != 'coordenador':
        return jsonify({'erro': 'Permissão negada. Apenas coordenadores podem acessar esta funcionalidade'}), 403
    
    # Buscar coordenador
    coordenador_model = Coordenador()
    coordenador = coordenador_model.buscar_por_id(coordenador_id)
    
    if not coordenador:
        return jsonify({'erro': 'Coordenador não encontrado'}), 404
    
    # Remover senha do resultado
    if 'senha_coordenador' in coordenador:
        del coordenador['senha_coordenador']
    
    return jsonify({'coordenador': coordenador}), 200

@coordenadores_blueprint.route('/', methods=['POST'])
@jwt_required()
def criar_coordenador():
    """
    Cria um novo coordenador (apenas para coordenadores)
    
    Request:
        - nome_coordenador: Nome do coordenador
        - sobrenome_coordenador: Sobrenome do coordenador
        - email_coordenador: Email do coordenador
        - senha_coordenador: Senha do coordenador
    
    Returns:
        - id: ID do coordenador criado
        - mensagem: Mensagem de sucesso
    """
    # Verificar se o usuário logado é coordenador
    identidade = get_jwt_identity()
    if identidade.get('tipo') != 'coordenador':
        return jsonify({'erro': 'Permissão negada. Apenas coordenadores podem acessar esta funcionalidade'}), 403
    
    dados = request.get_json()
    
    # Validar dados
    campos_obrigatorios = ['nome_coordenador', 'sobrenome_coordenador', 'email_coordenador', 'senha_coordenador']
    for campo in campos_obrigatorios:
        if campo not in dados:
            return jsonify({'erro': f'Campo obrigatório ausente: {campo}'}), 400
    
    # Verificar se o email já está em uso
    coordenador_model = Coordenador()
    if coordenador_model.buscar_por_email(dados['email_coordenador']):
        return jsonify({'erro': 'Este email já está em uso'}), 400
    
    # Hash da senha
    dados['senha_coordenador'] = hashlib.sha256(dados['senha_coordenador'].encode()).hexdigest()
    
    # Criar coordenador
    coordenador_id = coordenador_model.criar(dados)
    
    if not coordenador_id:
        return jsonify({'erro': 'Erro ao criar coordenador'}), 500
    
    return jsonify({
        'id': coordenador_id,
        'mensagem': 'Coordenador criado com sucesso'
    }), 201

@coordenadores_blueprint.route('/<coordenador_id>', methods=['PUT'])
@jwt_required()
def atualizar_coordenador(coordenador_id):
    """
    Atualiza os dados de um coordenador
    
    Args:
        coordenador_id (str): ID do coordenador
    
    Request:
        - nome_coordenador: Nome do coordenador
        - sobrenome_coordenador: Sobrenome do coordenador
        - email_coordenador: Email do coordenador
        - senha_coordenador: Senha do coordenador (opcional)
    
    Returns:
        - mensagem: Mensagem de sucesso
    """
    # Verificar se o usuário logado é o próprio coordenador
    identidade = get_jwt_identity()
    if identidade.get('tipo') != 'coordenador':
        return jsonify({'erro': 'Permissão negada. Apenas coordenadores podem acessar esta funcionalidade'}), 403
    
    dados = request.get_json()
    
    # Buscar coordenador
    coordenador_model = Coordenador()
    coordenador = coordenador_model.buscar_por_id(coordenador_id)
    
    if not coordenador:
        return jsonify({'erro': 'Coordenador não encontrado'}), 404
    
    # Se a senha foi informada, criar hash
    if 'senha_coordenador' in dados:
        dados['senha_coordenador'] = hashlib.sha256(dados['senha_coordenador'].encode()).hexdigest()
    
    # Atualizar coordenador
    sucesso = coordenador_model.atualizar(coordenador_id, dados)
    
    if not sucesso:
        return jsonify({'erro': 'Erro ao atualizar coordenador'}), 500
    
    return jsonify({
        'mensagem': 'Coordenador atualizado com sucesso'
    }), 200

@coordenadores_blueprint.route('/<coordenador_id>', methods=['DELETE'])
@jwt_required()
def deletar_coordenador(coordenador_id):
    """
    Remove um coordenador do sistema (apenas para coordenadores)
    
    Args:
        coordenador_id (str): ID do coordenador
    
    Returns:
        - mensagem: Mensagem de sucesso
    """
    # Verificar se o usuário logado é um coordenador diferente do que será removido
    identidade = get_jwt_identity()
    if identidade.get('tipo') != 'coordenador':
        return jsonify({'erro': 'Permissão negada. Apenas coordenadores podem remover coordenadores'}), 403
    
    if identidade.get('id') == coordenador_id:
        return jsonify({'erro': 'Você não pode remover seu próprio usuário'}), 400
    
    # Buscar coordenador
    coordenador_model = Coordenador()
    coordenador = coordenador_model.buscar_por_id(coordenador_id)
    
    if not coordenador:
        return jsonify({'erro': 'Coordenador não encontrado'}), 404
    
    # Deletar coordenador
    sucesso = coordenador_model.deletar(coordenador_id)
    
    if not sucesso:
        return jsonify({'erro': 'Erro ao deletar coordenador. Verifique se este coordenador possui cursos associados.'}), 500
    
    return jsonify({
        'mensagem': 'Coordenador removido com sucesso'
    }), 200
