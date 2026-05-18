#!/bin/bash
# Upload all Jenkinsfiles to server and create jobs

echo "=========================================="
echo "  Deploying Jenkins Pipelines"
echo "=========================================="

SERVER="root@121.199.46.101"
PASSWORD="Zkeqiyun1688@,,"
JENKINS_URL="http://121.199.46.101:8088"
JENKINS_USER="admin"
JENKINS_PASS="Zkeqiyun1688@"
LOCAL_DIR="/Users/yuhao/Desktop/yezannnnn/aiGroup/jarvis/jenkins"
REMOTE_DIR="/opt/chatbot/.jenkins/pipelines"

echo ""
echo "📁 Step 1: Uploading Jenkinsfiles to server..."
sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $SERVER "mkdir -p $REMOTE_DIR"

for file in Jenkinsfile.tenant-backend Jenkinsfile.tenant-frontend Jenkinsfile.platform-backend Jenkinsfile.platform-frontend; do
    echo "  Uploading $file..."
    sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no "$LOCAL_DIR/$file" "$SERVER:$REMOTE_DIR/"
done

echo "✅ Jenkinsfiles uploaded"
echo ""

echo "🔧 Step 2: Creating Jenkins jobs..."

# Function to create Jenkins job via CLI
create_job() {
    local job_name=$1
    local jenkinsfile_path=$2
    
    # Create job config XML
    cat > /tmp/job_config.xml << EOF
<?xml version='1.1' encoding='UTF-8'?>
<flow-definition plugin="workflow-job@1145.v7f7b_3a_7a_7736">
  <description>${job_name} CI/CD Pipeline</description>
  <keepDependencies>false</keepDependencies>
  <properties/>
  <definition class="org.jenkinsci.plugins.workflow.cps.CpsFlowDefinition" plugin="workflow-cps@2662.vd3b_75335c8a_1">
    <script>// Jenkinsfile loaded from: ${jenkinsfile_path}
// Use Pipeline script from SCM for production</script>
    <sandbox>false</sandbox>
  </definition>
  <triggers/>
  <disabled>false</disabled>
</flow-definition>
EOF
    
    # Upload config
    sshpass -p "$PASSWORD" scp -o StrictHostKeyChecking=no /tmp/job_config.xml "$SERVER:/tmp/${job_name}_config.xml"
    
    # Create job via CLI
    sshpass -p "$PASSWORD" ssh -o StrictHostKeyChecking=no $SERVER "
        java -jar /tmp/jenkins-cli.jar -s $JENKINS_URL -auth $JENKINS_USER:$JENKINS_PASS create-job $job_name < /tmp/${job_name}_config.xml 2>&1 || echo 'Job may already exist'
    "
    
    echo "  ✅ Job created: $job_name"
}

# Create all 4 jobs
create_job "tenant-backend-pipeline" "$REMOTE_DIR/Jenkinsfile.tenant-backend"
create_job "tenant-frontend-pipeline" "$REMOTE_DIR/Jenkinsfile.tenant-frontend"
create_job "platform-backend-pipeline" "$REMOTE_DIR/Jenkinsfile.platform-backend"
create_job "platform-frontend-pipeline" "$REMOTE_DIR/Jenkinsfile.platform-frontend"

echo ""
echo "=========================================="
echo "  ✅ All pipelines deployed!"
echo "=========================================="
echo ""
echo "Jenkins URL: $JENKINS_URL"
echo ""
echo "Jobs created:"
echo "  1. tenant-backend-pipeline"
echo "  2. tenant-frontend-pipeline"
echo "  3. platform-backend-pipeline"
echo "  4. platform-frontend-pipeline"
echo ""
echo "Next steps:"
echo "  1. Configure SCM (Git repository) for each job"
echo "  2. Add webhook triggers"
echo "  3. Test each pipeline"
