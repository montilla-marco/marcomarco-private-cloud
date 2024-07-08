#!/bin/bash


# Definir colores para la salida de terminal
YELLOW="\033[1;33m"
NC="\033[0m" # Sin color

# Obtener el nombre del pod de Jenkins
JENKINS_POD=$(kubectl get pods -n jenkins-ns -o jsonpath='{.items[0].metadata.name}')
JENKINS_URL="http://localhost:8080"
JENKINS_USER="admin"
JENKINS_TOKEN=$(kubectl exec -it $JENKINS_POD -n jenkins-ns -- cat /var/jenkins_home/secrets/initialAdminPassword | tr -d '\r')
CLI_JAR="jenkins-cli.jar"
FILE_NAME="/tmp/configure_tools.groovy"
K8_WORKER_NODE_IP=$(kubectl describe "pods/$JENKINS_POD" -n jenkins-ns | grep "Node:"| awk '{print $2}' | cut -d '/' -f 2)

echo -e "${YELLOW}JENKINS_POD: ${JENKINS_POD}${NC}"
echo -e "${YELLOW}JENKINS_URL: ${JENKINS_URL}${NC}"
echo -e "${YELLOW}JENKINS_USER: ${JENKINS_USER}${NC}"
echo -e "${YELLOW}JENKINS_TOKEN: ${JENKINS_TOKEN}${NC}"
echo -e "${YELLOW}CLI_JAR: ${CLI_JAR}${NC}"
echo -e "${YELLOW}FILE_NAME: ${FILE_NAME}${NC}"

# Groovy script to configure JDK and Maven
cat <<EOF > $FILE_NAME
import jenkins.model.*
import hudson.tools.*
import hudson.tasks.*

def instance = Jenkins.getInstance()

// Configure JDK
def jdkDesc = instance.getDescriptorByType(hudson.model.JDK.DescriptorImpl)
def installations = []
def jdkHome = "/opt/java/openjdk/"
def jdk = new JDK("OpenJDK 64-Bit Server VM Temurin-17.0.11+9", jdkHome)
installations += jdk
jdkDesc.setInstallations(installations as JDK[])
jdkDesc.save()

// Configure Maven
def mavenDesc = instance.getDescriptorByType(hudson.tasks.Maven.DescriptorImpl)
def mavenInstallations = []
def mavenHome = "/usr/share/maven"
def maven = new Maven.MavenInstallation("Maven3", mavenHome, [])
mavenInstallations += maven
mavenDesc.setInstallations(mavenInstallations as Maven.MavenInstallation[])
mavenDesc.save()

instance.save()
EOF

echo -e "${YELLOW}Downloading http://$K8_WORKER_NODE_IP:32000/jnlpJars/$CLI_JAR${NC}"
wget "http://$K8_WORKER_NODE_IP:32000/jnlpJars/$CLI_JAR"  -O "/tmp/$CLI_JAR"
echo -e "${YELLOW}Getting and copy the cli-jar file /tmp/$CLI_JAR $JENKINS_POD:/tmp/$CLI_JAR${NC}"
kubectl cp --namespace=jenkins-ns "/tmp/$CLI_JAR" $JENKINS_POD:"/tmp/$CLI_JAR"

# Copiar el script al pod y ejecutarlo
echo -e "${YELLOW}Copy the script file $JENKINS_POD:/tmp/$CLI_JAR${NC}"


kubectl cp --namespace=jenkins-ns $FILE_NAME $JENKINS_POD:$FILE_NAME
# Run Groovy script
echo -e "${YELLOW}Run Groovy script${NC}"
kubectl exec --namespace=jenkins-ns "pod/$JENKINS_POD" -- ls -al /tmp
kubectl exec --namespace=jenkins-ns "pod/$JENKINS_POD" -- java -jar "/tmp/$CLI_JAR" -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_TOKEN groovy = < $FILE_NAME

# Accede al contenedor de Jenkins
POD_NAME=$(kubectl get pods --namespace jenkins -l "app.kubernetes.io/component=jenkins-controller" -o jsonpath="{.items[0].metadata.name}")

# Crear el archivo para deshabilitar el wizard
kubectl exec --namespace=jenkins-ns "pod/$JENKINS_POD" -- bash -c 'echo "2.0" > /var/jenkins_home/jenkins.install.UpgradeWizard.state'

# Reiniciar el pod de Jenkins
kubectl delete pod "pod/$JENKINS_POD" --namespace=jenkins-ns

# Esperar a que reinicie pod
echo -e "${BLUE}Waiting for pod redeploy${NC}"
for s in $(seq 20 -10 10); do
    echo "Waiting $s seconds..."
    sleep 10
done

# Clean up
rm $FILE_NAME
