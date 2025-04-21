import mysql.connector
from bson import ObjectId
from pymongo import MongoClient
import datetime

MONGO_URI = "mongodb+srv://ac-user:DhSiEeAvv91BYcl3@cluster1.mfkyhze.mongodb.net/?appName=Cluster1"
MONGO_DB = "ac_smart_db"

# Connect to MySQL
mysql_conn = mysql.connector.connect(
    host="192.168.1.40",
    user="root",
    password="my-secret-pw",
    database="humanitae_db"
)
cursor = mysql_conn.cursor(dictionary=True)

# Connect to MongoDB
mongo_client = MongoClient(MONGO_URI)
mongo_db = mongo_client[MONGO_DB]

# Clear existing data (if needed)
mongo_db.users.drop()
mongo_db.courses.drop()

# Step 1: Migrate Coordinators and create ID mapping
coordinator_id_map = {}  # MySQL ID -> MongoDB ID
coordinators = []

cursor.execute("SELECT * FROM coordenador")
for coord in cursor.fetchall():
    mongo_id = ObjectId()
    coordinator_id_map[coord['cod_coordenador']] = mongo_id
    
    coordinators.append({
        "_id": mongo_id,
        "name": coord['nome_coordenador'],
        "surname": coord['sobrenome_coordenador'],
        "email": coord['email_coordenador'],
        "password": coord['senha_coordenador'],  # In production, rehash this
        "role": "coordinator",
        "coordinated_courses": []
    })

# Step 2: Migrate Courses with their disciplines
course_id_map = {}  # MySQL ID -> MongoDB ID
courses = []

cursor.execute("""
    SELECT c.*, co.nome_coordenador, co.sobrenome_coordenador, co.email_coordenador 
    FROM curso c
    JOIN coordenador co ON c.coordenador_curso = co.cod_coordenador
""")

for course in cursor.fetchall():
    mongo_id = ObjectId()
    course_id_map[course['cod_curso']] = mongo_id
    
    # Get disciplines for this course
    cursor2 = mysql_conn.cursor(dictionary=True)
    cursor2.execute("SELECT * FROM disciplina WHERE cod_curso = %s", (course['cod_curso'],))
    disciplines = []
    
    for disc in cursor2.fetchall():
        disciplines.append({
            "name": disc['nome'],
            "description": disc['descricao']
        })
    
    # Create course document
    course_doc = {
        "_id": mongo_id,
        "name": course['nome_curso'],
        "required_hours": course['horas_complementares'],
        "coordinator": {
            "coordinator_id": coordinator_id_map[course['coordenador_curso']],
            "name": course['nome_coordenador'],
            "surname": course['sobrenome_coordenador'],
            "email": course['email_coordenador']
        },
        "disciplines": disciplines,
        "student_count": 0,
        "pending_activities": []
    }
    
    courses.append(course_doc)
    
    # Update the coordinator's courses list
    for coord in coordinators:
        if coord["_id"] == coordinator_id_map[course['coordenador_curso']]:
            coord["coordinated_courses"].append({
                "course_id": mongo_id,
                "name": course['nome_curso'],
                "required_hours": course['horas_complementares']
            })

# Step 3: Migrate Students with their activities
students = []

cursor.execute("""
    SELECT a.*, c.nome_curso, c.horas_complementares, 
           co.cod_coordenador, co.nome_coordenador, co.sobrenome_coordenador, co.email_coordenador 
    FROM aluno a
    JOIN curso c ON a.cod_curso = c.cod_curso
    JOIN coordenador co ON c.coordenador_curso = co.cod_coordenador
""")

for student in cursor.fetchall():
    # Get all activities for this student
    cursor2 = mysql_conn.cursor(dictionary=True)
    cursor2.execute("""
        SELECT ac.*, obs.observacao, obs.observacao_atividade_timestamp 
        FROM atividade_complementar ac
        LEFT JOIN observacao_atividade obs ON ac.cod_atividade = obs.cod_atividade
        WHERE ac.RA_aluno = %s
    """, (student['RA_aluno'],))
    
    activities = []
    total_approved = 0
    total_pending = 0
    total_rejected = 0
    
    for activity in cursor2.fetchall():
        activity_id = ObjectId()
        
        # Process observations
        observations = []
        if activity['observacao']:
            observations.append({
                "text": activity['observacao'],
                "created_at": activity['observacao_atividade_timestamp'],
                "coordinator_name": f"{student['nome_coordenador']} {student['sobrenome_coordenador']}"
            })
        
        act_doc = {
            "activity_id": activity_id,
            "title": activity['titulo'],
            "description": activity['descricao'],
            "attachment_path": activity['caminho_anexo'],
            "requested_hours": activity['horas_solicitadas'],
            "completion_date": datetime.datetime.combine(activity['data'], datetime.time.min) if isinstance(activity['data'], datetime.date) else activity['data'],
            "status": activity['status'],
            "approved_hours": activity['horas_aprovadas'],
            "created_at": activity['atividade_complementar_timestamp'],
            "observations": observations
        }
        
        activities.append(act_doc)
        
        # Track hours by status
        if activity['status'] == 'Approved':
            total_approved += activity['horas_aprovadas']
        elif activity['status'] == 'Pending':
            total_pending += activity['horas_solicitadas']
            
            # Add to pending activities in course
            for course in courses:
                if course["_id"] == course_id_map[student['cod_curso']]:
                    course["pending_activities"].append({
                        "activity_id": activity_id,
                        "student_id": ObjectId(),  # Will be replaced after student creation
                        "student_name": f"{student['nome_aluno']} {student['sobrenome_aluno']}",
                        "student_RA": student['RA_aluno'],
                        "title": activity['titulo'],
                        "requested_hours": activity['horas_solicitadas'],
                        "created_at": activity['atividade_complementar_timestamp']
                    })
        elif activity['status'] == 'Reprovado':  # Assuming 'Reprovado' is 'Rejected' in Portuguese
            total_rejected += activity['horas_solicitadas']
    
    # Create student document
    student_doc = {
        "_id": ObjectId(),
        "name": student['nome_aluno'],
        "surname": student['sobrenome_aluno'],
        "email": student['email_aluno'],
        "password": student['senha_aluno'],  # In production, rehash this
        "role": "student",
        "RA": student['RA_aluno'],
        "course": {
            "course_id": course_id_map[student['cod_curso']],
            "name": student['nome_curso'],
            "required_hours": student['horas_complementares'],
            "coordinator": {
                "coordinator_id": coordinator_id_map[student['cod_coordenador']],
                "name": student['nome_coordenador'],
                "surname": student['sobrenome_coordenador'],
                "email": student['email_coordenador']
            }
        },
        "activities": activities,
        "total_approved_hours": total_approved,
        "total_pending_hours": total_pending,
        "total_rejected_hours": total_rejected
    }
    
    students.append(student_doc)
    
    # Update student count in course
    for course in courses:
        if course["_id"] == course_id_map[student['cod_curso']]:
            course["student_count"] += 1
    
    # Update student_id in pending activities
    for course in courses:
        for pending in course.get("pending_activities", []):
            if pending.get("student_RA") == student['RA_aluno']:
                pending["student_id"] = student_doc["_id"]

# Insert all data into MongoDB
if coordinators:
    mongo_db.users.insert_many(coordinators)
if courses:
    mongo_db.courses.insert_many(courses)
if students:
    mongo_db.users.insert_many(students)

print(f"Migration complete! Migrated {len(coordinators)} coordinators, {len(courses)} courses, and {len(students)} students.")