# CI/CD Pipeline
## Tools used
- Git
- Docker
- Jenkins
- Nexus
- SonarQube
- Helm
- datree.io


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



## Errors
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