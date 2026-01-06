-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jan 03, 2026 at 03:40 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `pawpal_db`
--

-- --------------------------------------------------------

--
-- Table structure for table `tbl_adoptions`
--

CREATE TABLE `tbl_adoptions` (
  `pet_id` int(5) NOT NULL,
  `adopter_user_id` int(5) NOT NULL,
  `reason` text NOT NULL,
  `requested_at` datetime(6) NOT NULL DEFAULT current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_adoptions`
--

INSERT INTO `tbl_adoptions` (`pet_id`, `adopter_user_id`, `reason`, `requested_at`) VALUES
(6, 2, 'i would like to have a dog', '2026-01-02 16:43:54.050189'),
(9, 2, 'i would like to have a dog', '2026-01-02 16:45:13.830487');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_pets`
--

CREATE TABLE `tbl_pets` (
  `pet_id` int(5) NOT NULL,
  `user_id` int(5) NOT NULL,
  `pet_name` varchar(100) NOT NULL,
  `pet_type` varchar(50) NOT NULL,
  `gender` varchar(6) NOT NULL,
  `age` int(10) NOT NULL,
  `health` varchar(50) NOT NULL,
  `category` varchar(50) NOT NULL,
  `description` text NOT NULL,
  `image_paths` text NOT NULL,
  `lat` varchar(50) NOT NULL,
  `lng` int(11) NOT NULL,
  `created_at` datetime(6) NOT NULL DEFAULT current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_pets`
--

INSERT INTO `tbl_pets` (`pet_id`, `user_id`, `pet_name`, `pet_type`, `gender`, `age`, `health`, `category`, `description`, `image_paths`, `lat`, `lng`, `created_at`) VALUES
(1, 1, 'Si comel', 'Dog', 'Female', 1, 'Healthy', 'Adoption', 'This is a very cute dog', '[\"uploads/pet_1_0.png\",\"uploads/pet_1_1.png\",\"uploads/pet_1_2.png\"]', '6.448535', 101, '2025-12-06 09:46:41.523932'),
(2, 1, 'Kitty', 'Cat', 'Male', 2, 'Unhealthy', 'Donation', 'This is a injured cat, it need a help for medicine.', '[\"uploads/pet_2_0.png\",\"uploads/pet_2_1.png\"]', '6.448535', 101, '2025-12-06 10:02:12.124449'),
(3, 1, 'Wang Cai', 'Dog', 'Male', 2, 'Healthy', 'Help', 'It need the help for food', '[\"uploads/pet_3_0.png\",\"uploads/pet_3_1.png\"]', '6.448535', 101, '2025-12-06 10:09:19.448945'),
(6, 1, 'Lai Fu', 'Dog', 'Male', 3, 'Healthy', 'Adoption', 'A very firendly dog', '[\"uploads/pet_6_0.png\"]', '6.448535', 101, '2025-12-06 10:13:24.808452'),
(7, 1, 'Man Tou', 'Dog', 'Male', 4, 'Healthy', 'Adoption', 'This is the cutty dog.', '[\"uploads/pet_7_0.png\",\"uploads/pet_7_1.png\",\"uploads/pet_7_2.png\"]', '6.448535', 101, '2025-12-06 10:38:12.409654'),
(8, 1, 'Husky', 'Dog', 'Female', 1, 'Unhealthy', 'Donation', 'This is a dog that is injured, it need a help', '[\"uploads/pet_8_0.png\",\"uploads/pet_8_1.png\",\"uploads/pet_8_2.png\"]', '6.448535', 101, '2025-12-06 11:22:40.226226'),
(9, 1, 'Labubu', 'Dog', 'Male', 1, 'Healthy', 'Adoption', 'This the Labubu that is sick, who can adopt it', '[\"uploads/pet_9_0.png\"]', '6.4377033', 101, '2026-01-02 15:07:40.565903');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_users`
--

CREATE TABLE `tbl_users` (
  `user_id` int(5) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(100) NOT NULL,
  `password` varchar(255) NOT NULL,
  `phone` varchar(20) NOT NULL,
  `wallet_balance` decimal(10,2) NOT NULL,
  `reg_date` datetime(6) NOT NULL DEFAULT current_timestamp(6)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_users`
--

INSERT INTO `tbl_users` (`user_id`, `name`, `email`, `password`, `phone`, `wallet_balance`, `reg_date`) VALUES
(1, 'Tan Hou Ren', 'tanhouren@gmail.com', '65c695a459d3a93f71c734f59f61ba020ab20e4e', '0123456789', 0.00, '2025-11-21 10:18:49.085032'),
(2, 'tan', 'tan@gmail.com', '65c695a459d3a93f71c734f59f61ba020ab20e4e', '0123456789', 0.00, '2026-01-02 10:07:25.975415');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tbl_adoptions`
--
ALTER TABLE `tbl_adoptions`
  ADD UNIQUE KEY `pet_id` (`pet_id`,`adopter_user_id`);

--
-- Indexes for table `tbl_pets`
--
ALTER TABLE `tbl_pets`
  ADD PRIMARY KEY (`pet_id`);

--
-- Indexes for table `tbl_users`
--
ALTER TABLE `tbl_users`
  ADD PRIMARY KEY (`user_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tbl_pets`
--
ALTER TABLE `tbl_pets`
  MODIFY `pet_id` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT for table `tbl_users`
--
ALTER TABLE `tbl_users`
  MODIFY `user_id` int(5) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
