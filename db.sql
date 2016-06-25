-- --------------------------------------------------------
-- Host:                         localhost
-- Server Version:               5.6.20 - MySQL Community Server (GPL)
-- Server Betriebssystem:        Win32
-- HeidiSQL Version:             9.1.0.4867
-- --------------------------------------------------------

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET NAMES utf8mb4 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;

-- Exportiere Datenbank Struktur für forum
CREATE DATABASE IF NOT EXISTS `forum` /*!40100 DEFAULT CHARACTER SET utf8 COLLATE utf8_unicode_ci */;
USE `forum`;


-- Exportiere Struktur von Tabelle forum.accounts
CREATE TABLE IF NOT EXISTS `accounts` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(24) COLLATE utf8_unicode_ci NOT NULL,
  `password` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `email` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `money` int(11) NOT NULL,
  `pos_x` double DEFAULT NULL,
  `pos_y` double DEFAULT NULL,
  `pos_z` double DEFAULT NULL,
  `pos_int` int(11) DEFAULT NULL,
  `pos_world` int(11) DEFAULT NULL,
  `admin_level` int(11) NOT NULL,
  `skin` int(11) DEFAULT NULL,
  `spawn` int(11) DEFAULT NULL,
  `premium_points` int(11) NOT NULL,
  `bounty` int(11) NOT NULL,
  `experience` int(11) NOT NULL,
  `payday` int(11) DEFAULT NULL,
  `grouping` int(11) NOT NULL,
  `grouping_rank` int(11) DEFAULT NULL,
  `grouping_leader` tinyint(1) DEFAULT NULL,
  `faction` int(11) NOT NULL,
  `faction_rank` int(11) DEFAULT NULL,
  `faction_leader` tinyint(1) DEFAULT NULL,
  `wanteds` int(11) NOT NULL,
  `wanted_reason` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `level` int(11) NOT NULL DEFAULT '1',
  `ip` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `banned` smallint(6) NOT NULL,
  `ban_time` datetime DEFAULT NULL,
  `ban_reason` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `joined` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=15 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Exportiere Struktur von Tabelle forum.atm
CREATE TABLE IF NOT EXISTS `atm` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `a_x` float DEFAULT NULL,
  `a_y` float DEFAULT NULL,
  `a_z` float DEFAULT NULL,
  `a_rx` float DEFAULT NULL,
  `a_ry` float DEFAULT NULL,
  `a_rz` float DEFAULT NULL,
  `comment` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Exportiere Daten aus Tabelle forum.atm: ~0 rows (ungefähr)
DELETE FROM `atm`;
/*!40000 ALTER TABLE `atm` DISABLE KEYS */;
INSERT INTO `atm` (`id`, `a_x`, `a_y`, `a_z`, `a_rx`, `a_ry`, `a_rz`, `comment`) VALUES
	(1, -2220.18, 578.569, 34.792, 0, 0, 0.900005, 'AD-Biz');
/*!40000 ALTER TABLE `atm` ENABLE KEYS */;


-- Exportiere Struktur von Tabelle forum.bank
CREATE TABLE IF NOT EXISTS `bank` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `ownerid` int(11) DEFAULT NULL,
  `number` int(11) DEFAULT NULL,
  `pin` int(11) DEFAULT NULL,
  `money` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Exportiere Daten aus Tabelle forum.bank: ~0 rows (ungefähr)
DELETE FROM `bank`;
/*!40000 ALTER TABLE `bank` DISABLE KEYS */;
/*!40000 ALTER TABLE `bank` ENABLE KEYS */;


