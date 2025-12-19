def DEV_APPROVERS_LIST = 'project_dev'
def MANAGER_APPROVERS_LIST = 'hungdn'

pipeline {
    agent {
        // Sử dụng label của Cloud Kubernetes bạn đã cấu hình
        label 'auto_deploy' 
    }

    stages {
        stage('Stage 1: Build and push image with kaniko') {
            steps {
                container('kaniko') {
                    script {
                        // Khởi tạo Tag cho Image
                        env.IMAGE_TAG = "nickgia002/demo_jenkins_${BRANCH_NAME}:v${BUILD_NUMBER}"
                        
                        // Sử dụng credentials để push image
                        withCredentials([usernamePassword(
                            credentialsId: 'docker-registry-credentials',
                            usernameVariable: 'DOCKER_USER',
                            passwordVariable: 'DOCKER_PASS'
                        )]) {
                            sh """
                            /kaniko/executor --context ${WORKSPACE} \
                              --dockerfile Dockerfile \
                              --destination ${env.IMAGE_TAG}
                            """
                        }
                    }
                }
            }
        }

        stage('Stage 2: Approval') {
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

        stage('Stage 3: Deploy to Dev') {
            when {
                allOf {
                    branch 'develop'
                    expression { env.APPROVED == 'true' }
                }
            }
            steps {
                container('helm') {
                    script {
                        // Khai báo PATH và thực hiện deploy
                        def CHART_PATH = "helm/oxii-work/oxii-work-chart/"
                        sh "helm upgrade --install test -n test ${CHART_PATH} --set image.tag=v${BUILD_NUMBER}"
                    }
                }
            }
        }
        
        stage('Stage 4: Deploy to Prod') {
            when {
                allOf {
                    branch 'main'
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
