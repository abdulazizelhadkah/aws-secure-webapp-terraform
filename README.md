# AWS Secure Web Application with Terraform

This project provisions a secure, highly-available, and scalable multi-tier web application on AWS using Terraform. The infrastructure is designed to separate concerns, protect backend services, and ensure fault tolerance by leveraging multiple Availability Zones (AZs).

This repository contains the complete Terraform code to deploy the architecture shown in the diagram.



## 🏛️ Architecture Deep Dive

The infrastructure is logically and physically isolated within a custom VPC. Here is a breakdown of the components and the traffic flow:
![AWS Architecture Diagram](Images/Diagram.png)

### 1. Networking (VPC)
* **VPC:** A single Virtual Private Cloud (VPC) with the CIDR block `10.0.0.0/16` serves as the foundational network, isolating all resources.
* **Availability Zones:** The architecture spans **two Availability Zones** (AZ1 and AZ2) to ensure high availability and fault tolerance. If one AZ fails, the application remains accessible.
* **Subnet Tiers:** The VPC is divided into two tiers:
    * **Public Subnets:**
        * `10.0.0.0/24` (in AZ1)
        * `10.0.2.0/24` (in AZ2)
        These subnets have a route to an **Internet Gateway (IGW)**, allowing resources within them (like the public-facing load balancer and proxy servers) to be accessible from the internet.
    * **Private Subnets:**
        * `10.0.1.0/24` (in AZ1)
        * `10.0.3.0/24` (in AZ2)
        These subnets do **not** have a direct route to the internet. Resources here (the backend web servers) are completely isolated. They use a **NAT Gateway** (provisioned in the public subnets) for outbound internet access (e.g., to download software updates).

### 2. Load Balancing
* **Public Application Load Balancer (ALB):** This is the single entry point for all user traffic. It receives requests from the internet (via the "URL") and distributes them across the **Proxy** instances in the public subnets.
* **Internal Application Load Balancer (ALB):** This *second* load balancer is private. It receives traffic *only* from the Proxy instances and distributes it to the **Backend Web Servers (BE WS)** in the private subnets. This adds a layer of abstraction and scalability for the backend.

### 3. Compute
* **Proxy Tier (Public):** These are EC2 instances (likely in an Auto Scaling Group) running in the public subnets. They act as a reverse proxy (e.g., Nginx, HAProxy). Their job is to receive traffic from the public ALB and forward it to the internal ALB.
* **Backend Tier (Private):** These are the EC2 instances (also likely in an Auto Scaling Group) running the core application (BE WS). They are placed in the private subnets and can only be reached via the internal ALB, completely protecting them from direct internet exposure.

### 4. Security
* **Security Groups (SG):** This is the core of the security model, acting as a stateful firewall for each instance.
    * **Public ALB SG:** Allows inbound traffic from the internet (e.g., ports 80/443).
    * **Proxy SG:** Allows inbound traffic *only* from the Public ALB (on ports 80/443). Allows outbound traffic to the Internal ALB.
    * **Internal ALB SG:** Allows inbound traffic *only* from the Proxy instances.
    * **Backend WS SG:** Allows inbound traffic *only* from the Internal ALB (on the application port, e.g., 8080).

---

## ✨ Key Features

* **High Availability:** Deploys all critical components (ALBs, EC2 instances) across two Availability Zones.
* **Security:** Implements a multi-tier "defense-in-depth" strategy. Backend servers are fully isolated in private subnets, accessible only through multiple layers of load balancers and security groups.
* **Scalability:** Uses load balancers and can be easily configured with Auto Scaling Groups (ASGs) to automatically scale the Proxy and Backend tiers based on traffic.
* **Infrastructure as Code (IaC):** The entire environment is defined as code using Terraform, enabling automated, repeatable, and consistent deployments.

---

## 📁 Project Structure

This project uses a **modular Terraform structure** to ensure the code is reusable, maintainable, and well-organized. The architecture is broken down into logical components, each represented by a module in the `modules/` directory.

The **root `main.tf` file** acts as the central orchestrator, responsible for instantiating these modules and "wiring" them together by passing outputs from one module (e.g., the VPC ID) as inputs to another (e.g., the subnet modules).

### 🌳 File Tree Overview

