#! /bin/sh

kubectl apply -f k8s/00-mesh-reset.yaml

kubectl delete trafficpermissions --all

kubectl delete -f k8s/05-traffic-route.yaml --ignore-not-found

kubectl scale deployment kuma-demo-backend-v1 -n kuma-demo --replicas=0
kubectl scale deployment kuma-demo-backend-v2 -n kuma-demo --replicas=0

kubectl delete -f k8s/02-ingress-frontend.yaml --ignore-not-found

kubectl delete -f https://bit.ly/demokuma --ignore-not-found

kumactl install gateway kong | kubectl delete -f - --ignore-not-found
kumactl install metrics | kubectl delete -f - --ignore-not-found
kumactl install tracing | kubectl delete -f - --ignore-not-found
kumactl install control-plane | kubectl delete -f - --ignore-not-found

