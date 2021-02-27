# Project B
The Project B is an application with a web
interface for aggregating phone numbers accordingly
to its sector.

## Setup
**Requirements**
* Docker version 20.10.3
* docker-compose version 1.27.4

### Set the env vars
*Remember to fill the values.*
```shell=
cp web-variables.env.sample web-variables.env
```

### Build the container
```shell=
docker-compose build
```

### Running the test suite
```shell=
docker-compose run web mix test
```

### Running the web server
*It will run on port 8080*
```shell=
docker-compose up
```
