from fabric.api import local
import os

def install_docker():
  print("\n-----------------------------------------------------------------------------")
  print("########## Checking/Installing Docker ##########")
  print("-----------------------------------------------------------------------------\n")
  local("sudo yum install wget curl epel-release -y")
  local("sudo yum install jq java-1.8.0-openjdk-devel -y")
  local("sudo yum install -y yum-utils")
  docker_check = os.popen('which docker').read().strip()
  if docker_check == '':
    print("\n-----------------------------------------------------------------------------")
    print("********** Installing Docker **********")
    print("-----------------------------------------------------------------------------\n")
    local("sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo")
    local("sudo yum -y install docker-ce docker-ce-cli containerd.io")
    local("sudo systemctl start docker && sudo systemctl enable docker")
  else:
    print("\n-----------------------------------------------------------------------------")
    print("!!!!!!!!!! Skipping Docker installation as it is already installed !!!!!!!!!!")
    print("-----------------------------------------------------------------------------\n")
  local('sudo curl -L "https://github.com/docker/compose/releases/download/1.23.1/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose')
  local("sudo chmod +x /usr/local/bin/docker-compose")
  local("docker login https://hub.itgo-devops.org:18443")
    
def download_repo():
  print("\n-----------------------------------------------------------------------------")
  print("########## Downloading GIT Repo ##########")
  print("-----------------------------------------------------------------------------\n")
  local("sudo yum install git -y")
  userid = raw_input('Enter GIT username: ')
  passwd = raw_input('Enter the GIT password: ')
  currDir = os.getcwd()
  ikepDir = os.path.join(currDir, "ikep-knowledgebase")
  checkDir = os.path.isdir(ikepDir)
  if checkDir == 'False':
    git_cmd = "git clone https://" + userid + ":" + passwd + "@github.itergo.com/ikep/ikep-knowledgebase.git"
    print(git_cmd)
    local(git_cmd)
    local("chmod -R 777 ikep-knowledgebase")
  else:
    print("\n-----------------------------------------------------------------------------")
    print("!!!!!!!!!! Skipping as the repo is already cloned !!!!!!!!!!")
    print("-----------------------------------------------------------------------------\n")

def set_env_variables():
  print("\n-----------------------------------------------------------------------------")
  print("########## Setting Environmental Variables ##########")
  print("-----------------------------------------------------------------------------\n")
  currDir = os.getcwd()
  envFile = os.path.join(currDir, ".env")
  fileBuff = open(envFile, "w")
  fileBuff.write("""
export IKEP_IMAGE_TAG="1.5.0"
export NEXUS_PATH="/ikep/snapshot/"
export IKEP_LOCAL_ENV="09"
export IKEP_REMOTE_GATEWAY="172.17.0.1"
export LOG_DIR=/tmp/log
export SCHEMA_REGISTRY_OPTS="
-Djavax.net.ssl.trustStore=${pathToLocalSecrets:-$PWD}/local_client.truststore.p12
-Djavax.net.ssl.trustStorePassword=localPwd
-Djavax.net.ssl.keyStore=${pathToLocalSecrets:-$PWD}/local_client.keystore.p12
-Djavax.net.ssl.keyStorePassword=localPwd
-Djavax.net.ssl.keyPassword=localPwd"
""")
  fileBuff.close()
  sourceCmd = "source " + envFile
  local(sourceCmd)
  print("\n*******************************************************")
  print(" Execute the command: $ source .env ")
  print("*******************************************************\n")

def start_containers():
  local("docker-compose up -d")

def download_confluent():
  currDir = os.getcwd()
  ikepDir = os.path.join(currDir, "ikep-knowledgebase", "ikep_local")
  os.chdir(ikepDir)
  start_containers()
  cDir = os.getcwd()
  print(cDir)
  local("""sed "s#/etc/ikep/secrets#${pathToLocalSecrets:-$PWD}#g" ${pathToLocalSecrets:-$PWD}/local_client.ssl.properties > ${pathToLocalSecrets:-$PWD}/local_client.ssl.local.properties""")
  checkConfluentDir = os.path.isdir("confluent-5.4.2")
  if checkConfluentDir == 'False':
    local("wget http://packages.confluent.io/archive/5.4/confluent-5.4.2-2.12.tar.gz")
    local("tar xvf confluent-5.4.2-2.12.tar.gz")
  else:
    print("\n-----------------------------------------------------------------------------")
    print("!!!!!!!!!! Skipping Confluent Tar Download as it is already present !!!!!!!!!!")
    print("-----------------------------------------------------------------------------\n")

def test_commands():
  print("""
\n\n###############################################################################################################

Run the following commands to test the Local IKEP:
-------------------------------------------------

$ source <work_dir>/.env

$ <work_dir>/ikep-knowledgebase/ikep_local/confluent-5.4.2/bin/kafka-avro-console-producer \
--broker-list localhost:9094 \
--topic local_a_testAvro \
--producer.config ${pathToLocalSecrets:-$PWD}/local_client.ssl.local.properties \
--property value.schema='{"type":"record","name":"myrecord","fields":[{"name":"f1","type":"string"}]}' \
--property schema.registry.url="https://localhost:8081"



$ <work_dir>/ikep-knowledgebase/ikep_local/confluent-5.4.2/bin/kafka-avro-console-consumer \
--bootstrap-server localhost:9094 \
--topic local_a_testAvro \
--group local_a_cg001 \
--from-beginning \
--consumer.config ${pathToLocalSecrets:-$PWD}/local_client.ssl.local.properties \
--property schema.registry.url="https://localhost:8091"


$ <work_dir>/ikep-knowledgebase/ikep_local/confluent-5.4.2/bin/kafka-console-producer \
--broker-list localhost:9093 \
--topic local_a_testNonAvro \
--producer.config ${pathToLocalSecrets:-$PWD}/local_client.ssl.local.properties


$ <work_dir>/ikep-knowledgebase/ikep_local/confluent-5.4.2/bin/kafka-console-consumer \
--bootstrap-server localhost:9094 \
--topic local_a_testNonAvro \
--group local_a_cg001 \
--from-beginning \
--consumer.config ${pathToLocalSecrets:-$PWD}/local_client.ssl.local.properties

###############################################################################################################\n
""")


def all():
  install_docker()
  download_repo()
  set_env_variables()
  download_confluent()
  test_commands()
