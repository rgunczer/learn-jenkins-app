pipeline {
    agent any

    environment {
        REACT_APP_VERSION = "1.2.$BUILD_ID"
        AWS_DEFAULT_REGION = "us-east-1"
    }

    stages {

        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    echo 'Small change...'
                    ls -la
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    ls -la
                '''
            }
        }

        stage('Deploy to AWS') {
            agent {
                docker {
                    image 'amazon/aws-cli'
                    args "--entrypoint=''"
                    reuseNode true
                }
            }
            environment {
                AWS_S3_BUCKET = 'learn-jenkins-20260720'
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'my-aws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        aws --version
                        # aws s3 ls
                        # echo "Hello S3 from Jenkins" > index.html
                        # aws s3 cp index.html s3://$AWS_S3_BUCKET/index.html
                        aws s3 sync build s3://$AWS_S3_BUCKET

                        aws ecs register-task-definition --cli-input-json file://aws/task-definition-prod.json


                        aws ecs update-service --cluster learn-jenkins-app-cluster-prod --service LearnJenkinsApp-Service-Prod  --task-definition LearnJenkinsApp-TaskDefinition-Prod:2
                    '''
                }
            }
        }

    }

}