#!/bin/bash
# PeeringDB

ASN="60614"
AS_SET=$(curl https://www.peeringdb.com/api/as_set/$ASN | jq '.data[0]["'$ASN'"]')
AS_SET=${AS_SET//'"'/}
echo $AS_SET
