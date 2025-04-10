#!/usr/bin/env python3
"""
Script para migrar dados do MySQL para o MongoDB.
Este script lê os dados do banco de dados MySQL antigo e os insere no MongoDB.

Uso:
    python migrate_data.py --mysql-host=localhost --mysql-user=root --mysql-password=password --mysql-db=humanitae_db

Autor: Gabriel Turri
Data: Abril 2025
"""

import argparse
import pymysql
import hashlib
from config.database import get_db_connection
from bson.objectid import ObjectId
from datetime import datetime
import sys

def parse_args():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(description='Migrar dados do MySQL para o MongoDB')
    
    parser.add_argument('--mysql-host', required=True, help='Host do MySQL')
    parser.add_argument('--mysql-user', required=True, help='Usuário do MySQL')
    parser.add_argument('--mysql-password', required=True, help='Senha do MySQL')
    parser.add_argument('--mysql-db', required=True, help='Nome do banco de dados MySQL')
    parser.add_argument('--mysql-port', type=int, default=3306, help='Porta do MySQL (padrão: 3306)')
    
    return parser.parse_args()

def connect_mysql(host, user, password, db, port):
    """Conecta ao banco de dados MySQL."""
    try:
        connection = pymysql.connect(
            host=host,
            user=user,
            password=password,
            database=db,
            port=port,
            charset='utf8mb4',
            cursorclass=pymysql.cursors.DictCursor
        )
        print(f"✅ Conexão com MySQL estabelecida: {host}:{port}/{db}")
        return connection
    except Exception as e:
        print(f"❌ Erro ao conectar ao MySQL: {e}")
        sys.exit(1)

def migrate_coordenadores(mysql_conn, mongodb):
    """Migra os coordenadores do MySQL para o MongoDB."""
    print("\n🔄 Migrando coordenadores...")
    coordenadores_collection = mongodb.coordenadores
    
    # Limpar coleção existente
    coordenadores_collection.delete_many({})
    
    # Mapear IDs antigos para novos
    id_mapping = {}
    
    with mysql_conn.cursor() as cursor:
        cursor.execute("SELECT * FROM coordenador")
        coordenadores = cursor.fetchall()
        
        for coordenador in coordenadores:
            # Hash da senha para segurança
            senha_hash = hashlib.sha256(
                coordenador.get('senha_coordenador', 'senha_padrao').encode()
            ).hexdigest()
            
            novo_coordenador = {
                'nome_coordenador': coordenador.get('nome_coordenador', ''),
                'sobrenome_coordenador': coordenador.get('sobrenome_coordenador', ''),
                'email_coordenador': coordenador.get('email_coordenador', ''),
                'senha_coordenador': senha_hash,
                'mysql_id': coordenador.get('cod_coordenador')
            }
            
            resultado = coordenadores_collection.insert_one(novo_coordenador)
            id_mapping[coordenador.get('cod_coordenador')] = resultado.inserted_id
            
    print(f"✅ {len(id_mapping)} coordenadores migrados.")
    return id_mapping

def migrate_cursos(mysql_conn, mongodb, coordenadores_mapping):
    """Migra os cursos do MySQL para o MongoDB."""
    print("\n🔄 Migrando cursos...")
    cursos_collection = mongodb.cursos
    
    # Limpar coleção existente
    cursos_collection.delete_many({})
    
    # Mapear IDs antigos para novos
    id_mapping = {}
    
    with mysql_conn.cursor() as cursor:
        cursor.execute("SELECT * FROM curso")
        cursos = cursor.fetchall()
        
        for curso in cursos:
            coordenador_id = curso.get('coordenador_curso')
            
            novo_curso = {
                'nome_curso': curso.get('nome_curso', ''),
                'horas_complementares': curso.get('horas_complementares', 0),
                'coordenador_id': str(coordenadores_mapping.get(coordenador_id)) if coordenador_id in coordenadores_mapping else None,
                'mysql_id': curso.get('cod_curso')
            }
            
            resultado = cursos_collection.insert_one(novo_curso)
            id_mapping[curso.get('cod_curso')] = resultado.inserted_id
            
    print(f"✅ {len(id_mapping)} cursos migrados.")
    return id_mapping