-- Exportiere Struktur von Tabelle forum.bizzes
CREATE TABLE IF NOT EXISTS `bizzes` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` int(11) DEFAULT NULL,
  `status` int(11) NOT NULL,
  `x` double NOT NULL,
  `y` double NOT NULL,
  `z` double NOT NULL,
  `int` int(11) NOT NULL,
  `world` int(11) NOT NULL,
  `int_x` double NOT NULL,
  `int_y` double NOT NULL,
  `int_z` double NOT NULL,
  `int_int` int(11) NOT NULL,
  `int_world` int(11) NOT NULL,
  `price` int(11) NOT NULL DEFAULT '100000',
  `prods` int(11) NOT NULL DEFAULT '100',
  `prod_price` int(11) NOT NULL,
  `prod_buy_price` int(11) NOT NULL,
  `opened` tinyint(1) NOT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'Tankstelle',
  `name_user` varchar(50) COLLATE utf8_unicode_ci NOT NULL DEFAULT 'Umbenennen',
  `port` tinyint(1) NOT NULL,
  `cash` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `IDX_ECBE08D4CF60E67C` (`owner`),
  CONSTRAINT `FK_ECBE08D4CF60E67C` FOREIGN KEY (`owner`) REFERENCES `accounts` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=22 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Exportiere Daten aus Tabelle forum.bizzes: ~21 rows (ungefähr)
DELETE FROM `bizzes`;
/*!40000 ALTER TABLE `bizzes` DISABLE KEYS */;
INSERT INTO `bizzes` (`id`, `owner`, `status`, `x`, `y`, `z`, `int`, `world`, `int_x`, `int_y`, `int_z`, `int_int`, `int_world`, `price`, `prods`, `prod_price`, `prod_buy_price`, `opened`, `name`, `name_user`, `port`, `cash`) VALUES
	(1, 0, 0, -2454.45, 504.042, 30.0786, 0, 0, 964.393, 2107.66, 1011.03, 1, 0, 100000, 100, 0, 0, 0, 'Paintball', 'Umbenennen', 1, 0),
	(2, 0, 0, -2217.22, 577.585, 35.1719, 0, 0, 0, 0, 0, 0, 0, 100000, 100, 0, 0, 0, 'Werbung', 'Umbenennen', 0, 0),
	(3, 0, 0, -1810.41, 902.291, 24.8906, 0, 0, 0, 0, 0, 0, 0, 100000, 100, 0, 0, 0, 'Lotto', 'Umbenennen', 0, 0),
	(4, 0, 0, -2029.2534, 156.8687, 28.8359, 0, 0, 0, 0, 0, 0, 0, 100000, 100, 0, 0, 0, 'Tankstelle', 'Umbenennen', 0, 0),
	(5, 0, 0, -1675.7361, 412.935, 7.1797, 0, 0, 0, 0, 0, 0, 0, 100000, 100, 0, 0, 0, 'Tankstelle', 'Umbenennen', 0, 0),
	(6, 0, 0, -2406.2659, 976.1958, 45.2969, 0, 0, 0, 0, 0, 0, 0, 100000, 100, 0, 0, 0, 'Tankstelle', 'Umbenennen', 0, 0),
	(7, 0, 0, -1470.848, 1863.9482, 32.6328, 0, 0, 0, 0, 0, 0, 0, 100000, 100, 0, 0, 0, 'Tankstelle', 'Umbenennen', 0, 0),
	(8, 0, 0, -1328.2729, 2677.5696, 50.0625, 0, 0, 0, 0, 0, 0, 0, 100000, 100, 0, 0, 0, 'Tankstelle', 'Umbenennen', 0, 0),
	(9, 0, 0, 615.2212, 1689.8625, 6.9922, 0, 0, 0, 0, 0, 0, 0, 100000, 100, 0, 0, 0, 'Tankstelle', 'Umbenennen', 0, 0),
	(10, 0, 0, 2147.2947, 2747.7573, 10.8203, 0, 0, 0, 0, 0, 0, 0, 100000, 100, 0, 0, 0, 'Tankstelle', 'Umbenennen', 0, 0),
	(11, 0, 0, 2202.6262, 2474.6785, 10.8203, 0, 0, 0, 0, 0, 0, 0, 100000, 100, 0, 0, 0, 'Tankstelle', 'Umbenennen', 0, 0),
	(12, 0, 0, 1596.1722, 2198.8076, 10.8203, 0, 0, 0, 0, 0, 0, 0, 100000, 100, 0, 0, 0, 'Tankstelle', 'Umbenennen', 0, 0),
	(13, 0, 0, -90.742, -1169.4635, 2.4121, 0, 0, 0, 0, 0, 0, 0, 100000, 100, 0, 0, 0, 'Tankstelle', 'Umbenennen', 0, 0),
	(14, 0, 0, 1004.4651, -940.6688, 42.1797, 0, 0, 0, 0, 0, 0, 0, 100000, 100, 0, 0, 0, 'Tankstelle', 'Umbenennen', 0, 0),
	(15, 0, 0, 1937.442, -1773.0424, 13.3828, 0, 0, 0, 0, 0, 0, 0, 100000, 100, 0, 0, 0, 'Tankstelle', 'Umbenennen', 0, 0),
	(16, 0, 0, -1605.9188, -2714.1924, 48.5335, 0, 0, 0, 0, 0, 0, 0, 100000, 100, 0, 0, 0, 'Tankstelle', 'Umbenennen', 0, 0),
	(17, 0, 0, -2244.0852, -2560.9641, 31.9219, 0, 0, 0, 0, 0, 0, 0, 100000, 100, 0, 0, 0, 'Tankstelle', 'Umbenennen', 0, 0),
	(18, 0, 0, 659.2364, -564.9952, 16.3359, 0, 0, 0, 0, 0, 0, 0, 100000, 100, 0, 0, 0, 'Tankstelle', 'Umbenennen', 0, 0),
	(19, 0, 0, 1383.2738, 462.3624, 20.1421, 0, 0, 0, 0, 0, 0, 0, 100000, 100, 0, 0, 0, 'Tankstelle', 'Umbenennen', 0, 0),
	(20, 0, 0, 2115.0396, 920.0233, 10.8203, 0, 0, 0, 0, 0, 0, 0, 100000, 100, 0, 0, 0, 'Tankstelle', 'Umbenennen', 0, 0),
	(21, 0, 0, 2640.1958, 1105.9785, 10.8203, 0, 0, 0, 0, 0, 0, 0, 100000, 100, 0, 0, 0, 'Tankstelle', 'Umbenennen', 0, 0);
/*!40000 ALTER TABLE `bizzes` ENABLE KEYS */;


-- Exportiere Struktur von Tabelle forum.dutypoints
CREATE TABLE IF NOT EXISTS `dutypoints` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `x` double NOT NULL,
  `y` double NOT NULL,
  `z` double NOT NULL,
  `int` int(11) NOT NULL,
  `world` int(11) NOT NULL,
  `comment` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `group` int(11) DEFAULT NULL,
  `faction` int(11) DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Exportiere Daten aus Tabelle forum.dutypoints: ~2 rows (ungefähr)
DELETE FROM `dutypoints`;
/*!40000 ALTER TABLE `dutypoints` DISABLE KEYS */;
INSERT INTO `dutypoints` (`id`, `x`, `y`, `z`, `int`, `world`, `comment`, `group`, `faction`) VALUES
	(1, 227.42, 111.002, 1010.22, 0, 0, 'SFPD', 0, 1),
	(2, -2645.94, -1583.79, 130.652, 0, 0, 'Hitman', 1, 0);
/*!40000 ALTER TABLE `dutypoints` ENABLE KEYS */;


-- Exportiere Struktur von Tabelle forum.enters
CREATE TABLE IF NOT EXISTS `enters` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `faction` int(11) DEFAULT NULL,
  `grouping` int(11) DEFAULT NULL,
  `icon` smallint(6) NOT NULL,
  `x` double NOT NULL,
  `y` double NOT NULL,
  `z` double NOT NULL,
  `int` int(11) NOT NULL,
  `world` int(11) NOT NULL,
  `text` varchar(70) COLLATE utf8_unicode_ci DEFAULT NULL,
  `visible` tinyint(1) NOT NULL,
  `to_x` double NOT NULL,
  `to_y` double NOT NULL,
  `to_z` double NOT NULL,
  `to_int` int(11) NOT NULL,
  `to_world` int(11) NOT NULL,
  `to_text` varchar(70) COLLATE utf8_unicode_ci DEFAULT NULL,
  `to_visible` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `IDX_B1BDF39483048B90` (`faction`),
  KEY `IDX_B1BDF3948FA8718` (`grouping`),
  CONSTRAINT `FK_B1BDF39483048B90` FOREIGN KEY (`faction`) REFERENCES `factions` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_B1BDF3948FA8718` FOREIGN KEY (`grouping`) REFERENCES `groupings` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=19 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Exportiere Daten aus Tabelle forum.enters: ~15 rows (ungefähr)
