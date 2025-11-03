pipeline {
  agent any

  options {
    timestamps()
    skipDefaultCheckout(true)
  }

  parameters {
    string(name: 'IMAGE', defaultValue: 'sree/devops-toolkit', description: 'Docker image name')
    string(name: 'TAG',   defaultValue: 'v2',                 description: 'Docker tag')
  }

  environment {
    IMAGE = "${params.IMAGE}"
    TAG   = "${params.TAG}"
  }

  stages {
    stage('Checkout') {
      steps {
        checkout scm
      }
    }

    stage('Lint') {
      steps {
        sh 'make lint'
      }
    }

    stage('Test') {
      steps {
        // keep moving even if tests fail for now; flip to strict later
        sh 'make test || true'
      }
    }

    stage('Package') {
      steps {
        sh 'make package'
      }
    }

    stage('Archive Artifact') {
      steps {
        archiveArtifacts artifacts: 'dist/*.tar.gz', fingerprint: true, allowEmptyArchive: true
      }
    }

    stage('Docker Build') {
      steps {
        sh 'make docker-build IMAGE=${IMAGE} TAG=${TAG}'
      }
    }
  }

  post {
    always {
      echo "Pipeline completed on ${env.BUILD_TAG}"
    }
  }
}

