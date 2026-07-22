pipeline {
    agent any

    environment {
        DOCKER_IMAGE = 'flarum-headless-app'
    }

    stages {
        stage('Lint Compose Syntax') {
            steps {
                // Load environment variables from .env file or default them so warnings don't throw off compose
                sh 'docker compose -f docker-compose.yml config'
            }
        }

        stage('Build Image Artifact') {
            steps {
                sh "docker build -t ${DOCKER_IMAGE}:${BUILD_NUMBER} -f docker/Dockerfile ."
            }
        }

        stage('Deploy Stack to EC2') {
            steps {
                sh '''
                    # Copy .env.example to .env if .env doesn't exist yet
                    if [ ! -f .env ]; then cp .env.example .env; fi
                    
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
