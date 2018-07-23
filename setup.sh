#!/bin/bash

function extractAgentAutoRegistryKey {
    echo $(grep 'agentAutoRegisterKey' GoServerData/config/cruise-config.xml | awk -F"agentAutoRegisterKey=\"" '{print $2}' | awk -F"\" webhookSecret" '{print $1}')
}

function startGoAgent {
    docker run -d \
    --net=host \
    -e WORKDIR=$(pwd)/GoAgentData \
    -e GO_SERVER_URL=https://localhost:8154/go \
    -v $(pwd)/GoAgentData:/godata \
    -e AGENT_AUTO_REGISTER_KEY=$(extractAgentAutoRegistryKey) \
    -e AGENT_AUTO_REGISTER_RESOURCES=docker \
    -e AGENT_AUTO_REGISTER_HOSTNAME=agent1 \
    goagent-with-docker:latest
}

function startGoServer {
    docker run -d \
    -v $(pwd)/GoServerData:/godata \
    -v $HOME:/home/go \
    -p8153:8153 -p8154:8154 \
    gocd/gocd-server:v18.6.0
}

#docker pull gocd server and agent image
docker pull gocd/gocd-agent-ubuntu-16.04:v18.6.0
docker pull gocd/gocd-server:v18.6.0

#docker build go agent with docker and rancher compose
docker build -t goagent-with-docker:latest .

#start docker server and agent
startGoServer \
&& echo "go server started" \
&& startGoAgent \
&& echo "go agent started"