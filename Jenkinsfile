node {
    def EC2_IP = '13.217.92.54'

    try {
        stage('Checkout') {
            checkout scm
        }

        stage('Lint Compose Syntax') {
            sh 'docker compose -f docker-compose.yml config'
        }

        stage('Deploy to Remote EC2') {
            sshagent(credentials: ['ec2-ssh-key']) {
                sh '''
                    ssh -o StrictHostKeyChecking=no ubuntu@13.217.92.54 << 'EOF'
                        if [ ! -d FLARUM1 ]; then
                            git clone https://github.com/DHAYALANKANIAPPAN/FLARUM1.git
                        fi
                        cd FLARUM1
                        git fetch origin main
                        git reset --hard origin/main
                        if [ ! -f .env ] && [ -f .env.example ]; then cp .env.example .env; fi

                        mkdir -p frontend

                        docker compose -f docker-compose.yml down --remove-orphans
                        docker rm -f flarum1-app flarum1-db-1 flarum1-nginx-1 || true
                        docker compose -f docker-compose.yml up -d --build
                    EOF
                '''
            }
        }
    } finally {
        stage('Cleanup') {
            sh 'docker image prune -f'
        }
    }
}pipeline {
    agent any

    environment {
        EC2_IP = '13.217.92.54'
    }

    stages {
        stage('Lint Compose Syntax') {
            steps {
                sh 'docker compose -f docker-compose.yml config'
            }
        }

        stage('Deploy to Remote EC2') {
            steps {
                sshagent(credentials: ['ec2-ssh-key']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ubuntu@13.217.92.54 << 'EOF'
                            if [ ! -d FLARUM1 ]; then
                                git clone https://github.com/DHAYALANKANIAPPAN/FLARUM1.git
                            fi
                            cd FLARUM1
                            git fetch origin main
                            git reset --hard origin/main
                            if [ ! -f .env ] && [ -f .env.example ]; then cp .env.example .env; fi

                            mkdir -p frontend

                            docker compose -f docker-compose.yml down --remove-orphans
                            docker rm -f flarum1-app flarum1-db-1 flarum1-nginx-1 || true
                            docker compose -f docker-compose.yml up -d --build
                        EOF
                    '''
                }
            }
        }
    }

    post {
        always {
            sh 'docker image prune -f'
        }
    }
}pipeline {
    agent any

    environment {
        EC2_IP = '13.217.92.54'
    }

    stages {
        stage('Lint Compose Syntax') {
            steps {
                sh 'docker compose -f docker-compose.yml config'
            }
        }

        stage('Deploy to Remote EC2') {
            steps {
                sshagent(credentials: ['ec2-ssh-key']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ubuntu@13.217.92.54 << 'EOF'
                            if [ ! -d FLARUM1 ]; then
                                git clone https://github.com/DHAYALANKANIAPPAN/FLARUM1.git
                            fi
                            cd FLARUM1
                            git fetch origin main
                            git reset --hard origin/main
                            if [ ! -f .env ] && [ -f .env.example ]; then cp .env.example .env; fi

                            mkdir -p frontend

                            docker compose -f docker-compose.yml down --remove-orphans
                            docker rm -f flarum1-app flarum1-db-1 flarum1-nginx-1 || true
                            docker compose -f docker-compose.yml up -d --build
                        EOF
                    '''
                }
            }
        }
    }

    post {
        always {
            sh 'docker image prune -f'
        }
    }
}
