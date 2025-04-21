from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity, get_jwt
from models.user import User
import hashlib

auth_blueprint = Blueprint('auth', __name__)

@auth_blueprint.route('/login', methods=['POST'])
def login():
    """
    Autentica um usuário (estudante ou coordenador)
    
    Request:
        - email: Email do usuário
        - senha: Senha do usuário
        - tipo: Tipo de usuário ('student' ou 'coordinator')
    
    Returns:
        - token: Token JWT para autenticação
        - usuario: Dados do usuário autenticado
    """
    data = request.get_json()
    
    if not data or 'email' not in data or 'senha' not in data or 'tipo' not in data:
        return jsonify({'erro': 'Dados incompletos. Email, senha e tipo são obrigatórios'}), 400
    
    email = data['email']
    senha = data['senha']
    tipo = data['tipo'].lower()
    
    # Mapear tipo para role no MongoDB
    role_map = {
        'aluno': 'student',
        'coordenador': 'coordinator',
        'student': 'student',
        'coordinator': 'coordinator'
    }
    
    if tipo not in role_map:
        return jsonify({'erro': 'Tipo de usuário inválido'}), 400
        
    role = role_map[tipo]
    
    # Buscar usuário pelo email e role
    user_model = User()
    usuario = user_model.buscar_por_email(email, role)
    
    if not usuario:
        return jsonify({'erro': 'Usuário não encontrado'}), 401
    
    # Hash da senha para comparação
    senha_hash = hashlib.sha256(senha.encode()).hexdigest()
    
    # Verificar senha
    if usuario.get('password') != senha_hash:
        return jsonify({'erro': 'Senha incorreta'}), 401
    
    # Criar token JWT - usar string como identity e armazenar dados adicionais em claims extras
    token = create_access_token(
        identity=str(usuario['_id']),
        additional_claims={'role': usuario['role']}
    )
    
    # Remover a senha antes de retornar os dados do usuário
    usuario_response = usuario.copy()
    if 'password' in usuario_response:
        del usuario_response['password']
    
    # Converter ObjectId para string para serialização JSON
    usuario_response['_id'] = str(usuario_response['_id'])
    
    # Converter outros ObjectId que possam existir
    if 'course' in usuario_response and 'course_id' in usuario_response['course']:
        usuario_response['course']['course_id'] = str(usuario_response['course']['course_id'])
        if 'coordinator' in usuario_response['course'] and 'coordinator_id' in usuario_response['course']['coordinator']:
            usuario_response['course']['coordinator']['coordinator_id'] = str(usuario_response['course']['coordinator']['coordinator_id'])
    
    if 'coordinated_courses' in usuario_response:
        for course in usuario_response['coordinated_courses']:
            if 'course_id' in course:
                course['course_id'] = str(course['course_id'])
    
    if 'activities' in usuario_response:
        for activity in usuario_response['activities']:
            if 'activity_id' in activity:
                activity['activity_id'] = str(activity['activity_id'])
    
    return jsonify({
        'token': token,
        'usuario': usuario_response
    }), 200

@auth_blueprint.route('/verificar', methods=['GET'])
@jwt_required()
def verificar_token():
    """
    Verifica se o token JWT é válido
    
    Returns:
        - mensagem: Mensagem de confirmação
        - usuario_id: ID do usuário autenticado
        - role: Papel do usuário ('student' ou 'coordinator')
    """
    # O identity é agora o ID do usuário como string
    usuario_id = get_jwt_identity()
    
    # Obter claims adicionais do token
    claims = get_jwt()
    role = claims.get('role')
    
    # Buscar informações atualizadas do usuário
    user_model = User()
    usuario = user_model.buscar_por_id(usuario_id)
    
    if not usuario:
        return jsonify({'erro': 'Usuário não encontrado'}), 404
    
    # Remover a senha antes de retornar os dados do usuário
    usuario_response = usuario.copy()
    if 'password' in usuario_response:
        del usuario_response['password']
    
    # Converter ObjectId para string para serialização JSON
    usuario_response['_id'] = str(usuario_response['_id'])
    
    # Converter outros ObjectId que possam existir
    if 'course' in usuario_response and 'course_id' in usuario_response['course']:
        usuario_response['course']['course_id'] = str(usuario_response['course']['course_id'])
        if 'coordinator' in usuario_response['course'] and 'coordinator_id' in usuario_response['course']['coordinator']:
            usuario_response['course']['coordinator']['coordinator_id'] = str(usuario_response['course']['coordinator']['coordinator_id'])
    
    if 'coordinated_courses' in usuario_response:
        for course in usuario_response['coordinated_courses']:
            if 'course_id' in course:
                course['course_id'] = str(course['course_id'])
    
    if 'activities' in usuario_response:
        for activity in usuario_response['activities']:
            if 'activity_id' in activity:
                activity['activity_id'] = str(activity['activity_id'])
    
    return jsonify({
        'mensagem': 'Token válido',
        'usuario_id': usuario_id,
        'role': role,
        'usuario': usuario_response
    }), 200
