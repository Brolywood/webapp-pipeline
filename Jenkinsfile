pipeline {
	agent any
    tools {
		maven 'apache-maven-3.5.2'
	}
    environment {
        TERRAFORM_HOME = tool name: 'terraform', type: 'com.cloudbees.jenkins.plugins.customtools.CustomTool'
        PATH = "$TERRAFORM_HOME:$PATH"
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        REGISTRY_AUTH = credentials("dockerhub-credentials")
        IMAGE_NAME = "${REGISTRY_AUTH_USR}/webapp"
        TAGGED_IMAGE_NAME = "${IMAGE_NAME}:${env.BUILD_ID}"
    }    
	stages {
		stage('Build') {
			steps {
				echo 'Building...'
				sh "mvn clean install"
			}
 		}
		stage('Package') {
			steps {	
				echo 'Packaging...'
                sh "docker build -t ${TAGGED_IMAGE_NAME} ."                 
			}
 		}
        stage('Publish') {
			steps {
				echo 'Publishing...'
                sh '''
                    docker login -u=${REGISTRY_AUTH_USR} -p=${REGISTRY_AUTH_PSW}
                    docker tag ${TAGGED_IMAGE_NAME} ${IMAGE_NAME}:latest
                    docker push ${TAGGED_IMAGE_NAME}
                    docker push ${IMAGE_NAME}:latest
                '''
			}
        }         
		stage('Plan') {
			steps {
                dir("deployment") {
                    echo 'Planning....'
                    sh "terraform init"
                    sh "terraform get -update=true"
                    sh "terraform plan -input=false -out=tfplan -var \"docker_image=${TAGGED_IMAGE_NAME}\" -var \"aws_access_key=${AWS_ACCESS_KEY_ID}\" -var \"aws_secret_key=${AWS_SECRET_ACCESS_KEY}\""
                }
			}
		}	
		stage('Deploy') {
			steps {
                dir("deployment") {
                    echo 'Deploying....'
                    sh "terraform apply -input=false tfplan "
                }
			}
		}	
		stage('Test') {
			steps {
                dir("deployment") {
                    echo 'Testing...'
                    sh "terraform show"
                }
			}
		}
	}
}

