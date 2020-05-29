@Library('shared-library-ansible-01') _

pipeline{

    agent{
        label "master"
    }

    stages{
        stage("Get Current Directory"){
            steps{
                scripts {
                    echo "========Get Current Directory========="
                    kafkaInstall.getCurrDir()
                }
            }
        }
        stage("Install Zookeeper and Kafka Broker"){
            steps{
                scripts {
                    echo "========Installing Zookeeper and Kafka Broker========="
                    kafkaInstall.ansibleDeploy('all', 'hosts.yml', 'main.yml')
                }
            }
        }
    }
}
