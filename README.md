# postgrespro

PostgresPro docker image based on Debian

# How to launch

`docker run -it --rm -p 5432:5432 -v $(PWD)/pg_data:/var/lib/pgpro/std-10/data -e POSTGRES_INITDB_ARGS='--locale ru_RU.utf8' marinad/postgrespro`

`pg_data` should be empty to launch initialization script
