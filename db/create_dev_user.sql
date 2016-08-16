CREATE USER 'workflows-dev'@localhost IDENTIFIED BY 'changeme';
GRANT ALL ON *.* to 'workflows-dev'@localhost IDENTIFIED BY 'changeme';
FLUSH PRIVILEGES;
CREATE DATABASE workflows_development;
CREATE DATABASE workflows_test;
CREATE DATABASE workflows_ci;
