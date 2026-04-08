def DEV_APPROVERS_LIST = 'duclh'
def MANAGER_APPROVERS_LIST = 'admin'
pipeline {
    agent {
        label 'kubernetes'
    }

    stages {
        stage('Stage 1: Sonarqube') {
            steps {
                container('sonarqube') {
                    script {
                        env.SONAR_PRJ_KEY="app-demo"
                        env.SONAR_URL="http://argocd-sonarqube-demo-sonarqube.argocd-demo.svc.cluster.local:9000"
                        withCredentials([string(credentialsId: 'sonarqube-app-demo-token', variable: 'SONAR_PRJ_TOKEN')]) {      
                            sh '''
                                sonar-scanner -Dsonar.projectKey=${SONAR_PRJ_KEY} -Dsonar.sources=${WORKSPACE} -Dsonar.java.binaries=${WORKSPACE}/target -Dsonar.host.url=${SONAR_URL} -Dsonar.token=${SONAR_PRJ_TOKEN} -Dsonar.qualitygate.wait=true -Dsonar.qualitygate.timeout=300
                            '''
                        }
                    }
                }
            }
        }

        stage('Stage 1: Build and push image with kaniko') {
            steps {
                container('kaniko') {
                    script {
                        env.IMAGE_TAG = "nickgia002/app-demo:v_${BUILD_NUMBER}"
                        
                        withCredentials([usernamePassword(
                            credentialsId: 'nickgia002-dockerhub',
                            usernameVariable: 'DOCKER_USER',
                            passwordVariable: 'DOCKER_PASS'
                        )]) {
                            sh '''
                                AUTH=$(echo -n "${DOCKER_USER}:${DOCKER_PASS}" | base64 | tr -d '\\n')
                                echo "{\\"auths\\":{\\"https://index.docker.io/v1/\\":{\\"auth\\":\\"$AUTH\\"}}}" > /kaniko/.docker/config.json
                                /kaniko/executor --context ${WORKSPACE} --dockerfile Dockerfile --destination ${env.IMAGE_TAG} --ignore-path=/workspace
                            '''
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
        
        stage('Stage 3: Prepare helm chart') {
            when {
                allOf {
                    branch 'main'
                    expression { env.APPROVED == 'true' }
                }
            }
            steps {
                container ('base') {
                    script {
                        withCredentials([usernamePassword(
                            credentialsId: 'github-credential',
                            usernameVariable: 'GITHUB_USER',
                            passwordVariable: 'GITHUB_PASS'
                        )]) {
                            sh '''
                                git clone https://${GITHUB_USER}:${GITHUB_PASS}@github.com/nickgia002/argo-cd.git
                            '''
                            dir('argo-cd') {
                                sh """
                                    sed -i 's/tag: .*/tag: "v_${BUILD_NUMBER}"/g' app-demo/values.yaml
                                """

                                sh """
                                    git config user.email "lehuynhduczxc@gmail.com"
                                    git config user.name "Le Huynh Duc"
                                
                                    git add app-demo/values.yaml
                                    
                                    # Kiểm tra xem có thay đổi gì không trước khi commit
                                    if ! git diff-index --quiet HEAD; then
                                        git commit -m "image update for app-deo: v_${BUILD_NUMBER} [skip ci]"
                                        git push origin main
                                    else
                                        echo "No changes to commit"
                                    fi
                                """
                            }
                        }
                    }
                }
            }
        }
    }
}
