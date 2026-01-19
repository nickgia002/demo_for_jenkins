def DEV_APPROVERS_LIST = 'duclh'
def MANAGER_APPROVERS_LIST = 'hungdn, admin'
pipeline {
    agent {
        label 'docker'
    }

    stages {
        stage('Stage 2: Build and push image with kaniko') {
            steps {
                script {
                    echo "ssh running!"
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
