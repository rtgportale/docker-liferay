
### Introduction

Liferay Portal is the world's leading enterprise open source portal framework, offering integrated web publishing and content management, an enterprise service bus and service-oriented architecture, and compatibility with all major IT infrastructure.

This image aims to help you run Liferay Portal Community Edition in a Docker container.

### Quick Start

Make sure your Docker host has sufficiently free RAM (at least 4 GB), then run the Liferay image:

```bash
docker run --name='liferay62' -d -p 8080:8080 rtgportale/liferay
```

**NOTE**: Please allow a few minutes for the server to start. If you want to make sure that everything went fine, watch the log:

```bash
docker exec -it liferay62 /bin/bash
tail -f /opt/liferay/tomcat/logs/catalina.out
```
Go to http://localhost:8080 (replace `localhost` with the IP address of your Docker host), then log in. Use the following to log in as the default administrative user:
* email address: **test@liferay.com**
* password: **test**

### Configuration

#### Database

If you use this image in production, you'll probably want to store data separately in an external location. You can use the DB_... environment variables to configure Liferay's database.

If `DB_KIND` is `hypersonic` (or not set), then an embedded Hypersonic database will be used. By setting `DB_KIND` to `mysql`, you can use an external MySQL server, e.g. one running in a Docker container:

```bash
docker run --name 'mysql' -d \
    -e MYSQL_ROOT_PASSWORD=secret \
    -e MYSQL_DATABASE=lportal \
    -e MYSQL_USER=liferay \
    -e MYSQL_PASSWORD=secret \
    mysql:5.6.30 \
    --character-set-server=utf8 \
    --collation-server=utf8_general_ci
```

Then start the Liferay container:

```bash
docker run --name 'liferay62' -d \
    -p 8080:8080 \
    -e DB_KIND=mysql \
    -e DB_HOST=liferaydb \
    -e DB_USERNAME=liferay \
    -e DB_PASSWORD=secret \
    --link mysql:liferaydb \
    rtgportale/liferay
```

#### Options

Below is a list of the currently available parameters that can be set
using environment variables.
- **DB_KIND**: hypersonic or mysql; default = `hypersonic`
- **DB_USERNAME**: username to use when connecting to the database
- **DB_PASSWORD**: password to use when connecting to the database
- **DB_NAME**: name of the database to connect to; default = `lportal`
- **DB_HOST**: host of the database server; default = `localhost`
- **DB_CONN_PARAMS**: database connection parameters; for MySQL, default = `characterEncoding=UTF-8&dontTrackOpenResources=true&holdResultsOpenOverStatementClose=true&useFastDateParsing=false&useUnicode=true`
- **SETUP_WIZARD_ENABLED**: starts Liferay's Setup Wizard on first run
