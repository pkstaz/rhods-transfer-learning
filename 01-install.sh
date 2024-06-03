



#############################################
## Install Camel K Operator (cluster-wide) ##
## Red Hat Integration - Camel K           ##
## 1.10.5 provided by Red Hat              ##
#############################################





###################################################
## Deliver the AI/ML model and run the ML server ##
###################################################
## Deploy the Edge Manager.
cd camel/edge-manager/
oc project edge1
./mvnw clean package -DskipTests -Dquarkus.kubernetes.deploy=true
cd ../../

## Deploy the TensorFlow server.
oc project edge1
oc apply -f deployment/edge/tensorflow.yaml

## Run an inference request.
# cd client
# ./infer.sh
# cd ../

#######################################
## Create a trigger for the Pipeline ##
#######################################
## Create a Pipeline trigger.
oc project tf
oc apply -f deployment/pipeline/trigger-template.yaml
oc apply -f deployment/pipeline/trigger-binding.yaml
oc apply -f deployment/pipeline/event-listener.yaml

## Deploy a Kafka cluster
oc project central
oc apply -f deployment/central/kafka.yaml

## Deploy the Camel delivery system
oc project central
cd camel/central-delivery/
./mvnw clean package -DskipTests -Dquarkus.kubernetes.deploy=true
cd ../../

######################################
## Deploy the data ingestion system ##
######################################

## Deploy the Feeder
oc project central
cd camel/central-feeder/
./mvnw clean package -DskipTests -Dquarkus.kubernetes.deploy=true
cd ../../

## Expose the Feeder service to the Service Interconnect network 
## to allow edge1 to have visibility:
kubectl annotate service feeder skupper.io/proxy=http

#############################################
## Deploy the AI-powered (intelligent) App ##
#############################################

## Deploy the Price Engine (Catalogue).
oc project edge1
cd camel/edge-shopper/camel-price
oc create cm catalogue --from-file=catalogue.json -n edge1
kamel run price-engine.xml --resource configmap:catalogue@/deployments/config
cd ../../../

## Deploy the Edge Monitor.
oc project edge1
cd camel/edge-monitor/
./mvnw clean package -DskipTests -Dquarkus.kubernetes.deploy=true
cd ../../

## Deploy the Edge Shopper (Intelligent App).
oc project edge1
cd camel/edge-shopper/
./mvnw clean package -DskipTests -Dquarkus.kubernetes.deploy=true
oc create route edge camel-edge --service shopper
cd ../../