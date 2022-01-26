#!/bin/bash

docker run --rm -it -v $(pwd)/..:$(pwd)/.. -w $(pwd) docker-devimg:v1.0