from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models.user import User
from bson import ObjectId
import hashlib

coordinators_blueprint = Blueprint('coordinators', __name__)

@coordinators_blueprint.route('/', methods=['GET'])
@jwt_required()
def list_coordinators():
    """
    Lista todos os coordenadores
    
    Query params:
        - page: Número da página (padrão: 1)
        - limit: Número de itens por página (padrão: 20)
        - name: Filtrar pelo nome do coordenador
    
    Returns:
        - coordinators: Lista de coordenadores
        - total: Total de coordenadores
        - page: Página atual
        - total_pages: Total de páginas
    """
    # Verificar se o usuário logado é coordenador
    identity = get_jwt_identity()
    if identity.get('role') != 'coordinator':
        return jsonify({'error': 'Permissão negada. Apenas coordenadores podem acessar esta funcionalidade'}), 403
    
    # Parâmetros de paginação
    page = int(request.args.get('page', 1))
    limit = int(request.args.get('limit', 20))
    
    # Filtros
    filters = {'role': 'coordinator'}
    
    if 'name' in request.args:
        name = request.args.get('name')
        # Filtro de busca por nome usando regex
        filters['name'] = {'$regex': name, '$options': 'i'}
    
    # Buscar coordenadores
    user_model = User()
    coordinators = user_model.buscar_todos(role='coordinator', filtros=filters, limite=limit, pagina=page)
    
    # Remover senhas dos resultados
    for coordinator in coordinators:
        if 'password' in coordinator:
            del coordinator['password']
    
    # Converter ObjectId para string para serialização JSON
    for coordinator in coordinators:
        coordinator['_id'] = str(coordinator['_id'])
        if 'coordinated_courses' in coordinator:
            for course in coordinator['coordinated_courses']:
                if 'course_id' in course:
                    course['course_id'] = str(course['course_id'])
    
    # Contar total de coordenadores para paginação
    total = len(coordinators)  # Simplificado, em produção deve usar count_documents
    total_pages = (total + limit - 1) // limit
    
    return jsonify({
        'coordinators': coordinators,
        'total': total,
        'page': page,
        'total_pages': total_pages
    }), 200

@coordinators_blueprint.route('/<coordinator_id>', methods=['GET'])
@jwt_required()
def get_coordinator(coordinator_id):
    """
    Busca um coordenador pelo ID
    
    Args:
        coordinator_id (str): ID do coordenador
    
    Returns:
        - coordinator: Dados do coordenador
    """
    # Verificar se o usuário logado é coordenador
    identity = get_jwt_identity()
    if identity.get('role') != 'coordinator':
        return jsonify({'error': 'Permissão negada. Apenas coordenadores podem acessar esta funcionalidade'}), 403
    
    # Buscar coordenador
    user_model = User()
    coordinator = user_model.buscar_por_id(coordinator_id)
    
    if not coordinator:
        return jsonify({'error': 'Coordenador não encontrado'}), 404
    
    # Verificar se é um coordenador
    if coordinator.get('role') != 'coordinator':
        return jsonify({'error': 'Usuário não é um coordenador'}), 400
    
    # Remover senha
    if 'password' in coordinator:
        del coordinator['password']
    
    # Converter ObjectId para string
    coordinator['_id'] = str(coordinator['_id'])
    if 'coordinated_courses' in coordinator:
        for course in coordinator['coordinated_courses']:
            if 'course_id' in course:
                course['course_id'] = str(course['course_id'])
    
    return jsonify(coordinator), 200

@coordinators_blueprint.route('/', methods=['POST'])
@jwt_required()
def create_coordinator():
    """
    Cria um novo coordenador
    
    Request:
        - name: Nome do coordenador
        - surname: Sobrenome do coordenador
        - email: Email do coordenador
        - password: Senha do coordenador
    
    Returns:
        - id: ID do coordenador criado
        - message: Mensagem de sucesso
    """
    # Verificar se o usuário logado é coordenador
    identity = get_jwt_identity()
    if identity.get('role') != 'coordinator':
        return jsonify({'error': 'Permissão negada. Apenas coordenadores podem criar outros coordenadores'}), 403
    
    data = request.get_json()
    
    # Validar dados
    required_fields = ['name', 'surname', 'email', 'password']
    for field in required_fields:
        if field not in data:
            return jsonify({'error': f'Campo obrigatório ausente: {field}'}), 400
    
    # Verificar se já existe um usuário com o mesmo email
    user_model = User()
    existing_user = user_model.buscar_por_email(data['email'])
    if existing_user:
        return jsonify({'error': 'Já existe um usuário com este email'}), 400
    
    # Criar novo coordenador
    new_coordinator = {
        'name': data['name'],
        'surname': data['surname'],
        'email': data['email'],
        'password': data['password'],  # Em produção, deve-se fazer hash da senha
        'role': 'coordinator',
        'coordinated_courses': []
    }
    
    # Inserir no banco de dados
    coordinator_id = user_model.criar(new_coordinator)
    
    if not coordinator_id:
        return jsonify({'error': 'Erro ao criar coordenador'}), 500
    
    return jsonify({
        'id': coordinator_id,
        'message': 'Coordenador criado com sucesso'
    }), 201

