pipeline {
    agent any

    stages {
        stage('Stage 1: Demo Task') {
            steps {
                echo 'Running Stage 1...'
            }
        }

        stage('Stage 2: Approval') {
            steps {
                script {
                    // Input step chờ user approve
                    def userInput = input(
                        id: 'Approval', message: 'Do you approve to continue to Stage 3?', ok: 'Yes', submitter: 'team-lead'
                    )

                    // Lưu trạng thái approval vào env để stage tiếp theo đọc
                    env.APPROVED = 'true'
                }
            }
        }

        stage('Stage 3: Post-Approval Task') {
            when {
                expression { env.APPROVED == 'true' }
            }
            steps {
                echo 'Running Stage 3 because approval was granted.'
            }
        }
    }
}

