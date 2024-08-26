CONTEXT=k3d-temporal

k3d cluster create --config ./config/cluster.yaml
kubectl --context $CONTEXT apply -f ./config/flux.yaml --validate=false
sleep 5
kubectl --context $CONTEXT -n flux-system wait --for=condition=ready pod -l app=helm-controller
kubectl --context $CONTEXT -n flux-system wait --for=condition=ready pod -l app=source-controller

kubectl --context $CONTEXT apply -f ./config/keda.yaml
sleep 5
kubectl --context $CONTEXT -n keda wait --for=condition=ready pod -l app.kubernetes.io/name=keda-operator --timeout=120s

kubectl --context $CONTEXT apply -f ./config/postgresql.yaml
sleep 15
kubectl --context $CONTEXT -n postgresql wait --for=condition=ready pod -l app.kubernetes.io/name=postgresql --timeout=120s
sleep 15

if [ ! -d "temporal" ] ; then
    git clone https://github.com/temporalio/temporal.git
fi

cd temporal
make temporal-sql-tool
./temporal-sql-tool -u temporal --pw temporal_password -p 30000 --pl postgres12 --db temporal create
./temporal-sql-tool -u temporal --pw temporal_password -p 30000 --pl postgres12 --db temporal_visibility create
./temporal-sql-tool -u temporal --pw temporal_password -p 30000 --pl postgres12 --db temporal setup-schema -v 0.0
./temporal-sql-tool -u temporal --pw temporal_password -p 30000 --pl postgres12 --db temporal update-schema -d ./schema/postgresql/v12/temporal/versioned
./temporal-sql-tool -u temporal --pw temporal_password -p 30000 --pl postgres12 --db temporal_visibility setup-schema -v 0.0
./temporal-sql-tool -u temporal --pw temporal_password -p 30000 --pl postgres12 --db temporal_visibility update-schema -d ./schema/postgresql/v12/visibility/versioned
cd ../

kubectl --context $CONTEXT apply -f ./config/temporal.yaml

docker build -t temporal-app:0.0.1 -f ./test-app/Dockerfile ./test-app
k3d image import temporal-app:0.0.1 --cluster temporal

sleep 10

kubectl --context $CONTEXT apply -f ./config/temporal-worker-slow.yaml
kubectl --context $CONTEXT wait --for=condition=ready pod -l app=temporal-worker
kubectl --context $CONTEXT apply -f ./config/temporal-client.yaml