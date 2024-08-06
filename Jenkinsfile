pipeline {
    agent any

    stages {
        // This is a comment
        /*
            multiline comment
        */
        /*
        stage('Build') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    ls -la
                    node --version
                    npm --version
                    npm ci
                    npm run build
                    ls -la
                '''
            }
        }
        */
        stage('Test') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    echo 'Test stage'
                    test build/index.html
                    npm test
                '''
            }
        }

        stage('E2E') {
            agent {
                docker {
                    // image 'mcr.microsoft.com/playwright:v1.46.0-jammy'
                    image 'mcr.microsoft.com/playwright:v1.39.0-jammy'
                    reuseNode true
                }
            }
            steps {
                sh '''
                    echo 'E2E stage'
                    npm i serve
                    node_modules/.bin/serve -s build &
                    sleep 10
                    npx playwright test --reporter=html
                '''
            }
        }
    }

    post {
        always {
            junit 'jest-results/junit.xml'
        }
    }
}