def migrate_alunos(mysql_conn, mongodb, cursos_mapping):
    """Migra os alunos do MySQL para o MongoDB."""
    print("\n🔄 Migrando alunos...")
    alunos_collection = mongodb.alunos
    
    # Limpar coleção existente
    alunos_collection.delete_many({})
    
    # Mapear IDs antigos para novos
    id_mapping = {}
    
    with mysql_conn.cursor() as cursor:
        cursor.execute("SELECT * FROM aluno")
        alunos = cursor.fetchall()
        
        for aluno in cursos:
            curso_id = aluno.get('cod_curso')
            
            # Hash da senha para segurança
            senha_hash = hashlib.sha256(
                aluno.get('senha_aluno', 'senha_padrao').encode()
            ).hexdigest()
            
            novo_aluno = {
                'ra_aluno': aluno.get('RA_aluno'),
                'nome_aluno': aluno.get('nome_aluno', ''),
                'sobrenome_aluno': aluno.get('sobrenome_aluno', ''),
                'email_aluno': aluno.get('email_aluno', ''),
                'curso_id': str(cursos_mapping.get(curso_id)) if curso_id in cursos_mapping else None,
                'senha_aluno': senha_hash,
                'mysql_id': aluno.get('RA_aluno')
            }
            
            resultado = alunos_collection.insert_one(novo_aluno)
            id_mapping[aluno.get('RA_aluno')] = resultado.inserted_id
            
    print(f"✅ {len(id_mapping)} alunos migrados.")
    return id_mapping

def migrate_atividades(mysql_conn, mongodb, alunos_mapping):
    """Migra as atividades complementares do MySQL para o MongoDB."""
    print("\n🔄 Migrando atividades complementares...")
    atividades_collection = mongodb.atividades
    observacoes_collection = mongodb.observacoes
    
    # Limpar coleções existentes
    atividades_collection.delete_many({})
    observacoes_collection.delete_many({})
    
    # Mapear IDs antigos para novos
    id_mapping = {}
    
    with mysql_conn.cursor() as cursor:
        cursor.execute("SELECT * FROM atividade_complementar")
        atividades = cursor.fetchall()
        
        for atividade in atividades:
            aluno_id = atividade.get('RA_aluno')
            
            nova_atividade = {
                'titulo': atividade.get('titulo', ''),
                'descricao': atividade.get('descricao', ''),
                'anexo': atividade.get('caminho_anexo', ''),
                'horas_solicitadas': atividade.get('horas_solicitadas', 0),
                'horas_aprovadas': atividade.get('horas_aprovadas', 0),
                'data': atividade.get('data'),
                'status': atividade.get('status', 'Pendente'),
                'aluno_id': str(alunos_mapping.get(aluno_id)) if aluno_id in alunos_mapping else None,
                'data_criacao': datetime.strptime(str(atividade.get('atividade_complementar_timestamp')), '%Y-%m-%d %H:%M:%S') if atividade.get('atividade_complementar_timestamp') else datetime.now(),
                'mysql_id': atividade.get('cod_atividade')
            }
            
            resultado = atividades_collection.insert_one(nova_atividade)
            id_mapping[atividade.get('cod_atividade')] = resultado.inserted_id
            
    print(f"✅ {len(id_mapping)} atividades complementares migradas.")
    
    # Migrar observações das atividades
    print("\n🔄 Migrando observações de atividades...")
    observacoes_count = 0
    
    with mysql_conn.cursor() as cursor:
        cursor.execute("SELECT * FROM observacao_atividade")
        observacoes = cursor.fetchall()
        
        for observacao in observacoes:
            atividade_id = observacao.get('cod_atividade')
            
            nova_observacao = {
                'observacao': observacao.get('observacao', ''),
                'atividade_id': str(id_mapping.get(atividade_id)) if atividade_id in id_mapping else None,
                'data_criacao': datetime.strptime(str(observacao.get('observacao_atividade_timestamp')), '%Y-%m-%d %H:%M:%S') if observacao.get('observacao_atividade_timestamp') else datetime.now(),
                'mysql_id': observacao.get('cod_observacao')
            }
            
            if nova_observacao['atividade_id']:
                observacoes_collection.insert_one(nova_observacao)
                observacoes_count += 1
            
    print(f"✅ {observacoes_count} observações de atividades migradas.")
    
    return id_mapping

def main():
    """Função principal."""
    args = parse_args()
    
    print("🚀 Iniciando migração de dados do MySQL para o MongoDB...")
    
    # Conexões com os bancos de dados
    mysql_conn = connect_mysql(
        args.mysql_host, 
        args.mysql_user, 
        args.mysql_password, 
        args.mysql_db, 
        args.mysql_port
    )
    
    mongodb = get_db_connection()
    if not mongodb:
        print("❌ Falha na conexão com o MongoDB.")
        sys.exit(1)
    
    print("✅ Conexão com MongoDB estabelecida")
    
    try:
        # Migrar dados
        coordenadores_mapping = migrate_coordenadores(mysql_conn, mongodb)
        cursos_mapping = migrate_cursos(mysql_conn, mongodb, coordenadores_mapping)
        alunos_mapping = migrate_alunos(mysql_conn, mongodb, cursos_mapping)
        atividades_mapping = migrate_atividades(mysql_conn, mongodb, alunos_mapping)
        
        print("\n✅ Migração de dados concluída com sucesso!")
        
    except Exception as e:
        print(f"\n❌ Erro durante a migração: {e}")
        sys.exit(1)
    finally:
        mysql_conn.close()
        
if __name__ == "__main__":
    main()
