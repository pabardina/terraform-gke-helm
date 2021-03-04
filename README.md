Technical test 
=======

# How to start

Be sure to have your `gcloud` command configured.

```
export GCP_PROJECT_ID=YOUR_GCP_PROJECT_ID

cd terraform
terraform init -backend-config="bucket=your-bucket-terraform-backend" -backend-config="prefix=state" modules/
terraform apply -var 'project_id=$GCP_PROJECT_ID' modules/

gcloud container clusters get-credentials gke-cluster --region northamerica-northeast1 --project $GCP_PROJECT_ID

cd ../kubernetes
helm upgrade --install fake-project -n app fake-project \
    --set cloudSqlProxy.instanceConnectionName="$GCP_PROJECT_ID:northamerica-northeast1:gke-cluster-sql-mysql-57" \
    --set wp.serviceAccount.annotations."iam\.gke\.io\/gcp-service-account"=gke-cluster-sa-k8s-cloudsql@$GCP_PROJECT_ID.iam.gserviceaccount.com \
    --set workload.serviceAccount.annotations."iam\.gke\.io\/gcp-service-account"=gke-cluster-sa-k8s-gcs@$GCP_PROJECT_ID.iam.gserviceaccount.com
```

# Access

```shell
export INGRESS_HOST=$(kubectl -n istio-system get service istio-ingressgateway -o jsonpath='{.status.loadBalancer.ingress[0].ip}')
echo $INGRESS_HOST
```

- open http://$INGRESS_HOST
- open http://$INGRESS_HOST/test123
