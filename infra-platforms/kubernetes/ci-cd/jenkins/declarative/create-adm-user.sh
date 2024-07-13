#!/bin/bash

# Definir colores para la salida de terminal
YELLOW="\033[1;33m"
BLUE="\033[1;34m"
NC="\033[0m" # Sin color

#!/bin/bash

# Obtener el nombre del pod de Jenkins
JENKINS_POD=$(kubectl get pods -n jenkins-ns -o jsonpath='{.items[0].metadata.name}')
JENKINS_CONFIG_PATH="/var/jenkins_home/config.xml"
JENKINS_INSTALL_STATE="/var/jenkins_home/jenkins.install.UpgradeWizard.state"
JENKINS_INSTALL_UTIL="/var/jenkins_home/jenkins.install.InstallUtil.lastExecVersion"
JENKINS_INSTALL_RUN_SETUP="/var/jenkins_home/jenkins.install.runSetupWizard"

echo -e "${YELLOW}JENKINS_POD: ${JENKINS_POD}${NC}"

# Crear el archivo XML de las credenciales
kubectl exec -it --namespace=jenkins-ns "pod/$JENKINS_POD" -- bash -c "echo '<securityRealm class=\"hudson.security.HudsonPrivateSecurityRealm\">
    <disableSignup>true</disableSignup>
    <enableCaptcha>false</enableCaptcha>
    <users>
        <user>
            <id>admin</id>
            <password>gladiator</password>
        </user>
    </users>
</securityRealm>
<authorizationStrategy class=\"hudson.security.FullControlOnceLoggedInAuthorizationStrategy\">
    <denyAnonymousReadAccess>true</denyAnonymousReadAccess>
</authorizationStrategy>' > $JENKINS_CONFIG_PATH"

echo -e "${BLUE}Credentials file created at : ${JENKINS_POD}${NC}"
kubectl exec -it --namespace=jenkins-ns "pod/$JENKINS_POD" -- cat $JENKINS_CONFIG_PATH


# Deshabilitar el wizard de instalación
echo -e "${YELLOW}Disable installation wizard : ${JENKINS_POD}${NC}"
kubectl exec -it --namespace=jenkins-ns "pod/$JENKINS_POD" -- bash -c "echo '2.0' > $JENKINS_INSTALL_STATE"
kubectl exec -it --namespace=jenkins-ns "pod/$JENKINS_POD" -- bash -c "echo '2.0' > $JENKINS_INSTALL_UTIL"
#kubectl exec -it --namespace=jenkins-ns "pod/$JENKINS_POD" -- bash -c "echo 'false' > $JENKINS_INSTALL_RUN_SETUP"
echo -e "${BLUE}Wizard disabled${NC}"

echo "Usuario administrador creado y wizard de instalación deshabilitado."
