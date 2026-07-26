-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: localhost
-- Generation Time: Feb 09, 2026 at 12:38 PM
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
-- Database: `cl_dt_ebook`
--

-- --------------------------------------------------------

--
-- Table structure for table `tbl_admin`
--

CREATE TABLE `tbl_admin` (
  `id` int(11) UNSIGNED NOT NULL,
  `user_name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tbl_admin`
--

INSERT INTO `tbl_admin` (`id`, `user_name`, `email`, `password`, `status`, `created_at`, `updated_at`) VALUES
(1, 'Admin', 'admin@admin.com', '$2y$10$FD11MIqAIxBflIsuLaCFMe29IZ.2dGzfTmhaP6JedFtylLWrO/a4e', 1, '2022-07-03 11:02:11', '2025-03-28 00:08:36');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_audio_book`
--

CREATE TABLE `tbl_audio_book` (
  `id` int(11) UNSIGNED NOT NULL,
  `author_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `title` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `portrait_img` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `landscape_img` varchar(255) NOT NULL,
  `access_type` int(11) NOT NULL DEFAULT 0 COMMENT '0- Free, 1- Paid, 2- Subscription Included',
  `price` int(11) NOT NULL DEFAULT 0,
  `description` text CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `full_audio` varchar(255) NOT NULL,
  `total_played` int(11) NOT NULL DEFAULT 0,
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '0- Under Review, 1- Show ,2 -Hide',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_audio_book_episode`
--

CREATE TABLE `tbl_audio_book_episode` (
  `id` int(11) UNSIGNED NOT NULL,
  `audio_book_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `image` varchar(255) NOT NULL,
  `audio_type` int(11) NOT NULL COMMENT '1- Server Audio, 2- External URL',
  `audio` varchar(255) NOT NULL,
  `is_episode_paid` int(11) NOT NULL DEFAULT 0 COMMENT '0- No, 1- Yes',
  `price` int(11) NOT NULL DEFAULT 0,
  `total_played` int(11) NOT NULL DEFAULT 0,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '0- Hide, 1- Show',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_author_payout`
--

CREATE TABLE `tbl_author_payout` (
  `id` int(11) NOT NULL,
  `author_id` int(11) NOT NULL,
  `total_read_time` int(11) NOT NULL,
  `gross_earning` decimal(15,2) NOT NULL,
  `admin_commission` decimal(15,2) NOT NULL,
  `total_payable_amount` decimal(15,2) NOT NULL,
  `author_payable_amount` int(11) NOT NULL,
  `content_earnings` int(11) NOT NULL,
  `payout_month` int(11) NOT NULL,
  `payout_year` int(11) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_author_request`
--

CREATE TABLE `tbl_author_request` (
  `id` int(11) UNSIGNED NOT NULL,
  `user_id` int(11) NOT NULL,
  `bank_name` varchar(255) NOT NULL,
  `bank_holder_name` varchar(255) NOT NULL,
  `account_no` varchar(255) NOT NULL,
  `ifsc_code` varchar(255) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 0 COMMENT '0- Pending, 1- Complete',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_bookmark`
--

CREATE TABLE `tbl_bookmark` (
  `id` int(11) UNSIGNED NOT NULL,
  `user_id` int(11) NOT NULL,
  `content_type` int(11) NOT NULL COMMENT '1- Audiobook, 2- Novel ,3- Magazine',
  `content_id` int(11) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_category`
--

CREATE TABLE `tbl_category` (
  `id` int(11) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `image` varchar(255) NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '0- Hide, 1- Show',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_contact_us`
--

CREATE TABLE `tbl_contact_us` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `subject` varchar(255) NOT NULL,
  `details` text NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '0- Hide, 1- Show',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_content_section`
--

CREATE TABLE `tbl_content_section` (
  `id` int(11) UNSIGNED NOT NULL,
  `section_type` int(11) NOT NULL COMMENT '0- Home Page, 1- Audiobook, 2- Novel, 3- Magazine',
  `content_type` int(11) NOT NULL COMMENT '1- Audiobook, 2- Novel, 3- Magazine, 4- Category, 5- Language, 6- Author',
  `title` varchar(255) NOT NULL,
  `short_title` varchar(255) NOT NULL,
  `screen_layout` varchar(255) NOT NULL,
  `author_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `access_type` int(11) NOT NULL DEFAULT 0 COMMENT '0- Free, 1- Paid, 2- Subscription Included',
  `order_by_view` int(11) NOT NULL DEFAULT 0 COMMENT '1- Asc, 2- Desc',
  `order_by_upload` int(11) NOT NULL DEFAULT 0 COMMENT '1- Asc, 2- Desc',
  `no_of_content` int(11) NOT NULL DEFAULT 0 COMMENT '0- All',
  `view_all` int(11) NOT NULL DEFAULT 0 COMMENT '0- No, 1- Yes',
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '0- Hide, 1- Show',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_content_transaction`
--

CREATE TABLE `tbl_content_transaction` (
  `id` int(11) UNSIGNED NOT NULL,
  `coupon_code` varchar(255) NOT NULL,
  `user_id` int(11) NOT NULL,
  `author_id` int(11) NOT NULL,
  `content_type` int(11) NOT NULL COMMENT '1- Audiobook, 2- Novel ,3- Magazine	',
  `content_id` int(11) NOT NULL,
  `sub_content_id` int(11) NOT NULL DEFAULT 0,
  `price` decimal(15,2) NOT NULL,
  `commission` decimal(15,2) NOT NULL,
  `total_tax` decimal(15,2) NOT NULL,
  `tax` text NOT NULL,
  `author_earning` decimal(15,2) NOT NULL,
  `transaction_id` varchar(255) NOT NULL,
  `payment_method` varchar(255) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '0- Processing, 1- Success, 2-Fail	',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_content_view`
--

CREATE TABLE `tbl_content_view` (
  `id` int(11) UNSIGNED NOT NULL,
  `user_id` int(11) NOT NULL,
  `content_type` int(11) NOT NULL COMMENT '1- Audiobook, 2- Novel ,3- Magazine	',
  `content_id` int(11) NOT NULL,
  `sub_content_id` int(11) NOT NULL DEFAULT 0,
  `status` int(11) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_coupon`
--

CREATE TABLE `tbl_coupon` (
  `id` int(11) NOT NULL,
  `coupon_code` varchar(255) NOT NULL,
  `name` varchar(255) NOT NULL,
  `amount_type` int(11) NOT NULL COMMENT '0- Price, 1- Percentage',
  `price` varchar(255) NOT NULL,
  `use_limit` int(11) NOT NULL,
  `is_use` int(11) NOT NULL COMMENT '0- All, 1- One',
  `start_date` varchar(255) NOT NULL,
  `end_date` varchar(255) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '0- Hide, 1- Show',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_general_setting`
--

CREATE TABLE `tbl_general_setting` (
  `id` int(11) UNSIGNED NOT NULL,
  `key` text NOT NULL,
  `value` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tbl_general_setting`
--

INSERT INTO `tbl_general_setting` (`id`, `key`, `value`, `created_at`, `updated_at`) VALUES
(1, 'app_name', 'DTEbook', '2024-09-18 05:56:52', '2025-11-06 07:17:07'),
(2, 'app_version', '1.3', '2024-09-18 05:56:52', '2026-02-09 09:23:38'),
(3, 'app_logo', '', '2024-09-18 05:56:52', '2026-02-09 09:23:43'),
(4, 'app_description', 'Divinetechs is an IT company specializing in providing technology solutions and services. The company likely focuses on various aspects of IT, such as software development, web and mobile app development, IT consulting, cloud solutions, and possibly more. Divinetechs aims to leverage technology to drive business growth and efficiency for its clients, offering innovative and customized solutions tailored to meet specific business needs.', '2024-09-18 05:56:52', '2026-02-09 09:24:19'),
(5, 'author', 'Divinetechs', '2024-09-18 05:56:52', '2025-04-16 03:41:47'),
(6, 'email', 'support@divinetechs.com', '2024-09-18 05:56:52', '2026-02-09 09:24:27'),
(7, 'contact', '+91 7984798190', '2024-09-18 05:56:52', '2026-02-09 09:24:43'),
(8, 'website', 'www.divinetechs.com', '2024-09-18 05:56:52', '2025-04-16 03:41:47'),
(9, 'currency', 'USD', '2024-09-18 06:00:12', '2026-02-09 10:14:00'),
(10, 'currency_code', '$', '2024-09-18 06:00:12', '2026-02-09 10:14:03'),
(11, 'admob_status', '0', '2024-09-18 06:02:38', '2025-11-06 07:28:57'),
(12, 'banner_ad', '0', '2024-09-18 06:04:59', '2026-02-09 09:24:52'),
(13, 'banner_adid', '', '2024-09-18 06:04:59', '2026-02-09 09:24:56'),
(14, 'interstital_ad', '0', '2024-09-18 06:05:36', '2026-02-09 09:24:58'),
(15, 'interstital_adid', '', '2024-09-18 06:05:36', '2026-02-09 09:24:59'),
(16, 'interstital_adclick', '', '2024-09-18 06:05:36', '2025-04-16 04:59:59'),
(17, 'reward_ad', '0', '2024-09-18 06:05:36', '2026-02-09 11:37:28'),
(18, 'reward_adid', '', '2024-09-18 06:05:36', '2026-02-09 09:25:04'),
(19, 'reward_adclick', '', '2024-09-18 06:05:36', '2025-04-16 04:59:59'),
(20, 'ios_banner_ad', '0', '2024-09-18 06:04:59', '2026-02-09 09:25:06'),
(21, 'ios_banner_adid', '', '2024-09-18 06:04:59', '2026-02-09 09:25:17'),
(22, 'ios_interstital_ad', '0', '2024-09-18 06:05:36', '2026-02-09 09:25:19'),
(23, 'ios_interstital_adid', '', '2024-09-18 06:05:36', '2026-02-09 09:25:20'),
(24, 'ios_interstital_adclick', '', '2024-09-18 06:05:36', '2025-04-16 04:59:47'),
(25, 'ios_reward_ad', '0', '2024-09-18 06:05:36', '2026-02-09 09:25:24'),
(26, 'ios_reward_adid', '', '2024-09-18 06:05:36', '2026-02-09 09:26:04'),
(27, 'ios_reward_adclick', '', '2024-09-18 06:05:36', '2025-04-16 04:59:47'),
(28, 'facebook_ads_status', '0', '2024-09-18 06:08:26', '2025-04-16 05:02:41'),
(29, 'fb_native_status', '0', '2024-09-18 06:09:04', '2025-04-16 05:04:10'),
(30, 'fb_native_id', '', '2024-09-18 06:09:04', '2025-04-16 05:04:10'),
(31, 'fb_banner_status', '0', '2024-09-18 06:09:18', '2025-04-16 05:04:10'),
(32, 'fb_banner_id', '', '2024-09-18 06:09:18', '2025-04-16 05:04:10'),
(33, 'fb_interstiatial_status', '0', '2024-09-18 06:09:31', '2025-04-16 05:04:10'),
(34, 'fb_interstiatial_id', '', '2024-09-18 06:09:31', '2025-04-16 05:04:10'),
(35, 'fb_rewardvideo_status', '0', '2024-09-18 06:10:25', '2025-04-16 05:04:10'),
(36, 'fb_rewardvideo_id', '', '2024-09-18 06:10:25', '2025-04-16 05:04:10'),
(37, 'fb_native_full_status', '0', '2024-09-18 06:10:45', '2025-04-16 05:04:10'),
(38, 'fb_native_full_id', '', '2024-09-18 06:10:45', '2025-04-16 05:04:10'),
(39, 'fb_ios_native_status', '0', '2024-09-18 06:09:04', '2025-04-16 05:04:33'),
(40, 'fb_ios_native_id', '', '2024-09-18 06:09:04', '2025-04-16 05:04:33'),
(41, 'fb_ios_banner_status', '0', '2024-09-18 06:09:18', '2025-04-16 05:04:33'),
(42, 'fb_ios_banner_id', '', '2024-09-18 06:09:18', '2025-04-16 05:04:33'),
(43, 'fb_ios_interstiatial_status', '0', '2024-09-18 06:09:31', '2025-04-16 05:04:33'),
(44, 'fb_ios_interstiatial_id', '', '2024-09-18 06:09:31', '2025-04-16 05:04:33'),
(45, 'fb_ios_rewardvideo_status', '0', '2024-09-18 06:10:25', '2025-04-16 05:04:33'),
(46, 'fb_ios_rewardvideo_id', '', '2024-09-18 06:10:25', '2025-04-16 05:04:33'),
(47, 'fb_ios_native_full_status', '0', '2024-09-18 06:10:45', '2025-04-16 05:04:33'),
(48, 'fb_ios_native_full_id', '', '2024-09-18 06:10:45', '2025-04-16 05:04:33'),
(49, 'page_background_color', '#ffffff', '2024-10-28 11:30:11', '2026-02-09 10:14:11'),
(50, 'page_title_color', '#000000', '2024-10-28 11:30:11', '2025-11-10 06:38:52'),
(63, 'panel_login_page_bg_image', '', '2025-03-04 10:02:37', '2026-02-09 09:25:39'),
(66, 'onesignal_apid', '', '2025-03-27 07:12:05', '2026-02-09 09:25:41'),
(67, 'onesignal_rest_key', '', '2025-03-27 07:12:05', '2026-02-09 09:25:43'),
(68, 'commission', '0', '2025-04-17 05:14:09', '2026-02-09 09:25:46'),
(70, 'screenshot', '0', '2025-09-09 05:34:34', '2025-11-06 07:18:34'),
(71, 'vap_id_key', '', '2025-09-15 05:49:46', '2026-02-09 09:25:48'),
(72, 'address', '', '2025-09-30 10:54:22', '2026-02-09 09:25:49'),
(73, 'active_commission', '0', '2026-01-23 10:51:42', '2026-02-09 09:25:51'),
(74, 'company_logo', '', '2026-01-27 07:23:53', '2026-02-09 09:25:53'),
(75, 'company_name', 'Divinetechs', '2026-01-27 07:23:53', '2026-01-27 07:28:47'),
(76, 'min_time', '0', '2026-02-04 05:45:49', '2026-02-04 06:46:55'),
(77, 'max_time', '0', '2026-02-04 05:45:49', '2026-02-04 06:46:55');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_history`
--

CREATE TABLE `tbl_history` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `author_id` int(11) NOT NULL,
  `content_type` int(11) NOT NULL,
  `content_id` int(11) NOT NULL,
  `sub_content_id` int(11) NOT NULL,
  `is_subscription` int(11) NOT NULL,
  `time_spend` int(11) NOT NULL,
  `last_position` int(11) NOT NULL DEFAULT 0,
  `activity_month` int(11) NOT NULL,
  `activity_year` int(11) NOT NULL,
  `status` int(11) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_language`
--

CREATE TABLE `tbl_language` (
  `id` int(11) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `image` varchar(255) NOT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '0- Hide, 1- Show',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_login_history`
--

CREATE TABLE `tbl_login_history` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `login_time` varchar(255) NOT NULL,
  `logout_time` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_magazine`
--

CREATE TABLE `tbl_magazine` (
  `id` int(11) UNSIGNED NOT NULL,
  `author_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `title` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `portrait_img` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `landscape_img` varchar(255) NOT NULL,
  `access_type` int(11) NOT NULL DEFAULT 0 COMMENT '0- Free, 1- Paid, 2- Subscription Included',
  `price` int(11) NOT NULL DEFAULT 0,
  `description` text CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `full_magazine` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `total_read` int(11) NOT NULL DEFAULT 0,
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '0- Under Review, 1- Show ,2 -Hide',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_notification`
--

CREATE TABLE `tbl_notification` (
  `id` int(11) UNSIGNED NOT NULL,
  `type` int(11) NOT NULL COMMENT '1- Admin, 2- Add Become Author Request, 3- Auther Request Status Change, 4- Review, 5- Upload New Content, 6- Add Withdrawal Request, 7- Withdrawal Request Status Change, 8- Content Status Change',
  `user_id` int(11) NOT NULL DEFAULT 0,
  `auther_id` int(11) NOT NULL DEFAULT 0,
  `content_type` int(11) NOT NULL DEFAULT 0 COMMENT '1- Audiobook, 2- Novel ,3- Magazine	',
  `content_id` int(11) NOT NULL DEFAULT 0,
  `sub_content_id` int(11) NOT NULL DEFAULT 0,
  `title` text NOT NULL,
  `message` text NOT NULL,
  `image` varchar(255) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_notification_configuration`
--

CREATE TABLE `tbl_notification_configuration` (
  `id` int(11) UNSIGNED NOT NULL,
  `type` varchar(255) NOT NULL,
  `send_mail` int(11) NOT NULL,
  `send_notification` int(11) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 0 COMMENT '0- Off, 1- On',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_notification_configuration`
--

INSERT INTO `tbl_notification_configuration` (`id`, `type`, `send_mail`, `send_notification`, `status`, `created_at`, `updated_at`) VALUES
(1, 'register', 0, 0, 0, '2025-01-31 06:23:14', '2026-02-09 09:27:04'),
(2, 'login', 0, 0, 0, '2025-01-31 06:23:14', '2026-02-09 09:27:07'),
(3, 'update-profile', 0, 0, 0, '2025-01-31 06:23:14', '2026-02-09 09:27:09'),
(4, 'change-password', 0, 0, 0, '2025-01-31 06:23:14', '2026-02-09 09:27:10'),
(5, 'add-become-auther-request', 0, 0, 0, '2025-01-31 06:23:14', '2026-02-09 09:27:11'),
(6, 'auther-request-status-change', 0, 0, 0, '2025-01-31 06:23:14', '2026-02-09 09:27:13'),
(7, 'upload-new-content', 0, 0, 0, '2025-01-31 06:23:14', '2026-02-09 09:27:14'),
(8, 'buy-content', 0, 0, 0, '2025-01-31 06:23:14', '2026-02-09 09:27:15'),
(9, 'add-review', 0, 0, 0, '2025-01-31 06:23:14', '2026-02-09 09:27:19'),
(10, 'add-withdrawal-request', 0, 0, 0, '2025-01-31 06:23:14', '2026-02-09 09:27:21'),
(11, 'withdrawal-request-status-chagne', 0, 0, 0, '2025-01-31 06:23:14', '2026-02-09 09:27:22'),
(116, 'content-status-change', 0, 0, 0, '2025-08-21 07:00:20', '2026-02-09 09:27:24'),
(122, 'buy-plan', 0, 0, 0, '2026-01-20 12:04:10', '2026-02-09 09:27:27'),
(123, 'subscription-status-change', 0, 0, 0, '2026-02-05 10:34:29', '2026-02-09 09:27:28'),
(124, 'plan-status-change', 0, 0, 0, '2026-02-05 12:14:19', '2026-02-09 09:27:30');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_novel`
--

CREATE TABLE `tbl_novel` (
  `id` int(11) UNSIGNED NOT NULL,
  `author_id` int(11) NOT NULL,
  `category_id` int(11) NOT NULL,
  `language_id` int(11) NOT NULL,
  `title` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `portrait_img` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `landscape_img` varchar(255) NOT NULL,
  `access_type` int(11) NOT NULL DEFAULT 0 COMMENT '0- Free, 1- Paid, 2- Subscription Included',
  `price` int(11) NOT NULL DEFAULT 0,
  `description` text CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `full_novel` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `total_read` int(11) NOT NULL DEFAULT 0,
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '0- Under Review, 1- Show ,2 -Hide',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_novel_chapter`
--

CREATE TABLE `tbl_novel_chapter` (
  `id` int(11) UNSIGNED NOT NULL,
  `novel_id` int(11) NOT NULL,
  `title` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `description` text CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `image` varchar(255) NOT NULL,
  `chapter_type` int(11) NOT NULL COMMENT '1- Server File, 2- External URL	',
  `chapter` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `is_chapter_paid` int(11) NOT NULL DEFAULT 0 COMMENT '0- No, 1- Yes',
  `price` int(11) NOT NULL DEFAULT 0,
  `total_read` int(11) NOT NULL DEFAULT 0,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '	0- Hide, 1- Show',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_onboarding_screen`
--

CREATE TABLE `tbl_onboarding_screen` (
  `id` int(11) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `image` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_page`
--

CREATE TABLE `tbl_page` (
  `id` int(11) UNSIGNED NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `icon` varchar(255) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '0- Hide, 1- Show	',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `tbl_page`
--

INSERT INTO `tbl_page` (`id`, `title`, `description`, `icon`, `status`, `created_at`, `updated_at`) VALUES
(1, 'About Us', '', '', 1, '2022-01-24 17:28:26', '2025-12-04 11:05:29'),
(2, 'Privacy Policy', '', '', 1, '2022-01-24 17:28:26', '2025-12-04 11:05:31'),
(3, 'Terms and Conditions', '', '', 1, '2022-01-24 17:28:37', '2025-12-04 11:05:33'),
(4, 'Refund Policy', '', '', 1, '2023-04-15 11:01:19', '2025-12-04 11:05:34');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_payment_option`
--

CREATE TABLE `tbl_payment_option` (
  `id` int(11) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `visibility` varchar(255) NOT NULL,
  `is_live` varchar(255) NOT NULL,
  `key_1` varchar(255) NOT NULL,
  `key_2` varchar(255) NOT NULL,
  `key_3` varchar(255) NOT NULL,
  `key_4` varchar(255) NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tbl_payment_option`
--

INSERT INTO `tbl_payment_option` (`id`, `name`, `visibility`, `is_live`, `key_1`, `key_2`, `key_3`, `key_4`, `created_at`, `updated_at`) VALUES
(1, 'inapppurchage', '0', '0', '', '', '', '', '2023-04-08 16:50:05', '2026-02-09 09:28:24'),
(2, 'paypal', '0', '0', '', '', '', '', '2023-04-08 16:50:05', '2026-02-09 09:28:41'),
(3, 'razorpay', '0', '0', '', '', '', '', '2023-04-08 16:50:05', '2026-02-09 09:28:38'),
(4, 'flutterwave', '0', '0', '', '', '', '', '2023-04-08 16:50:05', '2026-02-09 09:28:44'),
(5, 'payumoney', '0', '0', '', '', '', '', '2023-04-08 16:50:05', '2025-04-16 04:35:10'),
(6, 'paytm', '0', '0', '', '', '', '', '2023-04-08 16:50:05', '2025-04-16 04:35:20'),
(7, 'stripe', '0', '0', '', '', '', '', '2023-07-03 11:59:57', '2026-02-09 09:28:46');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_plan`
--

CREATE TABLE `tbl_plan` (
  `id` int(11) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `type` varchar(255) NOT NULL,
  `time` int(11) NOT NULL,
  `price` varchar(255) NOT NULL,
  `access_type` varchar(255) NOT NULL COMMENT '1- Unlimited Reading,\r\n2- Access On Mobile & Web,\r\n3- Dark Mode Reading',
  `cancel_anytime` int(11) NOT NULL COMMENT '0- No, 1- Yes',
  `auto_renew` int(11) NOT NULL COMMENT '0- No, 1- Yes',
  `image` varchar(255) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '0- Hide, 1- Show',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_read_notification`
--

CREATE TABLE `tbl_read_notification` (
  `id` int(11) UNSIGNED NOT NULL,
  `user_id` int(11) NOT NULL,
  `notification_id` int(11) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_review`
--

CREATE TABLE `tbl_review` (
  `id` int(11) UNSIGNED NOT NULL,
  `user_id` int(11) NOT NULL,
  `content_type` int(11) NOT NULL COMMENT '1- Audiobook, 2- Novel ,3- Magazine',
  `content_id` int(11) NOT NULL,
  `review` varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci NOT NULL,
  `rating` int(11) NOT NULL DEFAULT 0,
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '0- Hide, 1- Show',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_smtp`
--

CREATE TABLE `tbl_smtp` (
  `id` int(11) UNSIGNED NOT NULL,
  `protocol` varchar(255) NOT NULL,
  `host` varchar(255) NOT NULL,
  `port` varchar(255) NOT NULL,
  `user` varchar(255) NOT NULL,
  `pass` varchar(255) NOT NULL,
  `from_name` varchar(255) NOT NULL,
  `from_email` varchar(255) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 0 COMMENT '0- Off, 1- On',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `tbl_smtp`
--

INSERT INTO `tbl_smtp` (`id`, `protocol`, `host`, `port`, `user`, `pass`, `from_name`, `from_email`, `status`, `created_at`, `updated_at`) VALUES
(1, 'smtp123', 'smtp.gmail.com', '587', 'admin@admin.com', 'admin', 'DTEBook-Divinetechs', 'admin@admin.com', 0, '2023-06-27 05:29:22', '2026-02-09 09:29:18');

-- --------------------------------------------------------

--
-- Table structure for table `tbl_social_link`
--

CREATE TABLE `tbl_social_link` (
  `id` int(11) UNSIGNED NOT NULL,
  `name` varchar(255) NOT NULL,
  `image` varchar(255) NOT NULL,
  `url` varchar(255) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_tax`
--

CREATE TABLE `tbl_tax` (
  `id` int(11) NOT NULL,
  `name` varchar(255) NOT NULL,
  `percentage` int(11) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '0- Hide, 1- Show',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_transaction`
--

CREATE TABLE `tbl_transaction` (
  `id` int(11) UNSIGNED NOT NULL,
  `coupon_code` varchar(255) NOT NULL,
  `user_id` int(11) NOT NULL,
  `plan_id` int(11) NOT NULL,
  `auto_renew` int(11) NOT NULL DEFAULT 0,
  `transaction_id` varchar(255) NOT NULL,
  `price` int(11) NOT NULL,
  `total_tax` int(11) NOT NULL DEFAULT 0,
  `tax` varchar(255) NOT NULL,
  `payment_method` varchar(255) NOT NULL,
  `starts_at` varchar(255) NOT NULL,
  `expiry_date` varchar(255) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '0- Expire, 1- Active, 2- Upcoming',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_user`
--

CREATE TABLE `tbl_user` (
  `id` int(11) UNSIGNED NOT NULL,
  `is_author` int(11) NOT NULL DEFAULT 0 COMMENT '0- No, 1- Yes,',
  `category_ids` text NOT NULL,
  `user_name` varchar(255) NOT NULL,
  `first_name` varchar(255) NOT NULL,
  `last_name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `mobile_number` varchar(255) NOT NULL,
  `image` varchar(255) NOT NULL,
  `type` int(11) NOT NULL DEFAULT 0 COMMENT '1- OTP, 2- Google, 3- Apple, 4- Normal	',
  `address` text NOT NULL,
  `description` text NOT NULL,
  `wallet_amount` decimal(15,2) NOT NULL DEFAULT 0.00,
  `bank_name` varchar(255) NOT NULL,
  `bank_holder_name` varchar(255) NOT NULL,
  `account_no` varchar(255) NOT NULL,
  `ifsc_code` varchar(255) NOT NULL,
  `device_type` int(11) NOT NULL DEFAULT 0 COMMENT '1- Android, 2- iOS, 3- Web',
  `device_token` varchar(255) NOT NULL,
  `status` int(11) NOT NULL DEFAULT 1 COMMENT '0- Inactive, 1- Active',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `tbl_withdrawal_request`
--

CREATE TABLE `tbl_withdrawal_request` (
  `id` int(11) UNSIGNED NOT NULL,
  `author_id` int(11) NOT NULL,
  `price` int(11) NOT NULL,
  `payment_type` varchar(255) NOT NULL,
  `payment_detail` text NOT NULL,
  `status` int(11) NOT NULL DEFAULT 0 COMMENT '0- Pending, 1- Completed',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `tbl_admin`
--
ALTER TABLE `tbl_admin`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_audio_book`
--
ALTER TABLE `tbl_audio_book`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_audio_book_episode`
--
ALTER TABLE `tbl_audio_book_episode`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_author_payout`
--
ALTER TABLE `tbl_author_payout`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_author_request`
--
ALTER TABLE `tbl_author_request`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_bookmark`
--
ALTER TABLE `tbl_bookmark`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_category`
--
ALTER TABLE `tbl_category`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_contact_us`
--
ALTER TABLE `tbl_contact_us`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_content_section`
--
ALTER TABLE `tbl_content_section`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_content_transaction`
--
ALTER TABLE `tbl_content_transaction`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_content_view`
--
ALTER TABLE `tbl_content_view`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_coupon`
--
ALTER TABLE `tbl_coupon`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_general_setting`
--
ALTER TABLE `tbl_general_setting`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_history`
--
ALTER TABLE `tbl_history`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_language`
--
ALTER TABLE `tbl_language`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_login_history`
--
ALTER TABLE `tbl_login_history`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_magazine`
--
ALTER TABLE `tbl_magazine`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_notification`
--
ALTER TABLE `tbl_notification`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_notification_configuration`
--
ALTER TABLE `tbl_notification_configuration`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_novel`
--
ALTER TABLE `tbl_novel`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_novel_chapter`
--
ALTER TABLE `tbl_novel_chapter`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_onboarding_screen`
--
ALTER TABLE `tbl_onboarding_screen`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_page`
--
ALTER TABLE `tbl_page`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_payment_option`
--
ALTER TABLE `tbl_payment_option`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_plan`
--
ALTER TABLE `tbl_plan`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_read_notification`
--
ALTER TABLE `tbl_read_notification`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_review`
--
ALTER TABLE `tbl_review`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_smtp`
--
ALTER TABLE `tbl_smtp`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_social_link`
--
ALTER TABLE `tbl_social_link`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_tax`
--
ALTER TABLE `tbl_tax`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_transaction`
--
ALTER TABLE `tbl_transaction`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_user`
--
ALTER TABLE `tbl_user`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `tbl_withdrawal_request`
--
ALTER TABLE `tbl_withdrawal_request`
  ADD PRIMARY KEY (`id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `tbl_admin`
--
ALTER TABLE `tbl_admin`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `tbl_audio_book`
--
ALTER TABLE `tbl_audio_book`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_audio_book_episode`
--
ALTER TABLE `tbl_audio_book_episode`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_author_payout`
--
ALTER TABLE `tbl_author_payout`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_author_request`
--
ALTER TABLE `tbl_author_request`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_bookmark`
--
ALTER TABLE `tbl_bookmark`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_category`
--
ALTER TABLE `tbl_category`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_contact_us`
--
ALTER TABLE `tbl_contact_us`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_content_section`
--
ALTER TABLE `tbl_content_section`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_content_transaction`
--
ALTER TABLE `tbl_content_transaction`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_content_view`
--
ALTER TABLE `tbl_content_view`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_coupon`
--
ALTER TABLE `tbl_coupon`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_general_setting`
--
ALTER TABLE `tbl_general_setting`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=78;

--
-- AUTO_INCREMENT for table `tbl_history`
--
ALTER TABLE `tbl_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_language`
--
ALTER TABLE `tbl_language`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_login_history`
--
ALTER TABLE `tbl_login_history`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_magazine`
--
ALTER TABLE `tbl_magazine`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_notification`
--
ALTER TABLE `tbl_notification`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_notification_configuration`
--
ALTER TABLE `tbl_notification_configuration`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=125;

--
-- AUTO_INCREMENT for table `tbl_novel`
--
ALTER TABLE `tbl_novel`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_novel_chapter`
--
ALTER TABLE `tbl_novel_chapter`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_onboarding_screen`
--
ALTER TABLE `tbl_onboarding_screen`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_page`
--
ALTER TABLE `tbl_page`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `tbl_payment_option`
--
ALTER TABLE `tbl_payment_option`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=8;

--
-- AUTO_INCREMENT for table `tbl_plan`
--
ALTER TABLE `tbl_plan`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_read_notification`
--
ALTER TABLE `tbl_read_notification`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_review`
--
ALTER TABLE `tbl_review`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_smtp`
--
ALTER TABLE `tbl_smtp`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `tbl_social_link`
--
ALTER TABLE `tbl_social_link`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_tax`
--
ALTER TABLE `tbl_tax`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_transaction`
--
ALTER TABLE `tbl_transaction`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_user`
--
ALTER TABLE `tbl_user`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `tbl_withdrawal_request`
--
ALTER TABLE `tbl_withdrawal_request`
  MODIFY `id` int(11) UNSIGNED NOT NULL AUTO_INCREMENT;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
