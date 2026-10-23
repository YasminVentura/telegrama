package com.example.post.excecao;

public class PostagemNaoEncontradaException extends RuntimeException {
    public PostagemNaoEncontradaException(String mensagem) {
        super(mensagem);
    }
}
