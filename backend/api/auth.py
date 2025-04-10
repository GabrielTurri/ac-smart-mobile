from flask import Blueprint, request, jsonify
from flask_jwt_extended import create_access_token, jwt_required, get_jwt_identity
from models.aluno import Aluno
from models.coordenador import Coordenador
import hashlib

auth_blueprint = Blueprint('auth', __name__)

@auth_blueprint.route('/login', methods=['POST'])
def login():
    """
    Autentica um usuário (aluno ou coordenador)
    
    Request:
        - email: Email do usuário
        - senha: Senha do usuário
        - tipo: Tipo de usuário (aluno ou coordenador)
    
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
    
    # Hash da senha para comparação
    senha_hash = hashlib.sha256(senha.encode()).hexdigest()
    
    if tipo == 'aluno':
        aluno = Aluno().buscar_por_email(email)
        if not aluno or aluno.get('senha_aluno') != senha_hash:
            return jsonify({'erro': 'Credenciais inválidas'}), 401
        
        # Criar token JWT
        token = create_access_token(identity={'id': str(aluno['_id']), 'tipo': 'aluno'})
        
        # Remover a senha antes de retornar os dados do usuário
        del aluno['senha_aluno']
        
        return jsonify({
            'token': token,
            'usuario': aluno
        }), 200
        
    elif tipo == 'coordenador':
        coordenador = Coordenador().buscar_por_email(email)
        if not coordenador or coordenador.get('senha_coordenador') != senha_hash:
            return jsonify({'erro': 'Credenciais inválidas'}), 401
        
        # Criar token JWT
        token = create_access_token(identity={'id': str(coordenador['_id']), 'tipo': 'coordenador'})
        
        # Remover a senha antes de retornar os dados do usuário
        del coordenador['senha_coordenador']
        
        return jsonify({
            'token': token,
            'usuario': coordenador
        }), 200
    
    return jsonify({'erro': 'Tipo de usuário inválido'}), 400

@auth_blueprint.route('/verificar', methods=['GET'])
@jwt_required()
def verificar_token():
    """
    Verifica se o token JWT é válido
    
    Returns:
        - mensagem: Mensagem de confirmação
        - usuario_id: ID do usuário autenticado
        - tipo: Tipo de usuário (aluno ou coordenador)
    """
    identidade = get_jwt_identity()
    
    return jsonify({
        'mensagem': 'Token válido',
        'usuario_id': identidade.get('id'),
        'tipo': identidade.get('tipo')
    }), 200