DELETE FROM `enters`;
/*!40000 ALTER TABLE `enters` DISABLE KEYS */;
INSERT INTO `enters` (`id`, `faction`, `grouping`, `icon`, `x`, `y`, `z`, `int`, `world`, `text`, `visible`, `to_x`, `to_y`, `to_z`, `to_int`, `to_world`, `to_text`, `to_visible`) VALUES
	(1, 0, 1, 0, -2763.67, -1568.31, 141.212, 0, 0, 'Eingang', 0, -2649.48, -1567.37, 130.589, 0, 0, 'Ausgang', 1),
	(2, 0, 0, 0, -1605.52, 710.584, 13.8672, 0, 0, 'Police Department', 1, 246.401, 107.863, 1003.22, 10, 0, 'Ausgang', 1),
	(3, 0, 1, 0, -2648.86, -1585.24, 130.652, 0, 0, 'Ins Haus', 1, -2170.37, 635.793, 1052.38, 1, 0, 'Garage', 1),
	(4, 0, 0, 45, -1882.43, 866.229, 35.1719, 0, 0, 'ZIP Store', 1, 161.399, -97.0113, 1001.8, 18, 0, 'Ausgang', 1),
	(5, 0, 0, 17, -1672.49, 1337.9, 7.1875, 0, 0, 'C’est la vie', 1, 265.856, -83.942, 1023.39, 0, 0, 'Ausgang', 1),
	(6, 0, 0, 29, -1721.72, 1359.48, 7.1853, 0, 0, 'Pizzeria', 1, 372.46, -132.949, 1001.49, 5, 0, 'Ausgang', 1),
	(7, 0, 0, 29, -1808.4, 945.502, 24.8906, 0, 0, 'Pizzeria', 1, 372.46, -132.949, 1001.49, 5, 0, 'Ausgang', 1),
	(8, 0, 0, 10, -1911.83, 828.548, 35.1752, 0, 0, 'Burger Shot', 1, 363.363, -74.8508, 1001.51, 10, 0, 'Ausgang', 1),
	(9, 0, 0, 25, -2442.79, 754.423, 35.1719, 0, 0, '24 / 7', 1, 6.1035, -30.9455, 1003.55, 10, 0, 'Ausgang', 1),
	(10, 0, 0, 10, -2356.62, 1007.89, 50.8984, 0, 0, 'Burger Shot', 1, 363.363, -74.8508, 1001.51, 10, 0, 'Ausgang', 1),
	(11, 0, 0, 10, -2336.05, -167.175, 35.5547, 0, 0, 'Burger Shot', 1, 363.363, -74.8508, 1001.51, 10, 0, 'Ausgang', 1),
	(12, 0, 0, 14, -2672.25, 258.951, 4.6328, 0, 0, 'Cluckin\' bell', 1, 364.91, -10.8058, 1001.85, 9, 0, 'Ausgang', 1),
	(13, 0, 0, 50, -2767.41, 788.888, 52.7813, 0, 0, 'Rusty Browns Donuts', 1, 377.288, -192.451, 1000.63, 17, 0, 'Ausgang', 1),
	(17, 0, 0, 52, -1704.824, 785.7861, 24.8906, 0, 0, 'Bank', 1, 2305.845, -16.3172, 26.7496, 0, 0, 'Ausgang', 1),
	(18, 0, 0, 0, 2315.5757, -0.1934, 26.7422, 0, 0, 'Tresor', 1, 2144.2988, 1608.4183, 993.6882, 1, 0, 'Bank', 1);
