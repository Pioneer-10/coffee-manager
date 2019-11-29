# Coffee Manager by Alexey Ten

## How to run

To build and run the application:

	$ docker-compose up -d
	
then, feel free to make requests, e.g. via `curl`:

	$ curl 'http://localhost:8080/user/request' -X PUT -d '{"login":"John","password":"Smith","email":"john@smith.co.uk"}'  

## Requirements

* `Starman`
* `Routes::Tiny`
* `DBD::SQLite`
* `JSON::XS`

## TODO

* Add tests for models, views and adapters
* Store passwords encrypted into DB
* OpenAPI specification and browsable version (SwaggerUI / ReDoc)
* Add check that user/machine exists into stat endpoints
