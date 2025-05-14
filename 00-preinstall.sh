OCP_DOMAIN=$(oc get IngressController default -n openshift-ingress-operator -o json | jq -r '.status.domain')

###############################
## Create necessary projects ##
###############################
oc new-project central
oc apply -f deployment/central/minio.yaml

mc alias set minio-central https://minio-api-central.$OCP_DOMAIN minio minio123
mc mb minio-central/workbench
mc mb minio-central/edge1-data
mc mb minio-central/edge1-models
mc mb minio-central/edge1-ready

mc cp --recursive dataset/images minio-central/edge1-data/


oc new-project edge1
oc apply -f deployment/edge/amq-broker.yaml
oc create route edge broker-amq-mqtt --service broker-amq-mqtt-0-svc

oc apply -f deployment/edge/minio.yaml
mc alias set minio-edge1 https://minio-api-edge1.$OCP_DOMAIN minio minio123
mc mb minio-edge1/production
mc mb minio-edge1/data
mc mb minio-edge1/valid
mc mb minio-edge1/unclassified


oc project central
curl https://skupper.io/install.sh | sh
export PATH="/home/user/.local/bin:$PATH"
skupper init --enable-console --enable-flow-collector --console-auth unsecured
skupper token create edge_to_central.token

oc project edge1
skupper init
skupper link create edge_to_central.token --name edge-to-central

oc project central 
kubectl annotate service minio-service skupper.io/proxy=http skupper.io/address=minio-central

oc project edge1
oc create route edge --service=minio-central --port=port9090

