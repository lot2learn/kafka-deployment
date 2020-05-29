pipeline{
    agent{
        label "master"
    }
    stages{
        stage("Install Zookeeper and Kafka Broker"){
            steps{
                echo "========Installing Zookeeper and Kafka Broker========"
                zookeeperinstall('all', 'hosts.yml', 'main.yml')
            }
        }
    }
}