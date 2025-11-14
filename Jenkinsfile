// // Check the correctness of the trigger and checkout

// pipeline {
//     agent any



//     stages {
//         stage('Stage 1: Build and push image') {
//             steps {
//                 withCredentials([usernamePassword(
//                     credentialsId: 'docker-registry-credentials',
//                     usernameVariable: 'DOCKER_USER',
//                     passwordVariable: 'DOCKER_PASS'
//                 )]) {
//                 sh '''
//                     docker build -t nickgia002/demo_jenkins_${BRANCH_NAME}:v${BUILD_NUMBER} .
//                     echo $DOCKER_PASS | docker login docker.io -u $DOCKER_USER --password-stdin
//                     docker push nickgia002/demo_jenkins_${BRANCH_NAME}:v${BUILD_NUMBER}

//                 '''
//                 }
//             }
//         }

//         stage('Stage 2: Approval') {
//             steps {
//                 script {
//                     // Đặt tên nhóm hoặc các vai trò (groups/roles) được phép phê duyệt (tiền tố là ROLE_)
//                     // Ví dụ: Nhóm có tên "PRODUCTION_APPROVERS" và "ADMINS"
//                     def approverGroups = 'ROLE_PRODUCTION_APPROVERS, ROLE_ADMINS' 

//                     // Input step chờ user approve
//                     def userInput = input(
//                         id: 'Approval', 
//                         message: 'Do you approve to continue to Stage 3?', 
//                         ok: 'Yes', 
//                         // SỬ DỤNG DANH SÁCH NHÓM CÓ QUYỀN PHÊ DUYỆT
//                         submitter: approverGroups 
//                         // Lưu ý: Tùy thuộc vào plugin ủy quyền, bạn có thể cần thêm tiền tố (ví dụ: ROLE_)
//                     )

//                     env.APPROVED = 'true'
//                 }
//             }
//         }

//         stage('Stage 3: Deploy') {
//             when {
//                 expression { env.APPROVED == 'true' }
//             }
//             steps {
//                 sh '''
//                     docker stop demoJenkins && docker rm demoJenkins
//                     docker run -tid --name demoJenkins -p 9090:9090 nickgia002/demo_jenkins_${BRANCH_NAME}:v${BUILD_NUMBER}
//                 '''
//             }
//         }
//     }

//     post {
//     always {
//         cleanWs()  // Dọn sạch workspace sau khi job kết thúc
//         }
//     }

// }




// =================================================================
// CẤU HÌNH PHÊ DUYỆT THEO USER (THAY THẾ GROUPS)
// CHỈNH SỬA các biến này với TÊN TÀI KHOẢN JENKINS thực tế của bạn
// =================================================================
def DEV_APPROVERS_LIST = 'project1_dev'        // Ví dụ: Team Dev
def MANAGER_APPROVERS_LIST = 'hungdn'  // Ví dụ: Manager/Leader
// =================================================================

pipeline {
    agent any

    stages {
        stage('Stage 1: Build and push image') {
            steps {
                script {
                    // Tạo Tag động cho Docker Image
                    env.IMAGE_TAG = "nickgia002/demo_jenkins_${BRANCH_NAME}:v${BUILD_NUMBER}"
                }

                withCredentials([usernamePassword(
                    credentialsId: 'docker-registry-credentials',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh """
                    // Build Image
                    docker build -t ${IMAGE_TAG} .
                    
                    // Đăng nhập và Push Image lên Registry
                    echo \$DOCKER_PASS | docker login docker.io -u \$DOCKER_USER --password-stdin
                    docker push ${IMAGE_TAG}
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
            steps {
                sh """
                echo "Triển khai Image ${IMAGE_TAG} lên môi trường DEVELOPMENT..."
                // Dừng và xóa container hiện tại (dùng '|| true' để tránh lỗi nếu container không tồn tại)
                docker stop demoJenkins || true
                docker rm demoJenkins || true
                
                // Chạy container mới
                docker run -tid --name demoJenkins -p 9090:9090 ${IMAGE_TAG}
                """
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
                // Thay thế bằng lệnh deploy production thực tế của bạn
            }
        }
    }

    post {
        always {
            cleanWs() // Dọn sạch workspace sau khi job kết thúc
        }
    }
}