pipeline{
    agent any
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
    }
    post{
        always{
            echo "Sucess"
        }
        
    }
}