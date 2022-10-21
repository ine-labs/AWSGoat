SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
--

-- --------------------------------------------------------
CREATE DATABASE appdb;
USE `appdb`;


CREATE TABLE `appdb`.`organizations`(
    `organization_id` INT NOT NULL,
    `organization` TEXT NOT NULL,
    PRIMARY KEY(`organization_id`)
) ENGINE = InnoDB;

INSERT INTO `organizations`(`organization_id`, `organization`)
VALUES('0', 'No-organization');

INSERT INTO `organizations`(`organization_id`, `organization`)
VALUES('1', 'Techio');

INSERT INTO `organizations`(`organization_id`, `organization`)
VALUES('2', 'FinexTech');


CREATE TABLE `appdb`.`users` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `organization_id` INT NOT NULL,
  `username` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `isadmin` tinyint(1) NOT NULL,
  PRIMARY KEY(`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;


ALTER TABLE
    `users` ADD CONSTRAINT `organization_relation` FOREIGN KEY(`organization_id`) REFERENCES `organizations`(`organization_id`) ON DELETE RESTRICT ON UPDATE RESTRICT;
--
-- Dumping data for table `users`
--
INSERT INTO `users` (`id`, `organization_id`, `username`, `email`, `password`, `isadmin`) VALUES 
(1, 0, 'chris', 'chris@ineorganization.com', '7ada536411f87bb92f7724091c3dc814', '2');

INSERT INTO `users` (`id`, `organization_id`, `username`, `email`, `password`, `isadmin`) VALUES 
(2, 2, 'terry', 'terry@inefinextech.com', '517271135df0a1492bd675be384ce456', '1');

INSERT INTO `users` (`id`,`organization_id`, `username`, `email`, `password`, `isadmin`) VALUES
(3, 1, 'jasmine', 'jasmine@inetechio.com', '6e864de5f25031fe838ab339f7a66d7d', '1');

INSERT INTO `users` (`id`, `organization_id`, `username`, `email`, `password`, `isadmin`) VALUES 
(4, 2, 'alice', 'alice@inefinextech.com', '9936092579f57e69a6a26461bad6eafa', '0');

INSERT INTO `users` (`id`,`organization_id`, `username`, `email`, `password`, `isadmin`) VALUES
(5, 1, 'mark', 'mark@inetechio.com', '9052d8503f8e9680109fcaa72055d213', '0');











--
-- AUTO_INCREMENT for dumped tables
--

--
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

CREATE TABLE `appdb`.`users_info`(
    `id` INT(11) NOT NULL,
    `first_name` VARCHAR(15) NOT NULL,
    `last_name` VARCHAR(15) NOT NULL,
    `email` VARCHAR(40) NOT NULL,
    `address` VARCHAR(100) NOT NULL,
    `ssn` BIGINT(16) NOT NULL,
    `bank_account` VARCHAR(16) NULL,
    `phone` VARCHAR(13) NULL,
    `isadmin` tinyint(1) NOT NULL,
    PRIMARY KEY(`id`)
) ENGINE = InnoDB;

ALTER TABLE `users_info` ADD CONSTRAINT `foreign key` FOREIGN KEY (`id`) REFERENCES `users`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;


INSERT INTO `users_info`(
    `id`,
    `first_name`,
    `last_name`,
    `email`,
    `address`,
    `ssn`,
    `bank_account`,
    `phone`,
    `isadmin`
)
VALUES(
    '1',
    'Chris',
    'Hampstead',
    'chris@ineorganization.com',
    '416 Mueller Keys, Apt. 836, 36501-2432, Port Anastasiatown, Oregon, United States',
    '15151511',
    NULL,
    NULL,
    '2'
);

INSERT INTO `users_info`(
    `id`,
    `first_name`,
    `last_name`,
    `email`,
    `address`,
    `ssn`,
    `bank_account`,
    `phone`,
    `isadmin`
)
VALUES(
    '2',
    'Terry',
    'Mathews',
    'terry@inefinextech.com',
    '4484 Isabelle Stravenue, Suite 422, TU2 7GK, Adonismouth, Wisconsin, Great Britain',
    '456789213',
    NULL,
    NULL,
    '1'
);

INSERT INTO `users_info`(
    `id`,
    `first_name`,
    `last_name`,
    `email`,
    `address`,
    `ssn`,
    `bank_account`,
    `phone`,
    `isadmin`
)
VALUES(
    '3',
    'Jasmine',
    'Dalton',
    'jasmine@inetechio.com',
    '4085 Kuphal Harbor, Suite 798, 55256-9935, Alexisborough, Idaho, United States',
    '15625323',
    NULL,
    NULL,
    '1'
);


INSERT INTO `users_info`(
    `id`,
    `first_name`,
    `last_name`,
    `email`,
    `address`,
    `ssn`,
    `bank_account`,
    `phone`,
    `isadmin`
)
VALUES(
    '4',
    'Alice',
    'White',
    'alice@inefinextech.com',
    '66892 Sydnee Prairie, Suite 479, PC9 7ZO, Jakubowskibury, Tennessee, Great Britain',
    '741852963',
    '258741369',
    '456789312',
    '0'
);

INSERT INTO `users_info`(
    `id`,
    `first_name`,
    `last_name`,
    `email`,
    `address`,
    `ssn`,
    `bank_account`,
    `phone`,
    `isadmin`
)
VALUES(
    '5',
    'Mark',
    'Huston',
    'mark@inetechio.com',
    '874 Kunde Camp, Apt. 501, 10073-2876, Quincyberg, Connecticut, United States',
    '15151511',
    'A535483213',
    '+16985452',
    '0'
);









CREATE TABLE `appdb`.`payslips`(
    `payslip_id` INT NOT NULL AUTO_INCREMENT,
    `date` DATE NULL,
    `id` INT NOT NULL,
    `file` TEXT NULL,
    PRIMARY KEY(`payslip_id`)
) ENGINE = InnoDB;
ALTER TABLE 
    `payslips` ADD CONSTRAINT `foreignkeypay` FOREIGN KEY (`id`) REFERENCES `users`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;


INSERT INTO `payslips`(`payslip_id`, `date`, `id`, `file`)
VALUES(
    '1',
    '2022-10-01',
    '5',
    '..//documents/payslips/38343834353753616c6172792d506179736c69702e706466.pdf'
),(
    '2',
    '2022-10-01',
    '4',
    '..//documents/payslips/48343834353753616c6172792d506179736c69702e706466.pdf'
),(
    '3',
    '2022-10-01',
    '3',
    '..//documents/payslips/58343834353753616c6172792d506179736c69702e706466.pdf'
),(
    '4',
    '2022-10-01',
    '2',
    '..//documents/payslips/68343834353753616c6172792d506179736c69702e706466.pdf'
);










CREATE TABLE `appdb`.`leave_applications`(
    `first_name` VARCHAR(15) NOT NULL,
    `leave_id` INT NOT NULL AUTO_INCREMENT,
    `id` INT NOT NULL,
    `leave_type` VARCHAR(20) NOT NULL,
    `from_date` DATE NOT NULL,
    `to_date` DATE NULL,
    `reason` VARCHAR(100) NULL,
    `isadmin` tinyint(1) NULL,
    PRIMARY KEY(`leave_id`)
) ENGINE = InnoDB;

-- ALTER TABLE `leave_applications`
--   ADD PRIMARY KEY (`leave_id`);

ALTER TABLE 
  `leave_applications` ADD `status` VARCHAR(20) NOT NULL DEFAULT 'Pending' AFTER `reason`;

ALTER TABLE
    `leave_applications` ADD CONSTRAINT `foreignkey` FOREIGN KEY(`id`) REFERENCES `users_info`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

INSERT INTO `leave_applications`(
    `first_name`,
    `leave_id`,
    `id`,
    `leave_type`,
    `from_date`,
    `to_date`,
    `reason`,
    `isadmin`
)
VALUES(
    'mark',
    '1',
    '5',
    'Paid time off',
    '2022-09-25',
    '2022-09-28',
    NULL,
    0
);

INSERT INTO `leave_applications`(
    `first_name`,
    `leave_id`,
    `id`,
    `leave_type`,
    `from_date`,
    `to_date`,
    `reason`,
    `isadmin`
)
VALUES(
    'alice',
    '2',
    '4',
    'Medical',
    '2022-09-24',
    '2022-09-25',
    NULL,
    0
);

INSERT INTO `leave_applications`(
    `first_name`,
    `leave_id`,
    `id`,
    `leave_type`,
    `from_date`,
    `to_date`,
    `reason`,
    `isadmin`
)
VALUES(
    'terry',
    '3',
    '2',
    'Medical',
    '2022-09-10',
    '2022-09-15',
    NULL,
    1
);

INSERT INTO `leave_applications`(
    `first_name`,
    `leave_id`,
    `id`,
    `leave_type`,
    `from_date`,
    `to_date`,
    `reason`,
    `isadmin`
)
VALUES(
    'jasmine',
    '4',
    '3',
    'Medical',
    '2022-09-19',
    '2022-09-20',
    NULL,
    1
);


CREATE TABLE `appdb`.`reimbursments`(
    `reimbursment_id` INT NOT NULL AUTO_INCREMENT,
    `id` INT NOT NULL,
    `first_name` VARCHAR(15) NOT NULL,
    `amount` INT NOT NULL,
    `status` VARCHAR(20) NOT NULL DEFAULT 'Pending',
    `filed_on` DATE NOT NULL,
    `isadmin` tinyint(1) NOT NULL,
    `file` TEXT NULL,
    PRIMARY KEY(`reimbursment_id`)
) ENGINE = InnoDB;

ALTER TABLE `reimbursments` ADD `type` VARCHAR(20) NULL AFTER `filed_on`;

ALTER TABLE
  `reimbursments` ADD CONSTRAINT `foreignkeyreim` FOREIGN KEY(`id`) REFERENCES `users`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

INSERT INTO `reimbursments`(
    `reimbursment_id`,
    `id`,
    `first_name`,
    `type`,
    `amount`,
    `status`,
    `filed_on`,
    `isadmin`,
    `file`
)
VALUES(
    '1',
    '5',
    'mark',
    'Food',
    '100',
    'Pending',
    '2022-09-02',
    '0',
    '..//documents/reimbursments/78343834353753616c6172792d506179736c69702e706466.pdf'
);

INSERT INTO `reimbursments`(
    `reimbursment_id`,
    `id`,
    `first_name`,
    `type`,
    `amount`,
    `status`,
    `filed_on`,
    `isadmin`,
    `file`
)
VALUES(
    '2',
    '4',
    'alice',
    'Equipment',
    '50',
    'Pending',
    '2022-09-10',
    '0',
    '..//documents/reimbursments/88343834353753616c6172792d506179736c69702e706466.pdf'
);

INSERT INTO `reimbursments`(
    `reimbursment_id`,
    `id`,
    `first_name`,
    `type`,
    `amount`,
    `status`,
    `filed_on`,
    `isadmin`,
    `file`
)
VALUES(
    '3',
    '3',
    'jasmine',
    'Medical',
    '500',
    'Pending',
    '2022-09-10',
    '1',
    '..//documents/reimbursments/98343834353753616c6172792d506179736c69702e706466.pdf'
);

INSERT INTO `reimbursments`(
    `reimbursment_id`,
    `id`,
    `first_name`,
    `type`,
    `amount`,
    `status`,
    `filed_on`,
    `isadmin`,
    `file`
)
VALUES(
    '4',
    '2',
    'terry',
    'Travel',
    '700',
    'Pending',
    '2022-09-10',
    '1',
    '..//documents/reimbursments/18343834353753616c6172792d506179736c69702e706466.pdf'
);

INSERT INTO `reimbursments`(
    `reimbursment_id`,
    `id`,
    `first_name`,
    `type`,
    `amount`,
    `status`,
    `filed_on`,
    `isadmin`
)
VALUES(
    '3',
    '2',
    'terry',
    'FOOD',
    '100',
    'Pending',
    '2022-09-10',
    '1'
    
);

INSERT INTO `reimbursments`(
    `reimbursment_id`,
    `id`,
    `first_name`,
    `type`,
    `amount`,
    `status`,
    `filed_on`,
    `isadmin`
)
VALUES(
    '4',
    '3',
    'jasmine',
    'Equipment',
    '50',
    'Pending',
    '2022-09-10',
    '1'
    
);



CREATE TABLE `appdb` . `complaints`(
    `complaint_id` INT NOT NULL AUTO_INCREMENT,
    `id` INT NOT NULL,
    `first_name` VARCHAR(15) NOT NULL,
    `remark` VARCHAR(100) NULL DEFAULT 'Processing',
    `message` VARCHAR(250) NOT NULL,
    `organization_id` INT NOT NULL,
    PRIMARY KEY(`complaint_id`)
)ENGINE = InnoDB;

ALTER TABLE
  `complaints` ADD CONSTRAINT `foreignkeycom` FOREIGN KEY(`id`) REFERENCES `users`(`id`) ON DELETE RESTRICT ON UPDATE RESTRICT;

INSERT INTO `complaints`(
    `complaint_id`,
    `id`,
    `first_name`,
    `message`,
    `organization_id`
    
)
VALUES(
    '1',
    '5',
    'mark',
    'AC not working',
    '1'
);

INSERT INTO `complaints`(
    `complaint_id`,
    `id`,
    `first_name`,
    `message`,
    `organization_id`
    
)
VALUES(
    '2',
    '4',
    'alice',
    'Need a new Desktop',
    '2'
);
