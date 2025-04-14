"""
MySQL to MongoDB Migration Script for Humanitae Database

This script migrates data from a MySQL database to MongoDB following a document-oriented
approach, transforming relational tables into document collections.

Requirements:
- mysql-connector-python
- pymongo
- python-dotenv (optional, for loading environment variables)

Usage:
1. Configure the database connections in the script or through environment variables
2. Run the script: python migrate_to_mongodb.py
"""

import mysql.connector
from mysql.connector import Error
from pymongo import MongoClient
from datetime import datetime
import logging
import os
from dotenv import load_dotenv  # Optional

# Load environment variables if .env file exists
try:
    load_dotenv()
except ImportError:
    pass

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler("migration.log"),
        logging.StreamHandler()
    ]
)
logger = logging.getLogger()

# Database configuration
# You can set these as environment variables or hardcode for testing
MYSQL_CONFIG = {
    'host': os.getenv('MYSQL_HOST', 'localhost'),
    'database': os.getenv('MYSQL_DB', 'humanitae_db'),
    'user': os.getenv('MYSQL_USER', 'root'),
    'password': os.getenv('MYSQL_PASSWORD', ''),
}

MONGO_URI = os.getenv('MONGO_URI', 'mongodb://localhost:27017/')
MONGO_DB = os.getenv('MONGO_DB', 'ac_smart_db')

def connect_mysql():
    """Connect to MySQL database"""
    try:
        connection = mysql.connector.connect(**MYSQL_CONFIG)
        if connection.is_connected():
            logger.info(f"Connected to MySQL database: {MYSQL_CONFIG['database']}")
            return connection
    except Error as e:
        logger.error(f"Error connecting to MySQL: {e}")
        return None

def connect_mongodb():
    """Connect to MongoDB"""
    try:
        client = MongoClient(MONGO_URI)
        db = client[MONGO_DB]
        logger.info(f"Connected to MongoDB: {MONGO_DB}")
        return db
    except Exception as e:
        logger.error(f"Error connecting to MongoDB: {e}")
        return None

def clean_mongodb(db):
    """Clean existing collections in MongoDB before migration"""
    try:
        collections = ['users', 'courses', 'activities']
        for collection in collections:
            if collection in db.list_collection_names():
                db[collection].drop()
                logger.info(f"Dropped collection: {collection}")
    except Exception as e:
        logger.error(f"Error cleaning MongoDB: {e}")

def migrate_coordenadores(mysql_conn, mongo_db):
    """Migrate coordinators from MySQL to MongoDB"""
    try:
        cursor = mysql_conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM coordenador")
        coordinators = cursor.fetchall()
        
        users_collection = mongo_db.users
        
        for coordinator in coordinators:
            # Create new coordinator document
            coordinator_doc = {
                "role": "coordenador",
                "codigo": str(coordinator['cod_coordenador']),
                "nome": coordinator['nome_coordenador'],
                "sobrenome": coordinator['sobrenome_coordenador'],
                "email": coordinator['email_coordenador'],
                "senha": coordinator['senha_coordenador'],
                "cursos_coordenados": []  # Will be populated when migrating courses
            }
            
            # Insert into MongoDB
            result = users_collection.insert_one(coordinator_doc)
            logger.info(f"Inserted coordinator: {coordinator['nome_coordenador']} with ID: {result.inserted_id}")
        
        logger.info(f"Migrated {len(coordinators)} coordinators")
    except Exception as e:
        logger.error(f"Error migrating coordinators: {e}")

def migrate_alunos(mysql_conn, mongo_db):
    """Migrate students from MySQL to MongoDB"""
    try:
        cursor = mysql_conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM aluno")
        students = cursor.fetchall()
        
        users_collection = mongo_db.users
        
        for student in students:
            # Create new student document
            student_doc = {
                "role": "aluno",
                "codigo": str(student['RA_aluno']),
                "nome": student['nome_aluno'],
                "sobrenome": student['sobrenome_aluno'],
                "email": student['email_aluno'],
                "senha": student['senha_aluno'],
                "curso_id": str(student['cod_curso'])
            }
            
            # Insert into MongoDB
            result = users_collection.insert_one(student_doc)
            logger.info(f"Inserted student: {student['nome_aluno']} with ID: {result.inserted_id}")
        
        logger.info(f"Migrated {len(students)} students")
    except Exception as e:
        logger.error(f"Error migrating students: {e}")