/*!40000 ALTER TABLE `enters` ENABLE KEYS */;


-- Exportiere Struktur von Tabelle forum.factions
CREATE TABLE IF NOT EXISTS `factions` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `spawn_x` double NOT NULL,
  `spawn_y` double NOT NULL,
  `spawn_z` double NOT NULL,
  `spawn_int` int(11) NOT NULL,
  `spawn_world` int(11) NOT NULL,
  `motd` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Exportiere Daten aus Tabelle forum.factions: ~5 rows (ungefähr)
DELETE FROM `factions`;
/*!40000 ALTER TABLE `factions` DISABLE KEYS */;
INSERT INTO `factions` (`id`, `name`, `spawn_x`, `spawn_y`, `spawn_z`, `spawn_int`, `spawn_world`, `motd`) VALUES
	(0, 'Zivi', 0, 0, 0, 0, 0, NULL),
	(1, 'San Fierro Police Department', 250.7, 123.1, 1010.2, 10, 2, '/fsettings'),
	(2, 'San Fierro Ordnungsamt', -2668, -5.5, 6.1, 0, 0, NULL),
	(3, 'San Fierro Army', -781.8, 467.2, 21.1, 0, 0, NULL),
	(4, 'San Fierro Medics', -2655, 638.7, 14.4, 0, 0, NULL);
