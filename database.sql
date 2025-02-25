CREATE TABLE IF NOT EXISTS `trucker_job`(
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `citizenid` varchar(50) DEFAULT NULL,
    `company_name` varchar(50) DEFAULT NULL,
    `company_money` int(11) DEFAULT 0,
    `company_jobs_done` int(11) DEFAULT 0,
    `company_garage` int(11) DEFAULT 0,
    `company_garage_capacity` int(11) DEFAULT 0,
    `garage_Upgrade_right` int(11) DEFAULT 0,
    `company_employee` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_bin DEFAULT '[]',
    `company_level` int(11) DEFAULT 0,
    `comp_exp` int(11) DEFAULT 0,
    PRIMARY KEY (`id`),
    KEY `citizenid` (`citizenid`)
) ENGINE=InnoDB AUTO_INCREMENT=1;
