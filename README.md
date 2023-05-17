# CI/CD Pipeline
## Tools used
- Git
- Docker
- Jenkins
- Nexus
- SonarQube
- Helm
- 


## Steps
### Create 5 EC2 instances (Jenkins, Nexus, Sonarqube, Master Node, Worker Node)

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
- add the code to jenkinsfile to use the mail server
```
post {
		always {
			mail bcc: '', body: "<br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> URL de build: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', subject: "${currentBuild.result} CI: Project name -> ${env.JOB_NAME}", to: "deekshith.snsep@gmail.com";  
		}
	}
```




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
If you manage to to get a workaround for the graphical login, this should do the job :
```
sudo chgrp docker /lib/systemd/system/docker.socket
sudo chmod g+w /lib/systemd/system/docker.socket
```