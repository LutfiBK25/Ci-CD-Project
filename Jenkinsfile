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