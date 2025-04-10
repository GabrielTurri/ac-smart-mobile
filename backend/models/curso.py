from config.database import get_db_connection
from bson.objectid import ObjectId

class Curso:
    """
    Modelo para representar um curso no sistema
    """
    def __init__(self):
        self.db = get_db_connection()
        self.collection = self.db.cursos

    def criar(self, dados_curso):
        """
        Cria um novo curso no banco de dados
        
        Args:
            dados_curso (dict): Dicionário com os dados do curso
            
        Returns:
            str: ID do curso criado
        """
        try:
            resultado = self.collection.insert_one(dados_curso)
            return str(resultado.inserted_id)
        except Exception as e:
            print(f"Erro ao criar curso: {e}")
            return None

    def buscar_todos(self, filtros=None, limite=100, pagina=1):
        """
        Busca todos os cursos no banco de dados
        
        Args:
            filtros (dict): Filtros a serem aplicados na busca
            limite (int): Limite de resultados por página
            pagina (int): Número da página
            
        Returns:
            list: Lista de cursos encontrados
        """
        try:
            skip = (pagina - 1) * limite
            
            if filtros is None:
                filtros = {}
                
            cursos = self.collection.find(filtros).skip(skip).limit(limite)
            return list(cursos)
        except Exception as e:
            print(f"Erro ao buscar cursos: {e}")
            return []

    def buscar_por_id(self, curso_id):
        """
        Busca um curso pelo ID
        
        Args:
            curso_id (str): ID do curso
            
        Returns:
            dict: Dados do curso encontrado
        """
        try:
            return self.collection.find_one({"_id": ObjectId(curso_id)})
        except Exception as e:
            print(f"Erro ao buscar curso por ID: {e}")
            return None
            
    def buscar_por_nome(self, nome):
        """
        Busca um curso pelo nome
        
        Args:
            nome (str): Nome do curso
            
        Returns:
            dict: Dados do curso encontrado
        """
        try:
            return self.collection.find_one({"nome_curso": nome})
        except Exception as e:
            print(f"Erro ao buscar curso por nome: {e}")
            return None

    def buscar_por_coordenador(self, coordenador_id):
        """
        Busca cursos pelo ID do coordenador
        
        Args:
            coordenador_id (str): ID do coordenador
            
        Returns:
            list: Lista de cursos encontrados
        """
        try:
            cursos = self.collection.find({"coordenador_id": coordenador_id})
            return list(cursos)
        except Exception as e:
            print(f"Erro ao buscar cursos por coordenador: {e}")
            return []

    def atualizar(self, curso_id, dados_atualizados):
        """
        Atualiza os dados de um curso
        
        Args:
            curso_id (str): ID do curso
            dados_atualizados (dict): Dados a serem atualizados
            
        Returns:
            bool: True se a atualização foi bem-sucedida, False caso contrário
        """
        try:
            resultado = self.collection.update_one(
                {"_id": ObjectId(curso_id)},
                {"$set": dados_atualizados}
            )
            return resultado.modified_count > 0
        except Exception as e:
            print(f"Erro ao atualizar curso: {e}")
            return False

    def deletar(self, curso_id):
        """
        Remove um curso do banco de dados
        
        Args:
            curso_id (str): ID do curso
            
        Returns:
            bool: True se a remoção foi bem-sucedida, False caso contrário
        """
        try:
            # Verificar se há alunos matriculados no curso
            alunos = self.db.alunos.find_one({"curso_id": curso_id})
            if alunos:
                # Não permitir exclusão se há alunos matriculados
                return False
                
            resultado = self.collection.delete_one({"_id": ObjectId(curso_id)})
            return resultado.deleted_count > 0
        except Exception as e:
            print(f"Erro ao deletar curso: {e}")
            return False
            
    def listar_alunos_do_curso(self, curso_id, limite=100, pagina=1):
        """
        Lista todos os alunos matriculados em um curso
        
        Args:
            curso_id (str): ID do curso
            limite (int): Limite de resultados por página
            pagina (int): Número da página
            
        Returns:
            list: Lista de alunos encontrados
        """
        try:
            skip = (pagina - 1) * limite
            alunos = self.db.alunos.find({"curso_id": curso_id}).skip(skip).limit(limite)
            return list(alunos)
        except Exception as e:
            print(f"Erro ao listar alunos do curso: {e}")
            return []
