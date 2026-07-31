pipeline {
    agent any

    environment {
        REACT_APP_VERSION = "1.2.$BUILD_ID"
        AWS_DEFAULT_REGION = "us-east-1"
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
                    image 'amazon/aws-cli'
                    args "-u root --entrypoint=''"
                    reuseNode true
                }
            }
            steps {
                sh '''
                    # 1. Update packages and install curl + tar
                    yum install -y curl tar

                    # 2. Download the official static binary archive
                    curl -fsSL https://docker.com -o docker.tgz

                    # 3. Extract ONLY the docker client binary
                    tar -xzf docker.tgz --strip-components=1 docker/docker

                    # 4. Move it to your local bin directory (Sudo isn't needed; you are already root)
                    mv docker /usr/local/bin/

                    # 5. Clean up the downloaded archive
                    rm docker.tgz

                    # 6. Verify the client works
                    docker --version

                    docker build -t myjenkinsapp .
                '''
            }
        }

        stage('Deploy to AWS') {
            agent {
                docker {
                    image 'amazon/aws-cli'
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
                        yum install jq -y
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