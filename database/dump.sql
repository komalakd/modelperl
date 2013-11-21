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
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=latin1;

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
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=latin1;

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
  PRIMARY KEY (`id_reserva`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=latin1;

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

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
