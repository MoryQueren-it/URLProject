pipeline {
    agent any

    stages {
        stage('Checkout') {
            steps {
                git branch: 'master', url: 'https://github.com/MoryQueren-it/URLProject.git'
            }
        }

        stage('Verification des fichiers') {
            steps {
                sh '''
                    test -f app.py
                    test -f requirements.txt
                    test -f Dockerfile
                    test -f run.sh
                '''
            }
        }

        stage('Build & Deploy') {
            steps {
                sh '''
                    chmod +x run.sh
                    ./run.sh
                '''
            }
        }

        stage('Test & Verification') {
            steps {
                sh '''
                    docker run --rm --entrypoint python quicklink-app -m py_compile app.py
                    sleep 2
                    docker ps --filter "name=quicklink" --format "table {{.Names}}\\t{{.Status}}\\t{{.Ports}}"
                '''
            }
        }
    }

    post {
        success {
            echo 'Pipeline QuickLink reussi : application deployee sur http://localhost:7000'
        }
        failure {
            echo 'Le pipeline QuickLink a echoue. Verifie la Console Output.'
        }
    }
}