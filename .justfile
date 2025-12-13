user    := "atareao"
name    := `basename ${PWD}`
version := `vampus show`

upgrade:
   vampus upgrade --patch

build:
    echo {{version}}
    echo {{name}}
    docker build -t {{user}}/{{name}}:{{version}} \
                 -t {{user}}/{{name}}:latest \
                 .
push:
    @docker image push --all-tags {{user}}/{{name}}
