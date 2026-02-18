-- =========================
-- V1__init_core.sql
-- =========================

-- Companies (tenant)
CREATE TABLE companies (
  id BINARY(16) PRIMARY KEY,
  name VARCHAR(150) NOT NULL,
  slug VARCHAR(150) NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  timezone VARCHAR(64) NOT NULL DEFAULT 'UTC',
  locale VARCHAR(10) NOT NULL DEFAULT 'en',
  currency CHAR(3) NOT NULL DEFAULT 'USD',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_companies_slug (slug)
) ENGINE=InnoDB;

-- Plans (global)
CREATE TABLE plans (
  id BINARY(16) PRIMARY KEY,
  name VARCHAR(80) NOT NULL,
  code VARCHAR(50) NOT NULL,
  price_cents INT NOT NULL DEFAULT 0,
  currency CHAR(3) NOT NULL DEFAULT 'USD',
  max_users INT NOT NULL DEFAULT 1,
  max_storage_mb INT NOT NULL DEFAULT 100,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_plans_code (code)
) ENGINE=InnoDB;

-- Subscriptions (company -> plan)
CREATE TABLE subscriptions (
  id BINARY(16) PRIMARY KEY,
  company_id BINARY(16) NOT NULL,
  plan_id BINARY(16) NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  starts_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  ends_at TIMESTAMP NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  CONSTRAINT fk_subscriptions_company FOREIGN KEY (company_id) REFERENCES companies(id),
  CONSTRAINT fk_subscriptions_plan FOREIGN KEY (plan_id) REFERENCES plans(id),
  KEY idx_subscriptions_company (company_id),
  KEY idx_subscriptions_plan (plan_id)
) ENGINE=InnoDB;

-- Modules (global catalog)
CREATE TABLE modules (
  id BINARY(16) PRIMARY KEY,
  code VARCHAR(80) NOT NULL,       -- inventory, crm, sales...
  name VARCHAR(120) NOT NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_modules_code (code)
) ENGINE=InnoDB;

-- Company Modules (toggle per company)
CREATE TABLE company_modules (
  id BINARY(16) PRIMARY KEY,
  company_id BINARY(16) NOT NULL,
  module_id BINARY(16) NOT NULL,
  is_enabled TINYINT(1) NOT NULL DEFAULT 1,
  enabled_at TIMESTAMP NULL DEFAULT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_company_modules_company FOREIGN KEY (company_id) REFERENCES companies(id),
  CONSTRAINT fk_company_modules_module FOREIGN KEY (module_id) REFERENCES modules(id),
  UNIQUE KEY uk_company_module (company_id, module_id),
  KEY idx_company_modules_company (company_id)
) ENGINE=InnoDB;

-- Users
-- Nota: company_id puede ser NULL para SYSTEM_ADMIN global (plataforma)
CREATE TABLE users (
  id BINARY(16) PRIMARY KEY,
  company_id BINARY(16) NULL,
  user_type VARCHAR(20) NOT NULL DEFAULT 'COMPANY', -- SYSTEM | COMPANY
  name VARCHAR(150) NOT NULL,
  email VARCHAR(190) NOT NULL,
  password_hash VARCHAR(255) NULL,
  status VARCHAR(30) NOT NULL DEFAULT 'active',
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP NULL DEFAULT NULL ON UPDATE CURRENT_TIMESTAMP,
  UNIQUE KEY uk_users_email (email),
  KEY idx_users_company (company_id),
  CONSTRAINT fk_users_company FOREIGN KEY (company_id) REFERENCES companies(id)
) ENGINE=InnoDB;

-- OAuth identities (Google, etc.)
CREATE TABLE auth_identities (
  id BINARY(16) PRIMARY KEY,
  user_id BINARY(16) NOT NULL,
  provider VARCHAR(30) NOT NULL,     -- google
  provider_user_id VARCHAR(190) NOT NULL,
  email VARCHAR(190) NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_auth_identities_user FOREIGN KEY (user_id) REFERENCES users(id),
  UNIQUE KEY uk_provider_user (provider, provider_user_id),
  KEY idx_auth_identities_user (user_id)
) ENGINE=InnoDB;

-- Roles & permissions (company scoped)
CREATE TABLE roles (
  id BINARY(16) PRIMARY KEY,
  company_id BINARY(16) NULL,        -- NULL = rol global (SYSTEM)
  name VARCHAR(80) NOT NULL,
  code VARCHAR(50) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_roles_scope (company_id, code),
  KEY idx_roles_company (company_id),
  CONSTRAINT fk_roles_company FOREIGN KEY (company_id) REFERENCES companies(id)
) ENGINE=InnoDB;

CREATE TABLE permissions (
  id BINARY(16) PRIMARY KEY,
  name VARCHAR(120) NOT NULL,
  code VARCHAR(80) NOT NULL,
  created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  UNIQUE KEY uk_permissions_code (code)
) ENGINE=InnoDB;

CREATE TABLE user_roles (
  user_id BINARY(16) NOT NULL,
  role_id BINARY(16) NOT NULL,
  PRIMARY KEY (user_id, role_id),
  CONSTRAINT fk_user_roles_user FOREIGN KEY (user_id) REFERENCES users(id),
  CONSTRAINT fk_user_roles_role FOREIGN KEY (role_id) REFERENCES roles(id)
) ENGINE=InnoDB;

CREATE TABLE role_permissions (
  role_id BINARY(16) NOT NULL,
  permission_id BINARY(16) NOT NULL,
  PRIMARY KEY (role_id, permission_id),
  CONSTRAINT fk_role_permissions_role FOREIGN KEY (role_id) REFERENCES roles(id),
  CONSTRAINT fk_role_permissions_permission FOREIGN KEY (permission_id) REFERENCES permissions(id)
) ENGINE=InnoDB;
