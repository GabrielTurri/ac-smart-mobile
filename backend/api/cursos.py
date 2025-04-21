from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt
from models.curso import Curso
from bson import ObjectId

cursos_blueprint = Blueprint('cursos', __name__)

# Helper function to convert ObjectId to string for JSON serialization
def serialize_course(course):
    # Make a copy so we don't modify the original
    if not course:
        return None
        
    course_copy = course.copy()
    
    # Convert ObjectId to string
    if '_id' in course_copy:
        course_copy['_id'] = str(course_copy['_id'])
    
    # Convert nested ObjectIds
    if 'coordinator' in course_copy and 'coordinator_id' in course_copy['coordinator']:
        course_copy['coordinator']['coordinator_id'] = str(course_copy['coordinator']['coordinator_id'])
    
    # Convert discipline IDs if they exist
    if 'disciplines' in course_copy and isinstance(course_copy['disciplines'], list):
        for discipline in course_copy['disciplines']:
            if '_id' in discipline:
                discipline['_id'] = str(discipline['_id'])
                
    # Convert pending_activities if they exist
    if 'pending_activities' in course_copy and isinstance(course_copy['pending_activities'], list):
        for activity in course_copy['pending_activities']:
            if 'activity_id' in activity:
                activity['activity_id'] = str(activity['activity_id'])
            if 'student_id' in activity:
                activity['student_id'] = str(activity['student_id'])
    
    return course_copy

@cursos_blueprint.route('/', methods=['GET'])
@jwt_required()
def listar_cursos():
    """
    Lista todos os cursos
    
    Query params:
        - pagina: Número da página (padrão: 1)
        - limite: Número de itens por página (padrão: 20)
        - nome: Filtrar pelo nome do curso
        - coordenador_id: Filtrar pelo ID do coordenador
    
    Returns:
        - cursos: Lista de cursos
        - total: Total de cursos
        - pagina: Página atual
        - total_paginas: Total de páginas
    """
    # Verificar se o usuário logado é coordenador
    claims = get_jwt()
    if claims.get('role') != 'coordinator':
        return jsonify({'error': 'Permissão negada. Apenas coordenadores podem acessar esta funcionalidade'}), 403
    
    # Parâmetros de paginação
    pagina = int(request.args.get('pagina', 1))
    limite = int(request.args.get('limite', 20))
    
    # Filtros
    filtros = {}
    
    if 'nome' in request.args:
        nome = request.args.get('nome')
        # Filtro de busca por nome usando regex
        filtros['nome_curso'] = {'$regex': nome, '$options': 'i'}
    
    if 'coordenador_id' in request.args:
        filtros['coordenador_id'] = request.args.get('coordenador_id')
    
    # Buscar cursos
    curso_model = Curso()
    cursos = curso_model.buscar_todos(filtros, limite, pagina)
    
    # Serializar cursos para JSON (converter ObjectId para string)
    serialized_cursos = [serialize_course(curso) for curso in cursos]
    
    # Contar total para paginação
    total = len(curso_model.buscar_todos(filtros, 0, 0))
    total_paginas = (total + limite - 1) // limite
    
    return jsonify({
        'cursos': serialized_cursos,
        'total': total,
        'pagina': pagina,
        'total_paginas': total_paginas
    }), 200

@cursos_blueprint.route('/<curso_id>', methods=['GET'])
@jwt_required()
def buscar_curso(curso_id):
    """
    Busca um curso pelo ID
    
    Args:
        curso_id (str): ID do curso
    
    Returns:
        - curso: Dados do curso
    """
    # Verificar se o usuário logado é coordenador
    claims = get_jwt()
    if claims.get('role') != 'coordinator':
        return jsonify({'error': 'Permissão negada. Apenas coordenadores podem acessar esta funcionalidade'}), 403
    
    # Buscar curso
    curso_model = Curso()
    curso = curso_model.buscar_por_id(curso_id)
    
    if not curso:
        return jsonify({'error': 'Curso não encontrado'}), 404
    
    # Serializar curso para JSON (converter ObjectId para string)
    serialized_curso = serialize_course(curso)
    
    return jsonify({'curso': serialized_curso}), 200

@cursos_blueprint.route('/', methods=['POST'])
@jwt_required()
def criar_curso():
    """
    Cria um novo curso (apenas para coordenadores)
    
    Request:
        - nome_curso: Nome do curso
        - horas_complementares: Total de horas complementares requeridas
        - coordenador_id: ID do coordenador responsável
    
    Returns:
        - id: ID do curso criado
        - mensagem: Mensagem de sucesso
    """
    # Verificar se o usuário logado é coordenador
    claims = get_jwt()
    if claims.get('role') != 'coordinator':
        return jsonify({'error': 'Permissão negada. Apenas coordenadores podem criar cursos'}), 403
    
    dados = request.get_json()
    
    # Validar dados
    campos_obrigatorios = ['name', 'required_hours', 'coordinator_id']
    for campo in campos_obrigatorios:
        if campo not in dados:
            return jsonify({'erro': f'Campo obrigatório ausente: {campo}'}), 400
    
    # Verificar se o nome do curso já existe
    curso_model = Curso()
    if curso_model.buscar_por_nome(dados['name']):
        return jsonify({'erro': 'Já existe um curso com este nome'}), 400
    
    # Buscar informações do coordenador
    from models.user import User
    user_model = User()
    coordinator = user_model.buscar_por_id(dados['coordinator_id'])
    
    if not coordinator or coordinator['role'] != 'coordinator':
        return jsonify({'erro': 'Coordenador não encontrado'}), 404
    
    # Criar objeto do curso conforme o novo esquema MongoDB
    novo_curso = {
        'name': dados['name'],
        'required_hours': dados['required_hours'],
        'coordinator': {
            'coordinator_id': ObjectId(dados['coordinator_id']),
            'name': coordinator['name'],
            'surname': coordinator['surname'],
            'email': coordinator['email']
        },
        'disciplines': dados.get('disciplines', []),
        'student_count': 0,
        'pending_activities': []
    }
    
    # Criar curso
    curso_id = curso_model.criar(novo_curso)
    
    if not curso_id:
        return jsonify({'erro': 'Erro ao criar curso'}), 500
    
    return jsonify({
        'id': str(curso_id),  # Convert ObjectId to string
        'mensagem': 'Curso criado com sucesso'
    }), 201

