from flask import Flask, jsonify, request
from flask_cors import CORS
from dotenv import load_dotenv
from flask_jwt_extended import JWTManager
import os
import logging
from api.routes import register_routes
from utils.mongo_encoder import MongoJSONEncoder
from utils.logging_config import configure_logging
from utils.request_logger import init_request_logger

# Carregar variáveis de ambiente
load_dotenv()

# Inicializar aplicação Flask
app = Flask(__name__)
app.url_map.strict_slashes = False  # Disable strict slash handling
CORS(app)

# Configurar logging
request_logger = configure_logging(app)
init_request_logger(app, request_logger)

# Configurar o encoder JSON personalizado para lidar com ObjectId do MongoDB
app.json_encoder = MongoJSONEncoder

# Configurações do JWT
app.config['JWT_SECRET_KEY'] = os.getenv('JWT_SECRET_KEY', 'seu-segredo-temporario')
app.config['JWT_ACCESS_TOKEN_EXPIRES'] = 86400  # 24 horas em segundos
jwt = JWTManager(app)

# Registrar rotas da API
register_routes(app)

# Rota de saúde da API
@app.route('/health', methods=['GET'])
def health_check():
    return jsonify({'status': 'online', 'message': 'API funcionando corretamente'})

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
