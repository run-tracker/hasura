## Set up a database on a server
Clone this repository on the server of interest.
`cd` into it and run
```
docker-compose pull
docker-compose up -d
```
Check if the containers are running:
```
docker ps

CONTAINER ID IMAGE                 ... CREATED STATUS PORTS          ...
097f58433a2b hasura/graphql-engine ... 1m ago  Up 1m  8080->8080/tcp ...
b0b1aac0508d postgres              ... 1m ago  Up 1m  5432/tcp       ...
```

## Access the Hasura Console
Clone this repository on a machine with access to a browser and a monitor.
Add a file named `config.yaml` to the root of this repository:
```
version: 3
endpoint: http://your-endpoint:1200
metadata_directory: metadata
actions:
  kind: synchronous
  handler_webhook_baseurl: http://localhost:3000
```
Replace `your-endpoint` with the url for your server machine, e.g. `http://something.eecs.umich.edu:1200`.
Note that port 1200 is hard-coded in `docker-compose.yaml`. If there are issues with that port, you can change it 
under `graphql-engine:`, under `ports:`.

Now (from inside the root directory of this repository), run
```
hasura console
```
If hasura indicates that there is a new version available for the CLI, feel free to update. This command should open the 
hasura console in your browser. Currently there is no data or metadata in your database so there is not much to see here yet.

## Import Hasura setup
This will use a Hasura migration. First
you need to determine the ip-address of the server where the database is running.

Next apply our metadata to the enpoint:
```
hasura metadata apply
```
Now we apply any saved migrations to the connected databases:
```
hasura migrate apply --all-databases
```
Finally we reload the metadata:
```
hasura metadata reload
```
The port is `8080` by default, but you can double check this by looking in the
`docker-compose.yml` file that you ran on the database server. This will add the appropriate tables and relations to your GraphQL endpoint. You can check this by running
```
hasura console
```
On the DATA tab, you should see the appropriate Database(s) and table(s) in the
left column. 

## Backup data
On the database server, run
```
docker exec hasura_postgres_1 pg_dump -U postgres -d postgres > [output-file]
```
This command makes a few assumptions which are true by default:

 - Your Postgres container is named `hasura_postgres_1` is the the container
   running Postgres. You can confirm this by running `docker ps`.
 - Both your Postgres username and database name is `postgres` (true per the
   default `docker-compose.yml`)

One way to perform regular backups is to run this command periodically using a `cron` job.

## Restore data
First follow the steps described in 
[Set up a database on a server](#set-up-a-database-on-a-server).
Next run
```
docker exec -i hasura_postgres_1 psql -U postgres -d postgres < [backup-file]
```
This will load the actual data into the postgres database backing hasura.
Finally run
```
hasura metadata apply
```
