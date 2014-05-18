#ifndef RSA_APIS_H
#define RSA_APIS_H

#ifdef __cplusplus
extern "C" {
#endif //end __cplusplus

int rsa_encrypt(unsigned char* srccode,int srclen,unsigned char* result); 
int rsa_decrypt(unsigned char* srccode,int srclen,unsigned char* result);


#ifdef __cplusplus
}
#endif //end __cplusplus


#endif




