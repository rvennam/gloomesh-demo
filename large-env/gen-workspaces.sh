rm workspaces-template-output.yaml
for i in {0..3000}
do
  echo "Number: $i"
  export x=$i
  envsubst < workspaces-template.yaml >> workspaces-template-output.yaml
done