/*!40000 ALTER TABLE `factions` ENABLE KEYS */;


-- Exportiere Struktur von Tabelle forum.faction_rank_names
CREATE TABLE IF NOT EXISTS `faction_rank_names` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `faction` int(11) DEFAULT NULL,
  `rank` int(11) NOT NULL,
  `name` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `IDX_FBD6263283048B90` (`faction`),
  CONSTRAINT `FK_FBD6263283048B90` FOREIGN KEY (`faction`) REFERENCES `factions` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Exportiere Daten aus Tabelle forum.faction_rank_names: ~10 rows (ungefähr)
DELETE FROM `faction_rank_names`;
/*!40000 ALTER TABLE `faction_rank_names` DISABLE KEYS */;
INSERT INTO `faction_rank_names` (`id`, `faction`, `rank`, `name`) VALUES
	(1, 1, 0, 'Praktikant'),
	(2, 1, 1, 'Trainee'),
	(3, 1, 2, 'zwei'),
	(4, 1, 3, 'drei'),
	(5, 1, 4, '-'),
	(6, 1, 5, '-'),
	(7, 0, 2, 'drei'),
	(8, 1, 6, 'sechs'),
	(9, 1, 10, 'BOSS'),
	(10, 3, 10, 'General');
/*!40000 ALTER TABLE `faction_rank_names` ENABLE KEYS */;


