pipeline {
    agent any

    environment {
        DOCKER_IMAGE = "bcloudacr.azurecr.io/samples/python-image:latest"
        ACR_CREDENTIALS_ID = 'acr-credentials-id'
        AKS_CREDENTIALS_ID = 'aks-credentials-id'
        AKS_RESOURCE_GROUP = 'Mustafa_Candidate'
        AKS_CLUSTER_NAME = 'bcloudaks'
        DOCKER_REGISTRY_URL = "bcloudacr.azurecr.io"
        AZURE_CLIENT_ID = credentials('azure-client-id')
        AZURE_TENANT_ID = credentials('azure-tenant-id')
        AZURE_CLIENT_SECRET = credentials('azure-client-secret')        
        
    }

    stages {
        stage('Checkout') {
            steps {
                script {
                    checkout scm
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    docker.build(DOCKER_IMAGE)
                }
            }
        }

        stage('Push Docker Image') {
            steps {
                script {
                    docker.withRegistry("https://${env.DOCKER_REGISTRY_URL}", ACR_CREDENTIALS_ID) {
                        docker.image(DOCKER_IMAGE).push()
                    }
                }
            }
        }

        stage('Deploy to AKS') {
            steps {
                // withCredentials([azureServicePrincipal(credentialsId: aks-credentials-id)]) {
                script {
                        sh """
                        az login --service-principal --username $AZURE_CLIENT_ID --password $AZURE_CLIENT_SECRET --tenant $AZURE_TENANT_ID 
                        az aks get-credentials --resource-group ${AKS_RESOURCE_GROUP} --name ${AKS_CLUSTER_NAME} 
                        kubectl apply -f k8s/deployment.yaml         
                        kubectl apply -f k8s/service.yaml
                        """
                    // }
                }
            }
        }
    }
}
