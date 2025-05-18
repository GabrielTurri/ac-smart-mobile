from config.database import get_db_connection
from bson.objectid import ObjectId

class Aluno:
    """
    Modelo para representar um aluno no sistema
    """
    def __init__(self):
        self.db = get_db_connection()
        self.collection = self.db.alunos

    def criar(self, dados_aluno):
        """
        Cria um novo aluno no banco de dados
        
        Args:
            dados_aluno (dict): Dicionário com os dados do aluno
            
        Returns:
            str: ID do aluno criado
        """
        try:
            resultado = self.collection.insert_one(dados_aluno)
            return str(resultado.inserted_id)
        except Exception as e:
            print(f"Erro ao criar aluno: {e}")
            return None

    def buscar_todos(self, filtros=None, limite=100, pagina=1):
        """
        Busca todos os alunos no banco de dados
        
        Args:
            filtros (dict): Filtros a serem aplicados na busca
            limite (int): Limite de resultados por página
            pagina (int): Número da página
            
        Returns:
            list: Lista de alunos encontrados
        """
        try:
            skip = (pagina - 1) * limite
            
            if filtros is None:
                filtros = {}
                
            alunos = self.collection.find(filtros).skip(skip).limit(limite)
            return list(alunos)
        except Exception as e:
            print(f"Erro ao buscar alunos: {e}")
            return []

    def buscar_por_id(self, aluno_id):
        """
        Busca um aluno pelo ID
        
        Args:
            aluno_id (str): ID do aluno
            
        Returns:
            dict: Dados do aluno encontrado
        """
        try:
            return self.collection.find_one({"_id": ObjectId(aluno_id)})
        except Exception as e:
            print(f"Erro ao buscar aluno por ID: {e}")
            return None

    def buscar_por_email(self, email):
        """
        Busca um aluno pelo email
        
        Args:
            email (str): Email do aluno
            
        Returns:
            dict: Dados do aluno encontrado
        """
        try:
            return self.collection.find_one({"email_aluno": email})
        except Exception as e:
            print(f"Erro ao buscar aluno por email: {e}")
            return None

    def buscar_por_ra(self, ra):
        """
        Busca um aluno pelo RA
        
        Args:
            ra (int): RA do aluno
            
        Returns:
            dict: Dados do aluno encontrado
        """
        try:
            return self.collection.find_one({"ra_aluno": ra})
        except Exception as e:
            print(f"Erro ao buscar aluno por RA: {e}")
            return None

    def atualizar(self, aluno_id, dados_atualizados):
        """
        Atualiza os dados de um aluno
        
        Args:
            aluno_id (str): ID do aluno
            dados_atualizados (dict): Dados a serem atualizados
            
        Returns:
            bool: True se a atualização foi bem-sucedida, False caso contrário
        """
        try:
            resultado = self.collection.update_one(
                {"_id": ObjectId(aluno_id)},
                {"$set": dados_atualizados}
            )
            return resultado.modified_count > 0
        except Exception as e:
            print(f"Erro ao atualizar aluno: {e}")
            return False

    def deletar(self, aluno_id):
        """
        Remove um aluno do banco de dados
        
        Args:
            aluno_id (str): ID do aluno
            
        Returns:
            bool: True se a remoção foi bem-sucedida, False caso contrário
        """
        try:
            resultado = self.collection.delete_one({"_id": ObjectId(aluno_id)})
            return resultado.deleted_count > 0
        except Exception as e:
            print(f"Erro ao deletar aluno: {e}")
            return False
