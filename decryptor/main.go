package main

import (
	"crypto/aes"
	"encoding/base64"
	"fmt"
	"os"
)

func main() {
	if len(os.Args) != 3 {
		fmt.Println("Usage: key encryptedData")
		fmt.Println("Hint: Retrieve key using ../getSockAddr.sh")
		fmt.Println("Hint: Provide data base64 encoded")
		os.Exit(2)
	}
	key := os.Args[1]
	dataRaw, err := base64.StdEncoding.DecodeString(os.Args[2])
	if err != nil {
		panic(err)
	}

	decrypted := DecryptAes128Ecb(dataRaw, []byte(key))
	fmt.Println(string(decrypted))
}

func DecryptAes128Ecb(data, key []byte) []byte {
	cipher, _ := aes.NewCipher([]byte(key))
	decrypted := make([]byte, len(data))
	size := 16

	for bs, be := 0, size; bs < len(data); bs, be = bs+size, be+size {
		cipher.Decrypt(decrypted[bs:be], data[bs:be])
	}

	return decrypted
}
