package com.example.authetication.controller;

import com.example.authetication.dto.AutenticacaoResultado;
import com.example.authetication.dto.LoginRequisicaoDto;
import com.example.authetication.dto.RefreshTokenRequisicaoDto;
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
    exposedHeaders = {"Set-Cookie", "X-Session-Id", "X-Refresh-Token"},
    allowCredentials = "true"
)
@RestController
@RequestMapping("/auth")
@RequiredArgsConstructor
public class AuthController {

    private final AuthService authService;
    private final UsuarioService usuarioService;

    @PostMapping("/registro")
    public ResponseEntity<UsuarioRespostaDto> registrar(@RequestBody @Valid RegistroRequisicaoDto request) {
        usuarioService.registrar(request);

        LoginRequisicaoDto loginAuto = new LoginRequisicaoDto();
        loginAuto.setIdentificador(request.getEmail());
        loginAuto.setSenha(request.getSenha());
        AutenticacaoResultado resultado = authService.autenticar(loginAuto);

        return construirRespostaAutenticada(resultado, HttpStatus.CREATED);
    }

    @DeleteMapping("/interno/usuarios/{identificador}")
    @ResponseStatus(HttpStatus.NO_CONTENT)
    public void excluirCredencialInterna(@PathVariable String identificador) {
        usuarioService.excluirCredencialInterna(identificador);
    }

    @PostMapping("/login")
    public ResponseEntity<UsuarioRespostaDto> login(@RequestBody @Valid LoginRequisicaoDto request) {
        AutenticacaoResultado resultado = authService.autenticar(request);
        return construirRespostaAutenticada(resultado, HttpStatus.OK);
    }

    @PostMapping("/refresh")
    public ResponseEntity<UsuarioRespostaDto> refresh(
            @RequestBody(required = false) RefreshTokenRequisicaoDto body,
            @RequestHeader(value = "X-Refresh-Token", required = false) String refreshHeader,
            @CookieValue(value = "refreshToken", required = false) String refreshCookie
    ) {
        String token = (body != null && body.getRefreshToken() != null && !body.getRefreshToken().isBlank())
                ? body.getRefreshToken()
                : ((refreshHeader != null && !refreshHeader.isBlank()) ? refreshHeader : refreshCookie);

        AutenticacaoResultado resultado = authService.renovarSessaoComRefreshToken(token);
        return construirRespostaAutenticada(resultado, HttpStatus.OK);
    }

    @PostMapping("/logout")
    public ResponseEntity<Void> logout(
            @RequestHeader(value = "X-Session-Id", required = false) String sessionHeader,
            @RequestHeader(value = "X-Refresh-Token", required = false) String refreshHeader,
            @CookieValue(value = "idSessao", required = false) String sessionCookie,
            @CookieValue(value = "refreshToken", required = false) String refreshCookie
    ) {
        String idSessao = (sessionCookie != null && !sessionCookie.isBlank()) ? sessionCookie : sessionHeader;
        String refreshToken = (refreshCookie != null && !refreshCookie.isBlank()) ? refreshCookie : refreshHeader;
        authService.encerrarSessao(idSessao, refreshToken);

        ResponseCookie cookieSessao = ResponseCookie.from("idSessao", "")
                .httpOnly(true)
                .secure(false)
                .path("/")
                .maxAge(0)
                .sameSite("Lax")
                .build();

        ResponseCookie cookieRefresh = ResponseCookie.from("refreshToken", "")
                .httpOnly(true)
                .secure(false)
                .path("/")
                .maxAge(0)
                .sameSite("Lax")
                .build();

        return ResponseEntity.noContent()
                .header(HttpHeaders.SET_COOKIE, cookieSessao.toString())
                .header(HttpHeaders.SET_COOKIE, cookieRefresh.toString())
                .build();
    }

    private ResponseEntity<UsuarioRespostaDto> construirRespostaAutenticada(
            AutenticacaoResultado resultado,
            HttpStatus status
    ) {
        ResponseCookie cookieSessao = ResponseCookie.from("idSessao", resultado.idSessao())
                .httpOnly(true)
                .secure(false)
                .path("/")
                .maxAge(24 * 60 * 60)
                .sameSite("Lax")
                .build();

        ResponseCookie cookieRefresh = ResponseCookie.from("refreshToken", resultado.refreshToken())
                .httpOnly(true)
                .secure(false)
                .path("/")
                .maxAge(7 * 24 * 60 * 60)
                .sameSite("Lax")
                .build();

        return ResponseEntity.status(status)
                .header(HttpHeaders.SET_COOKIE, cookieSessao.toString())
                .header(HttpHeaders.SET_COOKIE, cookieRefresh.toString())
                .header("X-Session-Id", resultado.idSessao())
                .header("X-Refresh-Token", resultado.refreshToken())
                .body(resultado.usuario());
    }
}
