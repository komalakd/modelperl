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

/*Data for the table `accesorios` */

LOCK TABLES `accesorios` WRITE;

insert  into `accesorios`(`id_accesorio`,`descripcion`,`marca`,`modelo`,`estado`,`id_complejo`,`precio`) values (1,'Guitarra negra','Gibson','Les Paul','D',1,'0'),(2,'Palos de bateria','sarasa','Palos de bateria','D',1,'0');

UNLOCK TABLES;

/*Data for the table `alquileres` */

LOCK TABLES `alquileres` WRITE;

insert  into `alquileres`(`id_accesorio`,`id_reserva`) values (1,1),(2,2);

UNLOCK TABLES;

/*Data for the table `bandas` */

LOCK TABLES `bandas` WRITE;

insert  into `bandas`(`id_banda`,`nombre`,`fecha_alta`,`id_complejo`) values (9,'Banda 1','2012-08-06',1),(10,'Banda 2','2012-08-06',1),(11,'Los Gardelitos','2012-08-12',1);

UNLOCK TABLES;

/*Data for the table `bandas_musicos` */

LOCK TABLES `bandas_musicos` WRITE;

insert  into `bandas_musicos`(`id_musico`,`id_banda`) values (5,9);

UNLOCK TABLES;

/*Data for the table `complejos` */

LOCK TABLES `complejos` WRITE;

insert  into `complejos`(`id_complejo`,`nombre`,`direccion`,`telefono`,`id_duenio`) values (1,'MdeA','Callao 1021','123',1),(2,'COMPLEJOOO','dir','123',0),(3,'COMPLEJOOO','dir','123',0),(4,'COMPLEJOOO','dir','123',0),(5,'COMPLEJOOO','dir','123',1);

UNLOCK TABLES;

/*Data for the table `duenios` */

LOCK TABLES `duenios` WRITE;

insert  into `duenios`(`id_duenio`,`nombre`,`apellido`,`telefono_fijo`,`telefono_celular`) values (1,'Señor','Dueño','123456','123456789');

UNLOCK TABLES;

/*Data for the table `musicos` */

LOCK TABLES `musicos` WRITE;

insert  into `musicos`(`id_musico`,`nombre`,`apellido`,`telefono_fijo`,`telefono_celular`,`fecha_alta`,`id_complejo`) values (4,'Gonzalo','Alvarez','4324252','156090807','2012-08-24',1),(5,'Ivan','Fenoy','4562789','155076789','2012-11-06',1),(6,'Walter','Molina','3456778','153987654','2012-11-06',1);

UNLOCK TABLES;

/*Data for the table `precios_salas` */

LOCK TABLES `precios_salas` WRITE;

insert  into `precios_salas`(`fecha_desde`,`banda_fija`,`banda_no_fija`,`id_sala`) values ('2012-08-06','10','12',24),('2012-08-06','20','22',28),('2012-08-06','30','32',29),('2012-12-31','22','24',28);

UNLOCK TABLES;

/*Data for the table `reservas` */

LOCK TABLES `reservas` WRITE;

insert  into `reservas`(`id_reserva`,`id_musico`,`id_banda`,`fecha_desde`,`fecha_hasta`,`fecha_reserva`,`fecha_cancelacion`,`fecha_pago`,`id_sala`) values (1,1,NULL,'2013-02-19 01:32:11','2013-02-19 01:32:11','2013-02-13 20:00:39',NULL,NULL,1),(2,2,2,'2013-02-19 19:59:47','2013-02-19 21:00:06','2013-02-19 20:00:12',NULL,NULL,1),(3,3,3,'2013-02-20 01:01:30','2013-02-20 01:01:38','2013-02-19 20:01:44',NULL,NULL,1);

UNLOCK TABLES;

/*Data for the table `salas` */

LOCK TABLES `salas` WRITE;

insert  into `salas`(`id_sala`,`nombre`,`estado`,`id_complejo`) values (24,'SALA 1','A',1),(28,'SALA 2','A',1),(29,'SALA 3','A',1),(30,'SALA 4','D',1);

UNLOCK TABLES;

/*Data for the table `usuarios` */

LOCK TABLES `usuarios` WRITE;

insert  into `usuarios`(`id_usuario`,`password`,`nombre`,`apellido`,`id_complejo`,`fecha_alta`,`perfil`,`estado`) values ('avalle','asd','Andés','Valle',1,'2012-08-09','','X');

UNLOCK TABLES;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
