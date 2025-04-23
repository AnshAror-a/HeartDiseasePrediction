pipeline {
    agent any

    environment {
        // Docker image name based on your DockerHub username and repo
        DOCKER_IMAGE = 'ansharora5971/heart-disease-prediction:latest'
        DOCKER_CLIENT_TIMEOUT = '300'
        COMPOSE_HTTP_TIMEOUT = '300'
    }

    triggers {
        githubPush() // Auto trigger on GitHub push
    }

    stages {

        stage('Clone Repository') {
            steps {
                git 'https://github.com/AnshAror-a/HeartDiseasePrediction.git'
            }
        }

        stage('Install Dependencies (Optional for Pre-check)') {
            steps {
                sh 'pip install -r requirements.txt'
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    withEnv(["DOCKER_CLIENT_TIMEOUT=${DOCKER_CLIENT_TIMEOUT}", "COMPOSE_HTTP_TIMEOUT=${COMPOSE_HTTP_TIMEOUT}"]) {
                        docker.build("${DOCKER_IMAGE}")
                    }
                }
            }
        }

        stage('Push to Docker Hub') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh """
                            echo Logging in to Docker Hub...
                            docker login -u $DOCKER_USER -p $DOCKER_PASS
                            docker push ${DOCKER_IMAGE}
                        """
                    }
                }
            }
        }

        stage('Deploy Container') {
            steps {
                script {
                    // Remove previous container if running
                    sh "docker rm -f heart-disease-container || true"
                    // Run new container on port 5000
                    sh "docker run -d --name heart-disease-container -p 5000:5000 ${DOCKER_IMAGE}"
                }
            }
        }
    }

    post {
        success {
            mail to: 'ansharora5971@gmail.com',
                 subject: "✅ Build Success - #${env.BUILD_NUMBER}",
                 body: "Heart Disease Prediction pipeline executed successfully!"
        }

        failure {
            mail to: 'ansharora5971@gmail.com',
                 subject: "❌ Build Failure - #${env.BUILD_NUMBER}",
                 body: "Jenkins pipeline failed. Please check the logs."
        }
    }
}
