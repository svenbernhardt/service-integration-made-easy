# Demo Script

This Demo is built upon the Kuma demo application, which is officially available on [Github](https://github.com/kumahq/kuma-demo).

The demo was shown during a Kong meetup in July 2021. The recording is available on [Youtube](https://www.youtube.com/watch?v=f3GeuKzYrsA).

## Setup Demo environment

You can use the script bootstrap-demo-base.sh to setup a base demo environment. As a result, you'll get a local k3d Kubernetes Cluster (Note that you need to have Docker runtime installed) with Kuma Demo app installed.

Before you can access Kuma demo app, you nee to port-forward to Kuma Demo

```bash
kubectl port-forward svc/frontend -n kuma-demo 8080
```

When you hit URL http://localhost:8080 in your browser now, you'll be able to see the Kuma demo Webshop.

## Initial Kuma setup

Next setup Kuma in K8s.

```bash
kumactl install control-plane | k apply -f -
```

Port forward to Kuma Control Plane

```bash
kubectl port-forward svc/kuma-control-plane -n kuma-system 5681
```

When you hit URL http://localhost:5681/gui in your browser, you'll be able to see the Kuma UI.

## Install and configure Kuma Gateway (Kong Ingress Controller)

Install Kong Ingress Controller to be able to access the application running in K8s.

```bash
kumactl install gateway kong | kubectl apply -f -
```

After ingress has been installed successfully, we define the respective ingress rules.

```bash
kubectl apply -f k8s/02-ingress-frontend.yaml
```

After ingress has been established, you can stop port-forwarding to Kuma demo application on port 8080 and just hit http://localhost:8088 in your browser and should be able to reach the application using the ingress rule, we just defined.

## Configure the mesh

Delete Traffic permission that allow to route all traffic, because in the real world we want to have fine-grained control over service-to-service communication.

```bash
kubectl delete trafficpermission allow-all-default
```

### Enable mTLS for the default mesh

```bash
kubectl apply -f k8s/03-mesh-add-mtls.yaml
```

**Note:** If you try to hit the Kuma demo app now on http://localhost:8088, you'll receive an error, because all traffic within the mesh is forbidden. We need to explicitly define traffic permissions using the following command:

```bash
kubectl apply -f k8s/04-traffic-permissions.yaml
```

### Traffic routing

If you want to make use of advanced deployment patterns like Canary deployments or A/B testing, traffic routings can be used. To demo this, we'll do the following:

Scale v1 and v2 of backend application

```bash
kubectl scale deployment kuma-demo-backend-v1 -n kuma-demo --replicas=1

kubectl scale deployment kuma-demo-backend-v2 -n kuma-demo --replicas=1
```

After scaling the two additional deployments, we have three different backend containers, that are used by the Kuma frontend using a round-robin strategy (Default config for Kubernetes Services). You can try this out by hitting the refresh button in the browser for several times (on http://localhost:8088).

To influence the traffic routing behaviour, you can add a traffic routing policy to control service invocation behavior:

```bash
kubectl apply -f k8s/05-traffic-route.yaml
```

After applying the configuration, 70% of the traffic goes to v0 backend, 20% to v1 and 10% to v2 backend.

**Note:** In this example, we're using TCP-based traffic routing policies (Layer 4), but Kuma is also supports HTTP-based traffic routing (Layer 7) which allows defining routing policies e.g. besaed on HTTP Header values.

### Metrics

A Service mesh is capable of improving the overall observabilty of a distributed service architecture. Collecting metrics of your service architecture is an essential pillar of observabiltiy to be able to monitor your environment and to trace down problems efficiently.

Out-of-the-box Kuma provides support for Prometheus and Grafane with respect to metrics collection and visualisation. In this last step, we're going to install a respective demo stack for basic monitoring.

```bash
kumactl install metrics | k apply -f -
```

This bootstraps Prometheus and Grafana in our K8s demo cluster.

Because we have mTLS enabled in our mesh, we need to define respective traffic permissions for the metrics components to work.

```bash
kubectl apply -f k8s/06-traffic-permissions-metrics.yaml
```

Before you can explore the metrics using Grafana we need to add Metrics support to the current mesh configuration.

```bash
kubectl apply -f k8s/07-mesh-add-metrics.yaml
```

Finally, you need to port-forward toi Grafana to be able to access Grafana.

```bash
kubectl port-forward svc/grafana d -n kuma-metrics 3000:80
```

If you hit URL http://localhost:3000 in your browser, you're able to explore the pre-defined Kuma dashboards in Grafana.

**Note:** Username and password for Grafana is admin/admin.