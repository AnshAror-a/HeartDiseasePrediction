pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'ansharora5971/heart-disease-prediction:latest'
        DOCKER_CLIENT_TIMEOUT = '300'
        COMPOSE_HTTP_TIMEOUT = '300'
    }

    triggers {
        githubPush()
    }

    stages {
        stage('Checkout Source Code') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies (Pre-check)') {
            steps {
                catchError(buildResult: 'FAILURE', stageResult: 'FAILURE') {
                    bat 'pip install -r requirements.txt'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    withEnv(["DOCKER_CLIENT_TIMEOUT=${DOCKER_CLIENT_TIMEOUT}", "COMPOSE_HTTP_TIMEOUT=${COMPOSE_HTTP_TIMEOUT}"]) {
                        bat "docker build -t ${DOCKER_IMAGE} ."
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        bat """
                            docker login -u %DOCKER_USER% -p %DOCKER_PASS%
                            docker push ${DOCKER_IMAGE}
                        """
                    }
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    // Remove any previous instance of the container
                    bat "docker rm -f heart-disease-container || exit 0"
                    
                    // Run the container
                    bat "docker run -d --name heart-disease-container -p 5000:5000 ${DOCKER_IMAGE}"

                    // Check if the container is running
                    bat "docker ps"

                    // Fetch logs from the container to troubleshoot
                    bat "docker logs heart-disease-container"
                }
            }
        }
    }

    post {
        success {
            mail to: 'ansharora5971@gmail.com',
                 subject: "✅ Build Success - #${env.BUILD_NUMBER}",
                 body: """Hello Ansh,

Your Jenkins pipeline for Heart Disease Prediction has executed successfully.

🛠️ Build Number: #${env.BUILD_NUMBER}
📦 Docker Image: ${DOCKER_IMAGE}
"""
        }

        failure {
            mail to: 'ansharora5971@gmail.com',
                 subject: "❌ Build Failure - #${env.BUILD_NUMBER}",
                 body: """Hello Ansh,

Your Jenkins pipeline has failed. Please check logs in Jenkins for more details.

🛠️ Build Number: #${env.BUILD_NUMBER}
"""
        }
    }
}
