from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity, get_jwt
from models.user import User
from bson import ObjectId
import hashlib

students_blueprint = Blueprint('students', __name__)

@students_blueprint.route('/', methods=['GET'])
@jwt_required()
def list_students():
    """
    Lista todos os estudantes
    
    Query params:
        - page: Número da página (padrão: 1)
        - limit: Número de itens por página (padrão: 20)
        - name: Filtrar pelo nome do estudante
        - course_id: Filtrar pelo ID do curso
    
    Returns:
        - students: Lista de estudantes
        - total: Total de estudantes
        - page: Página atual
        - total_pages: Total de páginas
    """
    # Verificar se o usuário logado é coordenador
    # O identity agora é apenas o ID do usuário como string
    # O role está nos claims adicionais
    claims = get_jwt()
    if claims.get('role') != 'coordinator':
        return jsonify({'error': 'Permissão negada. Apenas coordenadores podem acessar esta funcionalidade'}), 403
    
    # Parâmetros de paginação
    page = int(request.args.get('page', 1))
    limit = int(request.args.get('limit', 20))
    
    # Filtros
    filters = {'role': 'student'}
    
    if 'name' in request.args:
        name = request.args.get('name')
        # Filtro de busca por nome usando regex
        filters['name'] = {'$regex': name, '$options': 'i'}
    
    if 'course_id' in request.args:
        course_id = request.args.get('course_id')
        filters['course.course_id'] = ObjectId(course_id)
    
    # Buscar estudantes
    user_model = User()
    students = user_model.buscar_todos(role='student', filtros=filters, limite=limit, pagina=page)
    
    # Remover senhas dos resultados
    for student in students:
        if 'password' in student:
            del student['password']
    
    # ObjectId conversion is now handled in the User model
    
    # Contar total de estudantes para paginação
    total = len(students)  # Simplificado, em produção deve usar count_documents
    total_pages = (total + limit - 1) // limit
    
    return jsonify({
        'students': students,
        'total': total,
        'page': page,
        'total_pages': total_pages
    }), 200

@students_blueprint.route('/<student_id>', methods=['GET'])
@jwt_required()
def get_student(student_id):
    """
    Busca um estudante pelo ID
    
    Args:
        student_id (str): ID do estudante
    
    Returns:
        - student: Dados do estudante
    """
    # Verificar se o usuário logado é coordenador ou o próprio estudante
    usuario_id = get_jwt_identity()  # ID do usuário como string
    claims = get_jwt()
    role = claims.get('role')
    if role != 'coordinator' and usuario_id != student_id:
        return jsonify({'error': 'Permissão negada'}), 403
    
    # Buscar estudante
    user_model = User()
    student = user_model.buscar_por_id(student_id)
    
    if not student:
        return jsonify({'error': 'Estudante não encontrado'}), 404
    
    # Verificar se é um estudante
    if student.get('role') != 'student':
        return jsonify({'error': 'Usuário não é um estudante'}), 400
    
    # Remover senha
    if 'password' in student:
        del student['password']
    
    # Converter ObjectId para string
    student['_id'] = str(student['_id'])
    if 'course' in student and 'course_id' in student['course']:
        student['course']['course_id'] = str(student['course']['course_id'])
    if 'activities' in student:
        for activity in student['activities']:
            if 'activity_id' in activity:
                activity['activity_id'] = str(activity['activity_id'])
    
    return jsonify(student), 200

@students_blueprint.route('/', methods=['POST'])
@jwt_required()
def create_student():
    """
    Cria um novo estudante
    
    Request:
        - name: Nome do estudante
        - surname: Sobrenome do estudante
        - email: Email do estudante
        - password: Senha do estudante
        - RA: RA do estudante (opcional)
        - course_id: ID do curso
    
    Returns:
        - id: ID do estudante criado
        - message: Mensagem de sucesso
    """
    # Verificar se o usuário logado é coordenador
    # O identity agora é apenas o ID do usuário como string
    # O role está nos claims adicionais
    claims = get_jwt()
    if claims.get('role') != 'coordinator':
        return jsonify({'error': 'Permissão negada. Apenas coordenadores podem criar estudantes'}), 403
    
    data = request.get_json()
    
    # Validar dados
    required_fields = ['name', 'surname', 'email', 'password', 'course_id']
    for field in required_fields:
        if field not in data:
            return jsonify({'error': f'Campo obrigatório ausente: {field}'}), 400
    
    # Verificar se já existe um usuário com o mesmo email
    user_model = User()
    existing_user = user_model.buscar_por_email(data['email'])
    if existing_user:
        return jsonify({'error': 'Já existe um usuário com este email'}), 400
    
    # Hash da senha usando SHA-256
    hashed_password = hashlib.sha256(data['password'].encode('utf-8')).hexdigest()
    
    # Criar novo estudante
    new_student = {
        'name': data['name'],
        'surname': data['surname'],
        'email': data['email'],
        'password': hashed_password,
        'role': 'student',
        'RA': data.get('RA', ''),
        'course': {
            'course_id': ObjectId(data['course_id'])
        },
        'activities': [],
        'total_approved_hours': 0,
        'total_pending_hours': 0,
        'total_rejected_hours': 0
    }
    
    # Inserir no banco de dados
    student_id = user_model.criar(new_student)
    
    if not student_id:
        return jsonify({'error': 'Erro ao criar estudante'}), 500
    
    return jsonify({
        'id': student_id,
        'message': 'Estudante criado com sucesso'
    }), 201

