CREATE USER vscode CREATEDB;
CREATE DATABASE vscode WITH OWNER vscode;

CREATE USER e_commerce_rails7 WITH PASSWORD 'e_commerce_rails7';
ALTER ROLE e_commerce_rails7 CREATEDB;