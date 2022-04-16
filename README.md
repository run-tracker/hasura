## Set up a database on a server
Make sure you have docker setup and ready to go. Follow [these instructions](https://docs.docker.com/engine/install/) if necessary.

Next, clone this repository on the server of interest.
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
To access the Hasura Console, you will first need to install the Hasura CLI following [these](https://hasura.io/docs/latest/graphql/core/hasura-cli/install-hasura-cli/) instructions.

Next, clone this repository on a machine with access to a browser and a monitor.
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
First, we run the migrations which load the correct schema into our postgres database:
```
hasura migrate apply --all-databases
```
To confirm that this worked, run `hasura console`, look on the `DATA` tab, and click on `public` on the left (represented with a small folder icon).
This should open a page that show a handful of untracked tables, views, and functions.

In order to set up Hasura to use these postgres entities, we apply our metadata to the endpoint:
```
hasura metadata apply
```
You should now see a list of tables under `public` (`DATA` tab):
```
chart
parameter_choices
run
run_blob
run_log
sweep
```
You will also see a long list of GraphQL Queries under the "Explorer" when you click on the `API` tab.

## Backup data
Even if you do not yet have data in your database, you will want to set up regular data backups.
The command to dump the contents of your postres data base is:
```
docker exec hasura_postgres_1 pg_dump -U postgres -d postgres > [output-file]
```
This command makes a few assumptions which are true by default:

 - Your Postgres container is named `hasura_postgres_1` is the the container
   running Postgres. You can confirm this by running `docker ps`.
 - Both your Postgres username and database name is `postgres` (true per the
   default `docker-compose.yml`)

One way to perform regular backups is to run this command periodically using a `cron` job. On your server (not on localhost),
run 
```
crontab -e
```
Edit the file that comes up so that it looks like this:
```
  # m h  dom mon dow   command
  0 *  *   *   *     /path/to/hasura/directory/backup.sh /path/to/backup
```
Replacing `/path/to/hasura/directory` and `/path/to/backup` with the appropriate file paths.
Your `cron` file may have other jobs running on it, and that is ok.

This will execute the `backup.sh` script every day and create a new file named `X.sql` where `X` is the 
day of the month. As a result, your data will overwrite itself every month, but you will have access
to the version of your database that existed on each of the days of the past month. 

## Restore data
Run
```
docker exec -i hasura_postgres_1 psql -U postgres -d postgres < [backup-file]
```
This will load the actual data into the postgres database backing hasura.
Finally run
```
hasura metadata apply
```
