user    := "atareao"
name    := `basename ${PWD}`
version := `vampus show`

upgrade:
   vampus upgrade --patch

build:
    echo {{version}}
    echo {{name}}
    podman build -t {{user}}/{{name}}:{{version}} \
                 -t {{user}}/{{name}}:latest \
                 .
push:
    @podman image push {{user}}/{{name}}:{{version}}
    @podman image push {{user}}/{{name}}:latest
