#!/bin/bash

#scripts
chmod +x ./requirements/*.sh

./requirements/agents.sh
./requirements/neovim.sh
./requirements/lazyvim.sh

#python packages
pip install -r ./requirements/requirements.txt

#nodejs packages
# npm install ... 

#java packages
# mvn install ...

#rust packages
# cargo build ...

#go packages
# go mod download && go mod tidy

#ruby packages
# bundle install ...

#php packages
# composer install ...