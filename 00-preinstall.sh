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

