@Library('shared-library-ansible') _

pipeline{

    agent{
        label "master"
    }

    stages{
        stage("Deploy Confluent Kafka Platform on AWS EC2 Instances...") {
            steps{
                script {
                    sh """
                    git log --format="medium" -1 ${env.GIT_COMMIT}
                    git log -1 --pretty=%B
                    git log -1 --pretty=%B ${env.GIT_COMMIT}
                    echo "---BRANCH---"
                    echo ${env.GIT_BRANCH}
                    git branch
                    """
                    echo "========Get Current Directory========="
                    kafkaInstall.getCurrDir()
                    echo "========Installing Zookeeper and Kafka Broker========="
                    kafkaInstall.ansibleDeploy('all', '~/hosts.yml', 'main.yml')
                }
            }
        }

        stage("Check Logs for WARNING...") {
            steps {
                echo "============Checking for any WARNING(s)==============="
                filterLogs (3)
            }
        }
    }
}
