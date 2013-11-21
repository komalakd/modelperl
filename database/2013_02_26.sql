/*
SQLyog Ultimate v9.63 
MySQL - 5.5.8-log : Database - salasrosario
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`salasrosario` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_spanish_ci */;

USE `salasrosario`;

/*Table structure for table `accesorios` */

DROP TABLE IF EXISTS `accesorios`;

CREATE TABLE `accesorios` (
  `id_accesorio` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `descripcion` varchar(50) NOT NULL,
  `marca` varchar(25) NOT NULL,
  `modelo` varchar(25) DEFAULT NULL,
  `estado` enum('D','N') NOT NULL,
  `id_complejo` int(11) unsigned NOT NULL,
  `precio` decimal(10,0) unsigned NOT NULL,
  PRIMARY KEY (`id_accesorio`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

/*Data for the table `accesorios` */

LOCK TABLES `accesorios` WRITE;

insert  into `accesorios`(`id_accesorio`,`descripcion`,`marca`,`modelo`,`estado`,`id_complejo`,`precio`) values (1,'Guitarra negra','Gibson','Les Paul','D',1,'0'),(2,'Palos de bateria','sarasa','Palos de bateria','D',1,'0'),(3,'otro','dsa','fdgd','D',1,'0');

UNLOCK TABLES;

/*Table structure for table `alquileres` */

DROP TABLE IF EXISTS `alquileres`;

CREATE TABLE `alquileres` (
  `id_accesorio` int(10) unsigned NOT NULL,
  `id_reserva` int(10) unsigned NOT NULL,
  PRIMARY KEY (`id_accesorio`,`id_reserva`),
  KEY `id_reserva` (`id_reserva`),
  CONSTRAINT `alquileres_ibfk_1` FOREIGN KEY (`id_accesorio`) REFERENCES `accesorios` (`id_accesorio`),
  CONSTRAINT `alquileres_ibfk_2` FOREIGN KEY (`id_reserva`) REFERENCES `reservas` (`id_reserva`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `alquileres` */

LOCK TABLES `alquileres` WRITE;

insert  into `alquileres`(`id_accesorio`,`id_reserva`) values (1,1),(2,2);

UNLOCK TABLES;

/*Table structure for table `bandas` */

DROP TABLE IF EXISTS `bandas`;

CREATE TABLE `bandas` (
  `id_banda` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(25) NOT NULL,
  `fecha_alta` date NOT NULL,
  `id_complejo` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id_banda`),
  KEY `id_complejo` (`id_complejo`),
  CONSTRAINT `bandas_ibfk_1` FOREIGN KEY (`id_complejo`) REFERENCES `complejos` (`id_complejo`)
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=latin1;

/*Data for the table `bandas` */

LOCK TABLES `bandas` WRITE;

insert  into `bandas`(`id_banda`,`nombre`,`fecha_alta`,`id_complejo`) values (9,'Banda 1','2012-08-06',1),(10,'Banda 2','2012-08-06',1),(11,'Los Gardelitos','2012-08-12',1);

UNLOCK TABLES;

/*Table structure for table `bandas_musicos` */

DROP TABLE IF EXISTS `bandas_musicos`;

CREATE TABLE `bandas_musicos` (
  `id_musico` int(11) unsigned NOT NULL,
  `id_banda` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id_musico`,`id_banda`),
  KEY `id_banda` (`id_banda`),
  CONSTRAINT `bandas_musicos_ibfk_1` FOREIGN KEY (`id_musico`) REFERENCES `musicos` (`id_musico`),
  CONSTRAINT `bandas_musicos_ibfk_2` FOREIGN KEY (`id_banda`) REFERENCES `bandas` (`id_banda`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `bandas_musicos` */

LOCK TABLES `bandas_musicos` WRITE;

insert  into `bandas_musicos`(`id_musico`,`id_banda`) values (5,9);

UNLOCK TABLES;

/*Table structure for table `complejos` */

DROP TABLE IF EXISTS `complejos`;

CREATE TABLE `complejos` (
  `id_complejo` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(25) NOT NULL,
  `direccion` varchar(25) NOT NULL,
  `telefono` varchar(25) NOT NULL,
  `id_duenio` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id_complejo`),
  KEY `id_duenio` (`id_duenio`),
  CONSTRAINT `complejos_ibfk_1` FOREIGN KEY (`id_duenio`) REFERENCES `duenios` (`id_duenio`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=latin1;

/*Data for the table `complejos` */

LOCK TABLES `complejos` WRITE;

insert  into `complejos`(`id_complejo`,`nombre`,`direccion`,`telefono`,`id_duenio`) values (1,'MdeA','Callao 1021','123',1),(2,'COMPLEJOOO','dir','123',0),(3,'COMPLEJOOO','dir','123',0),(4,'COMPLEJOOO','dir','123',0),(5,'COMPLEJOOO','dir','123',1);

UNLOCK TABLES;

/*Table structure for table `duenios` */

DROP TABLE IF EXISTS `duenios`;

CREATE TABLE `duenios` (
  `id_duenio` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(25) NOT NULL,
  `apellido` varchar(25) NOT NULL,
  `telefono_fijo` varchar(25) DEFAULT NULL,
  `telefono_celular` varchar(25) DEFAULT NULL,
  PRIMARY KEY (`id_duenio`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=latin1;

/*Data for the table `duenios` */

LOCK TABLES `duenios` WRITE;

insert  into `duenios`(`id_duenio`,`nombre`,`apellido`,`telefono_fijo`,`telefono_celular`) values (1,'Señor','Dueño','123456','123456789');

UNLOCK TABLES;

/*Table structure for table `horarios` */

DROP TABLE IF EXISTS `horarios`;

CREATE TABLE `horarios` (
  `id_complejo` int(11) NOT NULL,
  `dia` int(1) NOT NULL,
  `desde` time NOT NULL,
  `hasta` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_spanish_ci;

/*Data for the table `horarios` */

LOCK TABLES `horarios` WRITE;

insert  into `horarios`(`id_complejo`,`dia`,`desde`,`hasta`) values (1,1,'15:00:00','02:00:00'),(1,2,'11:00:00','02:00:00'),(1,3,'11:00:00','02:00:00'),(1,4,'11:00:00','02:00:00'),(1,5,'11:00:00','02:00:00'),(1,6,'11:00:00','02:00:00'),(1,7,'15:00:00','02:00:00');

UNLOCK TABLES;

/*Table structure for table `musicos` */

DROP TABLE IF EXISTS `musicos`;

CREATE TABLE `musicos` (
  `id_musico` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(25) NOT NULL,
  `apellido` varchar(25) NOT NULL,
  `telefono_fijo` varchar(25) DEFAULT NULL,
  `telefono_celular` varchar(25) DEFAULT NULL,
  `fecha_alta` date NOT NULL,
  `id_complejo` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id_musico`),
  KEY `id_complejo` (`id_complejo`),
  CONSTRAINT `musicos_ibfk_1` FOREIGN KEY (`id_complejo`) REFERENCES `complejos` (`id_complejo`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=latin1;

/*Data for the table `musicos` */

LOCK TABLES `musicos` WRITE;

insert  into `musicos`(`id_musico`,`nombre`,`apellido`,`telefono_fijo`,`telefono_celular`,`fecha_alta`,`id_complejo`) values (4,'Gonzalo','Alvarez','4324252','156090807','2012-08-24',1),(5,'Ivan','Fenoy','4562789','155076789','2012-11-06',1),(6,'Walter_modif','Molina!','3456778','153987654','2012-11-06',1),(7,'Nuâ‚¬v0 !','râ‚¬g!$trooo ^^','78','78','2013-02-19',1);

UNLOCK TABLES;

/*Table structure for table `precios_salas` */

DROP TABLE IF EXISTS `precios_salas`;

CREATE TABLE `precios_salas` (
  `fecha_desde` date NOT NULL,
  `banda_fija` decimal(10,0) NOT NULL,
  `banda_no_fija` decimal(10,0) NOT NULL,
  `id_sala` int(11) unsigned NOT NULL,
  KEY `id_sala` (`id_sala`),
  CONSTRAINT `precios_salas_ibfk_1` FOREIGN KEY (`id_sala`) REFERENCES `salas` (`id_sala`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `precios_salas` */

LOCK TABLES `precios_salas` WRITE;

insert  into `precios_salas`(`fecha_desde`,`banda_fija`,`banda_no_fija`,`id_sala`) values ('2012-08-06','10','12',24),('2012-08-06','20','22',28),('2012-08-06','30','32',29),('2012-12-31','22','24',28);

UNLOCK TABLES;

/*Table structure for table `reservas` */

DROP TABLE IF EXISTS `reservas`;

CREATE TABLE `reservas` (
  `id_reserva` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `id_musico` int(10) unsigned NOT NULL,
  `id_banda` int(10) unsigned DEFAULT NULL,
  `fecha_desde` datetime NOT NULL,
  `fecha_hasta` datetime NOT NULL,
  `fecha_reserva` datetime DEFAULT NULL,
  `fecha_cancelacion` datetime DEFAULT NULL,
  `fecha_pago` datetime DEFAULT NULL,
  `id_sala` int(10) unsigned NOT NULL,
  `tipo_reserva` enum('F','N') NOT NULL,
  PRIMARY KEY (`id_reserva`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

/*Data for the table `reservas` */

LOCK TABLES `reservas` WRITE;

insert  into `reservas`(`id_reserva`,`id_musico`,`id_banda`,`fecha_desde`,`fecha_hasta`,`fecha_reserva`,`fecha_cancelacion`,`fecha_pago`,`id_sala`,`tipo_reserva`) values (1,5,NULL,'2013-02-25 23:00:00','2013-02-26 01:30:00','2013-02-13 20:00:39',NULL,NULL,24,'F'),(2,4,9,'2013-02-25 23:00:00','2013-02-26 01:30:00','2013-02-19 20:00:12',NULL,NULL,28,'N'),(3,6,10,'2013-02-25 23:00:00','2013-02-26 01:30:00','2013-02-19 20:01:44',NULL,NULL,29,'F');

UNLOCK TABLES;

/*Table structure for table `salas` */

DROP TABLE IF EXISTS `salas`;

CREATE TABLE `salas` (
  `id_sala` int(11) unsigned NOT NULL AUTO_INCREMENT,
  `nombre` varchar(25) NOT NULL,
  `estado` char(1) NOT NULL,
  `id_complejo` int(11) unsigned NOT NULL,
  PRIMARY KEY (`id_sala`),
  KEY `id_complejo` (`id_complejo`),
  CONSTRAINT `salas_ibfk_1` FOREIGN KEY (`id_complejo`) REFERENCES `complejos` (`id_complejo`)
) ENGINE=InnoDB AUTO_INCREMENT=31 DEFAULT CHARSET=latin1;

/*Data for the table `salas` */

LOCK TABLES `salas` WRITE;

insert  into `salas`(`id_sala`,`nombre`,`estado`,`id_complejo`) values (24,'SALA 1','A',1),(28,'SALA 2','A',1),(29,'SALA 3','A',1),(30,'SALA 4','D',1);

UNLOCK TABLES;

/*Table structure for table `usuarios` */

DROP TABLE IF EXISTS `usuarios`;

CREATE TABLE `usuarios` (
  `id_usuario` varchar(25) NOT NULL,
  `password` varchar(25) NOT NULL,
  `nombre` varchar(25) NOT NULL,
  `apellido` varchar(25) NOT NULL,
  `id_complejo` int(11) unsigned NOT NULL,
  `fecha_alta` date NOT NULL,
  `perfil` enum('W','E','D') NOT NULL,
  `estado` char(1) NOT NULL,
  PRIMARY KEY (`id_usuario`),
  KEY `id_complejo` (`id_complejo`),
  CONSTRAINT `usuarios_ibfk_1` FOREIGN KEY (`id_complejo`) REFERENCES `complejos` (`id_complejo`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

/*Data for the table `usuarios` */

LOCK TABLES `usuarios` WRITE;

insert  into `usuarios`(`id_usuario`,`password`,`nombre`,`apellido`,`id_complejo`,`fecha_alta`,`perfil`,`estado`) values ('avalle','asd','Andés','Valle',1,'2012-08-09','','X');

UNLOCK TABLES;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
