def DEV_APPROVERS_LIST = 'duclh'
def MANAGER_APPROVERS_LIST = 'hungdn, admin'

sonar-scanner \
  -Dsonar.projectKey=test-scan \
  -Dsonar.sources=. \
  -Dsonar.host.url=https://sonarqube.smarthiz.com \
  -Dsonar.token=sqp_b09d635e4da7f8ec801048a9236e2660aebc60f7


pipeline {
    agent none

    stages {
        stage('Stage 1: Scan code with sonarqube') {
            agent {
                label 'sonar-scanner'
            }
            steps {
                container(sonar-scanner) {
                    script {
                        sonar-scanner \
                            -Dsonar.projectKey=test-scan \
                            -Dsonar.sources=. \
                            -Dsonar.host.url=https://sonarqube.smarthiz.com \
                            -Dsonar.token=sqp_b09d635e4da7f8ec801048a9236e2660aebc60f7
                    }
                }
            }
        }

        stage('Stage 2: Build and push image with kaniko') {
            steps {
                container('openssh') {
                    script {
                        echo "ssh running!"
                    }
                }
            }
        }

        stage('Stage 3: Approval') {
            steps {
                script {
                    def approvers
                    def branchName = env.BRANCH_NAME
                    
                    if (branchName == 'main') {
                        approvers = MANAGER_APPROVERS_LIST
                        echo "Chờ phê duyệt triển khai Production từ: ${approvers}"
                    } else if (branchName == 'develop') {
                        approvers = "${DEV_APPROVERS_LIST},${MANAGER_APPROVERS_LIST}" 
                        echo "Chờ phê duyệt triển khai Development từ: ${approvers}"
                    } else {
                        approvers = DEV_APPROVERS_LIST
                        echo "Chờ phê duyệt triển khai Feature/Fix từ: ${approvers}"
                    }
                    
                    input(
                        id: 'Approval', 
                        message: "Bạn có đồng ý tiếp tục triển khai cho nhánh [${branchName}] không?", 
                        ok: 'Yes - Deploy', 
                        submitter: approvers 
                    )
                    env.APPROVED = 'true'
                }
            }
        }
        
        stage('Stage 4: Deploy to Prod') {
            when {
                allOf {
                    branch 'develop'
                    expression { env.APPROVED == 'true' }
                }
            }
            steps {
                echo "Deploy on production"
                // Thêm lệnh deploy Production tương tự Stage 3 ở đây
            }
        }
    }
}
