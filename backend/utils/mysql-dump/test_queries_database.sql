USE humanitae_db;

-- Consulta de alunos e seus respectivos coordenadores de curso
SELECT 
    a.nome_aluno, 
    a.sobrenome_aluno, 
    c.nome_curso, 
    co.nome_coordenador, 
    co.sobrenome_coordenador 
FROM 
    aluno a
JOIN 
    curso c ON a.cod_curso = c.cod_curso
JOIN 
    coordenador co ON c.coordenador_curso = co.cod_coordenador;

-- Lista de disciplinas por curso com descrição
SELECT 
    c.nome_curso, 
    d.nome, 
    d.descricao 
FROM 
    disciplina d
JOIN 
    curso c ON d.cod_curso = c.cod_curso;

-- Total de horas complementares aprovadas por aluno
SELECT 
    a.nome_aluno, 
    a.sobrenome_aluno, 
    SUM(ac.horas_aprovadas) AS total_horas_aprovadas
FROM 
    aluno a
JOIN 
    atividade_complementar ac ON a.RA_aluno = ac.RA_aluno
WHERE 
    ac.status = 'Aprovado'
GROUP BY 
    a.RA_aluno;
    
-- Alunos com atividades pendentes e suas respectivas atividades
SELECT 
    a.nome_aluno, 
    a.sobrenome_aluno, 
    ac.titulo, 
    ac.descricao, 
    ac.data 
FROM 
    aluno a
JOIN 
    atividade_complementar ac ON a.RA_aluno = ac.RA_aluno
WHERE 
    ac.status = 'Pendente';

-- Cursos e o número de alunos matriculados
SELECT 
    c.nome_curso, 
    COUNT(ca.RA_aluno) AS num_alunos
FROM 
    curso c
JOIN 
    curso_aluno ca ON c.cod_curso = ca.cod_curso
GROUP BY 
    c.cod_curso;

-- Detalhes de atividades complementares reprovadas, incluindo informações do aluno e do curso
SELECT 
    a.nome_aluno, 
    a.sobrenome_aluno, 
    c.nome_curso, 
    ac.titulo, 
    ac.descricao, 
    ac.horas_solicitadas, 
    ac.horas_aprovadas 
FROM 
    atividade_complementar ac
JOIN 
    aluno a ON ac.RA_aluno = a.RA_aluno
JOIN 
    curso c ON a.cod_curso = c.cod_curso
WHERE 
    ac.status = 'Reprovado';
    
    
-- View de Atividades Complementares com Status
-- Obs.: Criar view

-- Consulta para obter todas as atividades complementares com seus status
SELECT * FROM vw_atividades_complementares_status;