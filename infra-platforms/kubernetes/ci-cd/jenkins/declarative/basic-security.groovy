#!groovy

import jenkins.model.*
import hudson.security.*
import jenkins.install.InstallState
import jenkins.security.s2m.AdminWhitelistRule

def instance = Jenkins.getInstance()

// Set up security
println "--> Configuring security"
def hudsonRealm = new HudsonPrivateSecurityRealm(false)
hudsonRealm.createAccount("admin", "gladiator")
instance.setSecurityRealm(hudsonRealm)
def strategy = new FullControlOnceLoggedInAuthorizationStrategy()
instance.setAuthorizationStrategy(strategy)

// Disable Jenkins CLI over Remoting
instance.getDescriptor("jenkins.CLI").get().setEnabled(false)

// Disable old Non-Encrypted protocols
instance.getAgentProtocols().removeAll(Arrays.asList("JNLP3-connect", "JNLP2-connect", "JNLP-connect", "CLI-connect"))

// Enable CSRF protection
instance.getDescriptor("hudson.security.csrf.GlobalCrumbIssuerConfiguration").get().setCrumbIssuer(new DefaultCrumbIssuer(true))

// Setup API Token
Jenkins.instance.setInstallState(InstallState.INITIAL_SETUP_COMPLETED)

instance.save()

println "--> Jenkins configured successfully."
