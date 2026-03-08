CREATE DATABASE IF NOT EXISTS demo_db;

USE demo_db;


CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL
);


INSERT INTO users VALUES
(1,'Alice'),
(2,'Bob'),
(3,'Charlie'),
(4,'David');
