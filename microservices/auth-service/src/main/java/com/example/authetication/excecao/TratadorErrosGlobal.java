package com.example.authetication.excecao;

import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.time.LocalDateTime;
import java.util.LinkedHashMap;
import java.util.Map;

@RestControllerAdvice
public class TratadorErrosGlobal {

    @ExceptionHandler(RegraNegocioException.class)
    public ResponseEntity<Map<String, Object>> tratarRegraNegocio(RegraNegocioException ex) {
        HttpStatus status = (ex.getMessage() != null && ex.getMessage().toLowerCase().contains("não encontrad"))
                ? HttpStatus.NOT_FOUND
                : HttpStatus.BAD_REQUEST;

        Map<String, Object> corpo = new LinkedHashMap<>();
        corpo.put("timestamp", LocalDateTime.now().toString());
        corpo.put("status", status.value());
        corpo.put("error", status.getReasonPhrase());
        corpo.put("message", ex.getMessage());

        return ResponseEntity.status(status).body(corpo);
    }
}

