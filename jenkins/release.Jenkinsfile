// Release de UN servicio: construye la imagen desde su repo, la sube a GHCR y,
// con aprobación del líder, la despliega en el VPS (backup + rollback automático).
def SERVICES = [
  'ms-iam'         : [repo: 'iam-backend',            tagVar: 'MS_IAM_TAG'],
  'ms-places'      : [repo: 'ms-places',              tagVar: 'MS_PLACES_TAG'],
  'ms-device'      : [repo: 'ms-device',              tagVar: 'MS_DEVICE_TAG'],
  'ms-consumption' : [repo: 'ms-consumption',         tagVar: 'MS_CONSUMPTION_TAG'],
  'ms-valve'       : [repo: 'ms-valve',               tagVar: 'MS_VALVE_TAG'],
  'ms-notification': [repo: 'ms-notification',        tagVar: 'MS_NOTIFICATION_TAG'],
  'api-gateway'    : [repo: 'api-gateway',            tagVar: 'API_GATEWAY_TAG'],
  'web'            : [repo: 'cuida-tu-agua-frontNEW', tagVar: 'WEB_TAG'],
]

pipeline {
  agent any
  options {
    timestamps()
    disableConcurrentBuilds()                       // un release a la vez
    buildDiscarder(logRotator(numToKeepStr: '30'))
  }
  parameters {
    choice(name: 'SERVICE', choices: ['ms-iam', 'ms-places', 'ms-device', 'ms-consumption',
                                      'ms-valve', 'ms-notification', 'api-gateway', 'web'],
           description: 'Servicio a liberar')
    string(name: 'REF', defaultValue: 'main', description: 'Rama a construir (producción = main)')
    booleanParam(name: 'SOLO_PUBLICAR', defaultValue: false,
                 description: 'Solo construir y subir a GHCR, sin aprobar ni desplegar')
  }
  environment {
    REGISTRY       = 'ghcr.io/cuida-tu-agua'
    VPS            = 'deploy@2.24.75.148'
    INFRA_DIR      = '/opt/cuidatuagua/infra'
    PUBLIC_API_URL = 'https://api.sy-water.tech'   // solo lo usa la imagen web (queda dentro del bundle)
    APPROVER       = 'esteban'
    SSH_OPTS       = '-o UserKnownHostsFile=/var/jenkins_home/.ssh/known_hosts -o StrictHostKeyChecking=yes'
  }

  stages {
    stage('Checkout') {
      steps {
        script {
          def svc = SERVICES[params.SERVICE]
          env.TAG_VAR = svc.tagVar
          env.IMAGE   = "${env.REGISTRY}/${params.SERVICE}"
          dir('src') {
            deleteDir()
            git url: "https://github.com/cuida-tu-agua/${svc.repo}.git",
                branch: params.REF, credentialsId: 'github-token'
            env.TAG = sh(script: 'git rev-parse --short=7 HEAD', returnStdout: true).trim()
          }
          currentBuild.displayName = "#${env.BUILD_NUMBER} ${params.SERVICE}:${env.TAG}"
        }
      }
    }

    stage('Construir imagen') {
      steps {
        dir('src') {
          sh '''
            set -eu
            EXTRA=""
            if [ "$SERVICE" = "web" ]; then
              EXTRA="--build-arg EXPO_PUBLIC_API_URL=$PUBLIC_API_URL/iam
                     --build-arg EXPO_PUBLIC_PLACES_API_URL=$PUBLIC_API_URL/places
                     --build-arg EXPO_PUBLIC_DEVICES_API_URL=$PUBLIC_API_URL/devices
                     --build-arg EXPO_PUBLIC_CONSUMPTION_API_URL=$PUBLIC_API_URL/consumption
                     --build-arg EXPO_PUBLIC_VALVE_API_URL=$PUBLIC_API_URL/valve
                     --build-arg EXPO_PUBLIC_NOTIFICATIONS_API_URL=$PUBLIC_API_URL/notifications"
            fi
            docker build --pull $EXTRA -t "$IMAGE:$TAG" .
          '''
        }
      }
    }

    stage('Publicar en GHCR') {
      steps {
        withCredentials([usernamePassword(credentialsId: 'github-token',
                                          usernameVariable: 'GH_USER', passwordVariable: 'GH_TOKEN')]) {
          sh '''
            set -eu
            echo "$GH_TOKEN" | docker login ghcr.io -u "$GH_USER" --password-stdin
            docker push "$IMAGE:$TAG"
            docker logout ghcr.io
          '''
        }
      }
    }

    stage('Aprobación') {
      when { expression { !params.SOLO_PUBLICAR } }
      steps {
        timeout(time: 30, unit: 'MINUTES') {
          input message: "¿Desplegar ${params.SERVICE}:${env.TAG} en PRODUCCIÓN?",
                ok: 'Desplegar', submitter: env.APPROVER
        }
      }
    }

    stage('Desplegar') {
      when { expression { !params.SOLO_PUBLICAR } }
      steps {
        sshagent(credentials: ['vps-ssh']) {
          sh 'ssh $SSH_OPTS "$VPS" "cd $INFRA_DIR && bash scripts/deploy-service.sh $SERVICE $TAG_VAR $TAG"'
        }
      }
    }
  }

  post {
    always { sh 'docker image rm "$IMAGE:$TAG" || true' }   // no llenar el disco de tu PC
  }
}