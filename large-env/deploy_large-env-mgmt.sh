kubectl config use-context mgmt
for x in {0..3000}
do
  echo "Number: $x"
  export x=$x
  rm workspace-template-output.yaml
  envsubst < workspaces-template.yaml > workspace-template-output.yaml
  # kubectl create ns ns${x} --context mgmt
  kubectl apply -f workspace-template-output.yaml --context mgmt
done