@cursos_blueprint.route('/<curso_id>', methods=['PUT'])
@jwt_required()
def atualizar_curso(curso_id):
    """
    Atualiza os dados de um curso (apenas para coordenadores)
    
    Args:
        curso_id (str): ID do curso
    
    Request:
        - nome_curso: Nome do curso
        - horas_complementares: Total de horas complementares requeridas
        - coordenador_id: ID do coordenador responsável
    
    Returns:
        - mensagem: Mensagem de sucesso
    """
    # Verificar se o usuário logado é coordenador
    claims = get_jwt()
    if claims.get('role') != 'coordinator':
        return jsonify({'error': 'Permissão negada. Apenas coordenadores podem atualizar cursos'}), 403
    
    dados = request.get_json()
    
    # Buscar curso
    curso_model = Curso()
    curso = curso_model.buscar_por_id(curso_id)
    
    if not curso:
        return jsonify({'erro': 'Curso não encontrado'}), 404
    
    # Verificar se está alterando para um nome que já existe
    if 'nome_curso' in dados and dados['nome_curso'] != curso.get('nome_curso'):
        curso_existente = curso_model.buscar_por_nome(dados['nome_curso'])
        if curso_existente and str(curso_existente.get('_id')) != curso_id:
            return jsonify({'erro': 'Já existe um curso com este nome'}), 400
    
    # Atualizar curso
    sucesso = curso_model.atualizar(curso_id, dados)
    
    if not sucesso:
        return jsonify({'erro': 'Erro ao atualizar curso'}), 500
    
    return jsonify({
        'mensagem': 'Curso atualizado com sucesso'
    }), 200

@cursos_blueprint.route('/<curso_id>', methods=['DELETE'])
@jwt_required()
def deletar_curso(curso_id):
    """
    Remove um curso do sistema (apenas para coordenadores)
    
    Args:
        curso_id (str): ID do curso
    
    Returns:
        - mensagem: Mensagem de sucesso
    """
    # Verificar se o usuário logado é coordenador
    claims = get_jwt()
    if claims.get('role') != 'coordinator':
        return jsonify({'error': 'Permissão negada. Apenas coordenadores podem remover cursos'}), 403
    
    # Buscar curso
    curso_model = Curso()
    curso = curso_model.buscar_por_id(curso_id)
    
    if not curso:
        return jsonify({'erro': 'Curso não encontrado'}), 404
    
    # Deletar curso
    sucesso = curso_model.deletar(curso_id)
    
    if not sucesso:
        return jsonify({'erro': 'Erro ao deletar curso. Verifique se existem alunos matriculados neste curso.'}), 500
    
    return jsonify({
        'mensagem': 'Curso removido com sucesso'
    }), 200

@cursos_blueprint.route('/<curso_id>/alunos', methods=['GET'])
@jwt_required()
def listar_alunos_do_curso(curso_id):
    """
    Lista todos os alunos matriculados em um curso
    
    Args:
        curso_id (str): ID do curso
        
    Query params:
        - pagina: Número da página (padrão: 1)
        - limite: Número de itens por página (padrão: 20)
    
    Returns:
        - alunos: Lista de alunos
        - total: Total de alunos
        - pagina: Página atual
        - total_paginas: Total de páginas
    """
    # Verificar se o usuário logado é coordenador
    claims = get_jwt()
    
    # Parâmetros de paginação
    pagina = int(request.args.get('pagina', 1))
    limite = int(request.args.get('limite', 20))
    
    # Buscar curso
    curso_model = Curso()
    curso = curso_model.buscar_por_id(curso_id)
    
    if not curso:
        return jsonify({'erro': 'Curso não encontrado'}), 404
    
    # Se for aluno, verificar se está matriculado no curso
    if claims.get('role') == 'student':
        if not curso_model.db.alunos.find_one({"_id": claims.get('id'), "curso_id": curso_id}):
            return jsonify({'erro': 'Você não está matriculado neste curso'}), 403
    
    # Listar alunos do curso
    alunos = curso_model.listar_alunos_do_curso(curso_id, limite, pagina)
    
    # Serializar alunos para JSON
    serialized_alunos = []
    for aluno in alunos:
        aluno_copy = aluno.copy()
        if '_id' in aluno_copy:
            aluno_copy['_id'] = str(aluno_copy['_id'])
        serialized_alunos.append(aluno_copy)
    
    # Remover senhas dos resultados
    for aluno in serialized_alunos:
        if 'senha_aluno' in aluno:
            del aluno['senha_aluno']
    
    # Contar total para paginação
    total = len(curso_model.listar_alunos_do_curso(curso_id, 0, 0))
    total_paginas = (total + limite - 1) // limite
    
    return jsonify({
        'alunos': serialized_alunos,
        'total': total,
        'pagina': pagina,
        'total_paginas': total_paginas
    }), 200
