Here is your **pipeline diagram** (download below) and a **complete README.md** you can directly upload to GitHub.
If you want, I can also convert this into a **PDF report**.

---

## ✅ **Pipeline Diagram (Download)**

👉 **[Click to download pipeline_diagram.png](sandbox:/mnt/data/pipeline_diagram.png)**

---

# ✅ **README.md (Copy & Paste into your GitHub Repo)**

```md
# Brain Tasks App – Production Grade Deployment on AWS (Docker, ECR, EKS, CodeBuild, CodeDeploy, CodePipeline)

This project demonstrates a complete CI/CD pipeline for deploying a **React application** to a **production-grade Amazon EKS cluster** using:

- Docker  
- Amazon ECR  
- Amazon EKS  
- AWS CodeBuild  
- AWS CodeDeploy  
- AWS CodePipeline  

---

## 🚀 Project Overview

The application is cloned from:

**Repository:**  
https://github.com/Vennilavan12/Brain-Tasks-App.git  

The goal was to containerize the React app, push to ECR, deploy on EKS via CodeDeploy, and automate the entire workflow using CodePipeline.

---

# 🏗️ Architecture / Pipeline Flow

```

GitHub (Source)
↓
AWS CodePipeline
↓
CodeBuild → Docker Build → Push to ECR
↓
CodeDeploy → kubectl apply to EKS
↓
Amazon EKS → LoadBalancer → Application

````

![Pipeline Diagram](pipeline_diagram.png)

---

# 📌 Step-by-Step Implementation

---

## 1️⃣ Clone Application & Run Locally

```bash
git clone https://github.com/Vennilavan12/Brain-Tasks-App.git
cd Brain-Tasks-App
npm install
npm start
````

Application runs on **port 3000**

---

# 2️⃣ Dockerization

Create **Dockerfile**:

```dockerfile
FROM node:18-alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
EXPOSE 3000
CMD ["npm", "start"]
```

Build & test:

```bash
docker build -t brain-task-app .
docker run -p 3000:3000 brain-task-app
```

---

# 3️⃣ Push Image to AWS ECR

Create repository:

```bash
aws ecr create-repository --repository-name brain-task-app
```

Login & push:

```bash
aws ecr get-login-password --region ap-south-1 \
| docker login --username AWS --password-stdin <AWS_ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com

docker tag brain-task-app <AWS_ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/brain-task-app:latest
docker push <AWS_ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/brain-task-app:latest
```

---

# 4️⃣ Deploy Kubernetes on AWS EKS

### Create EKS Cluster

```bash
eksctl create cluster --name brain-task-cluster --region ap-south-1 --nodes 2
```

Confirm cluster:

```bash
kubectl get nodes
```

---

# 5️⃣ Kubernetes Deployment Files

### **k8s/deployment.yml**

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: brain-task-app
spec:
  replicas: 2
  selector:
    matchLabels:
      app: brain-task-app
  template:
    metadata:
      labels:
        app: brain-task-app
    spec:
      containers:
        - name: brain-task-app
          image: <AWS_ACCOUNT_ID>.dkr.ecr.ap-south-1.amazonaws.com/brain-task-app:latest
          ports:
            - containerPort: 3000
```

---

### **k8s/service.yml**

```yaml
apiVersion: v1
kind: Service
metadata:
  name: brain-task-app-service
spec:
  type: LoadBalancer
  selector:
    app: brain-task-app
  ports:
    - port: 80
      targetPort: 3000
```

---

# 6️⃣ CodeBuild Setup

### **buildspec.yml**

```yaml
version: 0.2

phases:
  install:
    commands:
      - curl -LO https://amazon-eks.s3.us-west-2.amazonaws.com/1.29.0/2024-06-13/bin/linux/amd64/kubectl
      - chmod +x kubectl && mv kubectl /usr/local/bin/

  pre_build:
    commands:
      - aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin $ECR_REPO
      - IMAGE_TAG=latest

  build:
    commands:
      - docker build -t brain-task-app .
      - docker tag brain-task-app $ECR_REPO:$IMAGE_TAG
      - docker push $ECR_REPO:$IMAGE_TAG

  post_build:
    commands:
      - aws eks update-kubeconfig --name brain-task-cluster --region ap-south-1
      - kubectl apply -f k8s/deployment.yml
      - kubectl apply -f k8s/service.yml
```

---

# 7️⃣ CodeDeploy Setup

### **appspec.yml**

```yaml
version: 0.0
resources:
  - myAppSpec:
      type: AWS::EKS::Application
      properties:
        name: brain-task-app
        clusterName: brain-task-cluster
        namespace: default
        file: k8s/deployment.yml
```

---

# 8️⃣ CodePipeline Setup

Stages:

1. **Source** → GitHub repo
2. **Build** → CodeBuild executes buildspec.yml
3. **Deploy** → CodeDeploy triggers kubectl on EKS

---

# 9️⃣ Monitoring

### Logs available in:

* **CloudWatch – CodeBuild logs**
* **CloudWatch – CodeDeploy logs**