-- Exportiere Struktur von Tabelle forum.gangzones
CREATE TABLE IF NOT EXISTS `gangzones` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` int(11) DEFAULT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  `min_x` double NOT NULL,
  `min_y` double NOT NULL,
  `max_x` double NOT NULL,
  `max_y` double NOT NULL,
  `flag_x` double NOT NULL,
  `flag_y` double NOT NULL,
  `flag_z` double NOT NULL,
  PRIMARY KEY (`id`),
  KEY `IDX_4FDA16C9CF60E67C` (`owner`),
  CONSTRAINT `FK_4FDA16C9CF60E67C` FOREIGN KEY (`owner`) REFERENCES `groupings` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Exportiere Daten aus Tabelle forum.gangzones: ~2 rows (ungefähr)
DELETE FROM `gangzones`;
/*!40000 ALTER TABLE `gangzones` DISABLE KEYS */;
INSERT INTO `gangzones` (`id`, `owner`, `name`, `min_x`, `min_y`, `max_x`, `max_y`, `flag_x`, `flag_y`, `flag_z`) VALUES
	(1, 2, 'Baustelle', -2136.15, 118.819, -2016.95, 310.443, -2072.33, 225.91, 36.0103),
	(2, 2, 'Schlangenstraße', -2128.95, 904.381, -2012.14, 964.393, -2067.29, 959.427, 60.0648);
/*!40000 ALTER TABLE `gangzones` ENABLE KEYS */;


-- Exportiere Struktur von Tabelle forum.groupings
CREATE TABLE IF NOT EXISTS `groupings` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  `spawn_x` double NOT NULL,
  `spawn_y` double NOT NULL,
  `spawn_z` double NOT NULL,
  `spawn_int` int(11) NOT NULL,
  `spawn_world` int(11) NOT NULL,
  `motd` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Exportiere Daten aus Tabelle forum.groupings: ~5 rows (ungefähr)
DELETE FROM `groupings`;
/*!40000 ALTER TABLE `groupings` DISABLE KEYS */;
INSERT INTO `groupings` (`id`, `name`, `spawn_x`, `spawn_y`, `spawn_z`, `spawn_int`, `spawn_world`, `motd`) VALUES
	(0, 'Zivi', 0, 0, 0, 0, 0, NULL),
	(1, 'Hitman Agency', -2170.2, 642.4, 1057.5, 1, 2, 'swag~test'),
	(2, 'Yakuza', -1755.6, 946.7, 24.8, 0, 0, 'Test~Neue Zeile'),
	(3, 'Insallah', -1730.3, 920.1, 24.7, 0, 0, '/gsettings'),
	(4, 'Allahu Akbar', -1994.1, 927, 45.2, 0, 0, 'swag');
/*!40000 ALTER TABLE `groupings` ENABLE KEYS */;


-- Exportiere Struktur von Tabelle forum.grouping_rank_names
CREATE TABLE IF NOT EXISTS `grouping_rank_names` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `grouping` int(11) DEFAULT NULL,
  `rank` int(11) DEFAULT NULL,
  `name` varchar(128) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `IDX_7CAD93E28FA8718` (`grouping`),
  CONSTRAINT `FK_7CAD93E28FA8718` FOREIGN KEY (`grouping`) REFERENCES `groupings` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=12 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Exportiere Daten aus Tabelle forum.grouping_rank_names: ~11 rows (ungefähr)
DELETE FROM `grouping_rank_names`;
/*!40000 ALTER TABLE `grouping_rank_names` DISABLE KEYS */;
INSERT INTO `grouping_rank_names` (`id`, `grouping`, `rank`, `name`) VALUES
	(1, 1, 0, 'Neuling'),
	(2, 1, 1, 'Lakei'),
	(3, 1, 2, 'Test'),
	(4, 1, 3, '-'),
	(5, 1, 4, '-'),
	(6, 1, 5, '-'),
	(7, 1, 10, 'Shadow Marshall'),
	(8, 2, 10, 'BABA'),
	(9, 2, 0, 'test'),
	(10, 2, 1, 'eins'),
	(11, 2, 2, 'zwei');
/*!40000 ALTER TABLE `grouping_rank_names` ENABLE KEYS */;


-- Exportiere Struktur von Tabelle forum.houses
CREATE TABLE IF NOT EXISTS `houses` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` int(11) DEFAULT NULL,
  `target_int` int(11) DEFAULT NULL,
  `status` int(11) NOT NULL,
  `x` double NOT NULL,
  `y` double NOT NULL,
  `z` double NOT NULL,
  `int` int(11) NOT NULL,
  `world` int(11) NOT NULL,
  `opened` tinyint(1) NOT NULL,
  `heal` int(11) NOT NULL,
  `rental` int(11) NOT NULL,
  `price` int(11) NOT NULL,
  `name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `cash` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `IDX_95D7F5CBCF60E67C` (`owner`),
  KEY `IDX_95D7F5CBDB41F844` (`target_int`),
  CONSTRAINT `FK_95D7F5CBCF60E67C` FOREIGN KEY (`owner`) REFERENCES `accounts` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_95D7F5CBDB41F844` FOREIGN KEY (`target_int`) REFERENCES `house_interiors` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=14 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Exportiere Daten aus Tabelle forum.houses: ~13 rows (ungefähr)
