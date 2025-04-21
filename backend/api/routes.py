from flask import Blueprint, request, jsonify
from flask_jwt_extended import jwt_required, get_jwt_identity
from api.students import students_blueprint
from api.atividades import atividades_blueprint
from api.cursos import cursos_blueprint
from api.coordinators import coordinators_blueprint
from api.auth import auth_blueprint

def register_routes(app):
    """
    Registra todas as rotas da API no aplicativo Flask
    Args:
        app: Instância do aplicativo Flask
    """
    # Registrar blueprints para cada recurso da API
    app.register_blueprint(auth_blueprint, url_prefix='/api/auth')
    app.register_blueprint(students_blueprint, url_prefix='/api/students')
    app.register_blueprint(atividades_blueprint, url_prefix='/api/atividades')
    app.register_blueprint(cursos_blueprint, url_prefix='/api/cursos')
    app.register_blueprint(coordinators_blueprint, url_prefix='/api/coordinators')
    
    return app
