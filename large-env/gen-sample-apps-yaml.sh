rm sample-apps-template-output.yaml
for i in {0..3000}
do
  echo "Number: $i"
  export x=$i
  envsubst < sample-apps-template.yaml >> sample-apps-template-output.yaml
done