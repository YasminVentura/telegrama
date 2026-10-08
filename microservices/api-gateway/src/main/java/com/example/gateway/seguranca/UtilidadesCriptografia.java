package com.example.gateway.seguranca;

import javax.crypto.Cipher;
import javax.crypto.spec.SecretKeySpec;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

public class UtilidadesCriptografia {
    private static final String CHAVE_SECRETA_STRING = "TelegramaSecreta"; // 16 bytes para AES-128
    private static final SecretKeySpec CHAVE_SECRETA = new SecretKeySpec(CHAVE_SECRETA_STRING.getBytes(StandardCharsets.UTF_8), "AES");

    public static String criptografar(String dados) {
        try {
            Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
            cipher.init(Cipher.ENCRYPT_MODE, CHAVE_SECRETA);
            byte[] bytesCriptografados = cipher.doFinal(dados.getBytes(StandardCharsets.UTF_8));
            return Base64.getUrlEncoder().withoutPadding().encodeToString(bytesCriptografados);
        } catch (Exception e) {
            throw new RuntimeException("Erro ao criptografar os dados", e);
        }
    }

    public static String descriptografar(String dadosCriptografados) {
        try {
            Cipher cipher = Cipher.getInstance("AES/ECB/PKCS5Padding");
            cipher.init(Cipher.DECRYPT_MODE, CHAVE_SECRETA);
            byte[] bytesDescriptografados = cipher.doFinal(Base64.getUrlDecoder().decode(dadosCriptografados));
            return new String(bytesDescriptografados, StandardCharsets.UTF_8);
        } catch (Exception e) {
            throw new RuntimeException("Erro ao descriptografar os dados", e);
        }
    }
}
