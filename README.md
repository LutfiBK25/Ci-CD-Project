Note: This project was finished but a lot didn't get documented as I switched to just learning and testing Jenkins Datree Helm Charts Sonar

# CI/CD Pipeline
## Tools used
- Git
- Docker
- Jenkins
- Nexus
- SonarQube
- Helm
- datree.io (they are retiring D:)


## Steps
### Preping my Enviroment
- Create 5 EC2 instances (Jenkins, Nexus, Sonarqube, Master Node, Worker Node)
- Configure Security groups and enable ports for all Jenkins/Nexus/Kubernets/Calico/SonarQube

- install datree plugin for helm on Jenkins (you are going to need unzip installed)
```
helm plugin install https://github.com/datreeio/helm-datree
```
### Configuring Mail server:
- Add Email Extention Plugin to Jenkins and add email in Configuere system
- in System Configuration: go to the E-mail Notification
- set the SMTP server (example : smtp.gmail.com ) 
- Enable use SMPT Authentication and Use SSL
- fill username and password with your email and pass (you can't user your password for google instead you have to create app password one)
- You could try authentification via "App password".<br />
On your Google account: <br />
1- set 2-Step Verification ON <br />
2- create 16-character "App password" ( https://support.google.com/mail/answer/185833?hl=en ) <br />
3- Instead of Google account password use 16-character password
- Set SMTP Port to 465
- check Test configuration and set the Test e-mail
- in Extended E-mail notification add the smtp server again and use same port
- in advanced setting add credentials again and check use SSL 
- Set default content type to HTML
- add the code in the post to jenkinsfile to use the mail server
```
			mail bcc: '', body: "<br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> URL de build: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', subject: "${currentBuild.result} CI: Project name -> ${env.JOB_NAME}", to: "deekshith.snsep@gmail.com";  
```

### Write the helm charts (It is in Kubernets Folder)

### Detecting misconfiguration in Helm Charts using datree
- add stage to jenkins files
- go to snippet generator in jenkins and get dir and type `kubernetes/` for path and generate
- using datree documentation to write the code https://github.com/datreeio/helm-datree
- add token and jenkinsfile datree script
- you can turn on and off policies from datree interfance in policies section
- policy errors i got i put at the end

### Pushing helm charts to private repo (nexus reg)
- in nexus; create a helm (hosted) repository and keep everything in default settings
- create stage in Jenkinsfile

### adding deploy helm charts to k8s cluster stage
- copy config from .kube in master node
- install k8s plugin
- in manage jenkins go to Manage Nodes and Clouds and through cloud add and kubernetes and add credential through file and copy config file in .kube in master node and upload it
- creating jenkins stage use kubeconfig syntax to handle the connection
- create a file /etc/docker/daemon.json in that file add details of nexus (create on both master and node)
```
{ "insecure-registries":["nexus_machine_ip:8083"] }
```
`systemctl restart docker`
- create a secret in k8s cluster master
```
kubectl create secret docker-registry registry-secret --docker-server=nexus_machine_ip_only:8083 --docker-username=admin --docker-password=admin --docker-email=not-needed@example.com
```

look in deployment.yaml to see the reference to registry secret

```
apiVersion: v1
kind: Pod
metadata:
  name: foo
spec:
  containers:
    - name: foo
      image: nginx
  imagePullSecrets:
    - name: registry-secret
```



## Errors

### Installing Kubectl kubeadm kubelet
- Problem : tried to rebuild the k8s cluster and i get this error ` The following signatures couldn't be verified because the public key is not available: NO_PUBKEY B53DC80D13EDEF05` apparentally google messed up or somthing
- found a replacement link `sudo curl -fsSLo /etc/apt/keyrings/kubernetes-archive-keyring.gpg https://dl.k8s.io/apt/doc/apt-key.gpg` when geting the gpg key instead of orginal gpg link

### Calico Nodes were not in ready state
- Solution: open BGP port TCP 179

### Building Dockerfile gave an error 
- ERROR: permission denied while trying to connect to the Docker daemon socket at unix:///var/run/docker.sock: Get "http://%2Fvar%2Frun%2Fdocker.sock/_ping": dial unix /var/run/docker.sock: connect: permission denied
- Solution:
in jenkins EC2
```
sudo chmod 666 /var/run/docker.sock
```
the first command should be enough but If you manage to to get a workaround for the graphical login, this should do the job :
```
sudo chgrp docker /lib/systemd/system/docker.socket
sudo chmod g+w /lib/systemd/system/docker.socket
```


### Jenkins EC2 storage full which stopped building pipelines
- Error : Your Jenkins data directory /var/lib/jenkins (AKA JENKINS_HOME) is almost full. You should act on it before it gets completely full.
- Solution: used `du -sh <directory>` to check file sizes and it was the docker directory in lib which has the overlay2 file so i used the following clear it. to cleanup unused containers and images
```
docker system prune
```
note : you can add a Crontab task for it to be cleaned regularly

### Jenkins kubectl command not found
- Problem : while testing connection of jenkins to k8s cluster, kubectl not found error happened
- Solution : downloaded ./kubectl once and started using it in the pipeline, change the version to the one needed
'''
sh 'curl -LO "https://storage.googleapis.com/kubernetes-release/release/v1.27.1/bin/linux/amd64 kubectl"'  
sh 'chmod u+x ./kubectl'
// to test kubectl working
sh './kubectl get nodes'
sh './kubectl version --short'
'''

### myapp pods giving CreateContainerConfigError in STATUS
- Problem: whern doing command `kubectl get all` they are not going into the ready state even after 60s (which i put in deployment).
- Analyzing: `kubectl get pods` show the pods with error and then using `kubectl logs <pod name>` gave me `waiting to start: CreateContainerConfigError` which i google next and then used command `kubectl describe pod <pod name>` and got ` Error: container has runAsNonRoot and image will run as root`
- Solution: added `runAsUser: 11000` to security context in depolyment.yaml

### myapp pods giving CrashLoopBackOff in STATUS
- Problem: when checking describe for the pods found the following error
```
  Warning  Unhealthy         21s (x3 over 31s)  kubelet            Liveness probe failed: Get "http://192.168.166.151:8080/": dial tcp 192.168.166.151:8080: connect: connection refused
  Normal   Killing           21s                kubelet            Container myapp failed liveness probe, will be restarted
  Warning  Unhealthy         1s (x8 over 31s)   kubelet            Readiness probe failed: Get "http://192.168.166.151:8080/": dial tcp 192.168.166.151:8080: connect: connection refused
```
-

### Datree Policies

[X] Policy check

[X]  Ensure seccomp profile is set to docker/default or runtime/default  [1 occurrence]
    - metadata.name: release-name-myapp (kind: Deployment)
      > key: spec.template.metadata (line: 43:7)

[*]  Invalid value for key `seccomp.security.alpha.kubernetes.io/pod` - set to docker/default or runtime/default to ensure restricted privileges

[X]  Ensure containers and pods have a configured security context  [1 occurrence]
    - metadata.name: release-name-myapp (kind: Deployment)

[*]  Missing key `securityContext` - set to enforce your containers' security and stability

[X]  Prevent the admission of containers with the NET_RAW capability  [1 occurrence]
    - metadata.name: release-name-myapp (kind: Deployment)
      > key: spec.template.spec.containers.0 (line: 50:11)

[*]  Invalid value for key `drop` - prohibit the potentially dangerous NET_RAW capability

[X]  Ensure each container has a read-only root filesystem  [1 occurrence]
    - metadata.name: release-name-myapp (kind: Deployment)
      > key: spec.template.spec.containers.0 (line: 50:11)

[*]  Incorrect value for key `readOnlyRootFilesystem` - set to 'true' to protect filesystem from potential attacks

[X]  Prevent container from running with root privileges  [1 occurrence]
    - metadata.name: release-name-myapp (kind: Deployment)
      > key: spec.template.spec.containers.0 (line: 50:11)

[*]  Invalid value for key `runAsNonRoot` - must be set to `true` to prevent unnecessary privileges

[X]  Prevent containers from escalating privileges  [1 occurrence]
    - metadata.name: release-name-myapp (kind: Deployment)
      > key: spec.template.spec.containers.0 (line: 50:11)

[*]  Missing key `allowPrivilegeEscalation` - set to false to prevent attackers from exploiting escalated container privileges


