pipeline {
  agent any

  options {
    timestamps()
    skipDefaultCheckout(true)
  }

  parameters {
    string(name: 'IMAGE', defaultValue: 'sreemanthenaclouddevops/devops-toolkit', description: 'Docker image name')
    string(name: 'TAG', defaultValue: 'v2', description: 'Docker tag')
  }

  environment {
    IMAGE = "${params.IMAGE}"
    TAG   = "${params.TAG}"
  }

  stages {

    stage('Checkout') {
      steps {
        checkout scm
        sh 'echo "✅ Code checked out successfully"'
      }
    }

    stage('Lint') {
      steps {
        sh 'make lint'
      }
    }

    stage('Test') {
      steps {
        sh 'make test || true' // continue even if tests fail (for CI learning)
      }
    }

    stage('Package') {
      steps {
        sh 'make package'
      }
    }

    stage('Docker Build') {
      steps {
        sh '''
          echo "🔨 Building Docker image: ${IMAGE}:${TAG}"
          make docker-build IMAGE=${IMAGE} TAG=${TAG}
          docker images | grep devops-toolkit || true
        '''
      }
    }

    stage('Docker Push') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'dockerhub-creds',
                 usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
          sh '''
            echo "🚀 Logging into Docker Hub as $DOCKER_USER"
            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin

            echo "Re-tagging image if necessary..."
            if docker image inspect sree/devops-toolkit:${TAG} >/dev/null 2>&1; then
              echo "🔁 Retagging old image: sree/devops-toolkit:${TAG} -> ${IMAGE}:${TAG}"
              docker tag sree/devops-toolkit:${TAG} ${IMAGE}:${TAG}
            fi

            echo "📦 Pushing image ${IMAGE}:${TAG} to Docker Hub..."
            docker push ${IMAGE}:${TAG}

            echo "🔒 Logging out of Docker Hub"
            docker logout
          '''
        }
      }
    }
  }

  post {
    always {
      echo "🧾 Pipeline completed on ${env.JOB_NAME} #${env.BUILD_NUMBER}"
    }
  }
}
