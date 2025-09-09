# Terraform practical task GD

This project defines a simple GCP cloud infrastructure using Terraform.  
It deploys a basic website behind an **external HTTP load balancer**.  
The backend consists of **1 Managed Instance Group (MIG)** with 3 VM instances.  

The website runs on the **Apache HTTP server** (port 80).

---

## How to use

1. **Download this repository**

2. **Create a `terraform.tfvars` file** and provide values for the variables.  
    Example:

    ```hcl
    count_vms    = 3
    prefix       = "random"
    project_name = "gd-gcp-my-project"
    region       = "europe-central2"
    vm_zone_main = "europe-central2-a"
    ```

3. **Initialize and deploy**
    Run:

    ```bash
    terraform init
    terraform apply
    ```

    * This will deploy a Cloud Storage bucket resource for the Terraform state backend.
    * Copy the name of the bucket from the Terraform output in your terminal.

4. **(Optional)** Enable remote state storage

   * Uncomment the `"backend"` block in `main.tf`.
   * Replace the bucket name with the one from step 3 to store your `.tfstate` file remotely in GCS.

<p align="center">
  <img src="img/img1.png" alt="Infrastructure Diagram" width="70%">
</p>

---

## Results

As a result we get output like this:

Outputs:

bucket_name = "bm2-9766b2-tfstate-bucket"
load_balancer_ip = "31.32.33.34"

Using provided IP address we can connect to the web-site and se load balancer in action:

<p align="center">
  <img src="img/img2.png" alt="Web1" width="70%">
</p>

After refreshing:

<p align="center">
  <img src="img/img3.png" alt="Web2" width="70%">
</p>

## Notes

* In the **compute module** (`modules/compute/main.tf`), a firewall rule was created that only allows access to the website from IP addresses in the range:
  **37.0.0.0/8**