from config.database import get_db_connection
from bson.objectid import ObjectId

class Coordenador:
    """
    Modelo para representar um coordenador no sistema
    """
    def __init__(self):
        self.db = get_db_connection()
        self.collection = self.db.coordenadores

    def criar(self, dados_coordenador):
        """
        Cria um novo coordenador no banco de dados
        
        Args:
            dados_coordenador (dict): Dicionário com os dados do coordenador
            
        Returns:
            str: ID do coordenador criado
        """
        try:
            resultado = self.collection.insert_one(dados_coordenador)
            return str(resultado.inserted_id)
        except Exception as e:
            print(f"Erro ao criar coordenador: {e}")
            return None

    def buscar_todos(self, filtros=None, limite=100, pagina=1):
        """
        Busca todos os coordenadores no banco de dados
        
        Args:
            filtros (dict): Filtros a serem aplicados na busca
            limite (int): Limite de resultados por página
            pagina (int): Número da página
            
        Returns:
            list: Lista de coordenadores encontrados
        """
        try:
            skip = (pagina - 1) * limite
            
            if filtros is None:
                filtros = {}
                
            coordenadores = self.collection.find(filtros).skip(skip).limit(limite)
            return list(coordenadores)
        except Exception as e:
            print(f"Erro ao buscar coordenadores: {e}")
            return []

    def buscar_por_id(self, coordenador_id):
        """
        Busca um coordenador pelo ID
        
        Args:
            coordenador_id (str): ID do coordenador
            
        Returns:
            dict: Dados do coordenador encontrado
        """
        try:
            return self.collection.find_one({"_id": ObjectId(coordenador_id)})
        except Exception as e:
            print(f"Erro ao buscar coordenador por ID: {e}")
            return None

    def buscar_por_email(self, email):
        """
        Busca um coordenador pelo email
        
        Args:
            email (str): Email do coordenador
            
        Returns:
            dict: Dados do coordenador encontrado
        """
        try:
            return self.collection.find_one({"email_coordenador": email})
        except Exception as e:
            print(f"Erro ao buscar coordenador por email: {e}")
            return None

    def atualizar(self, coordenador_id, dados_atualizados):
        """
        Atualiza os dados de um coordenador
        
        Args:
            coordenador_id (str): ID do coordenador
            dados_atualizados (dict): Dados a serem atualizados
            
        Returns:
            bool: True se a atualização foi bem-sucedida, False caso contrário
        """
        try:
            resultado = self.collection.update_one(
                {"_id": ObjectId(coordenador_id)},
                {"$set": dados_atualizados}
            )
            return resultado.modified_count > 0
        except Exception as e:
            print(f"Erro ao atualizar coordenador: {e}")
            return False

    def deletar(self, coordenador_id):
        """
        Remove um coordenador do banco de dados
        
        Args:
            coordenador_id (str): ID do coordenador
            
        Returns:
            bool: True se a remoção foi bem-sucedida, False caso contrário
        """
        try:
            # Verificar se o coordenador está associado a algum curso
            cursos = self.db.cursos.find_one({"coordenador_id": coordenador_id})
            if cursos:
                # Não permitir exclusão se o coordenador está associado a cursos
                return False
                
            resultado = self.collection.delete_one({"_id": ObjectId(coordenador_id)})
            return resultado.deleted_count > 0
        except Exception as e:
            print(f"Erro ao deletar coordenador: {e}")
            return False
