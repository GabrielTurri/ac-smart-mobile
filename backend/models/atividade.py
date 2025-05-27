from config.database import get_db_connection
from bson.objectid import ObjectId
from datetime import datetime

class Atividade:
    """
    Modelo para representar uma atividade complementar no sistema
    """
    def __init__(self):
        self.db = get_db_connection()
        self.collection = self.db.atividades

    def criar(self, dados_atividade):
        """
        Cria uma nova atividade complementar no banco de dados
        
        Args:
            dados_atividade (dict): Dicionário com os dados da atividade
            
        Returns:
            str: ID da atividade criada
        """
        try:
            # Adicionar data de criação
            dados_atividade['data_criacao'] = datetime.now()
            
            # Status padrão é 'Pendente'
            if 'status' not in dados_atividade:
                dados_atividade['status'] = 'Pendente'
                
            resultado = self.collection.insert_one(dados_atividade)
            return str(resultado.inserted_id)
        except Exception as e:
            print(f"Erro ao criar atividade: {e}")
            return None

    def buscar_todas(self, filtros=None, limite=100, pagina=1):
        """
        Busca todas as atividades complementares no banco de dados
        
        Args:
            filtros (dict): Filtros a serem aplicados na busca
            limite (int): Limite de resultados por página
            pagina (int): Número da página
            
        Returns:
            list: Lista de atividades encontradas com ObjectIds convertidos para strings
        """
        try:
            skip = (pagina - 1) * limite
            
            if filtros is None:
                filtros = {}
                
            atividades_cursor = self.collection.find(filtros).sort('data_criacao', -1).skip(skip).limit(limite)
            
            # Converter ObjectIds para strings
            atividades = []
            for atividade in atividades_cursor:
                # Converter _id para string
                if '_id' in atividade:
                    atividade['_id'] = str(atividade['_id'])
                # Converter outros ObjectIds que possam existir
                if 'aluno_id' in atividade and isinstance(atividade['aluno_id'], ObjectId):
                    atividade['aluno_id'] = str(atividade['aluno_id'])
                atividades.append(atividade)
                
            return atividades
        except Exception as e:
            print(f"Erro ao buscar atividades: {e}")
            return []

    def buscar_por_id(self, atividade_id):
        """
        Busca uma atividade pelo ID
        
        Args:
            atividade_id (str): ID da atividade
            
        Returns:
            dict: Dados da atividade encontrada com ObjectIds convertidos para strings
        """
        try:
            atividade = self.collection.find_one({"_id": ObjectId(atividade_id)})
            
            if atividade:
                # Converter _id para string
                if '_id' in atividade:
                    atividade['_id'] = str(atividade['_id'])
                # Converter outros ObjectIds que possam existir
                if 'aluno_id' in atividade and isinstance(atividade['aluno_id'], ObjectId):
                    atividade['aluno_id'] = str(atividade['aluno_id'])
                    
            return atividade
        except Exception as e:
            print(f"Erro ao buscar atividade por ID: {e}")
            return None

    def buscar_por_aluno(self, aluno_id, status=None, limite=100, pagina=1):
        """
        Busca atividades de um aluno específico
        
        Args:
            aluno_id (str): ID do aluno
            status (str): Status das atividades a serem filtradas
            limite (int): Limite de resultados por página
            pagina (int): Número da página
            
        Returns:
            list: Lista de atividades encontradas com ObjectIds convertidos para strings
        """
        try:
            skip = (pagina - 1) * limite
            
            filtros = {"aluno_id": aluno_id}
            
            if status:
                filtros["status"] = status
                
            atividades_cursor = self.collection.find(filtros).sort('data_criacao', -1).skip(skip).limit(limite)
            
            # Converter ObjectIds para strings
            atividades = []
            for atividade in atividades_cursor:
                # Converter _id para string
                if '_id' in atividade:
                    atividade['_id'] = str(atividade['_id'])
                # Converter outros ObjectIds que possam existir
                if 'aluno_id' in atividade and isinstance(atividade['aluno_id'], ObjectId):
                    atividade['aluno_id'] = str(atividade['aluno_id'])
                atividades.append(atividade)
                
            return atividades
        except Exception as e:
            print(f"Erro ao buscar atividades por aluno: {e}")
            return []

    def atualizar(self, atividade_id, dados_atualizados):
        """
        Atualiza os dados de uma atividade
        
        Args:
            atividade_id (str): ID da atividade
            dados_atualizados (dict): Dados a serem atualizados
            
        Returns:
            bool: True se a atualização foi bem-sucedida, False caso contrário
        """
        try:
            # Adicionar data de atualização
            dados_atualizados['data_atualizacao'] = datetime.now()
            
            # Se a atividade está sendo retificada, registrar histórico
            atividade_atual = self.buscar_por_id(atividade_id)
            if atividade_atual and atividade_atual.get('status') == 'Reprovado' and 'status' in dados_atualizados and dados_atualizados['status'] == 'Pendente':
                # Estamos retificando uma atividade reprovada
                dados_atualizados['retificada'] = True
                dados_atualizados['data_retificacao'] = datetime.now()
                
                # Registrar histórico da retificação
                if 'historico' not in atividade_atual:
                    atividade_atual['historico'] = []
                
                historico_item = {
                    'status_anterior': atividade_atual.get('status'),
                    'data': datetime.now(),
                    'acao': 'retificacao'
                }
                
                # Atualizar o histórico
                self.collection.update_one(
                    {"_id": ObjectId(atividade_id)},
                    {"$push": {"historico": historico_item}}
                )
            
            resultado = self.collection.update_one(
                {"_id": ObjectId(atividade_id)},
                {"$set": dados_atualizados}
            )
            return resultado.modified_count > 0
        except Exception as e:
            print(f"Erro ao atualizar atividade: {e}")
            return False

    def alterar_status(self, atividade_id, novo_status, horas_aprovadas=None, observacao=None):
        """
        Altera o status de uma atividade
        
        Args:
            atividade_id (str): ID da atividade
            novo_status (str): Novo status da atividade (Aprovado, Reprovado, Pendente, Arquivado)
            horas_aprovadas (int): Número de horas aprovadas (caso status seja 'Aprovado')
            observacao (str): Observação sobre a mudança de status
            
        Returns:
            bool: True se a alteração foi bem-sucedida, False caso contrário
        """
        try:
            dados_atualizados = {
                "status": novo_status,
                "data_atualizacao": datetime.now()
            }
            
            if novo_status == "Aprovado" and horas_aprovadas is not None:
                dados_atualizados["horas_aprovadas"] = horas_aprovadas
                
            resultado = self.collection.update_one(
                {"_id": ObjectId(atividade_id)},
                {"$set": dados_atualizados}
            )
            
            # Se tiver observação, adicionar à coleção de observações
            if observacao:
                self.db.observacoes.insert_one({
                    "atividade_id": atividade_id,
                    "observacao": observacao,
                    "data_criacao": datetime.now()
                })
                
            return resultado.modified_count > 0
        except Exception as e:
            print(f"Erro ao alterar status da atividade: {e}")
            return False

    def deletar(self, atividade_id):
        """
        Remove uma atividade do banco de dados
        
        Args:
            atividade_id (str): ID da atividade
            
        Returns:
            bool: True se a remoção foi bem-sucedida, False caso contrário
        """
        try:
            resultado = self.collection.delete_one({"_id": ObjectId(atividade_id)})
            
            # Remover também as observações relacionadas
            self.db.observacoes.delete_many({"atividade_id": atividade_id})
            
            return resultado.deleted_count > 0
        except Exception as e:
            print(f"Erro ao deletar atividade: {e}")
            return False
