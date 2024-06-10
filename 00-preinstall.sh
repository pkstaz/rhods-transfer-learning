read -p "Enter cluster wildcard [apps.cluster-xxxxx.sandbox0000.opentlc.com]: " wildcard
wildcard=${wildcard:-Dont forget set a wildcard}
echo $wildcard

###############################
## Create necessary projects ##
###############################
oc new-project central
oc apply -f deployment/central/minio.yaml

mc alias set minio-central https://minio-api-central.$WILDCARD minio minio123
mc mb minio-central/workbench
mc mb minio-central/edge1-data
mc mb minio-central/edge1-models
mc mb minio-central/edge1-ready










echo "#####################################"
echo "######### DON'T FORGET THIS #########"
echo "#####################################"
echo "export WILDCARD="$wildcard
echo "#####################################"