@Library('shared-library-ansible-01') _

pipeline{

    agent{
        label "master"
    }

    stages{
        stage("Deploy Confluent Kafka Platform on AWS EC2 Instances"){
            steps{
                script {
                    echo "========Get Current Directory========="
                    kafkaInstall.getCurrDir
                    echo "========Installing Zookeeper and Kafka Broker========="
                    kafkaInstall.ansibleDeploy 'all' 'hosts.yml' 'main.yml'
                }
            }
        }
    }
}
