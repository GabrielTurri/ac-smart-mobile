from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from api.alunos import alunos_blueprint
from api.atividades import atividades_blueprint
from api.cursos import cursos_blueprint
from api.coordenadores import coordenadores_blueprint
from api.auth import auth_blueprint

def register_routes(app):
    """
    Registra todas as rotas da API no aplicativo Flask
    Args:
        app: Instância do aplicativo Flask
    """
    # Registrar blueprints para cada recurso da API
    app.register_blueprint(auth_blueprint, url_prefix='/api/auth')
    app.register_blueprint(alunos_blueprint, url_prefix='/api/alunos')
    app.register_blueprint(atividades_blueprint, url_prefix='/api/atividades')
    app.register_blueprint(cursos_blueprint, url_prefix='/api/cursos')
    app.register_blueprint(coordenadores_blueprint, url_prefix='/api/coordenadores')
    
    return app
