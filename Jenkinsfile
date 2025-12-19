
// =================================================================
// CẤU HÌNH PHÊ DUYỆT THEO USER (THAY THẾ GROUPS)
// CHỈNH SỬA các biến này với TÊN TÀI KHOẢN JENKINS thực tế của bạn
// =================================================================
def DEV_APPROVERS_LIST = 'project_dev'        // Ví dụ: Team Dev
def MANAGER_APPROVERS_LIST = 'hungdn'  // Ví dụ: Manager/Leader
// =================================================================

pipeline {
    agent {
        label 'auto_deploy'
    }

    stages {
        stage('Stage 1: Build and push image with kaniko') {
            steps {
                script {
                    // Tạo Tag động cho Docker Image
                    env.IMAGE_TAG = "nickgia002/demo_jenkins_${BRANCH_NAME}:v${BUILD_NUMBER}"
                }

                withCredentials([usernamePassword(
                    credentialsId: 'docker-registry-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) container('kaniko') {
                        sh """
                        /kaniko/executor --context `pwd` \
                          --dockerfile Dockerfile \
                          --destination ${IMAGE_TAG}
                        """
                    }
            }
        }

        stage('Stage 2: Approval') {
            steps {
                script {
                    def approvers
                    def branchName = env.BRANCH_NAME
                    
                    if (branchName == 'main') {
                        // NHÁNH MAIN (Production): CHỈ Manager/Leader phê duyệt
                        approvers = MANAGER_APPROVERS_LIST
                        echo "Chờ phê duyệt triển khai Production từ: ${approvers}"
                    } else if (branchName == 'develop') {
                        // NHÁNH DEVELOP: Cả Dev Team VÀ Manager/Leader đều có quyền phê duyệt
                        // Nối hai danh sách người dùng
                        approvers = "${DEV_APPROVERS_LIST}, ${MANAGER_APPROVERS_LIST}" 
                        echo "Chờ phê duyệt triển khai Development từ: ${approvers}"
                    } else {
                        // Các nhánh khác: Mặc định Dev Team phê duyệt
                        approvers = DEV_APPROVERS_LIST
                        echo "Chờ phê duyệt triển khai Feature/Fix từ: ${approvers}"
                    }
                    
                    // Input step chờ user approve
                    input(
                        id: 'Approval', 
                        message: "Bạn có đồng ý tiếp tục triển khai cho nhánh [${branchName}] không?", 
                        ok: 'Yes - Deploy', 
                        // SỬ DỤNG DANH SÁCH NGƯỜI DÙNG ĐỘNG
                        submitter: approvers 
                    )

                    // Lưu trạng thái approval
                    env.APPROVED = 'true'
                }
            }
        }

        stage('Stage 3: Deploy to Dev') {
            when {
                // CHỈ CHẠY TRÊN NHÁNH DEVELOP (VÀ ĐÃ ĐƯỢC PHÊ DUYỆT)
                allOf {
                    branch 'develop'
                    expression { env.APPROVED == 'true' }
                }
            }
            script {
                    // Tạo Tag động cho Docker Image
                    env.CHART_PATH = "~/helm/oxii-work/oxii-work-chart/"
                }
            steps {
                container('helm') {
                        sh """
                        helm upgrade --install test -n test ${CHART_PATH}
                        """
                    }
            }
        }
        
        stage('Stage 4: Deploy to Prod') {
            when {
                // CHỈ CHẠY TRÊN NHÁNH MAIN (VÀ ĐÃ ĐƯỢC PHÊ DUYỆT)
                allOf {
                    branch 'main'
                    expression { env.APPROVED == 'true' }
                }
            }
            steps {
                echo "Deploy on production"
            }
        }
    }

    post {
        always {
            cleanWs() // Dọn sạch workspace sau khi job kết thúc
        }
    }
}
