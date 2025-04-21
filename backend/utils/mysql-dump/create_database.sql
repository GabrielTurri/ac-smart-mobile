CREATE DATABASE  IF NOT EXISTS `humanitae_db` /*!40100 DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci */;
USE `humanitae_db`;
-- MySQL dump 10.13  Distrib 8.0.36, for Win64 (x86_64)
--
-- Host: ac-smart-database.cha6yq8iwxxu.sa-east-1.rds.amazonaws.com    Database: humanitae_db
-- ------------------------------------------------------
-- Server version	5.5.5-10.11.6-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `aluno`
--

DROP TABLE IF EXISTS `aluno`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `aluno` (
  `RA_aluno` int(11) NOT NULL AUTO_INCREMENT,
  `nome_aluno` varchar(50) DEFAULT NULL,
  `sobrenome_aluno` varchar(50) DEFAULT NULL,
  `email_aluno` varchar(60) DEFAULT NULL,
  `cod_curso` int(11) DEFAULT NULL,
  `senha_aluno` varchar(255) DEFAULT '',
  PRIMARY KEY (`RA_aluno`),
  KEY `cod_curso` (`cod_curso`),
  CONSTRAINT `aluno_ibfk_1` FOREIGN KEY (`cod_curso`) REFERENCES `curso` (`cod_curso`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `atividade_complementar`
--

DROP TABLE IF EXISTS `atividade_complementar`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `atividade_complementar` (
  `cod_atividade` int(11) NOT NULL AUTO_INCREMENT,
  `titulo` varchar(150) DEFAULT NULL,
  `descricao` text DEFAULT NULL,
  `caminho_anexo` varchar(255) DEFAULT NULL,
  `horas_solicitadas` smallint(5) unsigned DEFAULT NULL,
  `data` date DEFAULT NULL,
  `status` enum('Aprovado','Reprovado','Pendente','Arquivado') DEFAULT 'Pendente',
  `horas_aprovadas` int(11) DEFAULT 0,
  `RA_aluno` int(11) DEFAULT NULL,
  `atividade_complementar_timestamp` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`cod_atividade`),
  KEY `RA_aluno` (`RA_aluno`),
  CONSTRAINT `atividade_complementar_ibfk_1` FOREIGN KEY (`RA_aluno`) REFERENCES `aluno` (`RA_aluno`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `coordenador`
--

DROP TABLE IF EXISTS `coordenador`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `coordenador` (
  `cod_coordenador` int(11) NOT NULL AUTO_INCREMENT,
  `nome_coordenador` varchar(50) DEFAULT NULL,
  `sobrenome_coordenador` varchar(50) DEFAULT NULL,
  `email_coordenador` varchar(60) DEFAULT NULL,
  `senha_coordenador` varchar(255) DEFAULT '',
  PRIMARY KEY (`cod_coordenador`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `curso`
--

DROP TABLE IF EXISTS `curso`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `curso` (
  `cod_curso` int(11) NOT NULL AUTO_INCREMENT,
  `nome_curso` varchar(50) DEFAULT NULL,
  `horas_complementares` int(11) DEFAULT NULL,
  `coordenador_curso` int(11) DEFAULT NULL,
  PRIMARY KEY (`cod_curso`),
  KEY `coordenador_curso` (`coordenador_curso`),
  CONSTRAINT `curso_ibfk_1` FOREIGN KEY (`coordenador_curso`) REFERENCES `coordenador` (`cod_coordenador`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `curso_aluno`
--

DROP TABLE IF EXISTS `curso_aluno`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `curso_aluno` (
  `cod_curso` int(11) NOT NULL,
  `RA_aluno` int(11) NOT NULL,
  PRIMARY KEY (`cod_curso`,`RA_aluno`),
  KEY `RA_aluno` (`RA_aluno`),
  CONSTRAINT `curso_aluno_ibfk_1` FOREIGN KEY (`cod_curso`) REFERENCES `curso` (`cod_curso`),
  CONSTRAINT `curso_aluno_ibfk_2` FOREIGN KEY (`RA_aluno`) REFERENCES `aluno` (`RA_aluno`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `curso_disciplina`
--

DROP TABLE IF EXISTS `curso_disciplina`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `curso_disciplina` (
  `cod_curso` int(11) NOT NULL,
  `cod_disciplina` int(11) NOT NULL,
  PRIMARY KEY (`cod_disciplina`,`cod_curso`),
  KEY `cod_curso` (`cod_curso`),
  CONSTRAINT `curso_disciplina_ibfk_1` FOREIGN KEY (`cod_disciplina`) REFERENCES `disciplina` (`cod_disciplina`),
  CONSTRAINT `curso_disciplina_ibfk_2` FOREIGN KEY (`cod_curso`) REFERENCES `curso` (`cod_curso`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `disciplina`
--

DROP TABLE IF EXISTS `disciplina`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `disciplina` (
  `cod_disciplina` int(11) NOT NULL AUTO_INCREMENT,
  `nome` varchar(150) DEFAULT NULL,
  `descricao` text DEFAULT NULL,
  `cod_curso` int(11) DEFAULT NULL,
  PRIMARY KEY (`cod_disciplina`),
  KEY `cod_curso` (`cod_curso`),
  CONSTRAINT `disciplina_ibfk_1` FOREIGN KEY (`cod_curso`) REFERENCES `curso` (`cod_curso`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Table structure for table `observacao_atividade`
--

DROP TABLE IF EXISTS `observacao_atividade`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `observacao_atividade` (
  `cod_observacao` int(11) NOT NULL AUTO_INCREMENT,
  `observacao` text DEFAULT NULL,
  `cod_atividade` int(11) DEFAULT NULL,
  `observacao_atividade_timestamp` timestamp NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`cod_observacao`),
  KEY `cod_atividade` (`cod_atividade`),
  CONSTRAINT `observacao_atividade_ibfk_1` FOREIGN KEY (`cod_atividade`) REFERENCES `atividade_complementar` (`cod_atividade`)
) ENGINE=InnoDB AUTO_INCREMENT=1 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Temporary view structure for view `vw_atividades_complementares_status`
--

DROP TABLE IF EXISTS `vw_atividades_complementares_status`;
/*!50001 DROP VIEW IF EXISTS `vw_atividades_complementares_status`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `vw_atividades_complementares_status` AS SELECT 
 1 AS `titulo`,
 1 AS `descricao`,
 1 AS `caminho_anexo`,
 1 AS `horas_solicitadas`,
 1 AS `data`,
 1 AS `status`,
 1 AS `horas_aprovadas`,
 1 AS `nome_aluno`,
 1 AS `sobrenome_aluno`,
 1 AS `email_aluno`,
 1 AS `nome_curso`*/;
SET character_set_client = @saved_cs_client;

--
-- Dumping events for database 'humanitae_db'
--

--
-- Dumping routines for database 'humanitae_db'
--

--
-- Final view structure for view `vw_atividades_complementares_status`
--

/*!50001 DROP VIEW IF EXISTS `vw_atividades_complementares_status`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_general_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`admin`@`%` SQL SECURITY DEFINER */
/*!50001 VIEW `vw_atividades_complementares_status` AS select `ac`.`titulo` AS `titulo`,`ac`.`descricao` AS `descricao`,`ac`.`caminho_anexo` AS `caminho_anexo`,`ac`.`horas_solicitadas` AS `horas_solicitadas`,`ac`.`data` AS `data`,`ac`.`status` AS `status`,`ac`.`horas_aprovadas` AS `horas_aprovadas`,`a`.`nome_aluno` AS `nome_aluno`,`a`.`sobrenome_aluno` AS `sobrenome_aluno`,`a`.`email_aluno` AS `email_aluno`,`c`.`nome_curso` AS `nome_curso` from ((`atividade_complementar` `ac` join `aluno` `a` on(`ac`.`RA_aluno` = `a`.`RA_aluno`)) join `curso` `c` on(`a`.`cod_curso` = `c`.`cod_curso`)) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2024-05-11 18:18:54
