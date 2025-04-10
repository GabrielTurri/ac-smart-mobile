import os
from pymongo import MongoClient
from dotenv import load_dotenv

# Carregar variáveis de ambiente
load_dotenv()

# Variáveis de conexão MongoDB
MONGO_URI = os.getenv('MONGO_URI', 'mongodb://localhost:27017')
MONGO_DB = os.getenv('MONGO_DB', 'ac_smart_db')

# Função para obter conexão com o MongoDB
def get_db_connection():
    """
    Estabelece conexão com o banco de dados MongoDB
    Returns:
        database: Instância do banco de dados MongoDB
    """
    try:
        client = MongoClient(MONGO_URI)
        db = client[MONGO_DB]
        return db
    except Exception as e:
        print(f"Erro ao conectar ao MongoDB: {e}")
        return None

# Função para testar a conexão com o banco de dados
def test_connection():
    """
    Testa a conexão com o banco de dados MongoDB
    Returns:
        bool: True se conectado com sucesso, False caso contrário
    """
    try:
        db = get_db_connection()
        # Tenta listar as coleções para verificar a conexão
        db.list_collection_names()
        return True
    except Exception as e:
        print(f"Erro ao testar conexão com MongoDB: {e}")
        return False
