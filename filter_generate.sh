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
	AS_SET=${AS_SET#*::}

	if [ ! $AS_SET ];
	then
		AS_SET="AS"$ASN
	fi
	echo $AS_SET

	# Generate filter
	filter_v4=$(bgpq3 -4l "define AS"$ASN"_v4" $AS_SET -R 24 -b)
	filter_v6=$(bgpq3 -6l "define AS"$ASN"_v6" $AS_SET -R 48 -b)

	if [[ ! $filter_v4 ]];
	then
		filter_v4="define AS"$ASN"_v4 = [ 149.112.26.0/24 ];"
	fi

	if [[ ! $filter_v6 ]];
	then
		filter_v6="define AS"$ASN"_v6 = [ 2a0f:607:1070::/48 ];"
	fi

cat << EOF > /etc/bird/filters/"AS"$ASN"_v4"
$filter_v4
EOF

cat << EOF > /etc/bird/filters/"AS"$ASN"_v6"
$filter_v6
EOF

	i=`expr $i + 1`
done
