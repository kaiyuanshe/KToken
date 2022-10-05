CREATE TABLE IF NOT EXISTS yq_users (
user_name VARCHAR(20),
user_id integer NOT NULL PRIMARY KEY,
user_login VARCHAR(20) NOT NULL,
user_wallet VARCHAR(42)
);
