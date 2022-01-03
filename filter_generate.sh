# Lambda-IX Member List
i=0
total=`expr $(curl https://lambda-ix.net/members.json | jq length) - 2`
member_list="https://lambda-ix.net/members.json"

# Generate Filter
while [ $i -lt $total ]
do
	# ASN
	ASN=$(curl https://lambda-ix.net/members.json | jq '.['$i'].asn')
	ASN=${ASN//'"'/}

	# AS-SET
	AS_SET=$(curl https://www.peeringdb.com/api/as_set/$ASN | jq '.data[0]["'$ASN'"]')
	AS_SET=${AS_SET//'"'/}

	# Print
	echo $ASN
	echo $AS_SET
	i=`expr $i + 1`

	# Generate filter
	filter_v4=$(bgpq3 -4l "AS"$ASN"_v4" $AS_SET -R 24 -b)
	filter_v6=$(bgpq3 -6l "AS"$ASN_"v6" $AS_SET -R 48 -b)

cat << EOF > filter/"AS"$ASN"_v4"
$filter_v4
EOF

	# echo $filter_v4
	# echo $filter_v6
done
