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
        stage("dockerbuild & pudh"){
            steps{
                script{
                    withCredentials([string(credentialsId: 'nexus_pass', variable: 'nexus_password')]) {
                    sh '''
                    docker build -t 54.173.32.46:8083/devOpsProj1:$(VERSION) .
                    docker login -u admin -p $nexus_password 54.173.32.46:8083
                    docker push  54.173.32.46:8083/devOpsProj1:$(VERSION)
                    docker rmi  54.173.32.46:8083/devOpsProj1:$(VERSION)
                    '''
                    }
                    
                }
            }
        }
    }
    post{
        always{
            echo "Sucess"
        }
        
    }
}