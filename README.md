# contour-operator
Contour Operator provides a method for packaging, deploying, and managing [Contour][1]. The operator extends the
functionality of the Kubernetes API to create, configure, and manage instances of Contour on behalf of users. It builds
upon the basic Kubernetes resource and controller concepts, but includes domain-specific knowledge to automate the
entire lifecycle of Contour. Refer to the official [Kubernetes documentation][2] to learn more about the benefits of the
operator pattern.

## Get Started

### Prerequisites

* A [Kubernetes](https://kubernetes.io/) cluster
* [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/) installed

Install the Contour Operator & Contour CRDs:
```
$ kubectl apply -f https://raw.githubusercontent.com/projectcontour/contour-operator/main/examples/operator/operator.yaml
```

Verify the deployment is available:
```
$ kubectl get deploy -n contour-operator
NAME               READY   UP-TO-DATE   AVAILABLE   AGE
contour-operator   1/1     1            1           1m
```

Install an instance of the `Contour` custom resource:
```
$ kubectl apply -f https://raw.githubusercontent.com/projectcontour/contour-operator/main/examples/contour/contour.yaml
```

Verify the `Contour` custom resource is available:
```
$ kubectl get contour/contour-sample
NAME             READY   REASON
contour-sample   True    ContourAvailable
```

__Note:__ It may take several minutes for the `Contour` custom resource to become available.

[Test with Ingress](https://projectcontour.io/docs/main/deploy-options/#test-with-ingress):
```
$ kubectl apply -f https://projectcontour.io/examples/kuard.yaml
```

Verify the example app deployment is available:
```
$ kubectl get deploy/kuard
NAME    READY   UP-TO-DATE   AVAILABLE   AGE
kuard   3/3     3            3           1m50s
```

Test the example app:
```
$ curl -o /dev/null -s -w "%{http_code}\n" http://local.projectcontour.io/
200
```

**Note:** A public DNS record exists for "local.projectcontour.io" which is
configured to resolve to `127.0.0.1`. This allows you to use a real domain name
when testing in a [kind](https://kind.sigs.k8s.io/) cluster. If testing on a
standard Kubernetes cluster, replace "local.projectcontour.io" with the
hostname of `kubectl get deploy/kuard`.


### OperatorHub install with custom index image

This process refers to building the operator in a way that it can be installed locally via the OperatorHub with a custom index image.

1. Build and push the bundle image to a registry:
   ```sh
   $ podman build -t <registry>/<username>/contour-operator-bundle:latest -f bundle.Dockerfile
   $ podman push <registry>/<username>/contour-operator-bundle:latest
   ```

2. Build and push the image index for operator-registry:
   ```sh
   # to get opm: https://github.com/operator-framework/operator-registry
   $ opm index add -c podman --bundles <registry>/<username>/contour-operator-bundle:latest --tag <registry>/<username>/contour-operator-bundle-index:1.0.0
   $ podman push <registry>/<username>/contour-operator-bundle-index:1.0.0
   ```

3. Create and apply catalogsource manifest:
   ```yaml
   apiVersion: operators.coreos.com/v1alpha1
   kind: CatalogSource
   metadata:
     name: contour-operator
     namespace: openshift-marketplace
   spec:
     sourceType: grpc
     image: <registry>/<username>/contour-operator-bundle-index:1.0.0
   ```

4. Create `contour-operator` namespace:
   ```sh
   $ oc create ns contour-operator
   ```


5. Open the console Operators -> OperatorHub, search for `Projectcontour Contour Operator` and install the operator

## Contributing

Thanks for taking the time to join our community and start contributing!

- Please familiarize yourself with the
[Code of Conduct](https://github.com/projectcontour/contour/blob/main/CODE_OF_CONDUCT.md) before contributing.
- See the [contributing guide](docs/CONTRIBUTING.md) for information about setting up your environment, the expected
workflow and instructions on the developer certificate of origin that is required.
- Check out the [open issues](https://github.com/projectcontour/contour-operator/issues).
- Join the Contour Slack channel: [#contour](https://kubernetes.slack.com/messages/contour/)
- Join the **Contour Community Meetings** - [details can be found here](https://projectcontour.io/community)

[1]: https://projectcontour.io/
[2]: https://kubernetes.io/docs/concepts/extend-kubernetes/operator/
