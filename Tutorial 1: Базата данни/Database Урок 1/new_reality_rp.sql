-- phpMyAdmin SQL Dump
-- version 5.2.0
-- https://www.phpmyadmin.net/
--
-- Хост: 127.0.0.1
-- Време на генериране: 13 юни 2023 в 16:47
-- Версия на сървъра: 10.4.25-MariaDB
-- Версия на PHP: 8.1.10

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- База данни: `new_reality_rp`
--

-- --------------------------------------------------------

--
-- Структура на таблица `accounts`
--

CREATE TABLE `accounts` (
  `id` int(11) NOT NULL,
  `Username` text NOT NULL,
  `Password` text NOT NULL,
  `RegisterDate` date NOT NULL,
  `RegisterIP` text NOT NULL,
  `Faction` int(11) NOT NULL,
  `FactionRank` int(11) NOT NULL,
  `Admin` int(11) NOT NULL,
  `Cash` bigint(11) NOT NULL,
  `Weapons` varchar(104) NOT NULL,
  `Bank` bigint(11) NOT NULL,
  `Skin` int(11) NOT NULL,
  `Level` int(11) NOT NULL,
  `Health` float NOT NULL,
  `Armour` float NOT NULL,
  `X` float NOT NULL,
  `Y` float NOT NULL,
  `Z` float NOT NULL,
  `Angle` float NOT NULL,
  `Gender` int(11) NOT NULL,
  `Age` int(11) NOT NULL,
  `Interior` int(11) NOT NULL,
  `VirtualWorld` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Схема на данните от таблица `accounts`
--

INSERT INTO `accounts` (`id`, `Username`, `Password`, `RegisterDate`, `RegisterIP`, `Faction`, `FactionRank`, `Admin`, `Cash`, `Weapons`, `Bank`, `Skin`, `Level`, `Health`, `Armour`, `X`, `Y`, `Z`, `Angle`, `Gender`, `Age`, `Interior`, `VirtualWorld`) VALUES
(24, 'bs.fallafellaz_2', '', '2000-01-21', '78.142.17.122', 0, 1, 6, 5050, '0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,', 0, 34, 1, 100, 0, 1634.76, 425.126, 16.793, 353.06, 1, 2004, 0, 0),
(25, 'Didkou_Didkow', '', '2000-01-22', '78.142.17.122', 0, 1, 5, 5050, '0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,', 0, 34, 1, 100, 0, 2319.84, -25.46, 26.336, 92.473, 1, 2004, 0, 0);

--
-- Indexes for dumped tables
--

--
-- Индекси за таблица `accounts`
--
ALTER TABLE `accounts`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `accounts`
--
ALTER TABLE `accounts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=26;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
