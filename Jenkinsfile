pipeline {
    agent any

    environment {
        REACT_APP_VERSION = "1.2.$BUILD_ID"
        APP_NAME = "learnjenkinsapp"
        AWS_DEFAULT_REGION = "us-east-1"
        AWS_DOCKER_REGISTRY = "414012778050.dkr.ecr.us-east-1.amazonaws.com"
        AWS_ECS_CLUSTER = "learn-jenkins-app-cluster-prod"
        AWS_ECS_SERVICE_PROD = "LearnJenkinsApp-Service-Prod"
        AWS_ECS_TD_PROD = "LearnJenkinsApp-TaskDefinition-Prod"
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

        stage('Build Docker image') {
            agent {
                docker {
                    image 'my-aws-cli'
                    args "-u root -v /var/run/docker.sock:/var/run/docker.sock --entrypoint=''"
                    reuseNode true
                }
            }
            steps {
                withCredentials([usernamePassword(credentialsId: 'my-aws', passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {
                    sh '''
                        # yum install -y docker
                        docker --version
                        docker build -t $AWS_DOCKER_REGISTRY/$APP_NAME:$REACT_APP_VERSION .
                        aws ecr get-login-password | docker login --username AWS --password-stdin $AWS_DOCKER_REGISTRY
                    '''
                }
            }
        }

        stage('Deploy to AWS') {
            agent {
                docker {
                    image 'my-aws-cli'
                    args "-u root --entrypoint=''"
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
                        # yum install jq -y
                        # aws s3 ls
                        # echo "Hello S3 from Jenkins" > index.html
                        # aws s3 cp index.html s3://$AWS_S3_BUCKET/index.html
                        aws s3 sync build s3://$AWS_S3_BUCKET

                        LATEST_TD_REVISION=$(aws ecs register-task-definition --cli-input-json file://aws/task-definition-prod.json | jq '.taskDefinition.revision')
                        echo $LATEST_TD_REVISION

                        aws ecs update-service --cluster $AWS_ECS_CLUSTER --service $AWS_ECS_SERVICE_PROD  --task-definition $AWS_ECS_TD_PROD:$LATEST_TD_REVISION

                        aws ecs wait services-stable --cluster $AWS_ECS_CLUSTER --services $AWS_ECS_SERVICE_PROD
                    '''
                }
            }
        }

    }

}