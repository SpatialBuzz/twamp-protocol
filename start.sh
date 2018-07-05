docker build -t twamp-server .

docker kill --signal=SIGINT twamp-server

docker rm twamp-server

docker run -d \
    --restart=always \
    --network host --name twamp-server twamp-server
