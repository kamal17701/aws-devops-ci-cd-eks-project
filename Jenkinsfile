// Jenkins Declarative Pipeline
// Equivalent to the GitHub Actions workflow — use this if you prefer Jenkins
// Configure these in Jenkins → Manage Jenkins → Credentials:
//   - AWS_CREDENTIALS_ID : AWS access key + secret
//   - ECR_REGISTRY       : <account_id>.dkr.ecr.ap-south-1.amazonaws.com

pipeline {

    agent any

    environment {
        AWS_REGION       = 'ap-south-1'
        ECR_REPOSITORY   = 'kamalapp'
        EKS_CLUSTER_NAME = 'kamal-eks-cluster'
        IMAGE_TAG        = "${env.GIT_COMMIT[0..6]}"
    }

    tools {
        maven 'Maven-3.9'
        jdk   'JDK-17'
    }

    options {
        timestamps()
        buildDiscarder(logRotator(numToKeepStr: '10'))
        timeout(time: 30, unit: 'MINUTES')
    }

    stages {

        stage('Checkout') {
            steps {
                checkout scm
                echo "Branch: ${env.BRANCH_NAME} | Commit: ${env.GIT_COMMIT}"
            }
        }

        stage('Build & Unit Test') {
            steps {
                sh 'mvn clean package --batch-mode --no-transfer-progress'
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
                }
            }
        }

        stage('Docker Build') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                      credentialsId: 'AWS_CREDENTIALS_ID']]) {
                        def ecrLogin = sh(
                            script: "aws ecr get-login-password --region ${AWS_REGION}",
                            returnStdout: true
                        ).trim()

                        env.ECR_REGISTRY = sh(
                            script: "aws ecr describe-repositories \
                                       --repository-names ${ECR_REPOSITORY} \
                                       --region ${AWS_REGION} \
                                       --query 'repositories[0].repositoryUri' \
                                       --output text",
                            returnStdout: true
                        ).trim()

                        sh """
                            echo "${ecrLogin}" | docker login \
                              --username AWS \
                              --password-stdin ${env.ECR_REGISTRY}

                            docker build \
                              -t ${env.ECR_REGISTRY}:${IMAGE_TAG} \
                              -t ${env.ECR_REGISTRY}:latest \
                              .
                        """
                    }
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                      credentialsId: 'AWS_CREDENTIALS_ID']]) {
                        sh """
                            docker push ${env.ECR_REGISTRY}:${IMAGE_TAG}
                            docker push ${env.ECR_REGISTRY}:latest
                            echo "✅ Pushed: ${env.ECR_REGISTRY}:${IMAGE_TAG}"
                        """
                    }
                }
            }
        }

        stage('Deploy to EKS') {
            when {
                branch 'main'
            }
            steps {
                script {
                    withCredentials([[$class: 'AmazonWebServicesCredentialsBinding',
                                      credentialsId: 'AWS_CREDENTIALS_ID']]) {
                        sh """
                            aws eks update-kubeconfig \
                              --region ${AWS_REGION} \
                              --name ${EKS_CLUSTER_NAME}

                            sed -i 's|IMAGE_PLACEHOLDER|${env.ECR_REGISTRY}:${IMAGE_TAG}|g' \
                              kubernetes/deployment.yaml

                            kubectl apply -f kubernetes/
                            kubectl rollout status deployment/kamalapp \
                              --namespace default \
                              --timeout=120s
                        """
                    }
                }
            }
        }

        stage('Health Check') {
            when {
                branch 'main'
            }
            steps {
                sh """
                    echo "=== Pod Status ==="
                    kubectl get pods -n default -l app=kamalapp

                    echo "=== Deployment ==="
                    kubectl get deployment kamalapp -n default
                """
            }
        }
    }

    post {
        success {
            echo "✅ Pipeline succeeded — ${env.ECR_REGISTRY}:${IMAGE_TAG} deployed to EKS"
        }
        failure {
            echo "❌ Pipeline failed — check logs above"
        }
        always {
            // Clean up local Docker images to save disk space
            sh 'docker image prune -f || true'
        }
    }
}
