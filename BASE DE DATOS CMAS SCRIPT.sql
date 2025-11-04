CREATE DATABASE cmasapp;

CREATE TABLE user_app(
    user_iD SERIAL PRIMARY KEY,
    email VARCHAR(100) UNIQUE NOT NULL,
    telephone VARCHAR(15) NOT NULL,
    password VARCHAR(100) NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP);

CREATE TABLE account_cmas(
    account_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    contract_number VARCHAR(20) NOT NULL,
    alias VARCHAR(50) NOT NULL,
    name VARCHAR(200) NOT NULL,
    address VARCHAR(200) NOT NULL,
    debt INT NOT NULL,
    user_id INT NOT NULL,

    CONSTRAINT fk_user_app
        FOREIGN KEY (user_id)
        REFERENCES user_app (user_id)
        ON DELETE CASCADE);

CREATE TABLE user_account_rel(
    user_id INT NOT NULL,
    account_id UUID NOT NULL,
    linking_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (user_id, account_id),

    CONSTRAINT fk_rel_user
        FOREIGN KEY (user_id)
        REFERENCES user_app (user_id)
        ON DELETE CASCADE,
        
    CONSTRAINT fk_rel_cuenta
        FOREIGN KEY (account_id)
        REFERENCES account_cmas (account_id)
        ON DELETE CASCADE);

CREATE TABLE card(
    card_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL,
    token VARCHAR(255) UNIQUE NOT NULL,
    alias VARCHAR(100),
    brand VARCHAR(50) NOT NULL,
    last_digit CHAR(4) NOT NULL,
    exp_month SMALLINT NOT NULL,
    exp_year SMALLINT NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    registered_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_card_user
        FOREIGN KEY (user_id)
        REFERENCES user_app (user_id)
        ON DELETE CASCADE,
        CONSTRAINT chk_exp_month
        CHECK (exp_month >= 1 AND exp_month <= 12)
);

CREATE TABLE notification_history (
    notification_id     SERIAL PRIMARY KEY,
    user_id             INT NOT NULL,
    notification_type   VARCHAR(50) NOT NULL,
    reference_id        UUID NOT NULL DEFAULT gen_random_uuid(),
    read                BOOLEAN NOT NULL DEFAULT FALSE,
    title               VARCHAR(200) NOT NULL,
    body                VARCHAR(500) NOT NULL, 
    sent_at             TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_notification_user
        FOREIGN KEY (user_id)
        REFERENCES user_app (user_id)
        ON DELETE CASCADE
);


CREATE TABLE service_report (
    report_id       SERIAL PRIMARY KEY,
    account_id  UUID NOT NULL, 
    user_id         INT NOT NULL,
    report_type     VARCHAR(75) NOT NULL,
    description     VARCHAR(700) NOT NULL,
    created_at      TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status          VARCHAR(35) NOT NULL DEFAULT 'ENVIADO',

    CONSTRAINT fk_service_account
        FOREIGN KEY (account_id)
        REFERENCES account_cmas (account_id)
        ON DELETE CASCADE,

    CONSTRAINT fk_service_user
        FOREIGN KEY (user_id)
        REFERENCES user_app (user_id)
        ON DELETE CASCADE
);

CREATE TABLE payment (
    payment_id          UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             INT NOT NULL,
    account_id          UUID NOT NULL,
    card_id             INT,
    amount              NUMERIC(10, 2) NOT NULL,
    date_time           TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    status              VARCHAR(35) NOT NULL,
    transaction_id      VARCHAR(255) UNIQUE,
    response_message    VARCHAR(255),

    CONSTRAINT fk_payment_user
        FOREIGN KEY (user_id)
        REFERENCES user_app (user_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_payment_cmas_account
        FOREIGN KEY (account_id)
        REFERENCES account_cmas (account_id)
        ON DELETE RESTRICT,

    CONSTRAINT fk_payment_card
        FOREIGN KEY (card_id)
        REFERENCES card (card_id)
        ON DELETE SET NULL
);

CREATE TABLE device_token (
    token_id            UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             INT NOT NULL,
    token               VARCHAR(255) UNIQUE NOT NULL,
    platform            VARCHAR(20) NOT NULL,
    active              BOOLEAN NOT NULL DEFAULT TRUE,
    last_updated_at     TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_devicetoken_user
        FOREIGN KEY (user_id)
        REFERENCES user_app (user_id)
        ON DELETE CASCADE,

    CONSTRAINT chk_platform
        CHECK (platform IN ('Android', 'iOS'))
);

CREATE TABLE cmas_office (
    branch_id           SERIAL PRIMARY KEY,
    branch_name         VARCHAR(150) NOT NULL,
    address             VARCHAR(255) NOT NULL,
    business_hours      VARCHAR(150),
    latitude            NUMERIC(10, 8),
    longitude           NUMERIC(10, 8)
);