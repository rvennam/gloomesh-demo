rm workspaces-template-pair-output.yaml
for i in {0..1499}
do
  echo "Number: $i"
  export x=$i
  export y=$((${x}+1500))
  envsubst < workspaces-template-server.yaml >> workspaces-template-pair-output.yaml
done
sleep 10
for i in {1500..2999}
do
  echo "Number: $i"
  export x=$i
  export y=$((${x}-1500))
  envsubst < workspaces-template-client.yaml >> workspaces-template-pair-output.yaml
done