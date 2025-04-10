from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from models.curso import Curso

cursos_blueprint = Blueprint('cursos', __name__)

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
    
    # Contar total para paginação
    total = len(curso_model.buscar_todos(filtros, 0, 0))
    total_paginas = (total + limite - 1) // limite
    
    return jsonify({
        'cursos': cursos,
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
    # Buscar curso
    curso_model = Curso()
    curso = curso_model.buscar_por_id(curso_id)
    
    if not curso:
        return jsonify({'erro': 'Curso não encontrado'}), 404
    
    return jsonify({'curso': curso}), 200

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
    identidade = get_jwt_identity()
    if identidade.get('tipo') != 'coordenador':
        return jsonify({'erro': 'Permissão negada. Apenas coordenadores podem criar cursos'}), 403
    
    dados = request.get_json()
    
    # Validar dados
    campos_obrigatorios = ['nome_curso', 'horas_complementares', 'coordenador_id']
    for campo in campos_obrigatorios:
        if campo not in dados:
            return jsonify({'erro': f'Campo obrigatório ausente: {campo}'}), 400
    
    # Verificar se o nome do curso já existe
    curso_model = Curso()
    if curso_model.buscar_por_nome(dados['nome_curso']):
        return jsonify({'erro': 'Já existe um curso com este nome'}), 400
    
    # Criar curso
    curso_id = curso_model.criar(dados)
    
    if not curso_id:
        return jsonify({'erro': 'Erro ao criar curso'}), 500
    
    return jsonify({
        'id': curso_id,
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
    identidade = get_jwt_identity()
    if identidade.get('tipo') != 'coordenador':
        return jsonify({'erro': 'Permissão negada. Apenas coordenadores podem atualizar cursos'}), 403
    
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
    identidade = get_jwt_identity()
    if identidade.get('tipo') != 'coordenador':
        return jsonify({'erro': 'Permissão negada. Apenas coordenadores podem remover cursos'}), 403
    
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
    identidade = get_jwt_identity()
    
    # Parâmetros de paginação
    pagina = int(request.args.get('pagina', 1))
    limite = int(request.args.get('limite', 20))
    
    # Buscar curso
    curso_model = Curso()
    curso = curso_model.buscar_por_id(curso_id)
    
    if not curso:
        return jsonify({'erro': 'Curso não encontrado'}), 404
    
    # Se for aluno, verificar se está matriculado no curso
    if identidade.get('tipo') == 'aluno':
        if not curso_model.db.alunos.find_one({"_id": identidade.get('id'), "curso_id": curso_id}):
            return jsonify({'erro': 'Você não está matriculado neste curso'}), 403
    
    # Listar alunos do curso
    alunos = curso_model.listar_alunos_do_curso(curso_id, limite, pagina)
    
    # Remover senhas dos resultados
    for aluno in alunos:
        if 'senha_aluno' in aluno:
            del aluno['senha_aluno']
    
    # Contar total para paginação
    total = len(curso_model.listar_alunos_do_curso(curso_id, 0, 0))
    total_paginas = (total + limite - 1) // limite
    
    return jsonify({
        'alunos': alunos,
        'total': total,
        'pagina': pagina,
        'total_paginas': total_paginas
    }), 200