@coordinators_blueprint.route('/<coordinator_id>', methods=['PUT'])
@jwt_required()
def update_coordinator(coordinator_id):
    """
    Atualiza os dados de um coordenador
    
    Args:
        coordinator_id (str): ID do coordenador
    
    Request:
        - name: Nome do coordenador
        - surname: Sobrenome do coordenador
        - email: Email do coordenador
        - password: Senha do coordenador (opcional)
    
    Returns:
        - message: Mensagem de sucesso
    """
    # Verificar se o usuário logado é coordenador
    identity = get_jwt_identity()
    if identity.get('role') != 'coordinator':
        return jsonify({'error': 'Permissão negada. Apenas coordenadores podem atualizar coordenadores'}), 403
    
    data = request.get_json()
    
    # Verificar se o coordenador existe
    user_model = User()
    coordinator = user_model.buscar_por_id(coordinator_id)
    
    if not coordinator:
        return jsonify({'error': 'Coordenador não encontrado'}), 404
    
    # Verificar se é um coordenador
    if coordinator.get('role') != 'coordinator':
        return jsonify({'error': 'Usuário não é um coordenador'}), 400
    
    # Preparar dados para atualização
    update_data = {}
    
    if 'name' in data:
        update_data['name'] = data['name']
    
    if 'surname' in data:
        update_data['surname'] = data['surname']
    
    if 'email' in data:
        # Verificar se o novo email já está em uso por outro usuário
        if data['email'] != coordinator['email']:
            existing_user = user_model.buscar_por_email(data['email'])
            if existing_user and str(existing_user['_id']) != coordinator_id:
                return jsonify({'error': 'Email já está em uso por outro usuário'}), 400
        update_data['email'] = data['email']
    
    if 'password' in data and data['password']:
        update_data['password'] = data['password']  # Em produção, deve-se fazer hash da senha
    
    # Atualizar no banco de dados
    success = user_model.atualizar(coordinator_id, update_data)
    
    if not success:
        return jsonify({'error': 'Erro ao atualizar coordenador'}), 500
    
    return jsonify({
        'message': 'Coordenador atualizado com sucesso'
    }), 200

@coordinators_blueprint.route('/<coordinator_id>', methods=['DELETE'])
@jwt_required()
def delete_coordinator(coordinator_id):
    """
    Remove um coordenador do sistema
    
    Args:
        coordinator_id (str): ID do coordenador
    
    Returns:
        - message: Mensagem de sucesso
    """
    # Verificar se o usuário logado é coordenador
    identity = get_jwt_identity()
    if identity.get('role') != 'coordinator' or identity.get('id') == coordinator_id:
        return jsonify({'error': 'Permissão negada. Apenas outros coordenadores podem remover um coordenador'}), 403
    
    # Verificar se o coordenador existe
    user_model = User()
    coordinator = user_model.buscar_por_id(coordinator_id)
    
    if not coordinator:
        return jsonify({'error': 'Coordenador não encontrado'}), 404
    
    # Verificar se é um coordenador
    if coordinator.get('role') != 'coordinator':
        return jsonify({'error': 'Usuário não é um coordenador'}), 400
    
    # Verificar se o coordenador tem cursos associados
    if 'coordinated_courses' in coordinator and coordinator['coordinated_courses']:
        return jsonify({'error': 'Não é possível remover um coordenador que possui cursos associados'}), 400
    
    # Remover do banco de dados
    success = user_model.excluir(coordinator_id)
    
    if not success:
        return jsonify({'error': 'Erro ao remover coordenador'}), 500
    
    return jsonify({
        'message': 'Coordenador removido com sucesso'
    }), 200
