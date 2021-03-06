#!/usr/bin/env bats

load ./../helper

@test "Applying Monitoring" {
    info
    kubectl apply -f https://raw.githubusercontent.com/sighupio/fury-kubernetes-monitoring/v1.3.0/katalog/prometheus-operator/crd-servicemonitor.yml
    kubectl apply -f https://raw.githubusercontent.com/sighupio/fury-kubernetes-monitoring/v1.3.0/katalog/prometheus-operator/crd-rule.yml
}

@test "Prepare Mongo Credentials" {
    info
    kubectl create ns mongo
    kubectl create secret generic mongodb-credentials --from-literal=username=sighup --from-literal=password=puhgis -n mongo
    kubectl create secret generic mongod-keyfile --from-file=mongod.key=katalog/tests/mongo/resources/example-mongod.key -n mongo
}

@test "Deploy MongoDB" {
    info
    deploy() {
        apply katalog/mongo
    }
    run deploy
    [ "$status" -eq 0 ]
}

@test "MongoDB is Running" {
    info
    test() {
        kubectl get pods -l app=mongo -o json -n mongo |jq '.items[].status.containerStatuses[].ready' | uniq |grep -q true
    }
    loop_it test 30 2
    status=${loop_it_result}
    [ "$status" -eq 0 ]
}