DELETE FROM `houses`;
/*!40000 ALTER TABLE `houses` DISABLE KEYS */;
INSERT INTO `houses` (`id`, `owner`, `target_int`, `status`, `x`, `y`, `z`, `int`, `world`, `opened`, `heal`, `rental`, `price`, `name`, `cash`) VALUES
	(1, 1, 1, 1, -2710.67, 968.314, 54.4609, 0, 0, 0, 0, 2, 500000, 'Villa Hurensohn', 0),
	(2, 7, 1, 1, -2641.11, 935.436, 71.9531, 0, 0, 0, 0, 0, 500000, '-', 0),
	(3, 0, 6, 0, -2662.05, 876.954, 79.7738, 0, 0, 0, 0, 0, 500000, '-', 0),
	(4, 4, 4, 1, -2661.41, 915.588, 81.0316, 0, 0, 0, 0, 9999, 1, 'Luxus Haus', 0),
	(5, 0, 1, 0, -2523.87, 2239.04, 5.39844, 0, 0, 0, 0, 0, 500000, '-', 0),
	(6, 0, 1, 0, -2552.16, 2266.49, 5.47552, 0, 0, 1, 0, 0, 500000, '-', 0),
	(7, 1, 1, 1, -911.017, 2685.94, 42.3703, 0, 0, 0, 0, 0, 100, 'lolz', 0),
	(8, 0, 5, 0, -2016.65, -29.0732, 35.2285, 0, 0, 0, 0, 0, 200000, '-', 0),
	(9, 5, 4, 1, -2052.33, -39.5604, 35.3599, 0, 0, 1, 0, 0, 100000, '-', 0),
	(10, NULL, 1, 1, -2706.66, 865.228, 70.7031, 0, 0, 0, 0, 69, 1, 'Paradiso Villa', 0),
	(11, 0, 4, 0, -2099.59, 897.357, 76.7109, 0, 0, 0, 0, 300, 100000, '-', 0),
	(12, 0, 1, 0, -2043.82, 1261.7, 9.16862, 0, 0, 0, 0, 0, 400000, '-', 0),
	(13, 3, 1, 1, -2655.23, 986.457, 64.9913, 0, 0, 1, 0, 333, 1, 'Villa Boyka', 0);
/*!40000 ALTER TABLE `houses` ENABLE KEYS */;


-- Exportiere Struktur von Tabelle forum.house_interiors
CREATE TABLE IF NOT EXISTS `house_interiors` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `x` double NOT NULL,
  `y` double NOT NULL,
  `z` double NOT NULL,
  `int` int(11) NOT NULL,
  `world` int(11) NOT NULL,
  `comment` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Exportiere Daten aus Tabelle forum.house_interiors: ~6 rows (ungefähr)
DELETE FROM `house_interiors`;
/*!40000 ALTER TABLE `house_interiors` DISABLE KEYS */;
INSERT INTO `house_interiors` (`id`, `x`, `y`, `z`, `int`, `world`, `comment`) VALUES
	(1, 2324.49, -1148.83, 1050.71, 12, 0, 'Unused safe house'),
	(2, 1701.34, -1667.97, 20.2188, 18, 0, 'LS Atruim'),
	(3, 965.851, -53.0888, 1001.12, 3, 0, 'Tiger Skin Brothel'),
	(4, 2807.52, -1174.05, 1025.57, 8, 0, 'Colonel Furhberger\'s'),
	(5, 318.594, 1114.77, 1083.88, 5, 0, 'Crack den'),
	(6, 1262.65, -785.466, 1091.91, 5, 0, 'Madd Doggs mansion');
/*!40000 ALTER TABLE `house_interiors` ENABLE KEYS */;


-- Exportiere Struktur von Tabelle forum.infopoints
CREATE TABLE IF NOT EXISTS `infopoints` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `x` float DEFAULT NULL,
  `y` float DEFAULT NULL,
  `z` float DEFAULT NULL,
  `text` varchar(50) COLLATE utf8_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Exportiere Daten aus Tabelle forum.infopoints: ~0 rows (ungefähr)
DELETE FROM `infopoints`;
/*!40000 ALTER TABLE `infopoints` DISABLE KEYS */;
INSERT INTO `infopoints` (`id`, `x`, `y`, `z`, `text`) VALUES
	(1, 2309.61, -8.313, 26.7422, 'Bitte Enter drücken');
/*!40000 ALTER TABLE `infopoints` ENABLE KEYS */;


-- Exportiere Struktur von Tabelle forum.server
CREATE TABLE IF NOT EXISTS `server` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `version` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `gamemode` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `map` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `homepage` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `motd` varchar(50) COLLATE utf8_unicode_ci NOT NULL,
  `record` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Exportiere Daten aus Tabelle forum.server: ~0 rows (ungefähr)
DELETE FROM `server`;
/*!40000 ALTER TABLE `server` DISABLE KEYS */;
INSERT INTO `server` (`id`, `name`, `version`, `gamemode`, `map`, `homepage`, `motd`, `record`) VALUES
	(1, '[GTA]Dynamic', '0.5', 'Dynamic Roleplay', 'Dyn SF', 'www.eldiabolo.de', 'Test~n~Neue Zeile~n~Noch ne neue Zeile', 2);
