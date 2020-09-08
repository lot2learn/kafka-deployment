@Library('shared-library-ansible') _

pipeline{

    agent{
        label "master"
    }

    stages{
        stage("Deploy Confluent Kafka Platform on AWS EC2 Instances") {
            steps{
                script {
                    echo "BRANCH:"
                    echo "${env.GIT_BRANCH}"
                    if env.GIT_BRANCH.toLower().contains('20') {
                        println env.GIT_BRANCH
                    }
                    echo "========Get Current Directory========="
                    kafkaInstall.getCurrDir()
                    echo "========Installing Zookeeper and Kafka Broker========="
                    kafkaInstall.ansibleDeploy('all', '~/hosts.yml', 'main.yml')
                }
            }
        }

        stage("Check Logs for WARNING") {
            steps {
                echo "============Checking for any WARNING(s)==============="
                filterLogs (3)
            }
        }
    }
}
