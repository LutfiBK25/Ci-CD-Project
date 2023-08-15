pipeline{
    agent any
    environment{
        VERSION = "${env.BUILD_ID}"
    }
    stages{
        stage("sonar_quality_check"){
            
            steps{
                script{
                    withSonarQubeEnv(credentialsId: 'sonar-token') {
                            sh 'chmod +x gradlew' //give a perm to gradlew to excute
                            sh './gradlew sonarqube' //help push code to sonar qube to check against the sonar rules
                    }
                     timeout(time: 1, unit: 'HOURS') { //check if status is okay with QualityGate as it meets the quality gate requirements
                      def qg = waitForQualityGate()
                      if (qg.status != 'OK') {
                           error "Pipeline aborted due to quality gate failure: ${qg.status}"
                      }
                    }
                }
            }
        
        }
        stage("docker build & push"){
            steps{
                script{
                    withCredentials([string(credentialsId: 'nexus_pass', variable: 'nexus_password')]) {
                    sh '''
                    docker build -t 54.173.32.46:8083/devopsproj1:${VERSION} .
                    docker login -u admin -p $nexus_password 54.173.32.46:8083
                    docker push  54.173.32.46:8083/devopsproj1:${VERSION}
                    docker rmi  54.173.32.46:8083/devopsproj1:${VERSION}
                    '''
                    }
                    
                }
            }
        }
        stage("identifying misconfigs using datree in helm charts"){
            steps{
                script{
                    dir('kubernetes/') {
                        // Jenkins didn't see that datree is installed so i installed datree using jenkins 
                        // sh 'helm plugin uninstall datree'
                        // sh 'helm plugin install https://github.com/datreeio/helm-datree'
                        
                        withEnv(['DATREE_TOKEN=b96e3fa8-80a7-48a0-9c81-43e7063307e9']) {
                              sh 'helm datree test myapp/'
                        }
                    }
                }
            }
        }
        stage("pushing helm charts to nexus"){
            steps{
                script{
                    dir('kubernetes/') {
                        withCredentials([string(credentialsId: 'nexus_pass', variable: 'nexus_password')]) {
                        //next command is what push helm charts to nexus
                        //first command grabs the version of helm (Check grep_tutorial.txt)
                        //second command will create the artifact (it takes the folder (myapp) and create tgz)
                        sh '''
                        helmversion=$(helm show chart myapp | grep version | cut -d: -f 2 | tr -d ' ')
                        tar -czvf  myapp-${helmversion}.tgz myapp/
                        curl -u admin:$nexus_password http://54.173.32.46:8081/repository/helm-hosted/ --upload-file myapp-${helmversion}.tgz -v
                        '''
                        }
                    } 
                }
            }
        }
        stage("Deploying app to k8s cluster"){
            steps {
                script{
                    withKubeConfig(caCertificate: '', clusterName: '', contextName: '', credentialsId: 'mykubeconfig', namespace: '', restrictKubeConfigAccess: false, serverUrl: '') {
                        dir('kubernetes/') {
                            sh 'helm upgrade --install --set image.repository="54.173.32.46:8083/devopsproj1" --set image.tag="${VERSION}" myjavaapp myapp/ '
                        }
                    }
                }
            }
        }
    }
    post{
        always{ // always means it will happen if it was sucess or fail
            echo "${VERSION}"
            mail bcc: '', body: "<br>Project: ${env.JOB_NAME} <br>Build Number: ${env.BUILD_NUMBER} <br> URL de build: ${env.BUILD_URL}", cc: '', charset: 'UTF-8', from: '', mimeType: 'text/html', replyTo: '', subject: "${currentBuild.result} CI: Project name -> ${env.JOB_NAME}", to: "lutfibk25@gmail.com";
	
        }
        
    }
}