/*!40000 ALTER TABLE `server` ENABLE KEYS */;


-- Exportiere Struktur von Tabelle forum.vehicles
CREATE TABLE IF NOT EXISTS `vehicles` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `model` int(11) NOT NULL,
  `status` int(11) NOT NULL,
  `owner` int(11) NOT NULL,
  `x` double NOT NULL,
  `y` double NOT NULL,
  `z` double NOT NULL,
  `r` double NOT NULL,
  `int` int(11) NOT NULL,
  `world` int(11) NOT NULL,
  `engine` tinyint(1) NOT NULL,
  `lights` tinyint(1) NOT NULL,
  `locked` tinyint(1) NOT NULL,
  `color_1` int(11) NOT NULL,
  `color_2` int(11) NOT NULL,
  `number_plate` varchar(32) COLLATE utf8_unicode_ci NOT NULL,
  `health` float NOT NULL,
  `tank` float NOT NULL,
  `km` int(11) NOT NULL,
  `slot_0` int(11) NOT NULL,
  `slot_1` int(11) NOT NULL,
  `slot_2` int(11) NOT NULL,
  `slot_3` int(11) NOT NULL,
  `slot_4` int(11) NOT NULL,
  `slot_5` int(11) NOT NULL,
  `slot_6` int(11) NOT NULL,
  `slot_7` int(11) NOT NULL,
  `slot_8` int(11) NOT NULL,
  `slot_9` int(11) NOT NULL,
  `slot_10` int(11) NOT NULL,
  `slot_11` int(11) NOT NULL,
  `slot_12` int(11) NOT NULL,
  `slot_13` int(11) NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;


-- Exportiere Struktur von Tabelle forum.vehicle_gates
CREATE TABLE IF NOT EXISTS `vehicle_gates` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `faction` int(11) DEFAULT NULL,
  `grouping` int(11) DEFAULT NULL,
  `x` double NOT NULL,
  `y` double NOT NULL,
  `z` double NOT NULL,
  `int` int(11) NOT NULL,
  `world` int(11) NOT NULL,
  `visible` tinyint(1) NOT NULL,
  `to_x` double NOT NULL,
  `to_y` double NOT NULL,
  `to_z` double NOT NULL,
  `to_int` int(11) NOT NULL,
  `to_world` int(11) NOT NULL,
  `to_visible` tinyint(1) NOT NULL,
  PRIMARY KEY (`id`),
  KEY `IDX_8E7B332283048B90` (`faction`),
  KEY `IDX_8E7B33228FA8718` (`grouping`),
  CONSTRAINT `FK_8E7B332283048B90` FOREIGN KEY (`faction`) REFERENCES `factions` (`id`) ON DELETE SET NULL,
  CONSTRAINT `FK_8E7B33228FA8718` FOREIGN KEY (`grouping`) REFERENCES `groupings` (`id`) ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;

-- Exportiere Daten aus Tabelle forum.vehicle_gates: ~0 rows (ungefähr)
DELETE FROM `vehicle_gates`;
/*!40000 ALTER TABLE `vehicle_gates` DISABLE KEYS */;
INSERT INTO `vehicle_gates` (`id`, `faction`, `grouping`, `x`, `y`, `z`, `int`, `world`, `visible`, `to_x`, `to_y`, `to_z`, `to_int`, `to_world`, `to_visible`) VALUES
	(1, 0, 1, -2763.93, -1556.63, 140.943, 0, 0, 0, -2647.78, -1561.84, 130.566, 0, 0, 1);
/*!40000 ALTER TABLE `vehicle_gates` ENABLE KEYS */;


-- Exportiere Struktur von Tabelle forum.weapons
CREATE TABLE IF NOT EXISTS `weapons` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `owner` int(11) DEFAULT NULL,
  `weapon` int(11) NOT NULL,
  `ammo` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `UNIQ_520EBBE1CF60E67C6933A7E6` (`owner`,`weapon`),
  KEY `IDX_520EBBE1CF60E67C` (`owner`),
  CONSTRAINT `FK_520EBBE1CF60E67C` FOREIGN KEY (`owner`) REFERENCES `accounts` (`id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=241 DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
