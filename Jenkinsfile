pipeline {
    agent any

    environment {
        EC2_IP = '16.16.159.159'
    }

    stages {
        stage('Lint Compose Syntax') {
            steps {
                sh 'docker compose -f docker-compose.yml config'
            }
        }

        stage('Deploy to Remote EC2') {
            steps {
                sshagent(['ec2-ssh-key']) {
                    sh '''
                        ssh -o StrictHostKeyChecking=no ubuntu@${EC2_IP} "
                            if [ ! -d FLARUM1 ]; then
                                git clone https://github.com/DHAYALANKANIAPPAN/FLARUM1.git
                            fi
                            cd FLARUM1
                            git pull origin main
                            if [ ! -f .env ]; then cp .env.example .env; fi
                            
                            # Ensure the frontend folder exists on the host/volume mapping if needed
                            mkdir -p frontend
                            
                            docker compose -f docker-compose.yml down
                            docker compose -f docker-compose.yml up -d --build
                        "
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
