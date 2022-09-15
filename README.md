# Introduction
This project creates 3 custom Opencast images based on environment variables. The 3 available images are the following:
-   admin
-   presentation
-   worker

Opencast is an open source video capture and processing software. For more information about the project visit [opencast.org](https://opencast.org/).

# Getting Started
## Application Prerequisites
1. docker
1. docker-compose
1. elasticsearch service Ex: [OpenSearch](https://opensearch.org/)
1. DB (MariaDB, PostgreSQL)

# Build Instructions
## Container Image Build
Run the following commands from the project root directory:

opencast-adminpresentation
```
docker build --tag lp-opencast/adminpresentation:12.2 --file docker/opencast-adminpresentation/Dockerfile .
```
opencast-worker
```
docker build --tag lp-opencast/worker:12.2 --file docker/opencast-worker/Dockerfile .
```

# Runtime
## Environment Variables
The following environment variables are used to control the application at run-time. You can refer to the docker/config/config.env.example file for a working local example. Refer to [opencast/opencast-docker documentation](https://github.com/opencast/opencast-docker#readme) for extended description and possible values. Mandatory variables are marked with an asterisk.

### Opencast Variables
-   **ELASTICSEARCH_SERVER_HOST** * : Hostname for the Elasticsearch service.
-   **ORG_OPENCASTPROJECT_DB_JDBC_PASS** * : Password for the DB user.
-   **ORG_OPENCASTPROJECT_DB_JDBC_URL** * : JDBC connection string.
-   **ORG_OPENCASTPROJECT_DB_JDBC_USER** * : DB user.
-   **ORG_OPENCASTPROJECT_DB_VENDOR** * : The type of database to use. Allowed values: "H2", "MariaDB", "PostgreSQL". Default value: "H2".
-   **ORG_OPENCASTPROJECT_DOWNLOAD_URL** : The HTTP-URL to use for downloading media files. If not set, defaults to: ${org.opencastproject.server.url}/static.
-   **ORG_OPENCASTPROJECT_SECURITY_ADMIN_PASS** * : Password of the admin user.
-   **ORG_OPENCASTPROJECT_SECURITY_ADMIN_USER** * : Username of the admin user.
-   **ORG_OPENCASTPROJECT_SECURITY_DIGEST_PASS** * : Password for the communication between Opencast nodes and capture agents.
-   **ORG_OPENCASTPROJECT_SECURITY_DIGEST_USER** * : Username for the communication between Opencast nodes and capture agents.
-   **PROP_ORG_OPENCASTPROJECT_ADMIN_UI_URL** * : HTTP-URL of the admin node.
-   **PROP_ORG_OPENCASTPROJECT_ENGAGE_UI_URL** * : HTTP-URL of the engage node.

The MariaDB and opensearch variables are only required when testing localy, an external MariaDB and elasticsearch service should be used for a production environment, the production configuration is not included in this readme.
### MariaDB Variables
-   **MYSQL_ROOT_PASSWORD** : Password for the root user.
-   **MYSQL_DATABASE** : Database name.
-   **MYSQL_USER** : Username for the admin user.
-   **MYSQL_PASSWORD** : Password for the admin user.

### OpenSearch Variables
-   **DISABLE_INSTALL_DEMO_CONFIG** : Disables execution of install_demo_configuration.sh bundled with security plugin, which installs demo certificates and security configurations to OpenSearch.
-   **DISABLE_SECURITY_PLUGIN** : Disables security plugin entirely in OpenSearch.
-   **OPENSEARCH_JAVA_OPTS** : Minimum and maximum Java heap size, recommend setting both to 50% of system RAM.
-   **BOOTSTRAP_MEMORY_LOCK** : Along with the memlock settings, disables swapping.
-   **DISCOVERY_TYPE** : Disables bootstrap checks that are enabled when network.host is set to a non-loopback address.

## Run the Application Locally
```
cd [project root]/docker/
cp ./config/config.env.example ./local_config.env
```
Edit the local_config.env as required.
```
docker-compose --env-file=config/local_config.env -f docker-compose.{ENV}.yml up
```
