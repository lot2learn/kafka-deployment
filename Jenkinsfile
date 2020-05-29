@Library('shared-library-ansible') _

pipeline{

    agent{
        label "master"
    }

    stages{
        stage("Get Current Directory"){
            steps{
                script {
                    echo "========Get Current Directory========="
                    kafkaInstall.getCurrDir()
                    echo "========Installing Zookeeper and Kafka Broker========="
                    kafkaInstall.ansibleDeploy 'all' 'hosts.yml' 'main.yml'
                }
            }
        }
    }
}