def migrate_cursos_disciplinas(mysql_conn, mongo_db):
    """Migrate courses and disciplines from MySQL to MongoDB"""
    try:
        cursor = mysql_conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM curso")
        courses = cursor.fetchall()
        
        courses_collection = mongo_db.courses
        users_collection = mongo_db.users
        
        for course in courses:
            # Get disciplines for this course
            cursor.execute("SELECT * FROM disciplina WHERE cod_curso = %s", (course['cod_curso'],))
            disciplines = cursor.fetchall()
            
            # Format disciplines as embedded documents
            disciplines_docs = []
            for discipline in disciplines:
                disciplines_docs.append({
                    "nome": discipline['nome'],
                    "descricao": discipline['descricao']
                })
            
            # Create course document
            course_doc = {
                "_id": str(course['cod_curso']),
                "nome": course['nome_curso'],
                "horas_complementares": course['horas_complementares'],
                "coordenador_id": str(course['coordenador_curso']),
                "disciplinas": disciplines_docs
            }
            
            # Insert into MongoDB
            result = courses_collection.insert_one(course_doc)
            logger.info(f"Inserted course: {course['nome_curso']} with ID: {result.inserted_id}")
            
            # Update coordinator's cursos_coordenados array
            users_collection.update_one(
                {"role": "coordenador", "codigo": str(course['coordenador_curso'])},
                {"$push": {"cursos_coordenados": str(course['cod_curso'])}}
            )
        
        logger.info(f"Migrated {len(courses)} courses with their disciplines")
    except Exception as e:
        logger.error(f"Error migrating courses and disciplines: {e}")

def migrate_atividades_observacoes(mysql_conn, mongo_db):
    """Migrate activities and observations from MySQL to MongoDB"""
    try:
        cursor = mysql_conn.cursor(dictionary=True)
        cursor.execute("SELECT * FROM atividade_complementar")
        activities = cursor.fetchall()
        
        activities_collection = mongo_db.activities
        
        for activity in activities:
            # Get observations for this activity
            cursor.execute("SELECT * FROM observacao_atividade WHERE cod_atividade = %s", (activity['cod_atividade'],))
            observations = cursor.fetchall()
            
            # Format observations as embedded documents
            observations_docs = []
            for observation in observations:
                observations_docs.append({
                    "observacao": observation['observacao'],
                    "created_at": observation.get('observacao_atividade_timestamp') or datetime.now()
                })
            
            # Create activity document
            activity_doc = {
                "_id": str(activity['cod_atividade']),
                "aluno_id": str(activity['RA_aluno']),
                "titulo": activity['titulo'],
                "descricao": activity['descricao'],
                "caminho_anexo": activity['caminho_anexo'],
                "horas_solicitadas": activity['horas_solicitadas'],
                "horas_aprovadas": activity['horas_aprovadas'],
                "data": activity['data'],
                "status": activity['status'],
                "created_at": activity.get('atividade_complementar_timestamp') or datetime.now(),
                "observacoes": observations_docs
            }
            
            # Insert into MongoDB
            result = activities_collection.insert_one(activity_doc)
            logger.info(f"Inserted activity: {activity['titulo']} with ID: {result.inserted_id}")
        
        logger.info(f"Migrated {len(activities)} activities with their observations")
    except Exception as e:
        logger.error(f"Error migrating activities and observations: {e}")

def create_indexes(mongo_db):
    """Create indexes for better query performance"""
    try:
        # Indexes for users collection
        mongo_db.users.create_index("codigo")
        mongo_db.users.create_index("email")
        mongo_db.users.create_index("role")
        
        # Indexes for activities collection
        mongo_db.activities.create_index("aluno_id")
        mongo_db.activities.create_index("status")
        
        logger.info("Created indexes for better query performance")
    except Exception as e:
        logger.error(f"Error creating indexes: {e}")

def migration_complete(mongo_db):
    """Log some stats after migration is complete"""
    try:
        users_count = mongo_db.users.count_documents({})
        coordinator_count = mongo_db.users.count_documents({"role": "coordenador"})
        student_count = mongo_db.users.count_documents({"role": "aluno"})
        courses_count = mongo_db.courses.count_documents({})
        activities_count = mongo_db.activities.count_documents({})
        
        logger.info("Migration complete!")
        logger.info(f"Total users: {users_count} (Coordinators: {coordinator_count}, Students: {student_count})")
        logger.info(f"Total courses: {courses_count}")
        logger.info(f"Total activities: {activities_count}")
    except Exception as e:
        logger.error(f"Error generating migration stats: {e}")

def main():
    """Main migration function"""
    logger.info("Starting migration from MySQL to MongoDB")
    
    # Connect to databases
    mysql_conn = connect_mysql()
    mongo_db = connect_mongodb()
    
    if not mysql_conn or not mongo_db:
        logger.error("Failed to connect to one or both databases. Exiting.")
        return
    
    try:
        # Clean MongoDB collections before migration
        clean_mongodb(mongo_db)
        
        # Migrate data
        migrate_coordenadores(mysql_conn, mongo_db)
        migrate_alunos(mysql_conn, mongo_db)
        migrate_cursos_disciplinas(mysql_conn, mongo_db)
        migrate_atividades_observacoes(mysql_conn, mongo_db)
        
        # Create indexes for better query performance
        create_indexes(mongo_db)
        
        # Log migration stats
        migration_complete(mongo_db)
        
    except Exception as e:
        logger.error(f"Migration failed: {e}")
    finally:
        # Close MySQL connection
        if mysql_conn and mysql_conn.is_connected():
            mysql_conn.close()
            logger.info("MySQL connection closed")

if __name__ == "__main__":
    main()