TERRAFORM PROJECT 
TERRAFORM PROJECT
├── modules/
│   ├── alb_target/   # Manages ALB target groups and attachment
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   ├── ec2_backend/        # Provisions the private backend EC2 instances
│   │   ├── scripts/        # User-data scripts for backend (e.g., install app)
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   ├── ec2_proxy/          # Provisions the public proxy EC2 instances
│   │   ├── scripts/        # User-data scripts for proxy (e.g., install nginx)
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   ├── igw/                # Manages the Internet Gateway
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   ├── load_balancer/      # Provisions the Public and Internal ALBs
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   ├── nat_gateway/        # Provisions the NAT Gateway and Elastic IP
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   ├── Private_subnet/     # Manages the private subnets
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   ├── public_subnet/      # Manages the public subnets
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   ├── routing_tables/     # Manages all route tables and associations
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   ├── security_group/     # A reusable module to create security groups
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   ├── vpc/                # Provisions the base VPC
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── variable.tf
│   └── webapp/             # (Likely a helper module, e.g., for deployment)
│   │   ├── app.py
│   │   └── requirements.txt
│
├── .gitignore              # Specifies files for Git to ignore
├── .terraform.lock.hcl     # Locks provider versions for consistency
├── main.tf                 # Root module: orchestrates all other modules
├── variables.tf            # Root variables: user-configurable inputs
└── outputs.tf              # Root outputs: displays key info (like the ALB URL)

### 🧩 Module Responsibilities

#### 🌍 Networking Foundation
* **`vpc`**: Defines the foundational network boundary (`10.0.0.0/16`). Its outputs (like `vpc_id`) are used by almost every other module.
* **`public_subnet` & `Private_subnet`**: These modules are called twice (once for each AZ) to create the four subnets. They depend on the `vpc` module.
* **`igw`**: Creates the Internet Gateway to allow inbound/outbound internet traffic for the public subnets.
* **`nat_gateway`**: Creates the NAT Gateway (in a public subnet) to allow *outbound-only* internet access for the private subnets (e.g., for software updates).
* **`routing_tables`**: The "traffic controller." This module creates the public and private route tables and associates them with the correct subnets. This is what officially makes a subnet "public" (a route to the IGW) or "private" (a route to the NAT Gateway).

#### 🔐 Security
* **`security_group`**: A highly reusable module. This module is called *multiple times* from the root `main.tf` to create the different firewalls for each tier:
    1.  **Public ALB SG:** Allows web traffic (80/443) from the internet.
    2.  **Proxy SG:** Allows traffic *only* from the Public ALB.
    3.  **Internal ALB SG:** Allows traffic *only* from the Proxy instances.
    4.  **Backend SG:** Allows traffic *only* from the Internal ALB.

#### 💻 Compute & Load Balancing
* **`load_balancer`**: Provisions *both* the internet-facing (public) ALB and the internal ALB.
* **`ec2_proxy`**: Deploys the reverse proxy instances into the public subnets.
* **`ec2_backend`**: Deploys the core application (BE WS) instances into the private subnets, making them inaccessible from the internet.
* **`alb_target`**: The glue that connects compute to the load balancers. This module is used to create target groups and register the EC2 instances from `ec2_proxy` and `ec2_backend` with their respective ALBs.
---

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following tools installed and configured:
* **Terraform** (v1.0.0 or later)
* **AWS CLI**
* **An AWS Account** with configured credentials (e.g., via `aws configure`)

### 🔧 Deployment Steps

1.  **Clone the repository:**
    ```sh
    git clone [https://github.com/abdulazizelhadkah/aws-secure-webapp-terraform.git](https://github.com/abdulazizelhadkah/aws-secure-webapp-terraform.git)
    cd aws-secure-webapp-terraform
    ```

2.  **Initialize Terraform:**
    This downloads the necessary AWS provider plugins.
    ```sh
    terraform init
    ```

3.  **Review the execution plan:**
    This command shows you what resources Terraform will create, modify, or destroy.
    ```sh
    terraform plan
    ```

4.  **Apply the configuration:**
    This command will build the infrastructure in your AWS account.
    ```sh
    terraform apply
    ```
    Type `yes` when prompted to approve the plan.

After the apply is complete, Terraform will output any configured values, such as the public URL of the load balancer.

### 🧹 Clean Up

To avoid ongoing charges, you can destroy all the resources created by this project when you are finished.

```sh
terraform destroy
```
Type yes when prompted to approve the deletion.
