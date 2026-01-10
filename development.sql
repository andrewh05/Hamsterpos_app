/*
 Navicat Premium Data Transfer

 Source Server         : localhost_3306
 Source Server Type    : MySQL
 Source Server Version : 80039 (8.0.39)
 Source Host           : localhost:3306
 Source Schema         : development

 Target Server Type    : MySQL
 Target Server Version : 80039 (8.0.39)
 File Encoding         : 65001

 Date: 08/01/2026 21:56:13
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for applications
-- ----------------------------
DROP TABLE IF EXISTS `applications`;
CREATE TABLE `applications`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `version` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `instdate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for attribute
-- ----------------------------
DROP TABLE IF EXISTS `attribute`;
CREATE TABLE `attribute`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for attributeinstance
-- ----------------------------
DROP TABLE IF EXISTS `attributeinstance`;
CREATE TABLE `attributeinstance`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `attributesetinstance_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `attribute_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `value` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `attinst_att`(`attribute_id` ASC) USING BTREE,
  INDEX `attinst_set`(`attributesetinstance_id` ASC) USING BTREE,
  CONSTRAINT `attinst_att` FOREIGN KEY (`attribute_id`) REFERENCES `attribute` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `attinst_set` FOREIGN KEY (`attributesetinstance_id`) REFERENCES `attributesetinstance` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for attributeset
-- ----------------------------
DROP TABLE IF EXISTS `attributeset`;
CREATE TABLE `attributeset`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for attributesetinstance
-- ----------------------------
DROP TABLE IF EXISTS `attributesetinstance`;
CREATE TABLE `attributesetinstance`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `attributeset_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `attsetinst_set`(`attributeset_id` ASC) USING BTREE,
  CONSTRAINT `attsetinst_set` FOREIGN KEY (`attributeset_id`) REFERENCES `attributeset` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for attributeuse
-- ----------------------------
DROP TABLE IF EXISTS `attributeuse`;
CREATE TABLE `attributeuse`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `attributeset_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `attribute_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `lineno` int NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `attuse_line`(`attributeset_id` ASC, `lineno` ASC) USING BTREE,
  INDEX `attuse_att`(`attribute_id` ASC) USING BTREE,
  CONSTRAINT `attuse_att` FOREIGN KEY (`attribute_id`) REFERENCES `attribute` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `attuse_set` FOREIGN KEY (`attributeset_id`) REFERENCES `attributeset` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for attributevalue
-- ----------------------------
DROP TABLE IF EXISTS `attributevalue`;
CREATE TABLE `attributevalue`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `attribute_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `value` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `attval_att`(`attribute_id` ASC) USING BTREE,
  CONSTRAINT `attval_att` FOREIGN KEY (`attribute_id`) REFERENCES `attribute` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for breaks
-- ----------------------------
DROP TABLE IF EXISTS `breaks`;
CREATE TABLE `breaks`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `visible` tinyint(1) NOT NULL DEFAULT 1,
  `notes` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for cancel_reason
-- ----------------------------
DROP TABLE IF EXISTS `cancel_reason`;
CREATE TABLE `cancel_reason`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `payment_category_name_inx`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for cart
-- ----------------------------
DROP TABLE IF EXISTS `cart`;
CREATE TABLE `cart`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `customer_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `user_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `customer_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `total` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `subtotal` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `tax` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `discount` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `status` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT 'open',
  `notes` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `modified_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_customer`(`customer_id` ASC) USING BTREE,
  INDEX `idx_status`(`status` ASC) USING BTREE,
  INDEX `idx_created`(`created_date` ASC) USING BTREE,
  INDEX `idx_user`(`user_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for cart_payments
-- ----------------------------
DROP TABLE IF EXISTS `cart_payments`;
CREATE TABLE `cart_payments`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `cart_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `payment_method` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `amount` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `tendered` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `card_name` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `voucher_number` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `notes` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_cart_id`(`cart_id` ASC) USING BTREE,
  CONSTRAINT `fk_cart_payments` FOREIGN KEY (`cart_id`) REFERENCES `cart` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for cart_properties
-- ----------------------------
DROP TABLE IF EXISTS `cart_properties`;
CREATE TABLE `cart_properties`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `cart_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `property_key` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `property_value` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_cart_property`(`cart_id` ASC, `property_key` ASC) USING BTREE,
  INDEX `idx_cart_id`(`cart_id` ASC) USING BTREE,
  CONSTRAINT `fk_cart_properties` FOREIGN KEY (`cart_id`) REFERENCES `cart` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for cartlines
-- ----------------------------
DROP TABLE IF EXISTS `cartlines`;
CREATE TABLE `cartlines`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `cart_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `line_num` int NOT NULL DEFAULT 0,
  `line_number` int NOT NULL,
  `product_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `product_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `product_ref` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `product_code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `product_taxcategory` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `attributeset_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `unit_price` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `quantity` decimal(10, 3) NOT NULL DEFAULT 1.000,
  `price` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `discount` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `tax_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `tax_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `tax_rate` decimal(5, 2) NOT NULL DEFAULT 0.00,
  `attributes` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL,
  `tax_amount` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `subtotal` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `total` decimal(10, 2) NOT NULL DEFAULT 0.00,
  `properties` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL,
  `created_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `uk_cart_line`(`cart_id` ASC, `line_number` ASC) USING BTREE,
  INDEX `idx_cart_id`(`cart_id` ASC) USING BTREE,
  INDEX `idx_product_id`(`product_id` ASC) USING BTREE,
  CONSTRAINT `fk_cartlines_cart` FOREIGN KEY (`cart_id`) REFERENCES `cart` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for categories
-- ----------------------------
DROP TABLE IF EXISTS `categories`;
CREATE TABLE `categories`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `parentid` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `image` mediumblob NULL,
  `texttip` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `catshowname` smallint NOT NULL DEFAULT 1,
  `catorder` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `superid` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `profitability` smallint NOT NULL DEFAULT 0,
  `custombutton` bit(1) NOT NULL DEFAULT b'0',
  `bgcolor` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `fgcolor` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `fontname` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `fontsize` smallint NOT NULL DEFAULT 12,
  `fontstyle` smallint NOT NULL DEFAULT 0,
  `valign` smallint NOT NULL DEFAULT 0,
  `halign` smallint NOT NULL DEFAULT 0,
  `showname` bit(1) NOT NULL DEFAULT b'0',
  `showprice` bit(1) NOT NULL DEFAULT b'0',
  `showimage` bit(1) NOT NULL DEFAULT b'0',
  `ACTIVE` bit(1) NOT NULL DEFAULT b'0',
  `webimage` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `SYNC` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `categories_name_inx`(`name` ASC) USING BTREE,
  INDEX `categories_fk_1`(`parentid` ASC) USING BTREE,
  CONSTRAINT `categories_fk_1` FOREIGN KEY (`parentid`) REFERENCES `categories` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for closedcash
-- ----------------------------
DROP TABLE IF EXISTS `closedcash`;
CREATE TABLE `closedcash`  (
  `money` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `host` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `hostsequence` int NOT NULL,
  `datestart` datetime NOT NULL,
  `dateend` datetime NULL DEFAULT NULL,
  `nosales` int NOT NULL DEFAULT 0,
  `SYNC` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`money`) USING BTREE,
  UNIQUE INDEX `closedcash_inx_seq`(`host` ASC, `hostsequence` ASC) USING BTREE,
  INDEX `closedcash_inx_1`(`datestart` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for contacts
-- ----------------------------
DROP TABLE IF EXISTS `contacts`;
CREATE TABLE `contacts`  (
  `ID` int NOT NULL AUTO_INCREMENT,
  `PHONE` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `sync` int UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`ID`) USING BTREE,
  UNIQUE INDEX `Index_phone`(`PHONE` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for csvimport
-- ----------------------------
DROP TABLE IF EXISTS `csvimport`;
CREATE TABLE `csvimport`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `rownumber` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `csverror` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `reference` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `pricebuy` double NULL DEFAULT NULL,
  `pricesell` double NULL DEFAULT NULL,
  `previousbuy` double NULL DEFAULT NULL,
  `previoussell` double NULL DEFAULT NULL,
  `category` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `tax` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `searchkey` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for customer_addresses
-- ----------------------------
DROP TABLE IF EXISTS `customer_addresses`;
CREATE TABLE `customer_addresses`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `customer_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `address_line` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `country` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `town` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `street` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `building` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `floor` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `note` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `customer_fk`(`customer_id` ASC) USING BTREE,
  CONSTRAINT `customer_fk` FOREIGN KEY (`customer_id`) REFERENCES `customers` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB AUTO_INCREMENT = 15 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for customers
-- ----------------------------
DROP TABLE IF EXISTS `customers`;
CREATE TABLE `customers`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `searchkey` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `taxid` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `taxcategory` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `card` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `maxdebt` double NOT NULL DEFAULT 0,
  `address` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `address2` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `postal` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `city` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `region` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `country` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `firstname` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `lastname` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `phone2` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `fax` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `notes` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `visible` bit(1) NOT NULL DEFAULT b'1',
  `curdate` datetime NULL DEFAULT NULL,
  `curdebt` double NULL DEFAULT 0,
  `image` mediumblob NULL,
  `isvip` bit(1) NOT NULL DEFAULT b'0',
  `discount` double NULL DEFAULT 0,
  `memodate` datetime NULL DEFAULT '2000-01-01 00:00:01',
  `custommenu` bit(1) NOT NULL DEFAULT b'0',
  `cp` int NOT NULL DEFAULT 0,
  `cpunit` int NOT NULL DEFAULT 1,
  `subscriber` tinyint(1) NOT NULL DEFAULT 0,
  `sp` int NOT NULL DEFAULT 0,
  `spunit` int NOT NULL DEFAULT 1,
  `ss` date NULL DEFAULT NULL,
  `vipgroup` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `curpoints` double NULL DEFAULT 0,
  `address3` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `allergy` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `blacklist` bit(1) NOT NULL DEFAULT b'0',
  `blacklist_reason` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `birth_date` date NULL DEFAULT NULL,
  `SYNC` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `customers_skey_inx`(`searchkey` ASC) USING BTREE,
  INDEX `customers_card_inx`(`card` ASC) USING BTREE,
  INDEX `customers_name_inx`(`name` ASC) USING BTREE,
  INDEX `customers_taxcat`(`taxcategory` ASC) USING BTREE,
  INDEX `customers_taxid_inx`(`taxid` ASC) USING BTREE,
  CONSTRAINT `customers_taxcat` FOREIGN KEY (`taxcategory`) REFERENCES `taxcustcategories` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for deleted
-- ----------------------------
DROP TABLE IF EXISTS `deleted`;
CREATE TABLE `deleted`  (
  `table_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `sync` int UNSIGNED NOT NULL DEFAULT 0
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for departments
-- ----------------------------
DROP TABLE IF EXISTS `departments`;
CREATE TABLE `departments`  (
  `ID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `ACTIVE` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for designations
-- ----------------------------
DROP TABLE IF EXISTS `designations`;
CREATE TABLE `designations`  (
  `ID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `ACTIVE` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for drawer_reason
-- ----------------------------
DROP TABLE IF EXISTS `drawer_reason`;
CREATE TABLE `drawer_reason`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `drawer_reason_name_inx`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for draweropened
-- ----------------------------
DROP TABLE IF EXISTS `draweropened`;
CREATE TABLE `draweropened`  (
  `opendate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `reason` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `ticketid` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for employees
-- ----------------------------
DROP TABLE IF EXISTS `employees`;
CREATE TABLE `employees`  (
  `ID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `NO` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `DEPARTMENT` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `DESIGNATION` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `ADDRESS` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `MOBILE` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `HOURLY_RATE` double NOT NULL DEFAULT 0,
  `ACTIVE` bit(1) NOT NULL DEFAULT b'1',
  `SALESPERSON` bit(1) NOT NULL DEFAULT b'1',
  `DOB` datetime NULL DEFAULT NULL,
  `DOE` datetime NULL DEFAULT NULL,
  `SALARY` double NOT NULL DEFAULT 0,
  `MAX_DISCOUNT` double NOT NULL DEFAULT 0,
  `DRIVERPERSON` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`ID`) USING BTREE,
  INDEX `employees_fk_1`(`DEPARTMENT` ASC) USING BTREE,
  INDEX `employees_fk_2`(`DESIGNATION` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for expenses
-- ----------------------------
DROP TABLE IF EXISTS `expenses`;
CREATE TABLE `expenses`  (
  `ID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `TYPE` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `NO` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `REASON` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `AMOUNT` double NOT NULL DEFAULT 0,
  `datenew` datetime NOT NULL,
  `RECURRENT` bit(1) NOT NULL DEFAULT b'0',
  `CP` int NOT NULL DEFAULT 0,
  `CPUNIT` int NOT NULL DEFAULT 1,
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for floors
-- ----------------------------
DROP TABLE IF EXISTS `floors`;
CREATE TABLE `floors`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `image` mediumblob NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `floors_name_inx`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for happy_hour_categories
-- ----------------------------
DROP TABLE IF EXISTS `happy_hour_categories`;
CREATE TABLE `happy_hour_categories`  (
  `ID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `CATEGORY` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `HAPPY_HOUR` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `RATE` double NULL DEFAULT NULL,
  `EXTRA` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`ID`) USING BTREE,
  UNIQUE INDEX `Index_4`(`CATEGORY` ASC, `HAPPY_HOUR` ASC) USING BTREE,
  INDEX `HAPPY_HOUR_CATEGORIES_FK_1`(`CATEGORY` ASC) USING BTREE,
  INDEX `HAPPY_HOUR_CATEGORIES_FK_2`(`HAPPY_HOUR` ASC) USING BTREE,
  CONSTRAINT `HAPPY_HOUR_CATEGORIES_FK_1` FOREIGN KEY (`CATEGORY`) REFERENCES `categories` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `HAPPY_HOUR_CATEGORIES_FK_2` FOREIGN KEY (`HAPPY_HOUR`) REFERENCES `happy_hours` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for happy_hour_products
-- ----------------------------
DROP TABLE IF EXISTS `happy_hour_products`;
CREATE TABLE `happy_hour_products`  (
  `ID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `PRODUCT` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `HAPPY_HOUR` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `RATE` double NULL DEFAULT NULL,
  `EXTRA` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`ID`) USING BTREE,
  UNIQUE INDEX `Index_4`(`PRODUCT` ASC, `HAPPY_HOUR` ASC) USING BTREE,
  INDEX `HAPPY_HOUR_PRODUCTS_FK_1`(`PRODUCT` ASC) USING BTREE,
  INDEX `HAPPY_HOUR_PRODUCTS_FK_2`(`HAPPY_HOUR` ASC) USING BTREE,
  CONSTRAINT `HAPPY_HOUR_PRODUCTS_FK_1` FOREIGN KEY (`PRODUCT`) REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `HAPPY_HOUR_PRODUCTS_FK_2` FOREIGN KEY (`HAPPY_HOUR`) REFERENCES `happy_hours` (`ID`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for happy_hours
-- ----------------------------
DROP TABLE IF EXISTS `happy_hours`;
CREATE TABLE `happy_hours`  (
  `ID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `RATE` double NULL DEFAULT NULL,
  `SELECTION_TYPE` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `START_HOUR` int NULL DEFAULT NULL,
  `START_MINUTE` int NULL DEFAULT NULL,
  `END_HOUR` int NULL DEFAULT NULL,
  `END_MINUTE` int NULL DEFAULT NULL,
  `ACTIVE` bit(1) NOT NULL DEFAULT b'0',
  `EXTRA` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `START_DATE` date NOT NULL,
  `END_DATE` date NOT NULL,
  `SUN` bit(1) NOT NULL DEFAULT b'0',
  `MON` bit(1) NOT NULL DEFAULT b'0',
  `TUE` bit(1) NOT NULL DEFAULT b'0',
  `WED` bit(1) NOT NULL DEFAULT b'0',
  `THU` bit(1) NOT NULL DEFAULT b'0',
  `FRI` bit(1) NOT NULL DEFAULT b'0',
  `SAT` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for kitchen_notes
-- ----------------------------
DROP TABLE IF EXISTS `kitchen_notes`;
CREATE TABLE `kitchen_notes`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `kitchen_notes_name_inx`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for leaves
-- ----------------------------
DROP TABLE IF EXISTS `leaves`;
CREATE TABLE `leaves`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `pplid` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `startdate` datetime NOT NULL,
  `enddate` datetime NOT NULL,
  `notes` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `leaves_pplid`(`pplid` ASC) USING BTREE,
  CONSTRAINT `leaves_pplid` FOREIGN KEY (`pplid`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for lineremoved
-- ----------------------------
DROP TABLE IF EXISTS `lineremoved`;
CREATE TABLE `lineremoved`  (
  `removeddate` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `ticketid` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `productid` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `productname` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `units` double NOT NULL,
  `ticket` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `SYNC` bit(1) NOT NULL DEFAULT b'0',
  `ID` int UNSIGNED NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`ID`) USING BTREE,
  UNIQUE INDEX `Index_5`(`ID` ASC) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for locations
-- ----------------------------
DROP TABLE IF EXISTS `locations`;
CREATE TABLE `locations`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `address` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `locations_name_inx`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for moorers
-- ----------------------------
DROP TABLE IF EXISTS `moorers`;
CREATE TABLE `moorers`  (
  `vesselname` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `size` int NULL DEFAULT NULL,
  `days` int NULL DEFAULT NULL,
  `power` bit(1) NOT NULL DEFAULT b'0'
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for orderdiary
-- ----------------------------
DROP TABLE IF EXISTS `orderdiary`;
CREATE TABLE `orderdiary`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `datenew` datetime NOT NULL,
  `reason` int NOT NULL,
  `location` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `product` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `attributesetinstance_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `units` double NOT NULL,
  `price` double NOT NULL,
  `appuser` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `supplier` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `supplierdoc` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `po` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `orderdiary_attsetinst`(`attributesetinstance_id` ASC) USING BTREE,
  INDEX `orderdiary_fk_1`(`product` ASC) USING BTREE,
  INDEX `orderdiary_fk_2`(`location` ASC) USING BTREE,
  INDEX `orderdiary_inx_1`(`datenew` ASC) USING BTREE,
  INDEX `orderdiary_fk_3`(`po` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for orders
-- ----------------------------
DROP TABLE IF EXISTS `orders`;
CREATE TABLE `orders`  (
  `id` mediumint NOT NULL AUTO_INCREMENT,
  `orderid` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `qty` int NULL DEFAULT 1,
  `details` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `attributes` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `notes` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `ticketid` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `ordertime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `displayid` int NULL DEFAULT 1,
  `auxiliary` int NULL DEFAULT NULL,
  `completetime` timestamp NULL DEFAULT NULL,
  `displays` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `status` int NULL DEFAULT 0,
  `product` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `line` int NULL DEFAULT 0,
  `processtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 2 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for payment_category
-- ----------------------------
DROP TABLE IF EXISTS `payment_category`;
CREATE TABLE `payment_category`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `ref` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `payment_category_name_inx`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for payments
-- ----------------------------
DROP TABLE IF EXISTS `payments`;
CREATE TABLE `payments`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `receipt` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `payment` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `total` double NOT NULL DEFAULT 0,
  `tip` double NULL DEFAULT 0,
  `transid` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `isprocessed` bit(1) NULL DEFAULT b'0',
  `returnmsg` mediumblob NULL,
  `notes` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `tendered` double NULL DEFAULT NULL,
  `cardname` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `voucher` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `payment_category` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `supplier` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `ref` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `settled` double NOT NULL DEFAULT 0,
  `payable_date` date NULL DEFAULT NULL,
  `seen` tinyint UNSIGNED NOT NULL DEFAULT 0,
  `currency` int NULL DEFAULT 0,
  `currency_format` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '',
  `currency_rate` double NOT NULL DEFAULT 1,
  `currency_amount` double NOT NULL DEFAULT 0,
  `SYNC` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `payments_fk_receipt`(`receipt` ASC) USING BTREE,
  INDEX `payments_inx_1`(`payment` ASC) USING BTREE,
  CONSTRAINT `payments_fk_receipt` FOREIGN KEY (`receipt`) REFERENCES `receipts` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for people
-- ----------------------------
DROP TABLE IF EXISTS `people`;
CREATE TABLE `people`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `apppassword` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `card` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `role` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `visible` bit(1) NOT NULL,
  `image` mediumblob NULL,
  `userid` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `MAX_DISCOUNT` double NOT NULL DEFAULT 0,
  `SYNC` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `people_name_inx`(`name` ASC) USING BTREE,
  INDEX `people_card_inx`(`card` ASC) USING BTREE,
  INDEX `people_fk_1`(`role` ASC) USING BTREE,
  CONSTRAINT `people_fk_1` FOREIGN KEY (`role`) REFERENCES `roles` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for pickup_number
-- ----------------------------
DROP TABLE IF EXISTS `pickup_number`;
CREATE TABLE `pickup_number`  (
  `id` int NOT NULL DEFAULT 0
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for places
-- ----------------------------
DROP TABLE IF EXISTS `places`;
CREATE TABLE `places`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `seats` varchar(6) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '1',
  `x` int NOT NULL,
  `y` int NOT NULL,
  `floor` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `customer` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `waiter` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `ticketid` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `tablemoved` smallint NOT NULL DEFAULT 0,
  `width` int NOT NULL,
  `height` int NOT NULL,
  `guests` int NULL DEFAULT 0,
  `occupied` datetime NULL DEFAULT NULL,
  `ready` smallint NOT NULL DEFAULT 0,
  `employee` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `qr_code_id` char(36) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `sync` bit(1) NULL DEFAULT b'0',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `places_name_inx`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for price_levels
-- ----------------------------
DROP TABLE IF EXISTS `price_levels`;
CREATE TABLE `price_levels`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `ORDER_NO` int UNSIGNED NOT NULL,
  `active` tinyint UNSIGNED NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for product_sku_selection
-- ----------------------------
DROP TABLE IF EXISTS `product_sku_selection`;
CREATE TABLE `product_sku_selection`  (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `product_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `sku_value_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `sku_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `sku_value_id`(`sku_value_id` ASC) USING BTREE,
  INDEX `sku_id`(`sku_id` ASC) USING BTREE,
  CONSTRAINT `product_sku_selection_ibfk_1` FOREIGN KEY (`sku_value_id`) REFERENCES `sku_value` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `product_sku_selection_ibfk_2` FOREIGN KEY (`sku_id`) REFERENCES `sku_products` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for production_batch_ingredients
-- ----------------------------
DROP TABLE IF EXISTS `production_batch_ingredients`;
CREATE TABLE `production_batch_ingredients`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `batch_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `product_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `quantity_used` decimal(12, 3) NOT NULL,
  `cost` decimal(12, 3) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `batch_ing_fk`(`batch_id` ASC) USING BTREE,
  INDEX `product_batch_ing_fk`(`product_id` ASC) USING BTREE,
  CONSTRAINT `batch_ing_fk` FOREIGN KEY (`batch_id`) REFERENCES `production_batches` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `product_batch_ing_fk` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for production_batch_products
-- ----------------------------
DROP TABLE IF EXISTS `production_batch_products`;
CREATE TABLE `production_batch_products`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `batch_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `product_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `quantity_produced` decimal(12, 3) NOT NULL,
  `waste` decimal(12, 3) NOT NULL DEFAULT 0.000,
  `expiry_date` datetime NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `batch_prod_fk`(`batch_id` ASC) USING BTREE,
  INDEX `product_batch_prod_fk`(`product_id` ASC) USING BTREE,
  CONSTRAINT `batch_prod_fk` FOREIGN KEY (`batch_id`) REFERENCES `production_batches` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `product_batch_prod_fk` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for production_batches
-- ----------------------------
DROP TABLE IF EXISTS `production_batches`;
CREATE TABLE `production_batches`  (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `recipe_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `location` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `lot_number` int NOT NULL,
  `production_date` datetime NOT NULL,
  `total_cost` decimal(12, 3) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `recipe_fk`(`recipe_id` ASC) USING BTREE,
  CONSTRAINT `recipe_fk` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for products
-- ----------------------------
DROP TABLE IF EXISTS `products`;
CREATE TABLE `products`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `reference` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `code` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `codetype` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `pricebuy` double NOT NULL DEFAULT 0,
  `pricesell` double NOT NULL DEFAULT 0,
  `category` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `taxcat` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `attributeset_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `stockcost` double NOT NULL DEFAULT 0,
  `stockvolume` double NOT NULL DEFAULT 0,
  `image` mediumblob NULL,
  `iscom` bit(1) NOT NULL DEFAULT b'0',
  `isscale` bit(1) NOT NULL DEFAULT b'0',
  `isconstant` bit(1) NOT NULL DEFAULT b'0',
  `printkb` bit(1) NOT NULL DEFAULT b'0',
  `sendstatus` bit(1) NOT NULL DEFAULT b'0',
  `isservice` bit(1) NOT NULL DEFAULT b'0',
  `attributes` mediumblob NULL,
  `display` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `isvprice` smallint NOT NULL DEFAULT 0,
  `isverpatrib` smallint NOT NULL DEFAULT 0,
  `texttip` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `warranty` smallint NOT NULL DEFAULT 0,
  `stockunits` double NOT NULL DEFAULT 0,
  `printto` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '1',
  `supplier` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `uom` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '0',
  `memodate` datetime NULL DEFAULT '2018-01-01 00:00:01',
  `displays` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `ingredient` smallint NOT NULL DEFAULT 0,
  `uoc` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '0',
  `uocrate` smallint NOT NULL DEFAULT 1,
  `auxcount` smallint NOT NULL DEFAULT 0,
  `auxmand` bit(1) NOT NULL DEFAULT b'0',
  `code1` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `code2` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `code3` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `code4` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `code5` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `code6` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `code7` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `code8` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `code9` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `code10` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `custombutton` bit(1) NOT NULL DEFAULT b'0',
  `bgcolor` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `fgcolor` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `fontname` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `fontsize` smallint NOT NULL DEFAULT 12,
  `fontstyle` smallint NOT NULL DEFAULT 0,
  `valign` smallint NOT NULL DEFAULT 0,
  `halign` smallint NOT NULL DEFAULT 0,
  `showname` bit(1) NOT NULL DEFAULT b'0',
  `showprice` bit(1) NOT NULL DEFAULT b'0',
  `showimage` bit(1) NOT NULL DEFAULT b'0',
  `ACTIVE` bit(1) NOT NULL DEFAULT b'1',
  `webdescription` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `webprice` double NOT NULL DEFAULT 0,
  `webimage` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `tag` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `pricebying` bit(1) NOT NULL DEFAULT b'0',
  `yield_percentage` decimal(5, 2) NOT NULL DEFAULT 100.00,
  `Alias_Name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `enableAlias` tinyint(1) NULL DEFAULT 0,
  `is_rentable` bit(1) NULL DEFAULT b'0',
  `rent_time_unit` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `rent_rate` decimal(12, 3) NULL DEFAULT NULL,
  `skuReference` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `minDiscount` decimal(10, 2) NULL DEFAULT NULL,
  `discountEnabled` bit(1) NOT NULL DEFAULT b'1',
  `discountbelowBuyPriceEnabled` bit(1) NOT NULL DEFAULT b'1',
  `SYNC` bit(1) NOT NULL DEFAULT b'0',
  `imageweb` mediumblob NULL,
  `sort_order` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `products_inx_0`(`reference` ASC) USING BTREE,
  UNIQUE INDEX `products_inx_1`(`code` ASC) USING BTREE,
  INDEX `products_attrset_fx`(`attributeset_id` ASC) USING BTREE,
  INDEX `products_fk_1`(`category` ASC) USING BTREE,
  INDEX `products_name_inx`(`name` ASC) USING BTREE,
  INDEX `products_taxcat_fk`(`taxcat` ASC) USING BTREE,
  CONSTRAINT `products_attrset_fk` FOREIGN KEY (`attributeset_id`) REFERENCES `attributeset` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `products_fk_1` FOREIGN KEY (`category`) REFERENCES `categories` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `products_taxcat_fk` FOREIGN KEY (`taxcat`) REFERENCES `taxcategories` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for products_bundle
-- ----------------------------
DROP TABLE IF EXISTS `products_bundle`;
CREATE TABLE `products_bundle`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `product` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `product_bundle` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `quantity` double NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `pbundle_inx_prod`(`product` ASC, `product_bundle` ASC) USING BTREE,
  INDEX `products_bundle_fk_2`(`product_bundle` ASC) USING BTREE,
  CONSTRAINT `products_bundle_fk_1` FOREIGN KEY (`product`) REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `products_bundle_fk_2` FOREIGN KEY (`product_bundle`) REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for products_cat
-- ----------------------------
DROP TABLE IF EXISTS `products_cat`;
CREATE TABLE `products_cat`  (
  `product` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `catorder` int NULL DEFAULT NULL,
  PRIMARY KEY (`product`) USING BTREE,
  INDEX `products_cat_inx_1`(`catorder` ASC) USING BTREE,
  CONSTRAINT `products_cat_fk_1` FOREIGN KEY (`product`) REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for products_com
-- ----------------------------
DROP TABLE IF EXISTS `products_com`;
CREATE TABLE `products_com`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `product` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `product2` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `pcom_inx_prod`(`product` ASC, `product2` ASC) USING BTREE,
  INDEX `products_com_fk_2`(`product2` ASC) USING BTREE,
  CONSTRAINT `products_com_fk_1` FOREIGN KEY (`product`) REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `products_com_fk_2` FOREIGN KEY (`product2`) REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for products_ing
-- ----------------------------
DROP TABLE IF EXISTS `products_ing`;
CREATE TABLE `products_ing`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `product` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `product2` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `qty` double NOT NULL,
  `cost` double NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `ping_inx_prod`(`product` ASC, `product2` ASC) USING BTREE,
  INDEX `products_ing_fk_2`(`product2` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for products_prices
-- ----------------------------
DROP TABLE IF EXISTS `products_prices`;
CREATE TABLE `products_prices`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `product` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `code` varchar(50) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '0',
  `conditions` varchar(500) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `price` double NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for purchaseorder
-- ----------------------------
DROP TABLE IF EXISTS `purchaseorder`;
CREATE TABLE `purchaseorder`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `datenew` datetime NOT NULL,
  `appuser` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `supplier` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `supplierdoc` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `processed` tinyint UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `purchaseorder_inx_1`(`datenew` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for qr_order_items
-- ----------------------------
DROP TABLE IF EXISTS `qr_order_items`;
CREATE TABLE `qr_order_items`  (
  `id` int NOT NULL,
  `order_id` int NULL DEFAULT NULL,
  `item_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `variation` int NULL DEFAULT NULL,
  `quantity` int NOT NULL DEFAULT 1,
  `price` double NOT NULL DEFAULT 0,
  `notes` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT '',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for qr_orders
-- ----------------------------
DROP TABLE IF EXISTS `qr_orders`;
CREATE TABLE `qr_orders`  (
  `id` int NOT NULL,
  `restaurant_id` int NULL DEFAULT NULL,
  `customer_name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `customer_address` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `customer_tp` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `table_number` int NULL DEFAULT NULL,
  `status` enum('pending','completed') CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT 'pending',
  `message` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `seen` tinyint(1) NOT NULL DEFAULT 0,
  `created_at` datetime NULL DEFAULT NULL,
  `table_ID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for receipts
-- ----------------------------
DROP TABLE IF EXISTS `receipts`;
CREATE TABLE `receipts`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `money` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `datenew` datetime NOT NULL,
  `attributes` mediumblob NULL,
  `person` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `SYNC` bit(1) NOT NULL DEFAULT b'0',
  `telegramstatus` int NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `receipts_fk_money`(`money` ASC) USING BTREE,
  INDEX `receipts_inx_1`(`datenew` ASC) USING BTREE,
  CONSTRAINT `receipts_fk_money` FOREIGN KEY (`money`) REFERENCES `closedcash` (`money`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for recipe_ingredients
-- ----------------------------
DROP TABLE IF EXISTS `recipe_ingredients`;
CREATE TABLE `recipe_ingredients`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `recipe_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `product_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `amount` decimal(12, 3) NOT NULL,
  `quantity` decimal(12, 3) NOT NULL,
  `total_cost` decimal(12, 3) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `product_fk`(`product_id` ASC) USING BTREE,
  INDEX `recipe_ing`(`recipe_id` ASC) USING BTREE,
  CONSTRAINT `product_fk` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `recipe_ing` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 27 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for recipe_products
-- ----------------------------
DROP TABLE IF EXISTS `recipe_products`;
CREATE TABLE `recipe_products`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `recipe_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `product_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `quantity` decimal(12, 3) NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `product_recipe_prod_fk`(`product_id` ASC) USING BTREE,
  INDEX `recipe_prod`(`recipe_id` ASC) USING BTREE,
  CONSTRAINT `product_recipe_prod_fk` FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `recipe_prod` FOREIGN KEY (`recipe_id`) REFERENCES `recipes` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 24 CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for recipes
-- ----------------------------
DROP TABLE IF EXISTS `recipes`;
CREATE TABLE `recipes`  (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `title` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `image` mediumblob NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL,
  `duration_hour` int NOT NULL DEFAULT 0,
  `duration_minute` int NOT NULL DEFAULT 0,
  `additional_costs` double NULL DEFAULT 0,
  `total_cost` decimal(12, 3) NOT NULL DEFAULT 0.000,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for rent
-- ----------------------------
DROP TABLE IF EXISTS `rent`;
CREATE TABLE `rent`  (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `ticketline_id` int UNSIGNED NOT NULL,
  `rate` decimal(12, 3) NOT NULL,
  `start_time` datetime NOT NULL,
  `end_time` datetime NULL DEFAULT NULL,
  `timer_mode` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `timer_duration` bigint NULL DEFAULT NULL,
  `time_unit` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `is_returned` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_rent_ticketline`(`ticketline_id` ASC) USING BTREE,
  CONSTRAINT `fk_rent_ticketline` FOREIGN KEY (`ticketline_id`) REFERENCES `ticketlines` (`ID`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for reservation_customers
-- ----------------------------
DROP TABLE IF EXISTS `reservation_customers`;
CREATE TABLE `reservation_customers`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `customer` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `res_cust_fk_2`(`customer` ASC) USING BTREE,
  CONSTRAINT `res_cust_fk_1` FOREIGN KEY (`id`) REFERENCES `reservations` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `res_cust_fk_2` FOREIGN KEY (`customer`) REFERENCES `customers` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for reservations
-- ----------------------------
DROP TABLE IF EXISTS `reservations`;
CREATE TABLE `reservations`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `created` datetime NOT NULL,
  `datenew` datetime NOT NULL DEFAULT '2018-01-01 00:00:00',
  `title` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `chairs` int NOT NULL,
  `isdone` bit(1) NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `reservations_inx_1`(`datenew` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for resources
-- ----------------------------
DROP TABLE IF EXISTS `resources`;
CREATE TABLE `resources`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `restype` int NOT NULL,
  `content` mediumblob NULL,
  `version` varchar(10) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `resources_name_inx`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for roles
-- ----------------------------
DROP TABLE IF EXISTS `roles`;
CREATE TABLE `roles`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `permissions` mediumblob NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `roles_name_inx`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sharedtickets
-- ----------------------------
DROP TABLE IF EXISTS `sharedtickets`;
CREATE TABLE `sharedtickets`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `cart_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `appuser` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `pickupid` int NOT NULL DEFAULT 0,
  `locked` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `ticket_type` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT 'general',
  `ticket_no` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `idx_cart_id`(`cart_id` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for shift_breaks
-- ----------------------------
DROP TABLE IF EXISTS `shift_breaks`;
CREATE TABLE `shift_breaks`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `shiftid` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `breakid` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `starttime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `endtime` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `shift_breaks_breakid`(`breakid` ASC) USING BTREE,
  INDEX `shift_breaks_shiftid`(`shiftid` ASC) USING BTREE,
  CONSTRAINT `shift_breaks_breakid` FOREIGN KEY (`breakid`) REFERENCES `breaks` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `shift_breaks_shiftid` FOREIGN KEY (`shiftid`) REFERENCES `shifts` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for shifts
-- ----------------------------
DROP TABLE IF EXISTS `shifts`;
CREATE TABLE `shifts`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `startshift` datetime NOT NULL,
  `endshift` datetime NULL DEFAULT NULL,
  `pplid` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for sku_category
-- ----------------------------
DROP TABLE IF EXISTS `sku_category`;
CREATE TABLE `sku_category`  (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `char_limit` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sku_products
-- ----------------------------
DROP TABLE IF EXISTS `sku_products`;
CREATE TABLE `sku_products`  (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `product_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `sku` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `count` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for sku_value
-- ----------------------------
DROP TABLE IF EXISTS `sku_value`;
CREATE TABLE `sku_value`  (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `category_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `value_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `alphanumeric_code` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `category_id`(`category_id` ASC) USING BTREE,
  CONSTRAINT `sku_value_ibfk_1` FOREIGN KEY (`category_id`) REFERENCES `sku_category` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for stockcurrent
-- ----------------------------
DROP TABLE IF EXISTS `stockcurrent`;
CREATE TABLE `stockcurrent`  (
  `location` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `product` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `attributesetinstance_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `units` double NOT NULL,
  `seen` tinyint UNSIGNED NOT NULL DEFAULT 0,
  `SYNC` bit(1) NOT NULL DEFAULT b'0',
  `ID` int UNSIGNED NOT NULL AUTO_INCREMENT,
  UNIQUE INDEX `Index_5`(`ID` ASC) USING BTREE,
  UNIQUE INDEX `stockcurrent_inx`(`location` ASC, `product` ASC, `attributesetinstance_id` ASC) USING BTREE,
  INDEX `stockcurrent_attsetinst`(`attributesetinstance_id` ASC) USING BTREE,
  INDEX `stockcurrent_fk_1`(`product` ASC) USING BTREE,
  CONSTRAINT `stockcurrent_attsetinst` FOREIGN KEY (`attributesetinstance_id`) REFERENCES `attributesetinstance` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `stockcurrent_fk_1` FOREIGN KEY (`product`) REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `stockcurrent_fk_2` FOREIGN KEY (`location`) REFERENCES `locations` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 53 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for stockdiary
-- ----------------------------
DROP TABLE IF EXISTS `stockdiary`;
CREATE TABLE `stockdiary`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `datenew` datetime NOT NULL,
  `reason` int NOT NULL,
  `location` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `product` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `attributesetinstance_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `units` double NOT NULL,
  `price` double NOT NULL,
  `appuser` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `supplier` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `supplierdoc` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `product2` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `expire_date` date NULL DEFAULT NULL,
  `used` double NULL DEFAULT 0,
  `seen` tinyint UNSIGNED NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `stockdiary_attsetinst`(`attributesetinstance_id` ASC) USING BTREE,
  INDEX `stockdiary_fk_1`(`product` ASC) USING BTREE,
  INDEX `stockdiary_fk_2`(`location` ASC) USING BTREE,
  INDEX `stockdiary_inx_1`(`datenew` ASC) USING BTREE,
  CONSTRAINT `stockdiary_attsetinst` FOREIGN KEY (`attributesetinstance_id`) REFERENCES `attributesetinstance` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `stockdiary_fk_1` FOREIGN KEY (`product`) REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `stockdiary_fk_2` FOREIGN KEY (`location`) REFERENCES `locations` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for stocklevel
-- ----------------------------
DROP TABLE IF EXISTS `stocklevel`;
CREATE TABLE `stocklevel`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `location` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `product` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `stocksecurity` double NULL DEFAULT NULL,
  `stockmaximum` double NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `stocklevel_location`(`location` ASC) USING BTREE,
  INDEX `stocklevel_product`(`product` ASC) USING BTREE,
  CONSTRAINT `stocklevel_location` FOREIGN KEY (`location`) REFERENCES `locations` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `stocklevel_product` FOREIGN KEY (`product`) REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for suppliers
-- ----------------------------
DROP TABLE IF EXISTS `suppliers`;
CREATE TABLE `suppliers`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `searchkey` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `taxid` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `maxdebt` double NOT NULL DEFAULT 0,
  `address` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `address2` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `postal` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `city` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `region` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `country` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `firstname` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `lastname` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `phone` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `phone2` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `fax` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `notes` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `visible` bit(1) NOT NULL DEFAULT b'1',
  `curdate` datetime NULL DEFAULT NULL,
  `curdebt` double NOT NULL DEFAULT 0,
  `vatid` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `cp` int NOT NULL DEFAULT 0,
  `cpunit` int NOT NULL DEFAULT 1,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `suppliers_skey_inx`(`searchkey` ASC) USING BTREE,
  INDEX `suppliers_name_inx`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for taxcategories
-- ----------------------------
DROP TABLE IF EXISTS `taxcategories`;
CREATE TABLE `taxcategories`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `superid` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `SYNC` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `taxcat_name_inx`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for taxcustcategories
-- ----------------------------
DROP TABLE IF EXISTS `taxcustcategories`;
CREATE TABLE `taxcustcategories`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `taxcustcat_name_inx`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for taxes
-- ----------------------------
DROP TABLE IF EXISTS `taxes`;
CREATE TABLE `taxes`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `category` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `custcategory` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `parentid` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `rate` double NOT NULL DEFAULT 0,
  `ratecascade` bit(1) NOT NULL DEFAULT b'0',
  `rateorder` int NULL DEFAULT NULL,
  `SYNC` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `taxes_name_inx`(`name` ASC) USING BTREE,
  INDEX `taxes_cat_fk`(`category` ASC) USING BTREE,
  INDEX `taxes_custcat_fk`(`custcategory` ASC) USING BTREE,
  INDEX `taxes_taxes_fk`(`parentid` ASC) USING BTREE,
  CONSTRAINT `taxes_cat_fk` FOREIGN KEY (`category`) REFERENCES `taxcategories` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `taxes_custcat_fk` FOREIGN KEY (`custcategory`) REFERENCES `taxcustcategories` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `taxes_taxes_fk` FOREIGN KEY (`parentid`) REFERENCES `taxes` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for taxlines
-- ----------------------------
DROP TABLE IF EXISTS `taxlines`;
CREATE TABLE `taxlines`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `receipt` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `taxid` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `base` double NOT NULL DEFAULT 0,
  `amount` double NOT NULL DEFAULT 0,
  `SYNC` bit(1) NOT NULL DEFAULT b'0',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `taxlines_receipt`(`receipt` ASC) USING BTREE,
  INDEX `taxlines_tax`(`taxid` ASC) USING BTREE,
  CONSTRAINT `taxlines_receipt` FOREIGN KEY (`receipt`) REFERENCES `receipts` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `taxlines_tax` FOREIGN KEY (`taxid`) REFERENCES `taxes` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for taxsuppcategories
-- ----------------------------
DROP TABLE IF EXISTS `taxsuppcategories`;
CREATE TABLE `taxsuppcategories`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for thirdparties
-- ----------------------------
DROP TABLE IF EXISTS `thirdparties`;
CREATE TABLE `thirdparties`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `cif` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `address` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `contactcomm` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `contactfact` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `payrule` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `faxnumber` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `phonenumber` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `mobilenumber` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `email` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `webpage` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `notes` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `thirdparties_cif_inx`(`cif` ASC) USING BTREE,
  UNIQUE INDEX `thirdparties_name_inx`(`name` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for ticket_dispatch
-- ----------------------------
DROP TABLE IF EXISTS `ticket_dispatch`;
CREATE TABLE `ticket_dispatch`  (
  `id` int UNSIGNED NOT NULL AUTO_INCREMENT,
  `ticket_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `employee_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `dispatched_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `delivery_status` int UNSIGNED NOT NULL DEFAULT 0,
  `delivered_at` timestamp NULL DEFAULT NULL,
  `settle_status` int UNSIGNED NOT NULL DEFAULT 0,
  `settled_at` timestamp NULL DEFAULT NULL,
  `current_location_long` double NOT NULL DEFAULT 0,
  `current_location_lat` double NOT NULL DEFAULT 0,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `delivered_to` text CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `delivery_location_long` double NOT NULL DEFAULT 0,
  `delivery_location_lat` double NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ticketlines
-- ----------------------------
DROP TABLE IF EXISTS `ticketlines`;
CREATE TABLE `ticketlines`  (
  `ticket` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `line` int NOT NULL,
  `product` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `attributesetinstance_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `units` double NOT NULL,
  `price` double NOT NULL,
  `taxid` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `attributes` mediumblob NULL,
  `stockdiary_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `ss` date NULL DEFAULT NULL,
  `se` date NULL DEFAULT NULL,
  `seen` tinyint UNSIGNED NOT NULL DEFAULT 0,
  `price_level` int UNSIGNED NOT NULL DEFAULT 0,
  `sku` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `SYNC` bit(1) NOT NULL DEFAULT b'0',
  `ID` int UNSIGNED NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`ticket`, `line`) USING BTREE,
  UNIQUE INDEX `Index_5`(`ID` ASC) USING BTREE,
  INDEX `ticketlines_attsetinst`(`attributesetinstance_id` ASC) USING BTREE,
  INDEX `ticketlines_fk_2`(`product` ASC) USING BTREE,
  INDEX `ticketlines_fk_3`(`taxid` ASC) USING BTREE,
  CONSTRAINT `ticketlines_attsetinst` FOREIGN KEY (`attributesetinstance_id`) REFERENCES `attributesetinstance` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ticketlines_fk_2` FOREIGN KEY (`product`) REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ticketlines_fk_3` FOREIGN KEY (`taxid`) REFERENCES `taxes` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `ticketlines_fk_ticket` FOREIGN KEY (`ticket`) REFERENCES `tickets` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB AUTO_INCREMENT = 14 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for ticketlines_stockdiary
-- ----------------------------
DROP TABLE IF EXISTS `ticketlines_stockdiary`;
CREATE TABLE `ticketlines_stockdiary`  (
  `id` int NOT NULL AUTO_INCREMENT,
  `stockdiary_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `ticket_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `line` int NULL DEFAULT 0,
  `used` double NULL DEFAULT 0,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB AUTO_INCREMENT = 1 CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for ticketlinesm
-- ----------------------------
DROP TABLE IF EXISTS `ticketlinesm`;
CREATE TABLE `ticketlinesm`  (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `ticketId` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `pid` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `quantity` double NOT NULL,
  `unitPrice` double NOT NULL,
  `vat` double NOT NULL,
  `total` double NOT NULL,
  `maxLevel` double NOT NULL,
  `minLevel` double NOT NULL,
  `expiringDate` date NULL DEFAULT NULL,
  `transferId` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `discount` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `discountValue` decimal(10, 2) NULL DEFAULT NULL,
  `yield_percentage` decimal(5, 2) NOT NULL DEFAULT 100.00,
  `creation_date` datetime NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `ticketId`(`ticketId` ASC) USING BTREE,
  INDEX `pid`(`pid` ASC) USING BTREE,
  CONSTRAINT `ticketlinesm_ibfk_1` FOREIGN KEY (`ticketId`) REFERENCES `ticketsm` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT,
  CONSTRAINT `ticketlinesm_ibfk_2` FOREIGN KEY (`pid`) REFERENCES `products` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for tickets
-- ----------------------------
DROP TABLE IF EXISTS `tickets`;
CREATE TABLE `tickets`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `tickettype` int NOT NULL DEFAULT 0,
  `ticketid` int NOT NULL,
  `person` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `customer` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `status` int NOT NULL DEFAULT 0,
  `salesid` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `salesname` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `guests` int NOT NULL DEFAULT 0,
  `ticket_type` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT 'general',
  `ticket_no` varchar(20) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL DEFAULT '',
  `SYNC` bit(1) NOT NULL DEFAULT b'0',
  `place_id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `tickets_customers_fk`(`customer` ASC) USING BTREE,
  INDEX `tickets_fk_2`(`person` ASC) USING BTREE,
  INDEX `tickets_ticketid`(`tickettype` ASC, `ticketid` ASC) USING BTREE,
  INDEX `fk_place_id`(`place_id` ASC) USING BTREE,
  CONSTRAINT `fk_place_id` FOREIGN KEY (`place_id`) REFERENCES `places` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `tickets_customers_fk` FOREIGN KEY (`customer`) REFERENCES `customers` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `tickets_fk_2` FOREIGN KEY (`person`) REFERENCES `people` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `tickets_fk_id` FOREIGN KEY (`id`) REFERENCES `receipts` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for ticketsm
-- ----------------------------
DROP TABLE IF EXISTS `ticketsm`;
CREATE TABLE `ticketsm`  (
  `id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NOT NULL,
  `reason` int NOT NULL,
  `locationId` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `locationIdDes` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `supplierId` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `document` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci NULL DEFAULT NULL,
  `date` date NULL DEFAULT NULL,
  `isSettled` bit(1) NULL DEFAULT b'0',
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `fk_location`(`locationId` ASC) USING BTREE,
  INDEX `fk_supplier`(`supplierId` ASC) USING BTREE,
  CONSTRAINT `fk_location` FOREIGN KEY (`locationId`) REFERENCES `locations` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT,
  CONSTRAINT `fk_supplier` FOREIGN KEY (`supplierId`) REFERENCES `suppliers` (`id`) ON DELETE RESTRICT ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_0900_ai_ci ROW_FORMAT = Dynamic;

-- ----------------------------
-- Table structure for ticketsnum
-- ----------------------------
DROP TABLE IF EXISTS `ticketsnum`;
CREATE TABLE `ticketsnum`  (
  `id` int NOT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for ticketsnum_payment
-- ----------------------------
DROP TABLE IF EXISTS `ticketsnum_payment`;
CREATE TABLE `ticketsnum_payment`  (
  `id` int NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for ticketsnum_refund
-- ----------------------------
DROP TABLE IF EXISTS `ticketsnum_refund`;
CREATE TABLE `ticketsnum_refund`  (
  `id` int NOT NULL
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for uom
-- ----------------------------
DROP TABLE IF EXISTS `uom`;
CREATE TABLE `uom`  (
  `id` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for vehicles
-- ----------------------------
DROP TABLE IF EXISTS `vehicles`;
CREATE TABLE `vehicles`  (
  `ID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `NO` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `LOG` double NOT NULL DEFAULT 0,
  `LAT` double NOT NULL DEFAULT 0,
  `ACTIVE` bit(1) NOT NULL DEFAULT b'1',
  `MODEL` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `INITKM` int NOT NULL DEFAULT 0,
  `MODELYEAR` int NOT NULL DEFAULT 0,
  `REGYEAR` int NOT NULL DEFAULT 0,
  `NOTES` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for vip_groups
-- ----------------------------
DROP TABLE IF EXISTS `vip_groups`;
CREATE TABLE `vip_groups`  (
  `ID` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `NAME` varchar(255) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `POINT_ENABLE` bit(1) NOT NULL DEFAULT b'1',
  `SPEND_DOLLAR` double NULL DEFAULT NULL,
  `GAIN_POINTS` double NULL DEFAULT NULL,
  `MIN_EARN` double NULL DEFAULT NULL,
  `DISCOUNT_ENABLE` bit(1) NOT NULL DEFAULT b'1',
  `DISCOUNT_RATE` double NULL DEFAULT 0,
  `ACTIVE` bit(1) NOT NULL DEFAULT b'1',
  PRIMARY KEY (`ID`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Table structure for vouchers
-- ----------------------------
DROP TABLE IF EXISTS `vouchers`;
CREATE TABLE `vouchers`  (
  `id` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NOT NULL,
  `voucher_number` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `customer` varchar(100) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT NULL,
  `amount` double NULL DEFAULT NULL,
  `status` char(1) CHARACTER SET utf8mb3 COLLATE utf8mb3_general_ci NULL DEFAULT 'A',
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb3 COLLATE = utf8mb3_general_ci ROW_FORMAT = COMPRESSED;

-- ----------------------------
-- Triggers structure for table places
-- ----------------------------
DROP TRIGGER IF EXISTS `trg_places_qr_uuid`;
delimiter ;;
CREATE TRIGGER `trg_places_qr_uuid` BEFORE INSERT ON `places` FOR EACH ROW SET NEW.qr_code_id = UUID()
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
