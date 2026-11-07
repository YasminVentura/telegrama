package com.example.authetication.controller;

import com.example.authetication.dto.AutenticacaoResultado;
import com.example.authetication.dto.LoginRequisicaoDto;
import com.example.authetication.dto.RegistroRequisicaoDto;
import com.example.authetication.dto.UsuarioRespostaDto;
import com.example.authetication.servico.AuthService;
import com.example.authetication.servico.UsuarioService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseCookie;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CookieValue;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestHeader;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseStatus;
import org.springframework.web.bind.annotation.RestController;

@CrossOrigin(
    originPatterns = {"http://localhost:*", "http://127.0.0.1:*"},
    allowedHeaders = "*",
    methods = {RequestMethod.GET, RequestMethod.POST, RequestMethod.PUT, RequestMethod.DELETE, RequestMethod.OPTIONS},
    exposedHeaders = {"Set-Cookie", "X-Session-Id"},
    allowCredentials = "true"
)
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final UsuarioService usuarioService;

    @PostMapping("/registro")
    @ResponseStatus(HttpStatus.CREATED)
    public void registrar(@RequestBody @Valid RegistroRequisicaoDto request) {
        usuarioService.registrar(request);
    }

    @DeleteMapping("/interno/usuarios/{identificador}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void excluirCredencialInterna(@PathVariable String identificador) {
        usuarioService.excluirCredencialInterna(identificador);
    }

    @PostMapping("/login")
    public ResponseEntity<UsuarioRespostaDto> login(@RequestBody @Valid LoginRequisicaoDto request) {
        AutenticacaoResultado resultado = authService.autenticar(request);
        
        ResponseCookie cookie = ResponseCookie.from("idSessao", resultado.idSessao())
                .httpOnly(true)
                .secure(false) // localhost / HTTP
                .path("/")
                .maxAge(24 * 60 * 60)
                .sameSite("Lax")
                .build();
                
        return ResponseEntity.ok()
                .header(HttpHeaders.SET_COOKIE, cookie.toString())
                .header("X-Session-Id", resultado.idSessao())
                .body(resultado.usuario());
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout(
            @RequestHeader(value = "X-Session-Id", required = false) String sessionHeader,
            @CookieValue(value = "idSessao", required = false) String sessionCookie) {
        
        String idSessao = (sessionCookie != null && !sessionCookie.isBlank()) ? sessionCookie : sessionHeader;
        authService.encerrarSessao(idSessao);
        
        ResponseCookie cookie = ResponseCookie.from("idSessao", "")
                .httpOnly(true)
                .secure(false)
                .path("/")
                .maxAge(0)
                .sameSite("Lax")
                .build();
                
        return ResponseEntity.noContent()
                .header(HttpHeaders.SET_COOKIE, cookie.toString())
                .build();
    }
}

