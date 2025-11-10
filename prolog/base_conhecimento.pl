% ---------------- Diretivas ----------------

% Jogador_a, Jogador_b, Carta_a, Carta_b, Resposta(true, false, carta)
:- dynamic pergunta/5.

% carta, tipo
:- dynamic carta/2, descartada/2, evidencia/2.

% jogador, carta
:- dynamic tem_carta/2, nao_tem_carta/2.

% jogador, carta_a, carta_b
:- dynamic pode_ter_ou/3.

% ---------------- Fatos ----------------

carta(castical, arma).
carta(corda, arma).
carta(faca, arma).
carta(revolver, arma).

carta(cozinha, lugar).
carta(hall, lugar).
carta(sala_de_estar, lugar).
carta(sala_de_jantar, lugar).
carta(spa, lugar).

carta(green, suspeito).
carta(peacock, suspeito).
carta(plum, suspeito).
carta(mustard, suspeito).
carta(scarlet, suspeito).
carta(white, suspeito).


% ---------------- Regras Básicas ----------------

/*
    Regra que descarta uma carta, caso ela ainda não tenha sido descartada.
*/
descartar(Carta) :-
    carta(Carta, Tipo), \+ descartada(Carta, Tipo) ->
    (
        assert(descartada(Carta, Tipo))
    ).

/*
    Regra que verifica de duas cartas são de tipos defirentes
*/
tipos_diferentes(Carta_a, Carta_b) :-
    carta(Carta_a, Tipo_a),
    carta(Carta_b, Tipo_b),
    Tipo_a \= Tipo_b.

/*
    Regra que verifica sem uma carta apareceu em alguma pergunta
*/
foi_perguntada(Jogador, Carta) :-
    carta(Carta, _Tipo),
    (
        pergunta(Jogador, _, Carta, _, _);
        pergunta(Jogador, _, _, Carta, _)
    ).

foi_resposta_da_pergunta(Carta) :-
    carta(Carta, _),
    foi_perguntada(j1, Carta),
    \+ descartada(Carta, _).

% ---------------- Regras Avançadas ----------------

/*
    Regra que anota as perguntas feitas no jogo.
    
    pergunta/5 se:
        As cartas existirem e os tipos forem diferentes,
        salva a pergunta em um fato,
        se a resposta for uma das cartas, salva que o j1 tem ela e descarta,
        se a resposta for verdadeira salva que o jogador_b por ter uma das duas,
        senão salva que o jogador_b não tem as duas.
*/
perguntar(Jogador_a, Jogador_b, Carta_a, Carta_b, Resposta) :-
    carta(Carta_a, Tipo_a),
    carta(Carta_b, Tipo_b),
    Tipo_a \= Tipo_b,
    assert(pergunta(Jogador_a, Jogador_b, Carta_a, Carta_b, Resposta)),
    (   
        Resposta == Carta_a ; Resposta == Carta_b
    ) ->
    (
        assert(tem_carta(Jogador_b, Resposta)), % Nesse caso, Jogador_b será j1
        descartar(Resposta)
    );
    (
        Resposta == true ->
        (

            assert(tem_carta_ou(Jogador_b, Carta_a, Carta_b))
        );
        (
            assert(nao_tem_carta(Jogador_b, Carta_a)),
            assert(nao_tem_carta(Jogador_b, Carta_b))
        )
    ).   

/*
    Regra que descarta cartas que jogadores podem ter com base em respostas de outros jogadores
    Se um Jogador_a tem a Carta_a e Jogador_b tem (Carta_a ou Carta_b), então descarta a Carta_b
*/
descartar_com_ou :-
    (
        tem_carta(_Jogador_a, Carta_a),
        tem_carta_ou(Jogador_b, Carta_a, Carta_b)
    ) ->
    (
        retract(tem_carta_ou(Jogador_b, Carta_a, Carta_b)),
        assert(tem_carta(Jogador_b, Carta_b)),
        descartar(Carta_b)
    );
    (
        (
            tem_carta(_Jogador_a, Carta_b),
            tem_carta_ou(Jogador_b, Carta_a, Carta_b)
        ) ->
        (
            retract(tem_carta_ou(Jogador_b, Carta_a, Carta_b)),
            assert(tem_carta(Jogador_b, Carta_a)),
            descartar(Carta_a)
        )
    ).


/*
    Vou melhorar
*/
como_responder(Carta_a, Carta_b) :-
    (
        carta(Carta_a, Tipo_a),
        carta(Carta_b, Tipo_b),
        Tipo_a \= Tipo_b
    ) ->
    (
        (
            evidencia(Carta_a, _), 
            evidencia(Carta_b, _)
        ) ->
        (
            format("Ambas as cartas")
            % Aqui preciso pensar em uma forma de responder com base na quantidade das cartas
        );
        (
            evidencia(Carta_a, _), format("Resposta: ~w", [Carta_a]);
            evidencia(Carta_b, _), format("Resposta: ~w", [Carta_b])
        )
    ).


% ---------------- Como Perguntar ----------------


como_perguntar(Carta, "a carta nao esta com j2 nem com j3") :-
    (
        carta(Carta, _),
        \+ foi_perguntada(j1, Carta)
    ),
    (
        nao_tem_carta(j2, Carta),
        nao_tem_carta(j3, Carta)
    ), !.

como_perguntar(Carta, "a carta nao esta com j2 ou com j3") :-
    (
        carta(Carta, _),
        \+ foi_perguntada(j1, Carta)
    ), 
    (   
        nao_tem_carta(j2, Carta);
        nao_tem_carta(j3, Carta)
    ), !.

como_perguntar(Carta, "a carta nao foi perguntada a ninguem") :-
    carta(Carta, _),
    \+ foi_perguntada(_, Carta), !.

como_perguntar(Carta, "a carta nao foi perguntada a j1") :-
    carta(Carta, _),
    \+ foi_perguntada(j1, Carta), !.

como_perguntar(Carta, "a carta foi perguntada mas nao foi a resposta") :-
    carta(Carta, _),
    foi_perguntada(j1, Carta), 
    \+ foi_resposta_da_pergunta(Carta), !.