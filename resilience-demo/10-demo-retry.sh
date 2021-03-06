#!/bin/bash

. $(dirname ${BASH_SOURCE})/../util.sh
SOURCE_DIR=$PWD

desc "Let's disable automatic retries"
run "kubectl apply -n resilience -f resources/istio/disable-auto-retries.yaml"

desc "Let's simulate some issues with v1 deployment. We'll deploy a version of the svc that generates faults 50% of the time"
read -s


#desc "first we need to disable automatic retries otherwise we won't see the faults"
desc "Deploy updated v1 svc"
run "kubectl apply -f $(relative resources/k8s/purchase-history-v1-error-50.yaml) -n resilience"
run "kubectl get pod -w -n resilience"

desc "Now, let's add a Retry policy for our service to smooth out the errors"
run "cat $(relative resources/istio/ph-v1-retry.yaml)"
run "kubectl apply -f $(relative resources/istio/ph-v1-retry.yaml) -n resilience"

desc "Note, this helps with most of the errors.. let's discuss what's happening here"
desc "Clean up/restore -- will come back to retries"
