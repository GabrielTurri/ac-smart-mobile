from config.database import get_db_connection
from bson.objectid import ObjectId

class User:
    """
    Modelo unificado para representar usuários no sistema (alunos e coordenadores)
    """
    def __init__(self):
        self.db = get_db_connection()
        self.collection = self.db.users

    def criar(self, dados_usuario):
        """
        Cria um novo usuário no banco de dados
        
        Args:
            dados_usuario (dict): Dicionário com os dados do usuário
            
        Returns:
            str: ID do usuário criado
        """
        try:
            resultado = self.collection.insert_one(dados_usuario)
            return str(resultado.inserted_id)
        except Exception as e:
            print(f"Erro ao criar usuário: {e}")
            return None

    def buscar_todos(self, role=None, filtros=None, limite=100, pagina=1):
        """
        Busca todos os usuários no banco de dados
        
        Args:
            role (str): Papel do usuário ('student' ou 'coordinator')
            filtros (dict): Filtros adicionais a serem aplicados na busca
            limite (int): Limite de resultados por página
            pagina (int): Número da página
            
        Returns:
            list: Lista de usuários encontrados
        """
        try:
            skip = (pagina - 1) * limite
            
            if filtros is None:
                filtros = {}
                
            if role:
                filtros['role'] = role
                
            usuarios = list(self.collection.find(filtros).skip(skip).limit(limite))
            
            # Convert ObjectIds to strings
            for usuario in usuarios:
                usuario['_id'] = str(usuario['_id'])
                if 'course' in usuario and 'course_id' in usuario['course']:
                    usuario['course']['course_id'] = str(usuario['course']['course_id'])
                if 'activities' in usuario:
                    for activity in usuario['activities']:
                        if 'activity_id' in activity:
                            activity['activity_id'] = str(activity['activity_id'])
            
            return usuarios
        except Exception as e:
            print(f"Erro ao buscar usuários: {e}")
            return []

    def buscar_por_id(self, usuario_id):
        """
        Busca um usuário pelo ID
        
        Args:
            usuario_id (str): ID do usuário
            
        Returns:
            dict: Dados do usuário encontrado
        """
        try:
            usuario = self.collection.find_one({"_id": ObjectId(usuario_id)})
            if usuario:
                usuario['_id'] = str(usuario['_id'])
                if 'course' in usuario and 'course_id' in usuario['course']:
                    usuario['course']['course_id'] = str(usuario['course']['course_id'])
                if 'activities' in usuario:
                    for activity in usuario['activities']:
                        if 'activity_id' in activity:
                            activity['activity_id'] = str(activity['activity_id'])
            return usuario
        except Exception as e:
            print(f"Erro ao buscar usuário por ID: {e}")
            return None

    def buscar_por_email(self, email, role=None):
        """
        Busca um usuário pelo email
        
        Args:
            email (str): Email do usuário
            role (str): Papel do usuário ('student' ou 'coordinator')
            
        Returns:
            dict: Dados do usuário encontrado
        """
        try:
            filtro = {"email": email}
            if role:
                filtro["role"] = role
            usuario = self.collection.find_one(filtro)
            if usuario:
                usuario['_id'] = str(usuario['_id'])
                if 'course' in usuario and 'course_id' in usuario['course']:
                    usuario['course']['course_id'] = str(usuario['course']['course_id'])
                if 'activities' in usuario:
                    for activity in usuario['activities']:
                        if 'activity_id' in activity:
                            activity['activity_id'] = str(activity['activity_id'])
            return usuario
        except Exception as e:
            print(f"Erro ao buscar usuário por email: {e}")
            return None

    def atualizar(self, usuario_id, dados_atualizados):
        """
        Atualiza os dados de um usuário
        
        Args:
            usuario_id (str): ID do usuário
            dados_atualizados (dict): Dados a serem atualizados
            
        Returns:
            bool: True se a atualização foi bem-sucedida, False caso contrário
        """
        try:
            resultado = self.collection.update_one(
                {"_id": ObjectId(usuario_id)},
                {"$set": dados_atualizados}
            )
            return resultado.modified_count > 0
        except Exception as e:
            print(f"Erro ao atualizar usuário: {e}")
            return False

    def excluir(self, usuario_id):
        """
        Exclui um usuário do banco de dados
        
        Args:
            usuario_id (str): ID do usuário
            
        Returns:
            bool: True se a exclusão foi bem-sucedida, False caso contrário
        """
        try:
            resultado = self.collection.delete_one({"_id": ObjectId(usuario_id)})
            return resultado.deleted_count > 0
        except Exception as e:
            print(f"Erro ao excluir usuário: {e}")
            return False
            
    # Métodos específicos para estudantes
    def adicionar_atividade(self, aluno_id, atividade):
        """
        Adiciona uma atividade complementar para um aluno
        
        Args:
            aluno_id (str): ID do aluno
            atividade (dict): Dados da atividade
            
        Returns:
            bool: True se a adição foi bem-sucedida, False caso contrário
        """
        try:
            resultado = self.collection.update_one(
                {"_id": ObjectId(aluno_id), "role": "student"},
                {"$push": {"activities": atividade}}
            )
            return resultado.modified_count > 0
        except Exception as e:
            print(f"Erro ao adicionar atividade: {e}")
            return False
            
    def atualizar_atividade(self, aluno_id, atividade_id, dados_atualizados):
        """
        Atualiza uma atividade complementar de um aluno
        
        Args:
            aluno_id (str): ID do aluno
            atividade_id (str): ID da atividade
            dados_atualizados (dict): Dados a serem atualizados
            
        Returns:
            bool: True se a atualização foi bem-sucedida, False caso contrário
        """
        try:
            # Construir o objeto de atualização com os campos específicos
            update_fields = {}
            for key, value in dados_atualizados.items():
                update_fields[f"activities.$.{key}"] = value
                
            resultado = self.collection.update_one(
                {
                    "_id": ObjectId(aluno_id),
                    "role": "student",
                    "activities.activity_id": ObjectId(atividade_id)
                },
                {"$set": update_fields}
            )
            return resultado.modified_count > 0
        except Exception as e:
            print(f"Erro ao atualizar atividade: {e}")
            return False
            
    def excluir_atividade(self, aluno_id, atividade_id):
        """
        Remove uma atividade complementar de um aluno
        
        Args:
            aluno_id (str): ID do aluno
            atividade_id (str): ID da atividade
            
        Returns:
            bool: True se a remoção foi bem-sucedida, False caso contrário
        """
        try:
            resultado = self.collection.update_one(
                {"_id": ObjectId(aluno_id), "role": "student"},
                {"$pull": {"activities": {"activity_id": ObjectId(atividade_id)}}}
            )
            return resultado.modified_count > 0
        except Exception as e:
            print(f"Erro ao excluir atividade: {e}")
            return False
