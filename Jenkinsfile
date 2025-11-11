pipeline {
    agent any



    stages {
        stage('Stage 1: Build and push image') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-registry-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                sh '''
                    docker build -t nickgia002/demo_jenkins_${BRANCH_NAME}:v${BUILD_NUMBER} .
                    echo $DOCKER_PASS | docker login docker.io -u $DOCKER_USER --password-stdin
                    docker push nickgia002/demo_jenkins_${BRANCH_NAME}:v${BUILD_NUMBER}

                '''
                }
            }
        }

        stage('Stage 2: Approval') {
            steps {
                script {
                    // Input step chờ user approve
                    def userInput = input(
                        id: 'Approval', message: 'Do you approve to continue to Stage 3?', ok: 'Yes', submitter: 'tpb'
                    )

                    // Lưu trạng thái approval vào env để stage tiếp theo đọc
                    env.APPROVED = 'true'
                }
            }
        }

        stage('Stage 3: Deploy') {
            when {
                expression { env.APPROVED == 'true' }
            }
            steps {
                sh '''
                    docker stop demoJenkins && docker rm demoJenkins
                    docker run -tid --name demoJenkins -p 9090:9090 nickgia002/demo_jenkins_${BRANCH_NAME}:v${BUILD_NUMBER}
                '''
            }
        }
    }

    post {
        always {
            cleanWs()  // Dọn sạch workspace sau khi job kết thúc
        }
    }

}