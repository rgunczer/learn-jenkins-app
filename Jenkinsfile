pipeline {
    agent any

    environment {
        NETLIFY_SITE_ID = '640cb4b2-fb93-44d1-a033-3d56219c0740'
        NETLIFY_AUTH_TOKEN = credentials('netlify-token')
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

        stage('Tests') {
            parallel {

                stage('Unit Test') {
                    agent {
                        docker {
                            image 'node:18-alpine'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            ls -la
                            ls -la build
                            test -f build/index.html
                            npm test
                        '''
                    }
                    post {
                        always {
                            junit 'jest-results/junit.xml'
                        }
                    }
                }

                stage('E2E') {
                    agent {
                        docker {
                            image 'mcr.microsoft.com/playwright:v1.61.0-noble'
                            reuseNode true
                        }
                    }
                    steps {
                        sh '''
                            npm install serve
                            node_modules/.bin/serve -s build &
                            sleep 10
                            npx playwright test --reporter=html
                        '''
                    }
                    post {
                        always {
                            publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Playwright Local', reportTitles: 'Playwright Test Results', useWrapperFileDirectly: true])
                        }
                    }
                }

            }
        }

        stage('Deploy staging') {
            agent {
                docker {
                    image 'node:18-alpine'
                    reuseNode true
                }
            }

            steps {
                sh '''
                    npm i netlify-cli node-jq
                    node_modules/.bin/netlify --version
                    echo "Deploying to Netlify staging, site id: [$NETLIFY_SITE_ID]"
                    node_modules/.bin/netlify status
                    # node_modules/.bin/netlify deploy --dir=build --no-build --json > deploy-output.json
                    node_modules/.bin/netlify deploy --dir=build --no-build --json | tee deploy-output.json
                    node_modules/.bin/node-jq -r '.deploy_url' deploy-output.json
                '''
                script {
                    env.STAGING_URL = sh(script: "node_modules/.bin/node-jq -r '.deploy_url' deploy-output.json", returnStdout: true)
                }
            }
        }

        stage('Staging E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.61.0-noble'
                    reuseNode true
                }
            }

            environment {
                CI_ENVIRONMENT_URL = "$env.STAGING_URL"
            }

            steps {
                sh '''
                    npx playwright test --reporter=html
                '''
            }
            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Staging E2E', reportTitles: 'Playwright Test Results', useWrapperFileDirectly: true])
                }
            }
        }

        stage('Approval') {
            steps {
                timeout(time: 15, unit: 'MINUTES') {
                    input message: 'Do you wish to deploy to PROD?', ok: 'Yes, I am sure'
                }
            }
        }

        stage('Prod Deploy and E2E') {
            agent {
                docker {
                    image 'mcr.microsoft.com/playwright:v1.61.0-noble'
                    reuseNode true
                }
            }

            environment {
                CI_ENVIRONMENT_URL = 'https://legendary-rugelach-97178a.netlify.app'
            }

            steps {
                sh '''
                    node --version
                    npm i netlify-cli
                    node_modules/.bin/netlify --version
                    echo "Deploying to Netlify production, site id: [$NETLIFY_SITE_ID]"
                    node_modules/.bin/netlify status
                    node_modules/.bin/netlify deploy --dir=build --prod --no-build
                    npx playwright test --reporter=html
                '''
            }
            post {
                always {
                    publishHTML([allowMissing: false, alwaysLinkToLastBuild: false, icon: '', keepAll: false, reportDir: 'playwright-report', reportFiles: 'index.html', reportName: 'Production E2E', reportTitles: 'Playwright Test Results', useWrapperFileDirectly: true])
                }
            }
        }

    }

}