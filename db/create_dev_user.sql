CREATE USER 'workflows-development'@localhost IDENTIFIED BY 'ph1uff';
GRANT ALL ON *.* to 'workflows-development'@localhost IDENTIFIED BY 'ph1uff';
CREATE USER 'workflows-test'@localhost IDENTIFIED BY 'ph1uff';
GRANT ALL ON *.* to 'workflows-test'@localhost IDENTIFIED BY 'ph1uff';
FLUSH PRIVILEGES;
CREATE DATABASE workflows_development;
CREATE DATABASE workflows_test;
