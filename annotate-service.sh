#! /bin/sh

kubectl annotate svc frontend -n kuma-demo 80.service.kuma.io='http'
kubectl annotate svc backend -n kuma-demo 80.service.kuma.io='http'
kubectl annotate svc kong-proxy -n kuma-gateway 80.service.kuma.io='http'