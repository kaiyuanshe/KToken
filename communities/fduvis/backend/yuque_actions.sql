CREATE TABLE IF NOT EXISTS yq_actions (
f_user integer NOT NULL,
f_path text,
f_doc text,
f_action varchar(20)  NOT NULL,
f_time varchar(24) NOT NULL,
f_amount integer NOT NULL
);
