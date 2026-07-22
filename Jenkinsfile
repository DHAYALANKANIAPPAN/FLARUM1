pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'flarum-headless-app'
        REGISTRY_TAG = "flarum:${BUILD_NUMBER}"
    }

    stages {
        stage('Lint Compose Syntax') {
            steps {
                sh 'docker compose -f docker-compose.yml config'
            }
        }

        stage('Build Image Artifact') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${REGISTRY_TAG} -f docker/Dockerfile ."
            }
        }

        stage('Deploy Stack to EC2') {
            steps {
                sh '''
                    docker compose -f docker-compose.yml up -d --build
                    docker exec $(docker ps -q -f name=app) php flarum cache:clear || true
                '''
            }
        }
    }

    post {
        always {
            sh 'docker image prune -f'
        }
    }
}
