@Library('shared-library-ansible-01') _

pipeline{

    agent{
        label "master"
    }

    stages{
        stage("Install Zookeeper and Kafka Broker"){
            steps{
                echo "========Installing Zookeeper and Kafka Broker========"
                zookeeperInstall('hosts.yml', 'main.yml')
            }
        }
    }
}
