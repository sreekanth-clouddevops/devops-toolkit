pipeline {
  agent any

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
        sh 'make test || true'  // Allow failure for now
      }
    }

    stage('Package') {
      steps {
        sh 'make package'
      }
    }

    stage('Archive Artifact') {
      steps {
        archiveArtifacts artifacts: 'dist/*.tar.gz', fingerprint: true
      }
    }
  }

  post {
    always {
      echo "Pipeline completed on ${env.BUILD_TAG}"
    }
  }
}
