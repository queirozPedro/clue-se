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

% Regra que descarta uma carta, caso ela ainda não tenha sido descartada.
descartar(Carta) :-
    carta(Carta, Tipo), \+ descartada(Carta, Tipo) ->
    (
        assert(descartada(Carta, Tipo))
    ).

% Marca a carta como evidencia e descarta ela.
marcar_evidencia(Carta) :-
    (
        carta(Carta, Tipo),
        \+ evidencia(Carta, _)
    ) ->
    (
        assert(evidencia(Carta, Tipo)),
        descartar(Carta)
    ).


% Regra que verifica de duas cartas são de tipos defirentes
tipos_diferentes(Carta_a, Carta_b) :-
    carta(Carta_a, Tipo_a),
    carta(Carta_b, Tipo_b),
    Tipo_a \= Tipo_b.

% Regra que verifica sem uma carta apareceu em alguma pergunta
foi_perguntada(Jogador, Carta) :-
    carta(Carta, _Tipo),
    (
        pergunta(Jogador, _, Carta, _, _);
        pergunta(Jogador, _, _, Carta, _)
    ).

% Regra que mostra se uma carta foi resposta da sua pergunta ao jogador_1
foi_resposta_da_pergunta(Carta) :-
    carta(Carta, _),
    foi_perguntada(jogador_1, Carta),
    \+ descartada(Carta, _).


% ---------------- Regras de Informação ----------------

/*
    Regra que anota as perguntas feitas no jogo.
    
    pergunta/5 se:
        As cartas existirem e os tipos forem diferentes,
        salva a pergunta em um fato,
        se a resposta for uma das cartas, salva que o jogador_1 tem ela e descarta,
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
        assert(tem_carta(Jogador_b, Resposta)), % Nesse caso, Jogador_b será jogador_1
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
    Interessante executar a cada pergunta
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


% ---------------- Como Perguntar ----------------

/*
    Como perguntar vai funcionar atribuindo prioridade de pergunta à cartas com maior chance de estar com o jogador_1
*/

como_perguntar(Carta, "a carta nao esta com jogador_2 nem com jogador_3") :-
    (
        carta(Carta, _),
        \+ foi_perguntada(jogador_1, Carta)
    ),
    (
        nao_tem_carta(jogador_2, Carta),
        nao_tem_carta(jogador_3, Carta)
    ), !.

como_perguntar(Carta, "a carta nao esta com jogador_2 ou com jogador_3") :-
    (
        carta(Carta, _),
        \+ foi_perguntada(jogador_1, Carta)
    ), 
    (   
        nao_tem_carta(jogador_2, Carta);
        nao_tem_carta(jogador_3, Carta)
    ), !.

como_perguntar(Carta, "a carta nao foi perguntada a ninguem") :-
    carta(Carta, _),
    \+ foi_perguntada(_, Carta), !.

como_perguntar(Carta, "a carta nao foi perguntada a jogador_1") :-
    carta(Carta, _),
    \+ foi_perguntada(jogador_1, Carta), !.

como_perguntar(Carta, "a carta foi perguntada mas nao foi a resposta") :-
    carta(Carta, _),
    foi_perguntada(jogador_1, Carta), 
    \+ foi_resposta_da_pergunta(Carta), !.


% ---------------- Como Responder ----------------

% Responde sempre prorizando as cartas com tipo que tem maior variedade de cartas.
% Suspeito > Lugar > Arma

como_responder(Carta_a, Carta_b, "carta_a") :-
    tipos_diferentes(Carta_a, Carta_b), 
    evidencia(Carta_a, _),
    \+ evidencia(Carta_b, _), !.

como_responder(Carta_a, Carta_b, "carta_b") :-
    tipos_diferentes(Carta_a, Carta_b), 
    evidencia(Carta_b, _),
    \+ evidencia(Carta_a, _), !.

como_responder(Carta_a, Carta_b, "carta_a") :-
    (
        tipos_diferentes(Carta_a, Carta_b), 
        evidencia(Carta_b, _),
        evidencia(Carta_a, _)
    ) -> (
        carta(Carta_a, Tipo_a),
        Tipo_a = suspeito
    ), !.

como_responder(Carta_a, Carta_b, "carta_b") :-
    (
        tipos_diferentes(Carta_a, Carta_b), 
        evidencia(Carta_b, _),
        evidencia(Carta_a, _)
    ) -> (
        carta(Carta_b, Tipo_b),
        Tipo_b = suspeito
    ), !.

como_responder(Carta_a, Carta_b, "carta_a") :-
    (
        tipos_diferentes(Carta_a, Carta_b), 
        evidencia(Carta_b, _),
        evidencia(Carta_a, _)
    ) -> (
        carta(Carta_a, Tipo_a),
        Tipo_a = lugar
    ), !.

como_responder(Carta_a, Carta_b, "carta_b") :-
    (
        tipos_diferentes(Carta_a, Carta_b), 
        evidencia(Carta_b, _),
        evidencia(Carta_a, _)
    ) -> (
        carta(Carta_b, Tipo_b),
        Tipo_b = lugar
    ), !.

como_responder(Carta_a, Carta_b, "carta_a") :-
    (
        tipos_diferentes(Carta_a, Carta_b), 
        evidencia(Carta_b, _),
        evidencia(Carta_a, _)
    ) -> (
        carta(Carta_a, Tipo_a),
        Tipo_a = arma
    ), !.

como_responder(Carta_a, Carta_b, "carta_b") :-
    (
        tipos_diferentes(Carta_a, Carta_b), 
        evidencia(Carta_b, _),
        evidencia(Carta_a, _)
    ) -> (
        carta(Carta_b, Tipo_b),
        Tipo_b = arma
    ), !.

como_responder(Carta_a, Carta_b, "nao posso te ajudar") :-
    tipos_diferentes(Carta_a, Carta_b), 
    \+ evidencia(Carta_b, _),
    \+ evidencia(Carta_a, _), !.

% ---------------- Como Chutar ----------------

% como_chutar(Carta, )
    