rm -rf ~/rsa_keys

echo "##################################################"
echo "# Generating access token private and public key #"
echo "##################################################"
openssl genrsa -out xapi_private.pem 2048
openssl rsa -in xapi_private.pem -pubout -out xapi_public.pem


echo "##### Access token Private key ########"
cat xapi_private.pem

echo ""
echo "#### Access token Private key ########"
cat xapi_public.pem

mkdir ~/rsa_keys
mv xapi_private.pem xapi_public.pem ~/rsa_keys

echo ""
echo ""
echo "#### You can check the directory ~/rsa_keys for keys created"
echo "### Use the commands - cat xapi_private.pem to display the private key"
echo "### Use the commands - cat xapi_public.pem to display the public key"
