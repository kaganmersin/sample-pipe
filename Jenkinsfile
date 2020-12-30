import java.text.SimpleDateFormat
def RUN_MAVEN='/bin/mvn'

pipeline {
    triggers {
        gitlab(triggerOnPush: true, triggerOnMergeRequest: true, branchFilterType: 'All')
    }
    options { timestamps () }
	agent any
	environment {
        PROJECT_ID = 'rising-cable-264810'
        LOCATION = 'europe-west6-a'
        CREDENTIALS_ID = 'My First Project'
        CLUSTER_NAME_PROD = 'cluster-1'          
    }

	stages {
	
	    stage ('Initilization') {
			steps {
				script {
				env.git_commit_id = sh(returnStdout: true, script: "git log -n 1 --pretty=format:'%h'").trim()
				env.tag = "helloworldhepsiburadafromkagan" + '-' + env.git_commit_id + '-build' + currentBuild.number
				env.dockerimagetag = "kaganmersin/maventest:" + env.tag
                echo env.tag
                echo env.dockerimagetag
				}
			}
		}
		
		stage ('Checkout') {
			steps {
				script {
			     git 'https://github.com/kaganmersin/sample-pipe'
				}
			}
	
			
		}

		stage ('Build and Sonarqube analysis') {
			steps {
				script {
				withSonarQubeEnv('SonarQube'){
				sh """
				cd $WORKSPACE/
				mvn clean package sonar:sonar
				"""
				}
				}
			}
			}
		
			stage("Quality Gate") {
			steps{
				script{
					timeout(time: 10, unit: 'MINUTES') {
					// true = set pipeline to UNSTABLE, false = don't
						sleep 10
						waitForQualityGate abortPipeline: true
					}
				}
			}
			}
			
		stage ('Dockerfile build and Push') {
			steps {
				script {
					ansiblePlaybook(
						playbook: '$WORKSPACE/build_docker.yml',
						extraVars:[
							hosts: "localhost",
							workspace: "${WORKSPACE}",
							dockerimagetag: "${dockerimagetag}"                      
						]
					   
					)
				}
			}
		}


          stage('Deploy to GKE production cluster') {
            steps{
				sh """
				cd $WORKSPACE/
				sed 's|#IMAGE_NAME|${env.dockerimagetag}|' k8s-definitions.yml
				"""
                step([
					$class: 'KubernetesEngineBuilder', 
					projectId: env.PROJECT_ID, 
					clusterName: env.CLUSTER_NAME_PROD, 
					location: env.LOCATION, 
					manifestPattern: "k8s-definitions.yml", 
					credentialsId: env.CREDENTIALS_ID,
					namespace: "default",
					verifyDeployments: true])
            }
        }

		    stage('Security analyze') {
            steps {
                catchError(buildResult: 'SUCCESS', stageResult: 'FAILURE') {
                sh 'echo "docker.io/${dockerimagetag} `pwd`/Dockerfile" > anchore_images'
                anchore name: 'anchore_images'
                }
            }
        }

		
	   
	
		}

}
