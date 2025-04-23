pipeline {
    agent any

    environment {
        // Docker image name based on your DockerHub username and repo
        DOCKER_IMAGE = 'ansharora5971/heart-disease-prediction:latest'
        DOCKER_CLIENT_TIMEOUT = '300'
        COMPOSE_HTTP_TIMEOUT = '300'
    }

    triggers {
        githubPush() // Auto-trigger on GitHub push
    }

    stages {

        stage('Checkout Source Code') {
            steps {
                checkout scm // Uses the Git repo configured in the Jenkins job
            }
        }

        stage('Install Dependencies (Pre-check)') {
            steps {
                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                    sh '''
                        echo "Installing dependencies..."
                        pip install -r requirements.txt
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    withEnv(["DOCKER_CLIENT_TIMEOUT=${DOCKER_CLIENT_TIMEOUT}", "COMPOSE_HTTP_TIMEOUT=${COMPOSE_HTTP_TIMEOUT}"]) {
                        echo "Building Docker image: ${DOCKER_IMAGE}"
                        docker.build("${DOCKER_IMAGE}")
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh '''
                            echo "Logging into Docker Hub..."
                            docker login -u $DOCKER_USER -p $DOCKER_PASS
                            echo "Pushing Docker image to Docker Hub..."
                            docker push ${DOCKER_IMAGE}
                        '''
                    }
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    echo "Cleaning up old container if it exists..."
                    sh "docker rm -f heart-disease-container || true"

                    echo "Deploying new container from image ${DOCKER_IMAGE}..."
                    sh "docker run -d --name heart-disease-container -p 5000:5000 ${DOCKER_IMAGE}"
                }
            }
        }
    }

    post {
        success {
            mail to: 'ansharora5971@gmail.com',
                 subject: "✅ Build Success - #${env.BUILD_NUMBER}",
                 body: """Hello Ansh,

Your Jenkins pipeline for Heart Disease Prediction has executed **successfully**.

🛠️ Build Number: #${env.BUILD_NUMBER}
📦 Docker Image: ${DOCKER_IMAGE}

Regards,
Jenkins
"""
        }

        failure {
            mail to: 'ansharora5971@gmail.com',
                 subject: "❌ Build Failure - #${env.BUILD_NUMBER}",
                 body: """Hello Ansh,

Your Jenkins pipeline for Heart Disease Prediction has **failed**.

Please check the Jenkins logs for more information.

Regards,
Jenkins
"""
        }
    }
}
