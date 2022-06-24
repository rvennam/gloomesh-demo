gcloud container clusters get-credentials rvennam-mgmt --zone us-central1-c --project solo-test-236622
k config rename-context gke_solo-test-236622_us-central1-c_rvennam-mgmt mgmt

gcloud container clusters get-credentials rvennam-remote1 --zone us-east1-b --project solo-test-236622
k config rename-context gke_solo-test-236622_us-east1-b_rvennam-remote1 cluster1

gcloud container clusters get-credentials rvennam-remote3 --zone us-west1-c --project solo-test-236622
k config rename-context gke_solo-test-236622_us-west1-c_rvennam-remote3 cluster2