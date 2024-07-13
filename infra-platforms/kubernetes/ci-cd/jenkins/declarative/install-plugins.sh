#!/bin/bash

# Definir colores para la salida de terminal
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m" # Sin color


# Obtener el nombre del pod de Jenkins
JENKINS_POD=$(kubectl get pods -n jenkins-ns -o jsonpath='{.items[0].metadata.name}')
JENKINS_URL="http://localhost:8080"
JENKINS_USER="admin"
JENKINS_TOKEN=$(kubectl exec -it $JENKINS_POD -n jenkins-ns -- cat /var/jenkins_home/secrets/initialAdminPassword | tr -d '\r')
CLI_JAR="jenkins-cli.jar"
FILE_NAME="/tmp/install_plugins.sh"
K8_WORKER_NODE_IP=$(kubectl describe "pods/$JENKINS_POD" -n jenkins-ns | grep "Node:"| awk '{print $2}' | cut -d '/' -f 2)

# Variables para la creacion del usuario admin
CREDENTIALS_XML="/tmp/admin-credentials.xml"

# Imprimir las variables en color amarillo
echo -e "${YELLOW}JENKINS_POD: ${JENKINS_POD}${NC}"
echo -e "${YELLOW}JENKINS_URL: ${JENKINS_URL}${NC}"
echo -e "${YELLOW}JENKINS_USER: ${JENKINS_USER}${NC}"
echo -e "${YELLOW}JENKINS_TOKEN: ${JENKINS_TOKEN}${NC}"
echo -e "${YELLOW}CLI_JAR: ${CLI_JAR}${NC}"
echo -e "${YELLOW}FILE_NAME: ${FILE_NAME}${NC}"


# Crear un archivo temporal con el contenido especificado
cat <<EOF > $FILE_NAME
# List of plugins to install
PLUGINS=(
  ant
  antisamy-markup-formatter
  apache-httpcomponents-client-4-api
  asm-api
  bootstrap5-api
  bouncycastle-api
  branch-api
  build-timeout
  caffeine-api
  caffeine-api.jpi
  checks-api
  checks-api.jpi
  cloudbees-folder
  cloudbees-folder.jpi
  commons-lang3-api
  commons-lang3-api.jpi
  commons-text-api
  commons-text-api.jpi
  config-file-provider
  config-file-provider.jpi
  configuration-as-code
  configuration-as-code.jpi
  coverage
  coverage.jpi
  credentials
  credentials-binding
  dark-theme
  dashboard-view
  data-tables-api
  display-url-api
  durable-task
  echarts-api
  eddsa-api
  email-ext
  font-awesome-api
  forensics-api
  git
  git-client
  github
  github-api
  github-branch-source
  gradle
  gson-api
  instance-identity
  ionicons-api
  jackson2-api
  jakarta-activation-api
  jakarta-mail-api
  javax-activation-api
  javax-mail-api
  jaxb
  jjwt-api
  joda-time-api
  jquery3-api
  json-api
  json-path-api
  junit
  ldap
  mailer
  matrix-auth
  matrix-project
  metrics
  mina-sshd-api-common
  mina-sshd-api-core
  nodejs
  okhttp-api
  pam-auth
  pipeline-build-step
  pipeline-github-lib
  pipeline-graph-analysis
  pipeline-graph-view
  pipeline-groovy-lib
  pipeline-input-step
  pipeline-milestone-step
  pipeline-model-api
  pipeline-model-definition
  pipeline-model-extensions
  pipeline-stage-step
  pipeline-stage-tags-metadata
  plain-credentials
  plugin-util-api
  prism-api
  resource-disposer
  scm-api
  script-security
  snakeyaml-api
  ssh-credentials
  ssh-slaves
  structs
  theme-manager
  timestamper
  token-macro
  trilead-api
  variant
  workflow-aggregator
  workflow-api
  workflow-basic-steps
  workflow-cps
  workflow-durable-task-step
  workflow-job
  workflow-multibranch
  workflow-scm-step
  workflow-step-api
  workflow-support
  ws-cleanup
)

cd /tmp
pwd
ls -al


# Function to install a plugin
install_plugin() {
  java -jar $CLI_JAR -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_TOKEN install-plugin \$1
}

# Install plugins
for plugin in "\${PLUGINS[@]}"; do
  echo "Installing plugin: \$plugin"
  install_plugin \$plugin
done


# Restart Jenkins to apply changes
echo "Restarting Jenkins to apply changes"
java -jar $CLI_JAR -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_TOKEN safe-restart
exit
EOF

kubectl cp --namespace=jenkins-ns "basic-security.groovy" $JENKINS_POD:"/usr/share/jenkins/ref/init.groovy.d/"

# Hacer que el archivo sea ejecutable
chmod +x $FILE_NAME

echo -e "${YELLOW}Downloading http://$K8_WORKER_NODE_IP:32000/jnlpJars/$CLI_JAR${NC}"
wget "http://$K8_WORKER_NODE_IP:32000/jnlpJars/$CLI_JAR"  -O "/tmp/$CLI_JAR"
#kubectl exec -it --namespace=jenkins-ns "pod/$JENKINS_POD" -- bash -c "sed -i '/<securityRealm>/,/<\/authorizationStrategy>/c\<securityRealm class=\"hudson.security.HudsonPrivateSecurityRealm\">\n  <disableSignup>true</disableSignup>\n  <enableCaptcha>false</enableCaptcha>\n</securityRealm>\n<authorizationStrategy class=\"hudson.security.FullControlOnceLoggedInAuthorizationStrategy\">\n  <denyAnonymousReadAccess>true</denyAnonymousReadAccess>\n</authorizationStrategy>' /var/jenkins_home/config.xml"
# Copiar adm file y el script al pod y ejecutarlo
echo -e "${YELLOW}Copy the script file $JENKINS_POD:/tmp/$CLI_JAR${NC}"
kubectl cp --namespace=jenkins-ns "/tmp/$CLI_JAR" $JENKINS_POD:"/tmp/$CLI_JAR"
kubectl cp --namespace=jenkins-ns $FILE_NAME $JENKINS_POD:$FILE_NAME
kubectl exec -it --namespace=jenkins-ns "pod/$JENKINS_POD" -- bash $FILE_NAME

rm "/tmp/$CLI_JAR"
rm $FILE_NAME

# Esperar a que reinicie jenkins
echo -e "${BLUE}Waiting for restart jenkins${NC}"
for s in $(seq 120 -10 10); do
    echo "Waiting $s seconds..."
    sleep 10
done

echo -e "${YELLOW}Proceed to create adm user${NC}"
./create-adm-user.sh

echo -e "${YELLOW}Proceed to configuring tools${NC}"
./configure-tools.sh

echo "Try http://$K8_WORKER_NODE_IP:32000 in your browser for jenkins server"