@students_blueprint.route('/<student_id>', methods=['PUT'])
@jwt_required()
def update_student(student_id):
    """
    Atualiza os dados de um estudante
    
    Args:
        student_id (str): ID do estudante
    
    Request:
        - name: Nome do estudante
        - surname: Sobrenome do estudante
        - email: Email do estudante
        - password: Senha do estudante (opcional)
        - RA: RA do estudante (opcional)
        - course_id: ID do curso (opcional)
    
    Returns:
        - message: Mensagem de sucesso
    """
    # Verificar se o usuário logado é coordenador ou o próprio estudante
    usuario_id = get_jwt_identity()  # ID do usuário como string
    claims = get_jwt()
    role = claims.get('role')
    if role != 'coordinator' and usuario_id != student_id:
        return jsonify({'error': 'Permissão negada'}), 403
    
    data = request.get_json()
    
    # Verificar se o estudante existe
    user_model = User()
    student = user_model.buscar_por_id(student_id)
    
    if not student:
        return jsonify({'error': 'Estudante não encontrado'}), 404
    
    # Verificar se é um estudante
    if student.get('role') != 'student':
        return jsonify({'error': 'Usuário não é um estudante'}), 400
    
    # Preparar dados para atualização
    update_data = {}
    
    if 'name' in data:
        update_data['name'] = data['name']
    
    if 'surname' in data:
        update_data['surname'] = data['surname']
    
    if 'email' in data:
        # Verificar se o novo email já está em uso por outro usuário
        if data['email'] != student['email']:
            existing_user = user_model.buscar_por_email(data['email'])
            if existing_user and str(existing_user['_id']) != student_id:
                return jsonify({'error': 'Email já está em uso por outro usuário'}), 400
        update_data['email'] = data['email']
    
    if 'password' in data and data['password']:
        update_data['password'] = hashlib.sha256(data['password'].encode()).hexdigest()
    
    if 'RA' in data:
        update_data['RA'] = data['RA']
    
    if 'course_id' in data and identity.get('role') == 'coordinator':
        # Apenas coordenadores podem alterar o curso
        update_data['course.course_id'] = ObjectId(data['course_id'])
    
    # Atualizar no banco de dados
    success = user_model.atualizar(student_id, update_data)
    
    if not success:
        return jsonify({'error': 'Erro ao atualizar estudante'}), 500
    
    return jsonify({
        'message': 'Estudante atualizado com sucesso'
    }), 200

@students_blueprint.route('/<student_id>', methods=['DELETE'])
@jwt_required()
def delete_student(student_id):
    """
    Remove um estudante do sistema
    
    Args:
        student_id (str): ID do estudante
    
    Returns:
        - message: Mensagem de sucesso
    """
    # Verificar se o usuário logado é coordenador
    # O identity agora é apenas o ID do usuário como string
    # O role está nos claims adicionais
    claims = get_jwt()
    if claims.get('role') != 'coordinator':
        return jsonify({'error': 'Permissão negada. Apenas coordenadores podem remover estudantes'}), 403
    
    # Verificar se o estudante existe
    user_model = User()
    student = user_model.buscar_por_id(student_id)
    
    if not student:
        return jsonify({'error': 'Estudante não encontrado'}), 404
    
    # Verificar se é um estudante
    if student.get('role') != 'student':
        return jsonify({'error': 'Usuário não é um estudante'}), 400
    
    # Remover do banco de dados
    success = user_model.excluir(student_id)
    
    if not success:
        return jsonify({'error': 'Erro ao remover estudante'}), 500
    
    return jsonify({
        'message': 'Estudante removido com sucesso'
    }), 200
