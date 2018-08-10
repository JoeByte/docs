SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;


CREATE TABLE `mp_assigned_resource` (
  `id` int(11) NOT NULL,
  `resource_id` int(11) DEFAULT '0',
  `entity_id` int(11) DEFAULT '0',
  `entity_type` varchar(40) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `mp_assigned_resource` (`id`, `resource_id`, `entity_id`, `entity_type`) VALUES
(1, 100, 10, 'ROLE');

CREATE TABLE `mp_assigned_role` (
  `id` int(11) NOT NULL,
  `role_id` int(11) DEFAULT '0',
  `entity_id` int(11) DEFAULT '0',
  `entity_type` varchar(40) DEFAULT ''
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `mp_assigned_role` (`id`, `role_id`, `entity_id`, `entity_type`) VALUES
(1, 10, 1000, 'USER');

CREATE TABLE `mp_navigation` (
  `id` int(11) NOT NULL,
  `name` varchar(128) DEFAULT '',
  `link` varchar(256) DEFAULT '',
  `style` varchar(128) DEFAULT '',
  `parent` int(11) DEFAULT '0',
  `sort` int(11) DEFAULT '0',
  `hidden` tinyint(4) DEFAULT '0',
  `ctime` int(11) DEFAULT '0',
  `mtime` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

CREATE TABLE `mp_resources` (
  `id` int(11) NOT NULL,
  `name` varchar(128) DEFAULT '',
  `resource` varchar(128) DEFAULT '',
  `category` varchar(128) DEFAULT '',
  `ctime` int(11) DEFAULT '0',
  `mtime` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `mp_resources` (`id`, `name`, `resource`, `category`, `ctime`, `mtime`) VALUES
(100, '用户管理', 'users-*', '权限', 0, 0),
(101, '角色管理', 'roles-*', '权限', 0, 0),
(102, '资源管理', 'resources-*', '权限', 0, 0),
(103, '文章管理', 'articles*', '内容', 0, 0);

CREATE TABLE `mp_roles` (
  `id` int(11) NOT NULL,
  `name` varchar(128) DEFAULT '',
  `ctime` int(11) DEFAULT '0',
  `mtime` int(11) DEFAULT '0'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

INSERT INTO `mp_roles` (`id`, `name`, `ctime`, `mtime`) VALUES
(10, '开发人员', 0, 0),
(11, '管理人员', 0, 0),
(12, '运营人员', 0, 0);


ALTER TABLE `mp_assigned_resource`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `mp_assigned_role`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `mp_navigation`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `mp_resources`
  ADD PRIMARY KEY (`id`);

ALTER TABLE `mp_roles`
  ADD PRIMARY KEY (`id`);


ALTER TABLE `mp_assigned_resource`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

ALTER TABLE `mp_assigned_role`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

ALTER TABLE `mp_navigation`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

ALTER TABLE `mp_resources`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=104;

ALTER TABLE `mp_roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
