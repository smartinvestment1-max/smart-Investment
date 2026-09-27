CREATE DATABASE IF NOT EXISTS smart_investment CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE smart_investment;

CREATE TABLE IF NOT EXISTS admins (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 username VARCHAR(60) NOT NULL UNIQUE,
 email VARCHAR(160) NOT NULL UNIQUE,
 password_hash VARCHAR(255) NOT NULL,
 role ENUM('admin','super_admin') NOT NULL DEFAULT 'admin',
 status ENUM('active','disabled') NOT NULL DEFAULT 'active',
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS users (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 username VARCHAR(60) NOT NULL UNIQUE,
 email VARCHAR(160) NULL UNIQUE,
 phone VARCHAR(30) NULL,
 password_hash VARCHAR(255) NOT NULL,
 referral_code VARCHAR(30) NOT NULL UNIQUE,
 referred_by_user_id BIGINT UNSIGNED NULL,
 balance DECIMAL(18,2) NOT NULL DEFAULT 0,
 referral_earnings DECIMAL(18,2) NOT NULL DEFAULT 0,
 status ENUM('active','suspended') NOT NULL DEFAULT 'active',
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 CONSTRAINT fk_users_referrer FOREIGN KEY(referred_by_user_id) REFERENCES users(id) ON DELETE SET NULL,
 INDEX idx_users_status(status), INDEX idx_users_created(created_at)
);

CREATE TABLE IF NOT EXISTS investment_plans (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 name VARCHAR(80) NOT NULL UNIQUE,
 amount DECIMAL(18,2) NOT NULL,
 daily_rate DECIMAL(8,4) NOT NULL DEFAULT 0,
 validity_days INT UNSIGNED NOT NULL,
 status ENUM('active','disabled') NOT NULL DEFAULT 'active',
 sort_order INT UNSIGNED NOT NULL DEFAULT 0,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS payment_settings (
 id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 method ENUM('easypaisa','jazzcash','bank') NOT NULL UNIQUE,
 enabled BOOLEAN NOT NULL DEFAULT FALSE,
 account_name VARCHAR(160) NULL,
 account_number VARCHAR(160) NULL,
 instructions TEXT NULL,
 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS deposits (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id BIGINT UNSIGNED NOT NULL,
 amount DECIMAL(18,2) NOT NULL,
 method VARCHAR(40) NOT NULL,
 reference VARCHAR(120) NULL UNIQUE,
 screenshot VARCHAR(255) NULL,
 status ENUM('pending','approved','rejected') NOT NULL DEFAULT 'pending',
 rejection_reason VARCHAR(500) NULL,
 reviewed_by BIGINT UNSIGNED NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 reviewed_at TIMESTAMP NULL,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
 FOREIGN KEY(reviewed_by) REFERENCES admins(id) ON DELETE SET NULL,
 INDEX idx_deposits_status(status), INDEX idx_deposits_user(user_id), INDEX idx_deposits_created(created_at)
);

CREATE TABLE IF NOT EXISTS investments (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id BIGINT UNSIGNED NOT NULL,
 plan_id INT UNSIGNED NOT NULL,
 amount DECIMAL(18,2) NOT NULL,
 daily_rate DECIMAL(8,4) NOT NULL,
 validity_days INT UNSIGNED NOT NULL,
 start_at DATETIME NOT NULL,
 end_at DATETIME NOT NULL,
 status ENUM('active','completed') NOT NULL DEFAULT 'active',
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
 FOREIGN KEY(plan_id) REFERENCES investment_plans(id),
 INDEX idx_investments_user(user_id), INDEX idx_investments_status(status)
);

CREATE TABLE IF NOT EXISTS withdrawals (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id BIGINT UNSIGNED NOT NULL,
 amount DECIMAL(18,2) NOT NULL,
 method VARCHAR(40) NOT NULL,
 account_details VARCHAR(1200) NOT NULL,
 reference VARCHAR(100) NULL UNIQUE,
 status ENUM('pending','processing','completed','rejected') NOT NULL DEFAULT 'pending',
 rejection_reason VARCHAR(500) NULL,
 reviewed_by BIGINT UNSIGNED NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 reviewed_at TIMESTAMP NULL,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
 FOREIGN KEY(reviewed_by) REFERENCES admins(id) ON DELETE SET NULL,
 INDEX idx_withdrawals_status(status), INDEX idx_withdrawals_user(user_id)
);

CREATE TABLE IF NOT EXISTS transactions (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id BIGINT UNSIGNED NOT NULL,
 type ENUM('deposit','withdrawal','investment','referral_reward','adjustment') NOT NULL,
 amount DECIMAL(18,2) NOT NULL,
 reference VARCHAR(120) NULL UNIQUE,
 status ENUM('pending','approved','completed','rejected') NOT NULL,
 description VARCHAR(500) NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
 INDEX idx_transactions_user(user_id), INDEX idx_transactions_type(type), INDEX idx_transactions_created(created_at)
);

CREATE TABLE IF NOT EXISTS referrals (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 referrer_user_id BIGINT UNSIGNED NOT NULL,
 referred_user_id BIGINT UNSIGNED NOT NULL UNIQUE,
 referral_code VARCHAR(30) NOT NULL,
 status ENUM('valid','invalid') NOT NULL DEFAULT 'valid',
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(referrer_user_id) REFERENCES users(id) ON DELETE CASCADE,
 FOREIGN KEY(referred_user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS referral_rewards (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 referral_id BIGINT UNSIGNED NOT NULL,
 referrer_user_id BIGINT UNSIGNED NOT NULL,
 referred_user_id BIGINT UNSIGNED NOT NULL,
 source_deposit_id BIGINT UNSIGNED NULL,
 amount DECIMAL(18,2) NOT NULL,
 status ENUM('pending','paid','invalid') NOT NULL DEFAULT 'pending',
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 paid_at TIMESTAMP NULL,
 FOREIGN KEY(referral_id) REFERENCES referrals(id) ON DELETE CASCADE,
 FOREIGN KEY(referrer_user_id) REFERENCES users(id) ON DELETE CASCADE,
 FOREIGN KEY(referred_user_id) REFERENCES users(id) ON DELETE CASCADE,
 FOREIGN KEY(source_deposit_id) REFERENCES deposits(id) ON DELETE SET NULL
);

CREATE TABLE IF NOT EXISTS notifications (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 user_id BIGINT UNSIGNED NOT NULL,
 title VARCHAR(160) NOT NULL,
 message VARCHAR(1000) NOT NULL,
 read_at TIMESTAMP NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE,
 INDEX idx_notifications_user(user_id)
);

CREATE TABLE IF NOT EXISTS audit_logs (
 id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
 admin_id BIGINT UNSIGNED NOT NULL,
 action VARCHAR(100) NOT NULL,
 target_type VARCHAR(80) NULL,
 target_id VARCHAR(80) NULL,
 change_info TEXT NULL,
 created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
 FOREIGN KEY(admin_id) REFERENCES admins(id) ON DELETE CASCADE,
 INDEX idx_audit_created(created_at)
);

CREATE TABLE IF NOT EXISTS platform_settings (
 setting_key VARCHAR(80) PRIMARY KEY,
 setting_value TEXT NOT NULL,
 updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
